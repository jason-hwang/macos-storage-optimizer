# macos-storage-optimizer

A concise shell script to reclaim disk space by purging development-related caches, logs, and temporary artifacts on macOS.

## Execution

Ensure the script has execution permissions before running. Administrative privileges are required for system-level cleanup.

```bash
chmod +x clean_mac.sh
./clean_mac.sh

```

## Cleanup Targets

The script automates the removal of data from the following sources:

* **Virtualization**: OrbStack/Docker build caches and unused resources.
* **Development**: Xcode DerivedData and iOS Simulator runtime images.
* **Package Managers**: Homebrew logs/caches, NPM global cache, and Conda unused packages.
* **Applications**: Claude Desktop VM bundles and general system caches.
* **System**: High-definition wallpaper assets (idleassetsd) and system trash.

## Note on Sparse Files

For tools like OrbStack or Parallels, this script removes data within the virtual environment. To reduce the actual size of the `.dmg` or `.pvm` files on the physical disk, you must manually initiate the **Optimize Storage** or **Reclaim Space** feature in the respective application's GUI.

## License

MIT License

Copyright (c) 2025 onthelook

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
