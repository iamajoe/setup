# REF: https://github.com/diogotcorreia/dotfiles/blob/nixos/profiles/graphical/firefox.nix

{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;

    # Firefox profiles
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;

        settings = {
          # Privacy settings
          "browser.startup.homepage" = "about:home";
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;

          # Search engine - DuckDuckGo as default
          "browser.search.defaultenginename" = "DuckDuckGo";
          "browser.urlbar.placeholderName" = "DuckDuckGo";

          # disable privacy invasive "private attribution" ad-tracking "feature"
          "dom.private-attribution.submission.enabled" = false;

          # disable sponsorships on newtab page
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.default.sites" = "";

          # disable recommendations in about:addons
          "extensions.getAddons.showPane" = false;
          "extensions.htmlaboutaddons.recommendations.enabled" = false;
          "browser.discovery.enabled" = false;
          "browser.shopping.experience2023.enabled" = false;

          # disable telemetry
          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.server" = "data:,";
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.coverage.opt-out" = true;
          "toolkit.coverage.opt-out" = true;
          "toolkit.coverage.endpoint.base" = "";
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;

          # disable studies
          "app.shield.optoutstudies.enabled" = false;
          "app.normandy.enabled" = false;
          "app.normandy.api_url" = "";

          # disable (auto) crash reports
          "breakpad.reportURL" = "";
          "browser.tabs.crashReporting.sendReport" = false;
          "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

          # disable pocket
          "extensions.pocket.enabled" = false;

          # disable AI features
          "browser.ml.enabled" = false;
          "browser.ml.chat.enabled" = false;
          "browser.ml.linkPreview.enabled" = false;

          # Performance
          "gfx.webrender.all" = true;
          "media.ffmpeg.vaapi.enabled" = true;

          # UI customization
          "browser.tabs.loadInBackground" = true;
          "browser.ctrlTab.recentlyUsedOrder" = false;
        };

        # Search engine configuration
        search = {
          force = true;
          default = "DuckDuckGo";
          order = ["DuckDuckGo" "Google"];
        };
      };
    };
  };
}
