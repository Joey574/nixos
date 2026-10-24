{ ... }:

{
  services.cloudflare = {
    enable = true;
    tunnels = {
      "00000000-0000-0000-0000-000000000000" = {
        credentialsFile = "/etc/secrets/tunnel.pem";
        ingress."topoview.org" = "http://127.0.0.1:8080";
        default = "http_status:404";
      };
    };
  };
}
