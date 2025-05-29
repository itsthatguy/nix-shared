final: prev: {
  kubectxScript = final.stdenv.mkDerivation {
    pname = "kubectx";
    version = "2024-05-21";
    src = final.fetchurl {
      url = "https://raw.githubusercontent.com/ahmetb/kubectx/013b6bc252ea6bbe7c8372ed64c327ad8a52f003/kubectx";
      sha256 = "0n16sw4w1k5vmsg1sjcv9w6a9zp92dq1aaaa09sc8l95wdi0qa5r";
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/kubectx
      chmod +x $out/bin/kubectx
    '';
  };
}
