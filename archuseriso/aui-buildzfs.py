#!/usr/bin/env python3
#
# Copyright (C) 2024 Laurent Jourden <laurent85@enarel.fr>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Script to build the ZFS packages against the linux kernel
# for Arch Linux.
#
# Version: 1.0.0
#
# This script automates the process of building ZFS packages by:
# - Fetching the latest or specified ZFS release from GitHub
# - Creating a chroot environment for isolated builds
# - Building zfs-utils and zfs-linux packages
# - Handling GPG key verification
#
# Requirements:
# - Run as root via sudo from a user session
# - devtools and pacman-contrib packages installed
# - Access to pkgbuild directory
#
# Usage: sudo ./aui-buildzfs.py [options]
# Examples:
#   sudo ./aui-buildzfs.py --release=2.1.2 --pkgdest=/path/to/output
#   sudo ./aui-buildzfs.py --linuxtesting --pkgdest=/tmp/zfs-packages
#   sudo ./aui-buildzfs.py --help

import argparse
import sys
import os
import subprocess
import shutil
import requests
import json
import re
import tempfile
import atexit
from pathlib import Path

# Constants
SCRIPT_VERSION = "1.0.0"
GITHUB_API_URL = "https://api.github.com/repos/openzfs/zfs/releases"
DEFAULT_PKGBUILD_DIR = "/usr/share/archuseriso/pkgbuild"
DEFAULT_PKGDEST = os.path.join(os.getcwd(), "out")
ZFS_PUBKEYS = ["C77B9667", "D4598027", "C6AF658B"]  # OpenZFS signing keys

# Global variables
WD = os.getcwd()
APP_NAME = os.path.basename(sys.argv[0])
PKGBUILD_DIR = DEFAULT_PKGBUILD_DIR
AUI_WORK_DIR = ""
ARCH_ROOT = ""
HELP_FLAG = False
LINUX_TESTING = False
LINUX_VERSION = ""
MODULES_VERSION = ""
PKG_DEST = ""
PKG_DEST_MAKEPKG = ""
RELEASE = ""
SCRIPT_USER = os.environ.get("SUDO_USER", "")
ZFS_VERSION = ""
ZFS_MISSING_KEYS = []
ZFS_PACKAGES = []
ZFS_SOURCES = []

def _usage(exit_code=0):
    print(f"\n{APP_NAME}, ZFS packages creation tool for Arch Linux.\n")
    print("Synopsis:")
    print(f"{APP_NAME} [options]\n")
    print("Examples:")
    print(f"  {APP_NAME} --release=2.1.2 --pkgdest=/path/to/output")
    print(f"  {APP_NAME} --linuxtesting --pkgdest=/tmp/zfs-packages")
    print(f"  {APP_NAME} --help\n")
    print(f"For more options, run: {APP_NAME} --help")
    sys.exit(exit_code)

def _help(exit_code=0):
    print("Options:")
    print("-h, --help                Command line help")
    print(f"-D, --pkgbuild-dir=<path> Path to pkgbuild directory (default: {DEFAULT_PKGBUILD_DIR})")
    print("--linuxtesting            Build packages against the linux kernel in testing repository")
    print(f"--pkgdest=<path>          Packages destination directory (default: {DEFAULT_PKGDEST})")
    print("-r, --release             Specify the ZFS release version to build")
    print(f"                          Example: {APP_NAME} --release=2.1.2\n")
    sys.exit(exit_code)

def _msg_info(msg):
    print(f"[{APP_NAME}] INFO: {msg}")

def _cleanup():
    global AUI_WORK_DIR
    if AUI_WORK_DIR and os.path.isdir(AUI_WORK_DIR):
        _msg_info(f"Cleaning up temporary directory: {AUI_WORK_DIR}")
        shutil.rmtree(AUI_WORK_DIR)

