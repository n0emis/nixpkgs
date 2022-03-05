{ lib, buildPythonPackage, fetchPypi, markdown, }:

buildPythonPackage rec {
  pname = "mkdocs-material-extensions";
  version = "1.0.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "bfd24dfdef7b41c312ede42648f9eb83476ea168ec163b613f9abd12bbfddba2";
  };

  propagatedBuildInputs = [
    markdown
  ];

  doCheck = false; # module is not tested, otherwise there would be a circular dependency with mkdocs-material

  meta = with lib; {
    homepage = "https://github.com/facelessuser/mkdocs-material-extensions";
    description = "Markdown extension resources for MkDocs Material";
    license = licenses.mit;
    maintainers = with maintainers; [ n0emis ];
  };
}
