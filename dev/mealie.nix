{ ... }:

# This might be better used after moving in

{
  services.mealie = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 8080;
  };
}
