{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
  sourcesFile,
}: let
  sourcesData = lib.importJSON sourcesFile;
  inherit (sourcesData) version;
  sources = sourcesData.platforms;
  source =
    sources.${stdenvNoCC.hostPlatform.system}
    or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
in
  stdenvNoCC.mkDerivation {
    pname = "capy-desktop";
    inherit version;

    src = fetchurl {inherit (source) url hash;};

    nativeBuildInputs = [undmg];
    sourceRoot = "Capy.app";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications/Capy.app
      cp -R . $out/Applications/Capy.app
      runHook postInstall
    '';

    # Signed and notarized by Capy: stripping or patching would break the signature.
    dontFixup = true;

    meta = {
      description = "Capy desktop app — run Capy agent threads on your own Mac";
      homepage = "https://capy.ai";
      license = lib.licenses.unfree;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = ["aarch64-darwin"];
    };
  }
