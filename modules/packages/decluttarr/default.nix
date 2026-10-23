{ lib
, fetchFromGitHub
, makeWrapper
, python3Packages
, nix-update-script
,
}:

python3Packages.buildPythonApplication rec {
  name = "decluttarr";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "ManiMatter";
    repo = "decluttarr";
    tag = "v${version}";
    hash = "sha256-36XOEnNE5aJg9QkVK2nI8xK3RiugNH3Xjhswt3dhj+s=";
  };

  pyproject = true;

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    requests
    python-dateutil
    pytest
    pytest-asyncio
    black
    pylint
    autoflake
    isort
    pyyaml-env-tag
    demjson3
    ruff
    watchdog
  ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec/declutarr
    cp -R main.py src tests $out/libexec/declutarr

    makeWrapper "${python3Packages.python.interpreter}" "$out/bin/declutarr" \
      --set PYTHONPATH "$PYTHONPATH" \
      --add-flags "$out/libexec/declutarr/main.py"

    runHook postInstall
  '';

  doCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Watches radarr, sonarr, lidarr, readarr and whisparr download queues and removes downloads if they become stalled or no longer needed.";
    homepage = "https://github.com/ManiMatter/decluttarr";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "declutarr";
  };
}
