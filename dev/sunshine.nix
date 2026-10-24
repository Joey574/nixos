{ ... }:

# Sample implementation for a remote gaming client sunshine

{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
}
