# nsL Assembler for Atom

[![apm](https://flat.badgen.net/apm/license/language-nsl)](https://atom.io/packages/language-nsl)
[![apm](https://flat.badgen.net/apm/v/language-nsl)](https://atom.io/packages/language-nsl)
[![apm](https://flat.badgen.net/apm/dl/language-nsl)](https://atom.io/packages/language-nsl)
[![CircleCI](https://flat.badgen.net/circleci/github/idleberg/atom-language-nsl)](https://circleci.com/gh/idleberg/atom-language-nsl)
[![David](https://flat.badgen.net/david/dep/idleberg/atom-language-nsl)](https://david-dm.org/idleberg/atom-language-nsl)

Atom language support for [nsL Assembler](https://sourceforge.net/projects/nslassembler/), including grammar, snippets and build system

![Screenshot](https://raw.github.com/idleberg/atom-language-nsl/master/screenshot.png)

*Screenshot of nsL Assembler in Atom with [Hopscotch](https://atom.io/themes/hopscotch) theme*

## Installation

### apm

* Install package `apm install language-nsl` (or use the GUI)

### Using Git

Change to your Atom packages directory:

```bash
# Windows
$ cd %USERPROFILE%\.atom\packages

# Linux & macOS
$ cd ~/.atom/packages/
```

Clone repository as `language-nsl`:

```bash
$ git clone https://github.com/idleberg/atom-language-nsl language-nsl
```

### Package Dependencies

This package automatically installs third-party packages it depends on. You can prevent this by disabling the *Manage Dependencies* option in the package settings.

## Usage

### Building

As of recently, this package contains a build system to translate nsL code into NSIS script and transpile it. To do so, select *Nsl Assembler: Save & Transpile”* from the [command-palette](https://atom.io/docs/latest/getting-started-atom-basics#command-palette) or use the keyboard shortcut.

Make sure to specify the path for `nsL.jar` in the package settings. There you can also customize the flags for the transpiler.

**Example:**

```cson
"language-nsl":
  pathToJar: "%PROGRAMFILES(X86)%\\NSIS\\NSL\\nsL.jar"
  customArguments: ["/nopause", "/nomake"]
```

#### Third-party packages

Should you already use the [build](https://atom.io/packages/build) package, you can install the [build-nsl](https://atom.io/packages/build-nsl) provider to build your code.

## License

This work is dual-licensed under [The MIT License](https://opensource.org/licenses/MIT) and the [GNU General Public License, version 2.0](https://opensource.org/licenses/GPL-2.0)
