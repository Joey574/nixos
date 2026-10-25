{ config, lib, ... }:

let
  iface = config.my.system.network.privateInterface;
  port = 8083;
in
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "open-webui" ];

  networking.firewall.interfaces.${iface}.allowedTCPPorts = [ port ];

  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = port;
    environment = {
      OPENAI_API_BASE_URL = "http://orin.netbird.cloud:8080/v1";
      ENABLE_OPENAI_API = "true";
      OPENAI_API_KEY = "sk-unused";
      ENABLE_SIGNUP = "true";
      DEFAULT_USER_ROLE = "pending";
      WEBUI_AUTH = "true";
      ANONYMIZED_TELEMETRY = "false";
      DO_NOT_TRACK = "1";
      ENABLE_COMMUNITY_SHARING = "false";
      ENABLE_WEB_SEARCH = "True";
      WEB_SEARCH_ENGINE = "duckduckgo";
    };

    environmentFile = "/etc/secrets/open-webui.env";
  };
}
