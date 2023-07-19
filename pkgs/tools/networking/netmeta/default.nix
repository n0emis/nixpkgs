{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "netmeta";
  version = "unstable-2023-07-18";

  src = fetchFromGitHub {
    owner = "monogon-dev";
    repo = "NetMeta";
    rev = "7297afa510c18053ee6514a03ffd6799039a5da3";
    hash = "sha256-DcM3icMgJq+f4Zd5AAndnwO2cHYkWBEjWzLbO3puBlQ=";
  };

  subPackages = [
    "cmd/helloworld"
    "cmd/portmirror"
    "cmd/reconciler"
    "cmd/risinfo"
  ];

  vendorHash = "sha256-sgv3WhtqMcZoUYmBBBKhgNtpRYdW9dMWbB+4L3Gyv5E=";

  meta = with lib; {
    description = "scalable network observability toolkit optimized for performance";
    homepage = "https://github.com/monogon-dev/NetMeta";
    license = licenses.asl20;
    maintainers = with maintainers; [ yuka ];
  };
}