def _init():
    global PKG_DEST_MAKEPKG, PKG_DEST, ZFS_SOURCES, ZFS_VERSION

    # Check for required packages
    try:
        subprocess.run(["pacman", "-Q", "devtools"], check=True, capture_output=True)
    except subprocess.CalledProcessError:
        print("Error: devtools package not installed. Please install it and try again.", file=sys.stderr)
        sys.exit(1)

    try:
        subprocess.run(["pacman", "-Q", "pacman-contrib"], check=True, capture_output=True)
    except subprocess.CalledProcessError:
        print("Error: pacman-contrib package not installed. Please install it and try again.", file=sys.stderr)
        sys.exit(1)

    # Determine package destination from makepkg.conf
    try:
        with open("/etc/makepkg.conf", "r") as f:
            for line in f:
                if line.startswith("PKGDEST="):
                    PKG_DEST_MAKEPKG = line.split("=", 1)[1].strip()
                    break
    except FileNotFoundError:
        pass
    PKG_DEST_MAKEPKG = PKG_DEST_MAKEPKG or DEFAULT_PKGDEST
    PKG_DEST = PKG_DEST or PKG_DEST_MAKEPKG

    # Validate PKGBUILD_DIR
    if not os.path.isdir(PKGBUILD_DIR):
        print(f"Error: PKGBUILD directory {PKGBUILD_DIR} does not exist", file=sys.stderr)
        sys.exit(1)

    # Validate RELEASE format if provided
    if RELEASE and not re.match(r"^[0-9]+\.[0-9]+\.[0-9]+$", RELEASE):
        print("Error: Invalid RELEASE format. Expected x.y.z", file=sys.stderr)
        sys.exit(1)

    # Create necessary directories
    global ARCH_ROOT
    ARCH_ROOT = os.path.join(AUI_WORK_DIR, "archroot64")
    try:
        os.makedirs(ARCH_ROOT, exist_ok=True)
        os.makedirs(PKG_DEST, exist_ok=True)
    except OSError as e:
        print(f"Error: Failed to create directories {ARCH_ROOT} or {PKG_DEST}: {e}", file=sys.stderr)
        sys.exit(1)

    # Fetch ZFS sources
    if not RELEASE:
        _msg_info("Fetching latest ZFS release information")
        try:
            response = requests.get(f"{GITHUB_API_URL}/latest", timeout=30)
            response.raise_for_status()
            data = response.json()
            ZFS_SOURCES = [asset.get("browser_download_url","") for asset in data.get("assets", [])]
        except requests.RequestException as e:
            print(f"Error: Failed to fetch latest ZFS release from GitHub API: {e}", file=sys.stderr)
            sys.exit(1)
        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON response from GitHub API: {e}", file=sys.stderr)
            sys.exit(1)
    else:
        _msg_info(f"Fetching ZFS release {RELEASE} information")
        try:
            response = requests.get(GITHUB_API_URL, timeout=30)
            response.raise_for_status()
            data = response.json()
            for release in data:
                if release["tag_name"] == f"zfs-{RELEASE}":
                    ZFS_SOURCES = [asset["browser_download_url"] for asset in release.get("assets", [])]
                    break
            else:
                print(f"Error: Release {RELEASE} not found", file=sys.stderr)
                sys.exit(1)
        except requests.RequestException as e:
            print(f"Error: Failed to fetch ZFS release {RELEASE} from GitHub API: {e}", file=sys.stderr)
            sys.exit(1)

    # Extract ZFS version
    if ZFS_SOURCES:
        # Assuming the first source is like https://.../zfs-2.1.2.tar.gz
        match = re.search(r"/zfs-([0-9]+\.[0-9]+\.[0-9]+)\.tar\.gz", ZFS_SOURCES[0])
        if match:
            ZFS_VERSION = match.group(1)
        else:
            print("Error: Failed to extract ZFS version from sources", file=sys.stderr)
            sys.exit(1)
    else:
        print("Error: No ZFS sources found", file=sys.stderr)
        sys.exit(1)
    _msg_info(f"Using ZFS version: {ZFS_VERSION}")

def _check_disk_space():
    required_space_gb = 5
    try:
        result = subprocess.run(["df", "--output=avail", os.getcwd()], capture_output=True, text=True, check=True)
        available_space_kb = int(result.stdout.splitlines()[1].strip())
        available_space_gb = available_space_kb // (1024 * 1024)
        if available_space_gb < required_space_gb:
            print(f"Error: Insufficient disk space. Required: {required_space_gb} GB, Available: {available_space_gb} GB", file=sys.stderr)
            sys.exit(1)
        _msg_info(f"Disk space check passed: {available_space_gb} GB available")
    except subprocess.CalledProcessError as e:
        print(f"Error: Failed to check disk space: {e}", file=sys.stderr)
        sys.exit(1)

