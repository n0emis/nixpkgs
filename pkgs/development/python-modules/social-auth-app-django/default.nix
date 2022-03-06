{ lib, buildPythonPackage, fetchPypi, social-auth-core, django, python }:

buildPythonPackage rec {
  pname = "social-auth-app-django";
  version = "5.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "b6e3132ce087cdd6e1707aeb1b588be41d318408fcf6395435da0bc6fe9a9795";
  };

  propagatedBuildInputs = [
    social-auth-core
  ];

  checkInputs = [
    django
  ];

  checkPhase = ''
    pwd
    sleep 500
    ${python.interpreter} -m django test --settings="tests.settings"
  '';

  meta = with lib; {
    homepage = "https://github.com/python-social-auth/social-app-django";
    description = "Python Social Auth - Application - Django";
    license = licenses.bsd3;
    maintainers = with maintainers; [ n0emis ];
  };
}
