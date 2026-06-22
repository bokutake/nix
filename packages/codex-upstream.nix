{ lib, stdenvNoCC, src }:

stdenvNoCC.mkDerivation rec {
  pname = "codex";
  version = "latest";
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    install -m0755 "${src}/codex-x86_64-unknown-linux-musl" "$out/bin/codex"

    runHook postInstall
  '';

  meta = with lib; {
    description = "OpenAI Codex CLI";
    homepage = "https://github.com/openai/codex";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "codex";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
