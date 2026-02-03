{ buildNpmPackage, fetchFromGitHub, lib, }:
buildNpmPackage rec {
  pname = "eufy-security-ws";
  version = "1.9.7";

  src = fetchFromGitHub {
    owner = "bropat";
    repo = "eufy-security-ws";
    tag = version;
    hash = "sha256-K9xSJ8W0doxgfXzvg+w32SgFfWuPPyrEUCq3BUE+0wQ=";
  };

  npmDepsHash = "sha256-/ck+R4cKFb0+CxmrjR+4riHmgdy0m8FUQvarn66QinA=";

  meta = {
    description =
      "Small server wrapper around eufy-security-client library to access it via a WebSocket";
    homepage = "https://github.com/bropat/eufy-security-ws";
    license = lib.licenses.mit;
  };
}
