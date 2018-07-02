import Foundation
import Moderator
import SwiftShell
import Rainbow
import xcproj

enum GenerationErrors: Error {
    case regenerationFailed
    case couldNotFindProject
    case couldNotOpenProject
    case couldNotFindTarget
    case couldNotSave
}

// Helper methods

func regenerateXcodeProject() throws {
    print("[1/5] Regenerating Xcode project…".blue)
    let regenerate = run(bash: "swift package generate-xcodeproj")

    guard regenerate.exitcode == 0 else {
        throw GenerationErrors.regenerationFailed
    }

    print("[1/5] ⚙️  Project regenerated!".green)
}

func locateXcodeProject() throws -> String {
    print("[2/5] Locating Xcode project…".blue)
    let packageName = run(bash: """
    grep name Package.swift | grep -vi target | head -n1 | awk '{ gsub(/[[:punct:]]/, "", $2); print $2 }'
    """).stdout

    let guessedProjectFilename = "\(packageName).xcodeproj"
    let workingPath = FileManager.default.currentDirectoryPath

    guard FileManager.default.fileExists(atPath: guessedProjectFilename) else {
        throw GenerationErrors.couldNotFindProject
    }

    print("[2/5] 🔎  Project found at \(workingPath)/\(guessedProjectFilename).".green)

    return guessedProjectFilename
}

func openXcodeProject(filename: String) throws -> XcodeProj {
    print("[3/5] Opening Xcode project…".blue)

    do {
        let project = try XcodeProj(pathString: filename)

        print("[3/5] 📖  Project opened!".green)

        return project
    } catch {
        throw GenerationErrors.couldNotOpenProject
    }
}

func modifyXcodeProject(
    _ project: XcodeProj,
    _ noSourcery: Bool,
    _ noSwiftLint: Bool
) throws {
    print("[4/5] Modifying Xcode project…".blue)

    if !noSourcery {
        let sourceryPhase = PBXShellScriptBuildPhase(name: "Run Sourcery", shellScript:
            """
            if which sourcery >/dev/null; then
                sourcery
            else
                echo "Error: Sourcery not installed, install via `brew install sourcery --HEAD` download from https://github.com/krzysztofzablocki/Sourcery"
                exit 1
            fi
            """
        )

        print("[4/5] ✨  Adding Sourcery…".lightBlue)
        try addShellScript(sourceryPhase, label: "Sourcery", to: project, at: 0)
    }

    if !noSwiftLint {
        let swiftLintPhase = PBXShellScriptBuildPhase(name: "Run SwiftLint", shellScript:
            """
            if which swiftlint >/dev/null; then
                swiftlint
            else
                echo "Error: SwiftLint not installed, install via `brew install swiftlint` or download from https://github.com/realm/SwiftLint"
                exit 1
            fi
            """
        )

        print("[4/5] 🖊️  Adding SwiftLint…".lightBlue)
        try addShellScript(swiftLintPhase, label: "SwiftLint", to: project)
    }

    print("[4/5] 🔧  Project modified!".green)
}

func addShellScript(
    _ phase: PBXShellScriptBuildPhase,
    label: String,
    to project: XcodeProj,
    at position: Int? = nil
) throws {
    guard let target = project.pbxproj.objects.nativeTargets.values.first(where: { $0.name == "Run" }) else {
        throw GenerationErrors.couldNotFindTarget
    }

    let reference = project.pbxproj.objects.generateReference(phase, label)

    project.pbxproj.objects.shellScriptBuildPhases.append(phase, reference: reference)

    if let position = position {
        target.buildPhases.insert(reference, at: position)
    } else {
        target.buildPhases.append(reference)
    }
}

func saveXcodeProject(_ project: XcodeProj, filename: String) throws {
    print("[5/5] Saving Xcode project…".blue)
    do {
        try project.write(pathString: filename, override: true)
    } catch {
        throw GenerationErrors.couldNotSave
    }

    print("[5/5] 💾  Project saved!".green)
}

// Configure CLI

let arguments = Moderator(description: "Regenerate Xcode project and add optional SwiftLint/Sourcery integrations.")
let skipSourcery = arguments.add(.option("s", "nosourcery", description: "Skip adding Sourcery phase"))
let skipSwiftLint = arguments.add(.option("l","noswiftlint", description: "Skip adding SwiftLint phase"))

// Main utility

do {
    try arguments.parse()
    try regenerateXcodeProject()
    let projectFilename = try locateXcodeProject()
    let project = try openXcodeProject(filename: projectFilename)
    try modifyXcodeProject(project, skipSourcery.value, skipSwiftLint.value)
    try saveXcodeProject(project, filename: projectFilename)

    print("🎉  All done!".green)
    exit(0)
} catch GenerationErrors.regenerationFailed {
    print("Couldn't regenerate Xcode project. Are you in the project folder?".red)
    exit(1)
} catch GenerationErrors.couldNotFindProject {
    print("Couldn't locate generated Xcode project. Maybe the generation failed or you're a using non-standard setup?".red)
    exit(1)
} catch GenerationErrors.couldNotOpenProject {
    print("Couldn't open Xcode project.".red)
    exit(1)
} catch GenerationErrors.couldNotFindTarget {
    print("Couldn't find the Run target. Are you using a non-standard setup?".red)
    exit(1)
} catch GenerationErrors.couldNotSave {
    print("Couldn't save the project. I'm out of ideas! 💦".red)
    exit(1)
} catch is ArgumentError {
    print(arguments.usagetext)
    exit(1)
}
