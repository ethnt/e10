{ lib
, buildPythonPackage
, fetchPypi
, faster-whisper
, numpy
, setuptools
, torch
, torchaudio
, tqdm
,
}:

buildPythonPackage rec {
  pname = "stable-ts-whisperless";
  version = "2.19.1";
  pyproject = true;

  src = fetchPypi {
    pname = "stable_ts_whisperless";
    inherit version;
    hash = "sha256-WpMT3OGaq3n8CPnbic7g6TyhQJHabjPXndUHWGmQ9gU=";
  };

  postPatch = ''
    substituteInPlace stable_whisper/result.py \
      --replace-fail 'any=.,\,,?' 'any=.,\\,,?'
  '';

  build-system = [ setuptools ];

  dependencies = [
    faster-whisper
    numpy
    torch
    torchaudio
    tqdm
  ];

  pythonImportsCheck = [ "stable_whisper" ];

  meta = {
    description = "Stable-ts package without the OpenAI Whisper dependency";
    homepage = "https://github.com/jianfch/stable-ts";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
