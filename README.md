# nsL Assembler for Atom

[![apm](https://img.shields.io/apm/l/language-nsl.svg?style=flat-square)](https://atom.io/packages/language-nsl)
[![apm](https://img.shields.io/apm/v/language-nsl.svg?style=flat-square)](https://atom.io/packages/language-nsl)
[![apm](https://img.shields.io/apm/dm/language-nsl.svg?style=flat-square)](https://atom.io/packages/language-nsl)
[![Travis](https://img.shields.io/travis/idleberg/atom-language-nsl.svg?style=flat-square)](https://travis-ci.org/idleberg/atom-language-nsl)
[![David](https://img.shields.io/david/dev/idleberg/atom-language-nsl.svg?style=flat-square)](https://david-dm.org/idleberg/atom-language-nsl#info=devDependencies)
[![Gitter](https://img.shields.io/badge/chat-Gitter-ff69b4.svg?style=flat-square)](https://gitter.im/NSIS-Dev/Atom)

Atom language support for [nsL Assembler](https://sourceforge.net/projects/nslassembler/), including grammar, snippets and a rudimentary build system

![Screenshot](https://raw.github.com/idleberg/atom-language-nsl/master/screenshot.png)

*Screenshot of nsL Assembler in Atom with [Hopscotch](https://atom.io/themes/hopscotch) theme*

## Installation

### apm

* Install package `apm install language-nsl` (or use the GUI)

### GitHub

Change to your Atom packages directory:

```bash
# Windows
$ cd %USERPROFILE%\.atom\packages

# Mac OS X & Linux
$ cd ~/.atom/packages/
```

Clone repository as `language-nsl`:

`$ git clone https://github.com/idleberg/atom-language-nsl language-nsl`

### Building

As of recently, this package contains a rudimentary build system to translate nsL code into NSIS script and compile it. To do so, select *Nsl Assembler: Save & Compile”* from the [command-palette](https://atom.io/docs/latest/getting-started-atom-basics#command-palette) or use the keyboard shortcut.

Make sure to specify the path for `nsL.jar` in your `config.cson`.

**Example:**

```cson
"language-nsl":
  pathToJar: "/full/path/to/nsL.jar"
```

#### Third-party packages

Should you already use the [build](https://atom.io/packages/build) package, you can install the [build-nsl](https://atom.io/packages/build-nsl) provider to build your code.

## License

This work is dual-licensed under [The MIT License](https://opensource.org/licenses/MIT) and the [GNU General Public License, version 2.0](https://opensource.org/licenses/GPL-2.0)

## Donate

You are welcome support this project using [Flattr](https://flattr.com/submit/auto?user_id=idleberg&url=https://github.com/idleberg/atom-language-nsl) or Bitcoin `17CXJuPsmhuTzFV2k4RKYwpEHVjskJktRd`