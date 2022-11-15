{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "xteve";
  version = "2.2.0.200";

  src = fetchFromGitHub {
    owner = "xteve-project";
    repo = "xTeVe";
    rev = version;
    sha256 = "hD4GudSkGZO41nR/CgcMg/SqKjpAO1yJDkfwa8AUges=";
  };

  vendorSha256 = "etS4duY+uUSWcErxctbM5m1++3dQRHeFgP8Bm1taibM=";

  proxyVendor = true;

  meta = with lib; {
    description = "M3U Proxy for Plex DVR and Emby Live TV";
    homepage = "https://github.com/xteve-project/xTeVe";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
