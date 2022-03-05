{ config, lib, pkgs, buildEnv, ... }:

with lib;

let
  cfg = config.services.netbox;
  staticDir = cfg.dataDir + "/static";
  configFile = pkgs.writeTextFile {
    name = "configuration.py";
    text = ''
      STATIC_ROOT = '${staticDir}'
      ALLOWED_HOSTS = ['*']
      DATABASE = {
        'NAME': 'netbox',
        'USER': 'netbox',
        'HOST': '/run/postgresql',
      }

      # Redis database settings. Redis is used for caching and for queuing background tasks such as webhook events. A separate
      # configuration exists for each. Full connection details are required in both sections, and it is strongly recommended
      # to use two separate database IDs.
      REDIS = {
          'tasks': {
              'HOST': 'localhost',
              'PORT': 6379,
              # Comment out `HOST` and `PORT` lines and uncomment the following if using Redis Sentinel
              # 'SENTINELS': [('mysentinel.redis.example.com', 6379)],
              # 'SENTINEL_SERVICE': 'netbox',
              'DATABASE': 0,
              'SSL': False,
          },
          'caching': {
              'HOST': 'localhost',
              'PORT': 6379,
              # Comment out `HOST` and `PORT` lines and uncomment the following if using Redis Sentinel
              # 'SENTINELS': [('mysentinel.redis.example.com', 6379)],
              # 'SENTINEL_SERVICE': 'netbox',
              'DATABASE': 1,
              'SSL': False,
          }
      }

      with open("${cfg.secretKeyFile}", "r") as file:
          SECRET_KEY = file.readline()

      ${cfg.extraConfig}
    '';
  };
  pkg = (pkgs.netbox.overrideAttrs (old: {
    installPhase = old.installPhase + ''
      ln -s ${configFile} $out/opt/netbox/netbox/netbox/configuration.py
    '';
  })).override {
    plugins = cfg.plugins;
  };

  netboxManageScript = with pkgs; (writeScriptBin "netbox-manage" ''
    #!${stdenv.shell}
    export PYTHONPATH=${pkg.pythonPath}
    ${pkg}/bin/netbox "$@"
  '');

in {
  options.services.netbox = {
    enable = mkEnableOption "Netbox";

    listenAddress = mkOption {
      type = types.str;
      default = "[::1]";
      description = ''
        Address the server will listen on.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8001;
      description = ''
        Port the server will listen on.
      '';
    };

    plugins = mkOption {
      type = types.listOf types.package;
      default = [];
      description = ''
        Python-Packages to install as Plugins
      '';
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/netbox";
      description = "Storage path of netbox.";
    };

    secretKeyFile = mkOption {
      type = types.path;
      description = ''
        A file containing the secret key
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Additional lines of configuration appended to the <literal>configuration.py</literal>
      '';
    };
  };

  config = mkIf cfg.enable {
    services.redis.enable = true;

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "netbox" ];
      ensureUsers = [
        {
          name = "netbox";
          ensurePermissions = {
            "DATABASE netbox" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    environment.systemPackages = [ netboxManageScript ];

    systemd.services.netbox = {
      description = "NetBox WSGI Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      preStart = ''
        ${pkg}/bin/netbox migrate
        ${pkg}/bin/netbox trace_paths --no-input
        ${pkg}/bin/netbox collectstatic --no-input
        ${pkg}/bin/netbox remove_stale_contenttypes --no-input
      '';

      environment = {
        PYTHONPATH = pkg.pythonPath; # this is the result of `makePythonPath` put into passthru
      };

      serviceConfig = {
        WorkingDirectory = "${cfg.dataDir}";
        ExecStart = ''
          ${pkgs.python3Packages.gunicorn}/bin/gunicorn netbox.wsgi \
            --bind ${cfg.listenAddress}:${toString cfg.port} \
            --pythonpath ${pkg}/opt/netbox/netbox
        '';
        User = "netbox";
        Group = "netbox";
        StateDirectory = "netbox";
        StateDirectoryMode = "0750";
        Restart = "on-failure";
      };
    };

    systemd.services.netbox-rq = {
      description = "NetBox Request Queue Worker";
      wantedBy = [ "multi-user.target" ];
      after = [ "netbox.service" ];

      environment = {
        PYTHONPATH = pkg.pythonPath; # this is the result of `makePythonPath` put into passthru
      };

      serviceConfig = {
        WorkingDirectory = "${cfg.dataDir}";
        ExecStart = ''
          ${pkg}/bin/netbox rqworker high default low
        '';
        User = "netbox";
        Group = "netbox";
        StateDirectory = "netbox";
        StateDirectoryMode = "0750";
        Restart = "on-failure";
      };
    };

    users.users.netbox = {
      home = "${cfg.dataDir}";
      isSystemUser = true;
      group = "netbox";
    };
    users.groups.netbox = {};
  };
}
