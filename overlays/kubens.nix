final: prev: {
  kubensScript = final.stdenv.mkDerivation {
    pname = "kubens";
    version = "2024-05-21";
    src = final.fetchurl {
      url = "https://raw.githubusercontent.com/ahmetb/kubectx/013b6bc252ea6bbe7c8372ed64c327ad8a52f003/kubens";
      sha256 = "1p1vq5j7vd5x0nllgd1xi3j07h679i917anqzbl8ls1fi309g72h";
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/kubens
      chmod +x $out/bin/kubens
    '';
  };
}
