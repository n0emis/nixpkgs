{ lib, buildPythonPackage, fetchPypi, jinja2, markdown, mkdocs, mkdocs-material-extensions, pygments, pymdown-extensions }:

buildPythonPackage rec {
  pname = "mkdocs-material";
  version = "8.2.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "aea074a5b368c8a27c8ae4fe72bd943176512b225541106797e367c62ce3f5a0";
  };

  propagatedBuildInputs = [
    jinja2
    markdown
    mkdocs
    mkdocs-material-extensions
    pygments
    pymdown-extensions
  ];

  pythonImportsCheck = [ "material" ];

  meta = with lib; {
    homepage = "https://github.com/squidfunk/mkdocs-material";
    description = "Technical documentation that just works";
    license = licenses.mit;
    maintainers = with maintainers; [ n0emis ];
  };
}
