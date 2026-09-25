{ lib
, ctranslate2
, fetchFromGitHub
, ffmpeg
, makeWrapper
, python3Packages
, stable-ts-whisperless
, stdenv
, cudaSupport ? stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64
, cudaCapabilities ? [ "All" ]
, cudnnSupport ? true
,
}:

let
  ctranslate2Cuda = (ctranslate2.override {
    withCUDA = true;
    withCuDNN = cudnnSupport;
  }).overrideAttrs (prev: {
    cmakeFlags = prev.cmakeFlags ++ [
      (lib.cmakeFeature "CUDA_ARCH_LIST" (lib.concatStringsSep ";" cudaCapabilities))
    ];

    preBuild = ''
      if [ "$NIX_BUILD_CORES" -gt 8 ]; then
        export NIX_BUILD_CORES=8
      fi
    '';
  });

  ctranslate2Python =
    if cudaSupport then
      python3Packages.ctranslate2.override { ctranslate2-cpp = ctranslate2Cuda; }
    else
      python3Packages.ctranslate2;
  fasterWhisper = python3Packages.faster-whisper.override { ctranslate2 = ctranslate2Python; };
  stableTsWhisperless = stable-ts-whisperless.override { faster-whisper = fasterWhisper; };

  pythonDependencies = [
    fasterWhisper
    stableTsWhisperless
  ]
  ++ (with python3Packages; [
    av
    fastapi
    ffmpeg-python
    numpy
    python-multipart
    requests
    torch
    uvicorn
    watchdog
  ]);
  pythonEnvironment = python3Packages.python.withPackages (_: pythonDependencies);
in
python3Packages.buildPythonApplication {
  pname = "subgen";
  version = "2026.08.1";
  format = "other";

  src = fetchFromGitHub {
    owner = "McCloudS";
    repo = "subgen";
    rev = "5f98ed611dcb46844e8d671bd5c17e1d092261f5";
    hash = "sha256-DOsP1AE7kSELHIbLunF7legjtSIrtnG9nq1zkXgY4gc=";
  };

  dontBuild = true;
  dontWrapPythonPrograms = true;

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ pythonEnvironment ];
  dependencies = pythonDependencies;

  postPatch = ''
    substituteInPlace subgen.py \
      --replace-fail \
        'host="0.0.0.0"' \
        'host=os.getenv("WEBHOOK_HOST", "127.0.0.1")'
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 subgen.py language_code.py -t "$out/libexec/subgen"
    makeWrapper ${pythonEnvironment}/bin/python "$out/bin/subgen" \
      --add-flags "-u $out/libexec/subgen/subgen.py" \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}

    runHook postInstall
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    ${pythonEnvironment}/bin/python -m py_compile subgen.py language_code.py
    ${pythonEnvironment}/bin/python - <<'PY'
    import av
    import faster_whisper
    import fastapi
    import ffmpeg
    import multipart
    import numpy
    import requests
    import stable_whisper
    import torch
    import uvicorn
    import watchdog
    PY

    runHook postCheck
  '';

  meta = {
    description = "Automatic subtitle generation backend for Bazarr";
    homepage = "https://github.com/McCloudS/subgen";
    license = lib.licenses.mit;
    mainProgram = "subgen";
    platforms = lib.platforms.linux;
  };
}
