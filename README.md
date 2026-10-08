# Bast watch faces

Two watch-face designs for the Garmin Forerunner 965:

- `pulse/`: browser prototype and Monkey C application in `pulse/ciq/`.
- `shadow/`: browser prototype; no Connect IQ application yet.

## Development environment

On x86_64 Linux (including NixOS), with Nix flakes enabled:

```sh
nix develop
```

The shell provides OpenSSL, Python, unzip, SDK command wrappers, an FHS
runtime (`garmin-run`, with Java 17) for Garmin's native Linux executables, and
`go-mtpfs`. The first
invocation creates `flake.lock`; commit it alongside `flake.nix` to pin the Nix
dependencies. Garmin's SDK and device downloads are managed separately below.

### Install Garmin's tools once

Download the Linux SDK Manager from [Garmin](https://developer.garmin.com/connect-iq/sdk/),
unzip it, preserve its directory structure and launch:

```sh
garmin-run /absolute/path/to/sdk-manager/bin/sdkmanager
```

Sign in, install a Linux SDK and the **Forerunner 965 (`fr965`) device files**,
and select the installed SDK as active. The `monkeyc`, `monkeydo`, and `connectiq`
wrappers read `~/.Garmin/ConnectIQ/current-sdk.cfg` on each invocation, so SDK
changes take effect without restarting the shell. For a custom installation:

```sh
export CONNECTIQ_SDK_HOME=/absolute/path/to/connectiq-sdk
```

This is the SDK directory containing `bin/`, not the SDK Manager directory.
Garmin officially supports Ubuntu; the FHS runtime supplies conventional Linux
paths on NixOS. A graphical desktop with X11/XWayland is required for the
manager and simulator. SDK versions with different native library requirements
may need changes to the runtime's package list.

### Developer signing key

Garmin requires a 4096-bit RSA developer key. Generate it once, outside the
repository, and keep a backup. The shell defaults `GARMIN_DEVELOPER_KEY` to
`~/.local/share/garmin/developer_key.der`; set it before entering the shell if
you already have a key elsewhere.

```sh
mkdir -p "$(dirname "$GARMIN_DEVELOPER_KEY")"
if [ ! -e "$GARMIN_DEVELOPER_KEY" ]; then
  (set -euo pipefail
   umask 077
   openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 |
     openssl pkcs8 -topk8 -inform PEM -outform DER -nocrypt \
       -out "$GARMIN_DEVELOPER_KEY")
fi
```

### Build and simulate Pulse

Run from the repository root:

```sh
mkdir -p pulse/ciq/bin
monkeyc -d fr965 -f pulse/ciq/monkey.jungle \
  -o pulse/ciq/bin/pulse.prg -y "$GARMIN_DEVELOPER_KEY" -w
connectiq
```

Once the simulator window is ready, run this in another development shell:

```sh
monkeydo pulse/ciq/bin/pulse.prg fr965
```

To compile and run the existing layout tests, with the simulator open:

```sh
monkeyc -d fr965 -f pulse/ciq/monkey.jungle \
  -o pulse/ciq/bin/pulse-tests.prg -y "$GARMIN_DEVELOPER_KEY" -w -t
monkeydo pulse/ciq/bin/pulse-tests.prg fr965 -t
```

### Load Pulse onto your physical FR965

Build `pulse.prg` using the command above. Connect the watch with a USB data
cable and select **System → USB Mode → MTP** on the watch if needed. The
[FR965 manual](https://www8.garmin.com/manuals/webhelp/GUID-0221611A-992D-495E-8DED-1DD448F7A066/EN-US/GUID-1500E73F-F386-49AF-A542-25D4B1655A08.html)
describes this setting. Use your desktop's MTP file browser to copy `pulse.prg`
into the watch's `GARMIN/APPS` directory, as described in Garmin's
[sideloading guide](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/).
Safely eject/disconnect the watch, then select the installed watch face.

Alternatively, use the included MTP mount utility from `nix develop`:

```sh
mkdir -p /tmp/bast-fr965
go-mtpfs /tmp/bast-fr965
```

Keep only the watch connected as an MTP device. Leave `go-mtpfs` running and,
in another terminal, locate `GARMIN/APPS` under the mount (it may be inside an
internal-storage folder), copy `pulse.prg` there, then unmount with your host's
`fusermount -u /tmp/bast-fr965` (or `fusermount3`)
before unplugging. Close other MTP clients first; only one can own the device.
The host must provide FUSE and USB device access. A development shell cannot
install host udev rules or grant USB permissions; if access is denied, configure
your host's libmtp/udev support.

### Preview either browser design

From the repository root:

```sh
python3 -m http.server 8000 --bind 127.0.0.1
```

Open either:

- <http://127.0.0.1:8000/pulse/crossover_965_bast_pulse.html>
- <http://127.0.0.1:8000/shadow/crossover_965_bast_shadow.html>

For editor support, install Garmin's **Monkey C** extension in VS Code and open
`pulse/ciq/`. Configure its developer key path to the same key used above.
On NixOS, launch the editor through `garmin-run code pulse/ciq` from this shell
so SDK binaries launched directly by the extension also use the FHS runtime.
