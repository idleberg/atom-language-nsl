# atom-language-nsl

[![License](https://img.shields.io/github/license/idleberg/atom-language-nsl?color=blue&style=for-the-badge)](https://github.com/idleberg/atom-language-nsl/blob/master/LICENSE)
[![Release](https://img.shields.io/github/v/release/idleberg/atom-language-nsl?style=for-the-badge)](https://github.com/idleberg/atom-language-nsl/releases)
[![Downloads](https://img.shields.io/pulsar/dt/language-nsl?style=for-the-badge&color=slateblue)](https://web.pulsar-edit.dev/packages/language-nsl)
[![CI](https://img.shields.io/github/actions/workflow/status/idleberg/atom-language-nsl/default.yml?style=for-the-badge)](https://github.com/idleberg/atom-language-nsl/actions)

Atom language support for [nsL Assembler](https://sourceforge.net/projects/nslassembler/), including grammar, snippets and build system

![Screenshot](https://raw.github.com/idleberg/atom-language-nsl/master/screenshot.png)

## Installation

> [!NOTE]
>
> The following guide assumes that you're by now using Pulsar, a
> community-driven fork of the Atom editor. Should you still be using Atom, use
> `apm` command instead of `ppm`.

### Package Manager

Install `language-nsl` from the editor's
[Package Manager](http://flight-manual.atom-editor.cc/using-atom/sections/atom-packages/)
or the command-line equivalent:

```bash
$ ppm install language-nsl
```

### Using Git

Change to your Atom packages directory:

**Windows**

```powershell
# Powershell
$ cd $Env:USERPROFILE\.pulsar\packages
```

```cmd
:: Command Prompt
$ cd %USERPROFILE%\.pulsar\packages
```

**Linux & macOS**

```bash
$ cd ~/.pulsar/packages/
```

Clone repository as `language-nsl`:

```bash
$ git clone https://github.com/idleberg/atom-language-nsl language-nsl
```

Inside the cloned directory, install its dependencies:

```bash
$ ppm ci
```

Build the source:

```bash
$ ppm run build
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

This work is licensed under [The MIT License](LICENSE).
