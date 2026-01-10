# Nix-podman-appflowy-quadlet
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

  };

  outputs =
    {
      self,
      home-manager,
      nixpkgs,
      quadlet-nix,
      sops-nix,
      systems,
      ...
    }@attrs:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
          system:
          f {
            pkgs = import nixpkgs { system = system; };
          }
        );

      # Small tool to iterate over each system
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      packages = forAllSystems (
        { pkgs }:
        {
          appflowySource = pkgs.stdenv.mkDerivation {
            pname = "appflowy-source";
            version = "1.0";
            src = /etc/nixos/sharedModules/podman-quadlets/appflowy/AppFlowy-Cloud;
            unpackPhase = "true";
            installPhase = ''
              mkdir -p $out
              cp -r $src/* $out/
            '';
          };
        }
      );

    in
    {

      packages = packages;

      #

      nixosModules.folders =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let

          cfg = config.services.nix-podman-appflowy-infra;

        in
        {

          options.services.nix-podman-appflowy-infra = {
            enable = lib.mkEnableOption "create necessary folders for appflowy with sops-nix";

            username = lib.mkOption { type = lib.types.str; };

            usergroup = lib.mkOption {
              type = lib.types.str;
              default = cfg.username;
            };

          };

          imports = [ sops-nix.nixosModules.sops ];

          config = lib.mkIf cfg.enable {

            systemd.tmpfiles.settings = {
              "containers_folder" = {
                "/var/lib/containers" = {

                  d = {
                  };
                };
              };

              "appflowy_folders" = {
                "/var/lib/containers/appflowy" = {
                  d = {
                    group = cfg.usergroup;
                    mode = "0755";
                    user = cfg.username;
                  };
                };

                "/var/lib/containers/appflowy/minio_data" = {
                  d = {
                    group = cfg.usergroup;
                    mode = "0755";
                    user = cfg.username;
                  };
                };

                "/var/lib/containers/appflowy/postgres_data" = {
                  d = {
                    group = cfg.usergroup;
                    mode = "0755";
                    user = cfg.username;
                  };
                };
              };
            };
          };
        };

      homeManagerModules.quadlet =
        {
          config,
          lib,
          pkgs,
          ...
        }:

        let
          cfg = config.services.nix-podman-appflowy-quadlet;
          envPaths = cfg.envPaths;
          networks = {
            appflowy_cloud = "appflowy_cloud";
          };
          # networks = { appflowy_cloud = "172.20.0.1/24"; };

          secretsDir = ./secrets;

        in
        {

          options.services.nix-podman-appflowy-quadlet = {
            enable = lib.mkEnableOption "Enable nix-podman-appflowy-quadlet service.";

            envPaths = lib.mkOption {
              type = lib.types.attrsOf lib.types.path;
              default = { };
              description = "Mapping of env names to their decrypted paths on disk.";
            };
          };

          imports = [
            quadlet-nix.homeManagerModules.quadlet
          ];

          config = lib.mkIf cfg.enable (

            let

              globalCommonEnv = {
                APPFLOWY_BASE_URL = "https://appflowy.juiveli.fi";
                APPFLOWY_WEB_URL = "https://appflowy.juiveli.fi";
                APPFLOWY_WEBSOCKET_BASE_URL = "wss://appflowy.juiveli.fi/ws/v2"; # actually on appflowy_web needs this
                APPFLOWY_WS_BASE_URL = "wss://appflowy.juiveli.fi/ws/v2"; # actually on appflowy_web needs this
                APPFLOWY_ENVIRONMENT = "production";
                APPFLOWY_WORKER_ENVIRONMENT = "production";
                APPFLOWY_ACCESS_CONTROL = "true";
                APPFLOWY_WEBSOCKET_MAILBOX_SIZE = "6000";

              };

              networkHostEnv = {
                POSTGRES_HOST = "postgres";
                POSTGRES_PORT = "5432"; # Port for internal connections to Postgres
                REDIS_HOST = "redis";
                REDIS_PORT = "6379"; # Port for internal connections to Redis
                MINIO_HOST = "minio";
                MINIO_PORT = "9000"; # Port for internal connections to Minio
                AI_SERVER_HOST = "ai";
                APPFLOWY_AI_SERVER_PORT = "8080";

                # APPFLOWY_GOTRUE_BASE_URL = "https://appflowy.juiveli.fi/gotrue";
                APPFLOWY_GOTRUE_BASE_URL = "http://gotrue:9999";

                ADMIN_FRONTEND_GOTRUE_URL = "https://appflowy.juiveli.fi/gotrue";
                ADMIN_FRONTEND_REDIS_URL = "redis://redis:6379";
                ADMIN_FRONTEND_APPFLOWY_CLOUD_URL = "http://appflowy_cloud:8000";
                ADMIN_FRONTEND_PATH_PREFIX = "/";
                APPFLOWY_S3_MINIO_URL = "http://minio:9000"; # AppFlowy services need this to connect to MinIO
                APPFLOWY_WORKER_REDIS_URL = "redis://redis:6379";

              };

              dbCredsEnvBundle = {
                environmentFile = [
                  envPaths.postgres-user # POSTGRES_USER
                  envPaths.postgres-password # POSTGRES_PASSWORD
                ];

                environment = {
                  POSTGRES_DB = "postgres";
                };
              };

              minioCreds = {
                environment = {

                  APPFLOWY_S3_BUCKET = "appflowy";
                  APPFLOWY_S3_USE_MINIO = "true";
                  APPFLOWY_S3_CREATE_BUCKET = "true";
                  # APPFLOWY_S3_PRESIGNED_URL_ENDPOINT = "${globalCommonEnv.APPFLOWY_BASE_URL}/minio-api"; # Uncomment and adjust Nginx if using

                };

                environmentFile = [
                  envPaths.minio-root-user # APPFLOWY_S3_ACCESS_KEY
                  envPaths.minio-root-password # APPFLOWY_S3_SECRET_KEY
                ];

              };

              appflowyMailer = {

                environment = {
                  APPFLOWY_MAILER_SMTP_HOST = "smtp.gmail.com";
                  APPFLOWY_MAILER_SMTP_PORT = "465";
                  APPFLOWY_MAILER_SMTP_TLS_KIND = "wrapper";
                };

                environmentFile = [
                  envPaths.appflowy-mailer-smtp-username # APPFLOWY_MAILER_SMTP_USERNAME
                  envPaths.appflowy-mailer-smtp-email # APPFLOWY_MAILER_SMTP_EMAIL
                  envPaths.appflowy-mailer-smtp-password # APPFLOWY_MAILER_SMTP_PASSWORD
                ];

              };

              minioSpecific = {
                environment = {
                  MINIO_BROWSER_REDIRECT_URL = "${globalCommonEnv.APPFLOWY_BASE_URL}/minio";
                };
                environmentFile = [
                  envPaths.minio-root-user # MINIO_ROOT_USER
                  envPaths.minio-root-password # MINIO_ROOT_PASSWORD
                ];
              };

              gotrueSpecific = {

                environment = {
                  # There are a lot of options to configure GoTrue. You can reference the example config:
                  # https://github.com/supabase/auth/blob/master/example.env

                  # The initial GoTrue Admin user password to create, if not already exists.
                  # If the user already exists, the update will be skipped.
                  GOTRUE_DISABLE_SIGNUP = "false";
                  GOTRUE_SITE_URL = "appflowy-flutter://"; # redirected to AppFlowy application
                  GOTRUE_URI_ALLOW_LIST = "**";
                  GOTRUE_JWT_EXP = "7200";
                  # Without this environment variable, the createuser command will create an admin
                  # with the `admin` role as opposed to `supabase_admin`
                  GOTRUE_JWT_ADMIN_GROUP_NAME = "supabase_admin";
                  GOTRUE_DB_DRIVER = "postgres";
                  API_EXTERNAL_URL = "https://appflowy.juiveli.fi/gotrue";
                  # URL that connects to the postgres docker container. If your password contains special characters,
                  # instead of using ${POSTGRES_PASSWORD}, you will need to convert them into url encoded format.
                  # For example, `p@ssword` will become `p%40ssword`.
                  PORT = "9999";
                  GOTRUE_SMTP_HOST = "smtp.gmail.com";
                  GOTRUE_SMTP_PORT = "465";
                  GOTRUE_MAILER_URLPATHS_CONFIRMATION = "/gotrue/verify";
                  GOTRUE_MAILER_URLPATHS_INVITE = "/gotrue/verify";
                  GOTRUE_MAILER_URLPATHS_RECOVERY = "/gotrue/verify";
                  GOTRUE_MAILER_URLPATHS_EMAIL_CHANGE = "/gotrue/verify";
                  GOTRUE_MAILER_TEMPLATES_MAGIC_LINK = "default_magic_link_template";

                  GOTRUE_SMTP_MAX_FREQUENCY = "1ns"; # set to 1ns for running tests
                  GOTRUE_RATE_LIMIT_EMAIL_SENT = "100"; # number of email sendable per minute
                  GOTRUE_MAILER_AUTOCONFIRM = "false"; # change this to true to skip email confirmation

                  # Google OAuth2
                  GOTRUE_EXTERNAL_GOOGLE_ENABLED = "false";
                  GOTRUE_EXTERNAL_GOOGLE_REDIRECT_URI = "http://appflowy.juiveli.fi/gotrue/callback";

                  # GitHub OAuth2
                  GOTRUE_EXTERNAL_GITHUB_ENABLED = "false";
                  GOTRUE_EXTERNAL_GITHUB_REDIRECT_URI = "http://appflowy.juiveli.fi/gotrue/callback";

                  # Discord OAuth2
                  GOTRUE_EXTERNAL_DISCORD_ENABLED = "false";
                  GOTRUE_EXTERNAL_DISCORD_REDIRECT_URI = "http://appflowy.juiveli.fi/gotrue/callback";

                  # Apple OAuth2
                  GOTRUE_EXTERNAL_APPLE_ENABLED = "false";
                  GOTRUE_EXTERNAL_APPLE_REDIRECT_URI = "http://appflowy.juiveli.fi/gotrue/callback";

                  # SAML 2.0. Refer to https://github.com/AppFlowy-IO/AppFlowy-Cloud/blob/main/doc/OKTA_SAML.md for example using Okta.
                  GOTRUE_SAML_ENABLED = "false";

                };

                environmentFile = [
                  envPaths.gotrue-smtp-user # GOTRUE_SMTP_USER
                  envPaths.gotrue-smtp-pass # GOTRUE_SMTP_PASS
                  envPaths.gotrue-smtp-admin-email # GOTRUE_SMTP_ADMIN_EMAIL
                  # The initial GoTrue Admin user to create, if not already exists.
                  envPaths.gotrue-admin-email # GOTRUE_ADMIN_EMAIL
                  envPaths.gotrue-admin-password # GOTRUE_ADMIN_PASSWORD
                  envPaths.gotrue-jwt-secret # GOTRUE_JWT_SECRET

                  envPaths.gotrue-database-url
                  # DATABASE_URL = "postgres://postgres:password@postgres:5432/postgres?search_path=auth";
                  # GOTRUE_DATABASE_URL = "postgres://postgres:password@postgres:5432/postgres?search_path=auth";

                  # Google OAuth2 secrets
                  envPaths.gotrue-external-google-client-id # GOTRUE_EXTERNAL_GOOGLE_CLIENT_ID
                  envPaths.gotrue-external-google-secret # GOTRUE_EXTERNAL_GOOGLE_SECRET

                  # GitHub OAuth2 secrets
                  envPaths.gotrue-external-github-client-id # GOTRUE_EXTERNAL_GITHUB_CLIENT_ID
                  envPaths.gotrue-external-github-secret # GOTRUE_EXTERNAL_GITHUB_SECRET

                  # Discord OAuth2 secrets
                  envPaths.gotrue-external-discord-client-id # GOTRUE_EXTERNAL_DISCORD_CLIENT_ID
                  envPaths.gotrue-external-discord-secret # GOTRUE_EXTERNAL_DISCORD_SECRET

                  # Apple OAuth2
                  envPaths.gotrue-external-apple-client-id # GOTRUE_EXTERNAL_APPLE_CLIENT_ID
                  envPaths.gotrue-external-apple-secret # GOTRUE_EXTERNAL_APPLE_SECRET

                  # SAML 2.0
                  envPaths.gotrue-saml-private-key # GOTRUE_SAML_PRIVATE_KEY

                ];

              };

              appflowy_cloudSpecific = {

                environment = {
                  APPFLOWY_REDIS_URI = "redis://${networkHostEnv.REDIS_HOST}:${networkHostEnv.REDIS_PORT}";

                  APPFLOWY_ACCESS_CONTROL = globalCommonEnv.APPFLOWY_ACCESS_CONTROL;
                  APPFLOWY_DATABASE_MAX_CONNECTIONS = "40";
                  RUST_LOG = "debug";

                  APPFLOWY_GOTRUE_JWT_EXP = gotrueSpecific.environment.GOTRUE_JWT_EXP; # Expiration is general
                };

                environmentFile = [
                  envPaths.appflowy-database-url # APPFLOWY_DATABASE_URL = "${networkHostEnv.POSTGRES_HOST}://${dbCredsEnvBundle.POSTGRES_USER}:${dbCredsEnvBundle.POSTGRES_PASSWORD}@${networkHostEnv.POSTGRES_HOST}:${networkHostEnv.POSTGRES_PORT}/${dbCredsEnvBundle.POSTGRES_DB}?search_path=public";
                  envPaths.gotrue-jwt-secret # APPFLOWY_GOTRUE_JWT_SECRET gotrueSpecific.environmentFile.GOTRUE_JWT_SECRET;

                ];

              };

              admin_frontendSpecific = {
                RUST_LOG = "info";
              };

              appflowy_workerSpecific = {

                environment = {
                  RUST_LOG = "info";
                  APPFLOWY_WORKER_IMPORT_TICK_INTERVAL = "30";
                  APPFLOWY_WORKER_REDIS_URL = "redis://${networkHostEnv.REDIS_HOST}:${networkHostEnv.REDIS_PORT}";
                  APPFLOWY_WORKER_DATABASE_NAME = dbCredsEnvBundle.environment.POSTGRES_DB;
                };

                environmentFile = [
                  envPaths.appflowy-worker-database-url # APPFLOWY_WORKER_DATABASE_URL = "postgres://${dbCredsEnvBundle.POSTGRES_USER}:${dbCredsEnvBundle.POSTGRES_PASSWORD}@${networkHostEnv.POSTGRES_HOST}:${networkHostEnv.POSTGRES_PORT}/${dbCredsEnvBundle.POSTGRES_DB}?search_path=public";
                ];

              };

              aiApiKeys = {
                environmentFile = [ envPaths.openai-api-key ];
                # OPENAI_API_KEY
                # AI_OPENAI_API_KEY
              };

              aiSpecific = {
                environment = {
                  APPFLOWY_AI_REDIS_URL = "redis://${networkHostEnv.REDIS_HOST}:${networkHostEnv.REDIS_PORT}";
                };

                environmentFile = [
                  envPaths.appflowy-ai-database-url # APPFLOWY_AI_DATABASE_URL = "postgres://${dbCredsEnvBundle.POSTGRES_USER}:${dbCredsEnvBundle.POSTGRES_PASSWORD}@${networkHostEnv.POSTGRES_HOST}:${networkHostEnv.POSTGRES_PORT}/${dbCredsEnvBundle.POSTGRES_DB}?search_path=public";
                ];

              };

              minioVariables = {
                environment = networkHostEnv // minioCreds.environment // minioSpecific.environment;

                environmentFile = minioSpecific.environmentFile ++ minioCreds.environmentFile;

              };

              postgresVariables = {
                environment = networkHostEnv // dbCredsEnvBundle.environment;

                environmentFile = dbCredsEnvBundle.environmentFile;
              };

              redisEnvironment = networkHostEnv;

              gotrueEnvironment =
                globalCommonEnv // networkHostEnv // dbCredsEnvBundle.environment // gotrueSpecific.environment;
              gotrueEnvironmentFile = gotrueSpecific.environmentFile ++ dbCredsEnvBundle.environmentFile;

              appflowy_cloudVariables =

                {
                  environment =
                    globalCommonEnv
                    // networkHostEnv
                    // dbCredsEnvBundle.environment
                    // minioCreds.environment
                    // appflowyMailer.environment
                    // appflowy_cloudSpecific.environment;

                  environmentFile =
                    appflowyMailer.environmentFile
                    ++ appflowy_cloudSpecific.environmentFile
                    ++ dbCredsEnvBundle.environmentFile
                    ++ minioCreds.environmentFile
                    ++ aiApiKeys.environmentFile;
                };

              admin_frontendEnvironment = networkHostEnv // globalCommonEnv;

              aiEnvironment = {
                environment =
                  networkHostEnv # For AI connecting to Postgres/MinIO
                  // dbCredsEnvBundle.environment # If AI uses Postgres for embeddings

                  // minioCreds.environment # If AI stores/retrieves from S3

                  // aiSpecific.environment;

                environmentFile =
                  dbCredsEnvBundle.environmentFile
                  ++ aiSpecific.environmentFile
                  ++ minioCreds.environmentFile
                  ++ aiApiKeys.environmentFile;
              };

              appflowy_workerEnvironment =
                networkHostEnv
                // dbCredsEnvBundle.environment
                // minioCreds.environment
                // appflowyMailer.environment
                // appflowy_workerSpecific.environment;

              appflowy_workerEnvironmentFile =
                appflowyMailer.environmentFile
                ++ dbCredsEnvBundle.environmentFile
                ++ appflowy_workerSpecific.environmentFile
                ++ minioCreds.environmentFile;

              appflowy_webEnvironment = globalCommonEnv // {
                APPFLOWY_GOTRUE_BASE_URL = "https://appflowy.juiveli.fi/gotrue";
              };

              appflowy_nginxEnvironment = globalCommonEnv;

            in
            {

              home.packages = [ self.packages.x86_64-linux.appflowySource ];
              systemd.user.startServices = "sd-switch";

              services.podman.builds = {
                appflowyinc_gotrue = {
                  file = "/etc/nixos/sharedModules/podman-quadlets/appflowy/AppFlowy-Cloud/docker/gotrue/Dockerfile";
                  tags = [ "appflowyinc_gotrue" ];

                };

                admin_frontend_build = {
                  file = "/etc/nixos/sharedModules/podman-quadlets/appflowy/AppFlowy-Cloud/admin_frontend/Dockerfile";
                  tags = [ "admin_frontend_build" ];
                };

                appflowy_worker_build = {
                  file = "/etc/nixos/sharedModules/podman-quadlets/appflowy/AppFlowy-Cloud/services/appflowy-worker/Dockerfile";
                  tags = [ "appflowy_worker_build" ];
                  workingDirectory = "/etc/nixos/sharedModules/podman-quadlets/appflowy/AppFlowy-Cloud";
                };

                appflowy_cloud_build = {
                  file = "/etc/nixos/sharedModules/podman-quadlets/appflowy/AppFlowy-Cloud/Dockerfile";
                  tags = [ "appflowy_cloud_build" ];
                  # annotations = [ "FEATURES=" ];
                };
              };

              services.podman.containers.minio = {

                autoStart = true;
                extraConfig = {
                  Service = {
                    Restart = "on-failure";
                    RestartSec = "10";
                  };
                };

                image = "minio/minio";

                network = [
                  "podman"
                  networks.appflowy_cloud
                ];

                environment = minioVariables.environment;
                environmentFile = minioVariables.environmentFile;

                exec = "server /data --console-address :9001";

                volumes = [
                  "/var/lib/containers/appflowy/minio_data:/data"
                ];

              };

              services.podman.containers.postgres = {
                autoStart = true;
                extraConfig = {
                  Service = {
                    RestartSec = "10";
                    Restart = "on-failure";
                  };
                  # REMOVED Health Check Configuration from extraConfig.Container
                  # Container = {
                  #   HealthcheckCommand = "CMD pg_isready -U \\\"$POSTGRES_USER\\\" -d \\\"$POSTGRES_DB\\\"";
                  #   HealthcheckInterval = "5s";
                  #   HealthcheckTimeout = "5s";
                  #   HealthcheckRetries = "12";
                  # };
                };
                image = "pgvector/pgvector:pg16";

                network = [
                  "podman"
                  networks.appflowy_cloud
                ];

                environment = postgresVariables.environment;
                environmentFile = postgresVariables.environmentFile;

                volumes = [
                  "/var/lib/containers/appflowy/postgres_data:/var/lib/postgresql/data"
                ];
              };

              services.podman.containers.redis = {
                autoStart = true;
                extraConfig = {
                  Service = {
                    RestartSec = "10";
                    Restart = "on-failure";
                  };
                };
                image = "redis";

                environment = redisEnvironment;

                network = [
                  "podman"
                  networks.appflowy_cloud
                ];

              };

              services.podman.containers.gotrue = {
                autoStart = true;
                extraConfig = {
                  Service = {
                    RestartSec = "10";
                    Restart = "on-failure";
                  };
                  Unit = {
                    After = [ "podman-postgres.service" ];
                    Requires = [ "podman-postgres.service" ];
                  };
                  # REMOVED Health Check from extraConfig.Container
                  # Container = {
                  #   HealthcheckCommand = "CMD curl --fail http://127.0.0.1:9999/health || exit 1";
                  #   HealthcheckInterval = "5s";
                  #   HealthcheckTimeout = "5s";
                  #   HealthcheckRetries = "12";
                  # };
                };
                image = "appflowyinc_gotrue.build";

                environment = gotrueEnvironment;
                environmentFile = gotrueEnvironmentFile;

                network = [
                  "podman"
                  networks.appflowy_cloud
                ];

              };

              services.podman.containers.appflowy_cloud = {
                autoStart = true;
                extraConfig = {

                  Service = {
                    RestartSec = "10";
                    Restart = "on-failure";
                  };
                  # UNCOMMENTED AND CONFIGURED
                  Unit = {
                    After = "podman-gotrue.service";
                    Requires = "podman-gotrue.service";
                  };
                };
                image = "appflowy_cloud_build.build";

                network = [
                  "podman"
                  networks.appflowy_cloud
                ];

                # Health Check is commented in compose, so no change here
                # healthCmd = "curl --fail http://127.0.0.1:9999/health || exit 1";
                # healthInterval = "5s";
                # healthTimeout = "5s";
                # healthRetries = 12;

                environment = appflowy_cloudVariables.environment;
                environmentFile = appflowy_cloudVariables.environmentFile;

              };

              services.podman.containers.admin_frontend = {
                autoStart = true;
                extraConfig = {
                  Service = {
                    RestartSec = "10";
                    Restart = "on-failure";
                  };
                  Unit = {
                    After = [
                      "podman-gotrue.service"
                      "podman-appflowy_cloud.service"
                    ];
                    Requires = [
                      "podman-gotrue.service"
                      "podman-appflowy_cloud.service"
                    ];
                  };
                };

                image = "admin_frontend_build.build";

                network = [
                  "podman"
                  networks.appflowy_cloud
                ];

                environment = admin_frontendEnvironment;
              };

              services.podman.containers.ai = {
                autoStart = true;
                extraConfig = {
                  Service = {
                    RestartSec = "10";
                    Restart = "on-failure";
                  };
                  Unit = {
                    After = "podman-postgres.service";
                    Requires = "podman-postgres.service";
                  };
                };

                image = "appflowyinc/appflowy_ai:latest";

                network = [
                  "podman"
                  networks.appflowy_cloud
                ];

                environment = aiEnvironment.environment;
                environmentFile = aiEnvironment.environmentFile;
              };

              services.podman.containers.appflowy_worker = {
                autoStart = true;
                extraConfig = {
                  Service = {
                    RestartSec = "10";
                    Restart = "on-failure";
                  };
                  Unit = {
                    After = "podman-postgres.service";
                    Requires = "podman-postgres.service";
                  };
                };

                image = "appflowy_worker_build.build";

                network = [
                  "podman"
                  networks.appflowy_cloud
                ];

                environment = appflowy_workerEnvironment;
                environmentFile = appflowy_workerEnvironmentFile;

              };

              services.podman.containers.appflowy_web = {
                autoStart = true;
                extraConfig = {
                  Service = {
                    RestartSec = "10";
                    Restart = "on-failure";
                  };
                  Unit = {
                    After = "podman-appflowy_cloud.service";
                    Requires = "podman-appflowy_cloud.service";
                  };
                };

                image = "appflowyinc/appflowy_web:latest";

                environment = appflowy_webEnvironment;

                network = [
                  "podman"
                  networks.appflowy_cloud
                ];

              };

              services.podman.containers.appflowy_nginx = {
                autoStart = true;
                extraConfig = {
                  Service = {
                    RestartSec = "10";
                    Restart = "on-failure";
                  };
                  Unit = {
                    After = "podman-appflowy_cloud.service";
                    Requires = "podman-appflowy_cloud.service";
                  };
                };

                image = "docker.io/library/nginx:latest";

                ports = [ "4256:80" ];

                network = [
                  "podman"
                  networks.appflowy_cloud
                ];

                volumes = [ "/var/lib/containers/appflowy/nginx/nginx.conf:/etc/nginx/nginx.conf" ];

                environment = appflowy_nginxEnvironment;

              };
            }
          );
        };

      nixosModules.service =
        { config, lib, ... }:
        let
          cfg = config.services.nix-podman-appflowy-service;

          appflowySecretDefinitions = builtins.mapAttrs (name: _: {
            sopsFile = ./secrets/${name};
            format = "binary";
            owner = cfg.user;
            group = cfg.usergroup;
            mode = "0400";
          }) (lib.attrsets.filterAttrs (name: type: type == "regular") (builtins.readDir ./secrets));

          appflowySecretNames = builtins.attrNames appflowySecretDefinitions;

        in
        {
          options.services.nix-podman-appflowy-service = {

            enable = lib.mkEnableOption "Appflowy Service User and HM setup";
            user = lib.mkOption {
              type = lib.types.str;
              default = "appflowy-user";
            };

            usergroup = lib.mkOption {
              type = lib.types.str;
              default = "appflowy-user";
            };

            homeStateVersion = lib.mkOption {
              type = lib.types.str;
              description = "The stateVersion for the Home Manager user.";
            };

          };

          imports = [
            home-manager.nixosModules.home-manager
            quadlet-nix.nixosModules.quadlet
            self.nixosModules.folders
          ];

          config = lib.mkIf cfg.enable {

            sops.secrets = appflowySecretDefinitions;

            services.nix-podman-appflowy-infra = {
              enable = true;
              username = cfg.user;
              usergroup = cfg.usergroup;
            };

            users.groups.${cfg.user} = { };
            users.users.${cfg.user} = {
              isNormalUser = true;
              group = cfg.user;
              description = "Dedicated appflowy Service User";
              home = "/var/lib/containers/appflowy";
              createHome = true;
              linger = true; # Required for Podman to run without login
            };

            virtualisation.quadlet.enable = true;

            home-manager.users.${cfg.user} = {
              imports = [ self.homeManagerModules.quadlet ];

              home.stateVersion = cfg.homeStateVersion;
              services.podman.enable = true;
              services.nix-podman-appflowy-quadlet = {
                enable = true;
                envPaths = lib.genAttrs appflowySecretNames (name: config.sops.secrets.${name}.path);
              };

            };
          };
        };

    };
}