def _create_archroot64():
    _msg_info(f"Creating chroot environment in {ARCH_ROOT}/root")
    try:
        subprocess.run([
            "mkarchroot", "-C", f"{PKGBUILD_DIR}/pacman.conf",
            "-c", "/var/cache/pacman/pkg",
            f"{ARCH_ROOT}/root",
            "base", "linux", "linux-headers", "base-devel"
        ], check=True, capture_output=True)
    except subprocess.CalledProcessError as e:
        print(f"Error: Failed to create chroot environment: {e}", file=sys.stderr)
        sys.exit(1)

    if LINUX_TESTING:
        _msg_info("Setting up testing repository")
        try:
            subprocess.run([
                "unshare", "--fork", "--pid", "pacman",
                "--config", f"{PKGBUILD_DIR}/pacman-testing.conf",
                "--root", f"{ARCH_ROOT}/root", "-Sy"
            ], check=True, capture_output=True)
        except subprocess.CalledProcessError as e:
            print(f"Error: Failed to sync testing repository: {e}", file=sys.stderr)
            sys.exit(1)

        try:
            result = subprocess.run([
                "unshare", "--fork", "--pid", "pacman",
                "--config", f"{PKGBUILD_DIR}/pacman-testing.conf",
                "--root", f"{ARCH_ROOT}/root", "-Si", "testing/linux"
            ], capture_output=True)
            if result.returncode == 0:
                subprocess.run([
                    "pacstrap", "-C", f"{PKGBUILD_DIR}/pacman-testing.conf",
                    "-c", "-G", "-M", f"{ARCH_ROOT}/root",
                    "linux", "linux-headers"
                ], check=True, capture_output=True)
            else:
                print("Error: No linux package available in testing repository", file=sys.stderr)
                sys.exit(1)
        except subprocess.CalledProcessError as e:
            print(f"Error: Failed to install testing kernel in chroot: {e}", file=sys.stderr)
            sys.exit(1)
    _msg_info("Chroot environment created successfully")

