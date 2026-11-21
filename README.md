# capy-desktop-overlay

Nix flake for the [Capy](https://capy.ai) desktop app on macOS. Pre-built, signed app bundle, auto-updated every 6 hours.

## Usage

### Flake input

```nix
{
  inputs.capy-desktop-overlay = {
    url = "github:charliemeyer2000/capy-desktop-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Add the overlay and install it with nix-darwin, which copies the app to `/Applications/Nix Apps/Capy.app`:

```nix
nixpkgs.overlays = [capy-desktop-overlay.overlays.default];
environment.systemPackages = [pkgs.capy-desktop];
```

Or reference directly:

```nix
capy-desktop-overlay.packages.${system}.capy-desktop
```

### Pin a version

```nix
capy-desktop-overlay.packages.${system}."0.9.2"
```

## How it works

`versions/*.json` files hold the DMG URL and SHA-512 hash from Capy's own update feed (`downloads.capy.ai/stable/latest-mac.yml`). No binaries are stored in git: `nix build` fetches and verifies the DMG, then unpacks the app untouched so Capy's code signature and notarization stay valid. GitHub Actions checks for new releases every 6 hours on a macOS runner and verifies the build and signature before committing.

The app's built-in updater can't replace a bundle installed by Nix (the Nix store and `/Applications/Nix Apps` are read-only), so updates arrive through this flake: bump the input and rebuild.

## Platforms

aarch64-darwin (nixpkgs dropped x86_64-darwin in 26.11)

## License

Nix packaging: MIT. Capy desktop app: proprietary (Scrapybara, Inc.).
