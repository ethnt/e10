{ fetchurl
, lib
, stdenvNoCC
,
}:

let
  revision = "08e178d48790749d25932bbc082711ddcfdfbc4f";
  configHash = "sha256-NiKi3cQewOD9TmjBPGgw8DuQw42Jqq0YTeAsjGQs+Ac=";
  fetchModelFile =
    file: hash:
    fetchurl {
      url = "https://huggingface.co/Systran/faster-whisper-medium/resolve/${revision}/${file}";
      inherit hash;
    };
  modelFiles = {
    "config.json" = fetchModelFile "config.json" configHash;
    "model.bin" = fetchModelFile "model.bin" "sha256-m0XhAJ3MSrYB7/gVth2A5gzj/Yx0waFPSigiWChrUa4=";
    "tokenizer.json" =
      fetchModelFile "tokenizer.json" "sha256-+3tjGR6bsEUILHn9dCoxBqEsmVE6sw30oNR/pstv0Ks=";
    "vocabulary.txt" =
      fetchModelFile "vocabulary.txt" "sha256-NM4/4cUEECez+NQpEicJk/mG28S7NM8n+VHjSh5FORM=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "faster-whisper-medium";
  version = revision;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    ${lib.concatMapStringsSep "\n" (file: ''cp ${modelFiles.${file}} "$out/${file}"'') (
      builtins.attrNames modelFiles
    )}

    runHook postInstall
  '';

  meta = {
    description = "WhisperAI transcription model (medium)";
    homepage = "https://huggingface.co/Systran/faster-whisper-medium";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