def _build_zfs():
    global LINUX_VERSION, MODULES_VERSION, ZFS_PACKAGES

    # Get Linux version from chroot
    try:
        result = subprocess.run([
            "pacman", "--sysroot", f"{ARCH_ROOT}/root", "-Q", "linux"
        ], capture_output=True, text=True, check=True)
        LINUX_VERSION = result.stdout.split()[1]
    except subprocess.CalledProcessError as e:
        print(f"Error: Failed to get Linux version from chroot: {e}", file=sys.stderr)
        sys.exit(1)

    # Calculate modules version
    if '.arch' in LINUX_VERSION:
        base, arch_part = LINUX_VERSION.split('.arch', 1)
        MODULES_VERSION = f"{base}-{arch_part.split('-')[0]}"
    else:
        MODULES_VERSION = LINUX_VERSION

    # Copy PKGBUILD directories
    zfs_utils_dir = os.path.join(AUI_WORK_DIR, "zfs-utils")
    zfs_linux_dir = os.path.join(AUI_WORK_DIR, "zfs-linux")
    try:
        shutil.copytree(f"{PKGBUILD_DIR}/zfs-utils/", zfs_utils_dir)
        shutil.copytree(f"{PKGBUILD_DIR}/zfs-linux/", zfs_linux_dir)
    except OSError as e:
        print(f"Error: Failed to copy PKGBUILD directories: {e}", file=sys.stderr)
        sys.exit(1)

    # Update PKGBUILD files with versions
    for pkgbuild in [os.path.join(zfs_utils_dir, "PKGBUILD"), os.path.join(zfs_linux_dir, "PKGBUILD")]:
        try:
            with open(pkgbuild, "r") as f:
                content = f.read()
            content = content.replace("%ZFSVERSION%", ZFS_VERSION)
            content = content.replace("%LINUXVERSION%", LINUX_VERSION)
            content = content.replace("%MODULESVERSION%", MODULES_VERSION)
            with open(pkgbuild, "w") as f:
                f.write(content)
        except IOError as e:
            print(f"Error: Failed to update PKGBUILD files: {e}", file=sys.stderr)
            sys.exit(1)

    os.chdir(zfs_utils_dir)

    # Download ZFS source files in parallel
    _msg_info("Downloading ZFS source files in parallel")
    import concurrent.futures
    def download_file(url):
        filename = os.path.basename(url)
        try:
            response = requests.get(url, timeout=300)
            response.raise_for_status()
            with open(filename, "wb") as f:
                f.write(response.content)
        except requests.RequestException as e:
            print(f"Error: Failed to download {url}: {e}", file=sys.stderr)
            raise

    with concurrent.futures.ThreadPoolExecutor(max_workers=os.cpu_count()) as executor:
        futures = [executor.submit(download_file, url) for url in ZFS_SOURCES]
        for future in concurrent.futures.as_completed(futures):
            try:
                future.result()
            except Exception:
                sys.exit(1)

    # Copy source files to zfs-linux directory
    try:
        shutil.copy(f"zfs-{ZFS_VERSION}.tar.gz", zfs_linux_dir)
        shutil.copy(f"zfs-{ZFS_VERSION}.tar.gz.asc", zfs_linux_dir)
    except IOError as e:
        print(f"Error: Failed to copy ZFS source files: {e}", file=sys.stderr)
        sys.exit(1)

    # Set ownership
    try:
        subprocess.run(["chown", "-R", f"{SCRIPT_USER}:", zfs_utils_dir, zfs_linux_dir], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error: Failed to set ownership of work directories: {e}", file=sys.stderr)
        sys.exit(1)

    # Build zfs-utils
    _msg_info("Building zfs-utils and zfs-utils-debug")
    try:
        subprocess.run([
            "sudo", "--user", SCRIPT_USER, "makechrootpkg", "-r", ARCH_ROOT,
            "--", "PKGDEST=", "--cleanbuild", "--clean", "--force",
            "--syncdeps", "--needed", "--noconfirm", "--noprogressbar",
            f"--jobs={os.cpu_count()}"
        ], check=True, cwd=zfs_utils_dir)
    except subprocess.CalledProcessError as e:
        print(f"Error: Failed to build zfs-utils: {e}", file=sys.stderr)
        sys.exit(1)

    # Find packages
    try:
        result = subprocess.run([
            "find", zfs_utils_dir, zfs_linux_dir, "-name", "*.pkg.tar.*"
        ], capture_output=True, text=True, check=True)
        ZFS_PACKAGES = [pkg for pkg in result.stdout.strip().split('\n') if pkg]
    except subprocess.CalledProcessError as e:
        print(f"Error: Failed to find built packages: {e}", file=sys.stderr)
        sys.exit(1)
    if len(ZFS_PACKAGES) < 2:
        print("Error: Expected at least 2 ZFS packages after building zfs-utils", file=sys.stderr)
        sys.exit(1)
    _msg_info("zfs-utils build completed")

    # Build zfs-linux
    os.chdir(zfs_linux_dir)
    _msg_info("Building zfs-linux and zfs-linux-headers")
    try:
        subprocess.run([
            "sudo", "--user", SCRIPT_USER, "makechrootpkg", "-r", ARCH_ROOT,
            "-I", ZFS_PACKAGES[0], "-I", ZFS_PACKAGES[1],
            "--", "PKGDEST=", "--cleanbuild", "--clean", "--force",
            "--syncdeps", "--needed", "--noconfirm", "--noprogressbar",
            f"--jobs={os.cpu_count()}"
        ], check=True, cwd=zfs_linux_dir)
    except subprocess.CalledProcessError as e:
        print(f"Error: Failed to build zfs-linux: {e}", file=sys.stderr)
        sys.exit(1)

    # Find final packages
    try:
        result = subprocess.run([
            "find", zfs_utils_dir, zfs_linux_dir, "-name", "*.pkg.tar.*"
        ], capture_output=True, text=True, check=True)
        ZFS_PACKAGES = [pkg for pkg in result.stdout.strip().split('\n') if pkg]
    except subprocess.CalledProcessError as e:
        print(f"Error: Failed to find final packages: {e}", file=sys.stderr)
        sys.exit(1)
    _msg_info("zfs-linux build completed")

    # Copy packages to destination
    try:
        for pkg in ZFS_PACKAGES:
            shutil.copy(pkg, PKG_DEST)
    except IOError as e:
        print(f"Error: Failed to copy packages to {PKG_DEST}: {e}", file=sys.stderr)
        sys.exit(1)

def main():
    global AUI_WORK_DIR, HELP_FLAG, LINUX_TESTING, PKGBUILD_DIR, PKG_DEST, RELEASE, SCRIPT_USER, ZFS_MISSING_KEYS

    parser = argparse.ArgumentParser(description=f"{APP_NAME}, ZFS packages creation tool for Arch Linux.", add_help=False)
    parser.add_argument("-h", "--help", action="store_true", help="Command line help")
    parser.add_argument("-D", "--pkgbuild-dir", help=f"Path to pkgbuild directory (default: {DEFAULT_PKGBUILD_DIR})")
    parser.add_argument("--linuxtesting", action="store_true", help="Build packages against the linux kernel in testing repository")
    parser.add_argument("--pkgdest", help=f"Packages destination directory (default: {DEFAULT_PKGDEST})")
    parser.add_argument("-r", "--release", help="Specify the ZFS release version to build")

    args = parser.parse_args()

    HELP_FLAG = args.help
    LINUX_TESTING = args.linuxtesting
    if args.pkgbuild_dir:
        PKGBUILD_DIR = args.pkgbuild_dir
    if args.pkgdest:
        PKG_DEST = args.pkgdest
    RELEASE = args.release

    if HELP_FLAG:
        _help(0)

    # Check if running as root
    if os.geteuid() != 0:
        print("Error: This script must be run as root.\n", file=sys.stderr)
        print(f"Get help:\n{APP_NAME} --help", file=sys.stderr)
        sys.exit(1)

    # Check if run via sudo from user session
    if SCRIPT_USER == 'root' or not SCRIPT_USER:
        print("\nError: The script must be run from a user session using sudo!", file=sys.stderr)
        print("Aborting...", file=sys.stderr)
        sys.exit(1)

    # Check for missing GPG keys
    for zfs_pubkey in ZFS_PUBKEYS:
        try:
            subprocess.run(["sudo", "--user", SCRIPT_USER, "gpg", "--list-public-keys", zfs_pubkey], check=True, capture_output=True)
        except subprocess.CalledProcessError:
            ZFS_MISSING_KEYS.append(zfs_pubkey)

    # Handle missing GPG keys
    if ZFS_MISSING_KEYS:
        print(f"Missing OpenZFS public keys: {' '.join(ZFS_MISSING_KEYS)}\n")
        reply = input("Retrieve missing OpenZFS public keys (N/y)? ").strip().lower()
        if reply not in ['y', 'yes']:
            print("Operation canceled by user!", file=sys.stderr)
            sys.exit(1)
        for zfs_missing_key in ZFS_MISSING_KEYS:
            _msg_info(f"Retrieving GPG key {zfs_missing_key}")
            try:
                subprocess.run(["sudo", "--user", SCRIPT_USER, "gpg", "--recv", zfs_missing_key], check=True)
            except subprocess.CalledProcessError as e:
                print(f"Error: Failed to retrieve OpenZFS public key {zfs_missing_key}: {e}", file=sys.stderr)
                sys.exit(1)

    # Set up cleanup trap
    atexit.register(_cleanup)

    # Create temporary work directory
    AUI_WORK_DIR = tempfile.mkdtemp(prefix="auiwork.")

    # Main execution
    _msg_info("Starting ZFS package build process")
    _init()
    _check_disk_space()
    _create_archroot64()
    _build_zfs()

    # Return to original directory
    os.chdir(WD)

    # Display results
    print("\nDone!\n")
    for pkg in ZFS_PACKAGES:
        print(os.path.basename(pkg))
    print(f"\nZFS packages directory location: {PKG_DEST}\n")

if __name__ == "__main__":
    main()