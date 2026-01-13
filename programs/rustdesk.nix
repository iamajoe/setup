{ config, pkgs, ... }:

{
  # RustDesk remote desktop package
  home.packages = with pkgs; [
    rustdesk  # Remote desktop client & server

    # Helper script to show RustDesk connection info
    (pkgs.writeShellScriptBin "rustdesk-info" ''
      echo "=== RustDesk Connection Info ==="
      echo ""
      echo "RustDesk ID:"
      rustdesk --get-id
      echo ""
      echo "🌐 Local IP Addresses:"
      ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1
      echo ""
      echo "🔌 Connection Port: 21118"
      echo ""
    '')
  ];
}
