# BetterXC

![Swift](https://img.shields.io/badge/swift-4.1-brightgreen.svg)

BetterXC allows you to regenerate your Xcode project while retaining (technically, adding) SwiftLint and Sourcery build phases. It also makes sure that SwiftLint phase is added as the last build phase while Sourcery phase is executed before source code compilation begins.

## Installation

The recommended way of installing BetterXC is by using [BetterXC tap](https://github.com/monstar-lab/homebrew-betterxc):

```
$ brew tap monstar-lab/betterxc
$ brew install betterxc
```

## Usage

```
$ xc --help
Regenerate Xcode project and add optional SwiftLint/Sourcery integrations.

Usage: xc
  -s,--nosourcery:
      Skip adding Sourcery phase
  -l,--noswiftlint:
      Skip adding SwiftLint phase
```

## Known issues

Currently, it’s not possible to automatically disable adding either of these two phases, so in order to disable either of them, command-line arguments must be passed. In the future, it’ll be desirable to read an `.xc` configuration file instead, in order to determine which phases to add and which ones to skip.
