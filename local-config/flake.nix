{
  description = "Local config";

  outputs = { self }: {
    userConfig = {
      system = "aarch64-darwin";
      platform = "darwin";

      flakePath = "/etc/nix-darwin";
      flakeName = "dev_mac";

      username = "joel";
      homeDir = "/Users/joel";
      userFullname = "Joel Santos";
      userEmail = "joe@joesantos.io";
    };
  };
}

