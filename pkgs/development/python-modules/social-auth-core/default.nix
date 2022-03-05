{ lib
, buildPythonPackage
, fetchPypi
, requests
, oauthlib
, requests_oauthlib
, pyjwt
, cryptography
, defusedxml
, python3-openid
, python-jose
, python3-saml
, pytest
, httpretty
, pytest-cov
}:

buildPythonPackage rec {
  pname = "social-auth-core";
  version = "4.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "af6fc7d9ee39f0aa697cd953121add638fc32a49816341a9838a67904c39e034";
  };

  propagatedBuildInputs = [
    requests
    oauthlib
    requests_oauthlib
    pyjwt
    cryptography
    defusedxml
    python3-openid
    python-jose
    python3-saml
  ];

  checkInputs = [
    pytest
    httpretty
    pytest-cov
  ];

  pythonImportsCheck = [ "social_core" ];

  meta = with lib; {
    homepage = "https://github.com/python-social-auth/social-core";
    description = "Python Social Auth - Core";
    license = licenses.bsd3;
    maintainers = with maintainers; [ n0emis ];
  };
}
