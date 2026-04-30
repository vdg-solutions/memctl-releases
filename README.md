# memctl

Obsidian-compatible personal memory vault CLI.

Source code is private. Released binaries live here.

## Install

### One-line install (Linux / macOS)

```bash
curl -fsSL https://raw.githubusercontent.com/vdg-solutions/memctl-releases/main/install.sh | sh
```

### One-line install (Windows PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/vdg-solutions/memctl-releases/main/install.ps1 | iex
```

### Manual download

Grab the latest binary from [Releases](https://github.com/vdg-solutions/memctl-releases/releases/latest):

| Platform | Asset |
|----------|-------|
| Windows x64 | `memctl-win-x64-<version>.zip` |
| Linux x64 | `memctl-linux-x64-<version>.tar.gz` |
| macOS Apple Silicon | `memctl-osx-arm64-<version>.tar.gz` |
| macOS Intel | `memctl-osx-x64-<version>.tar.gz` |

Extract, place `memctl` (or `memctl.exe`) on `PATH`.

### dotnet global tool

```bash
dotnet tool install -g memctl
```

## Documentation

Each release archive ships `SKILL.md` — Claude Code skill describing the memctl protocol.

## License

MIT — see `LICENSE`.
