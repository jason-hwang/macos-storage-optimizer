# macOS Storage Optimizer

A concise shell script to reclaim disk space by purging development-related caches, logs, and temporary artifacts on macOS.

## Features

This script safely cleans up the following:

- **Homebrew**: Removes cached downloads and old versions
- **npm**: Clears npm cache
- **Yarn**: Clears Yarn cache
- **pip**: Removes Python pip cache
- **Python**: Deletes `__pycache__` directories
- **Xcode**: Removes DerivedData and Archives
- **CocoaPods**: Clears CocoaPods cache
- **Gradle**: Removes Gradle caches
- **Docker**: Prunes unused containers, images, and volumes
- **System Logs**: Removes old log files
- **Trash**: Empties the Trash

## Installation

1. Clone this repository or download the script:
   ```bash
   git clone https://github.com/jason-hwang/macos-storage-optimizer.git
   cd macos-storage-optimizer
   ```

2. Make the script executable:
   ```bash
   chmod +x macos-storage-optimizer.sh
   ```

## Usage

### Dry Run (Recommended First)

Always run with `--dry-run` first to see what would be cleaned:

```bash
./macos-storage-optimizer.sh --dry-run
```

This will show you what files/caches would be removed without actually deleting anything.

### Actual Cleanup

Once you're satisfied with the dry-run output:

```bash
./macos-storage-optimizer.sh
```

### Options

- `--dry-run`: Preview what would be cleaned without deleting anything
- `-h, --help`: Show help message

## Safety

⚠️ **Important Notes:**

- This script is designed to be safe and only removes caches and temporary files
- **Always run with `--dry-run` first** to preview what will be cleaned
- The script intentionally skips:
  - Application caches in `~/Library/Caches` (too broad, manual cleanup recommended)
  - Maven repository (can be large but may be actively used)
  - Old downloads (commented out for safety)
- Some cleanups require the respective tools to be installed (npm, brew, docker, etc.)

## Requirements

- macOS (the script checks and will exit on other operating systems)
- Bash shell (pre-installed on macOS)
- Optional: Development tools you want to clean (Homebrew, npm, Docker, etc.)

## What Gets Cleaned

| Category | Location | Safe? |
|----------|----------|-------|
| Homebrew Cache | `~/Library/Caches/Homebrew` | ✅ Yes |
| npm Cache | `~/.npm` | ✅ Yes |
| Yarn Cache | `~/Library/Caches/Yarn` | ✅ Yes |
| pip Cache | `~/Library/Caches/pip` | ✅ Yes |
| Python `__pycache__` | Throughout `~` | ✅ Yes |
| Xcode DerivedData | `~/Library/Developer/Xcode/DerivedData` | ✅ Yes |
| Xcode Archives | `~/Library/Developer/Xcode/Archives` | ⚠️ May contain signed apps |
| CocoaPods Cache | `~/Library/Caches/CocoaPods` | ✅ Yes |
| Gradle Cache | `~/.gradle/caches` | ✅ Yes |
| Docker Artifacts | Docker system | ⚠️ Removes unused containers/images |
| System Logs | `~/Library/Logs/*.log` | ✅ Yes |
| Trash | `~/.Trash` | ⚠️ Permanently deletes |

## Example Output

```
╔════════════════════════════════════════╗
║   macOS Storage Optimizer             ║
╚════════════════════════════════════════╝

==> Cleaning Homebrew caches...
✓ Cleaned: Homebrew cache (245.67 MB)
✓ Homebrew cleanup completed

==> Cleaning npm caches...
✓ npm cache cleaned

...

╔════════════════════════════════════════╗
║   Cleanup Summary                      ║
╚════════════════════════════════════════╝
Total space freed: 3.45 GB
✓ Cleanup completed successfully!
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Disclaimer

This script is provided as-is. While it's designed to be safe, always review what will be deleted (using `--dry-run`) before running. The authors are not responsible for any data loss.