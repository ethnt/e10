{ buildGo126Module, fetchFromGitHub }:

buildGo126Module {
  pname = "incus-apply";
  name = "incus-apply";

  src = fetchFromGitHub {
    owner = "abiosoft";
    repo = "incus-apply";
    tag = "v0.1.1";
    hash = "sha256-eeRcGfGZD7Tg4psAK1IzKgpAkI5RcrBiqyADk0eTdLY=";
  };

  vendorHash = "sha256-u+nl3P7YNl+3DJIXo7pnDKF4PkoYLaHf3B1LqF9b+V8=";

  # ldflags = [
  #   "-X main.version=${self.shortRev or self.dirtyShortRev or "dev"}"
  #   "-X main.commit=${self.rev or self.dirtyRev or "none"}"
  #   "-X main.date=${self.lastModifiedDate or "unknown"}"
  # ];

  meta = {
    description = "Declarative configuration management for Incus";
    homepage = "https://github.com/abiosoft/incus-apply";
    mainProgram = "incus-apply";
  };
}
