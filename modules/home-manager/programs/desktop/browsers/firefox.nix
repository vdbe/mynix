{ options, config, lib, mylib, pkgs, myconfig, ... }:

let
  inherit (builtins) attrValues;
  inherit (lib.attrsets) getBin recursiveUpdate;
  inherit (lib.lists) forEach;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkPackageOption;

  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.desktop.browsers.firefox;
in
{
  options.mymodules.programs.desktop.browsers.firefox = {
    enable = mkBoolOpt false;
    inherit (options.programs.firefox) profiles;
    package = mkPackageOption pkgs "firefox" { };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs = {
        firefox = {
          enable = true;
          inherit (cfg) package;

          profiles = recursiveUpdate
            {
              default = {
                isDefault = true;
                settings =
                  {
                    # Website appearance
                    "layout.css.prefers-color-scheme.content-override" = 2; # 0 = Dark, 1 = Light, 2 = Automatic (system)
                    # Enables dark-themed flash before page-load:
                    "ui.systemUsesDarkTheme" = "1";
                    # Developer tools -> uses dark theme
                    "devtools.theme" = "dark";
                    # Enables ETP = decent security -> firefox containers = redundent
                    "browser.contentblocking.category" = "strict";
                    "privacy.donottrackheader.enabled" = true;
                    "privacy.donottrackheader.value" = 1;
                    "privacy.purge_trackers.enabled" = true;
                    # Syncs Firefox toolbar settings across machines
                    # WARNING: May not work across OS'es
                    "services.sync.prefs.sync.browser.uiCustomization.state" = true;
                    # Don't use the built-in password manager. A nixos user is more likely
                    # using an external one (you are using one, right?).
                    "signon.rememberSignons" = false;
                    # Disable the "new tab page" feature and show a blank tab instead
                    # https://wiki.mozilla.org/Privacy/Reviews/New_Tab
                    # https://support.mozilla.org/en-US/kb/new-tab-page-show-hide-and-customize-top-sites#w_how-do-i-turn-the-new-tab-page-off
                    "browser.newtabpage.enabled" = false;
                    "browser.newtab.url" = "about:blank";
                    # Disable Activity Stream
                    # https://wiki.mozilla.org/Firefox/Activity_Stream
                    "browser.newtabpage.activity-stream.enabled" = false;
                    "browser.newtabpage.activity-stream.telemetry" = false;
                    # Disable new tab tile ads & preload
                    # http://www.thewindowsclub.com/disable-remove-ad-tiles-from-firefox
                    # http://forums.mozillazine.org/viewtopic.php?p=13876331#p13876331
                    # https://wiki.mozilla.org/Tiles/Technical_Documentation#Ping
                    # https://gecko.readthedocs.org/en/latest/browser/browser/DirectoryLinksProvider.html#browser-newtabpage-directory-source
                    # https://gecko.readthedocs.org/en/latest/browser/browser/DirectoryLinksProvider.html#browser-newtabpage-directory-ping
                    "browser.newtabpage.enhanced" = false;
                    "browser.newtabpage.introShown" = true;
                    "browser.newtab.preload" = false;
                    "browser.newtabpage.directory.ping" = "";
                    "browser.newtabpage.directory.source" = "data:text/plain,{}";
                    # Reduce search engine noise in the urlbar's completion window. The
                    # shortcuts and suggestions will still work, but Firefox won't clutter
                    # its UI with reminders that they exist.
                    "browser.urlbar.suggest.searches" = false;
                    "browser.urlbar.shortcuts.bookmarks" = false;
                    "browser.urlbar.shortcuts.history" = false;
                    "browser.urlbar.shortcuts.tabs" = false;
                    "browser.urlbar.showSearchSuggestionsFirst" = false;
                    "browser.urlbar.speculativeConnect.enabled" = false;
                    # https://blog.mozilla.org/data/2021/09/15/data-and-firefox-suggest/
                    "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
                    "browser.urlbar.suggest.quicksuggest.sponsored" = false;
                    # Show whole URL in address bar
                    "browser.urlbar.trimURLs" = false;
                    # Disable some not so useful functionality.
                    "browser.disableResetPrompt" = true; # "Looks like you haven't started Firefox in a while."
                    "browser.onboarding.enabled" = false; # "New to Firefox? Let's get started!" tour
                    "browser.aboutConfig.showWarning" = false; # Warning when opening about:config
                    "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
                    "extensions.pocket.enabled" = false;
                    "extensions.shield-recipe-client.enabled" = false;
                    "reader.parse-on-load.enabled" = false; # "reader view"

                    # Security-oriented defaults
                    "security.family_safety.mode" = 0;
                    # Use Mozilla geolocation service instead of Google if given permission
                    "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
                    "geo.provider.use_gpsd" = false;
                    # https://support.mozilla.org/en-US/kb/extension-recommendations
                    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr" = false;
                    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
                    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
                    "extensions.htmlaboutaddons.recommendations.enabled" = false;
                    "extensions.htmlaboutaddons.discover.enabled" = false;
                    "extensions.getAddons.showPane" = false; # uses Go
                    "browser.discovery.enabled" = false;
                    # Reduce File IO / SSD abuse
                    # Otherwise, Firefox bombards the HD with writes. Not so nice for SSDs.
                    # This forces it to write every 30 minutes, rather than 15 seconds.
                    "browser.sessionstore.interval" = "1800000";
                    # Disable battery API
                    # https://developer.mozilla.org/en-US/docs/Web/API/BatteryManager
                    # https://bugzilla.mozilla.org/show_bug.cgi?id=1313580
                    "dom.battery.enabled" = false;
                    # Disable "beacon" asynchronous HTTP transfers (used for analytics)
                    # https://developer.mozilla.org/en-US/docs/Web/API/navigator.sendBeacon
                    "beacon.enabled" = false;
                    # Disable pinging URIs specified in HTML <a> ping= attributes
                    # http://kb.mozillazine.org/Browser.send_pings
                    "browser.send_pings" = false;
                    # Disable gamepad API to prevent USB device enumeration
                    # https://www.w3.org/TR/gamepad/
                    # https://trac.torproject.org/projects/tor/ticket/13023
                    "dom.gamepad.enabled" = false;
                    # Don't try to guess domain names when entering an invalid domain name in URL bar
                    # http://www-archive.mozilla.org/docs/end-user/domain-guessing.html
                    "browser.fixup.alternate.enabled" = false;
                    # Disable telemetry
                    # https://wiki.mozilla.org/Platform/Features/Telemetry
                    # https://wiki.mozilla.org/Privacy/Reviews/Telemetry
                    # https://wiki.mozilla.org/Telemetry
                    # https://www.mozilla.org/en-US/legal/privacy/firefox.html#telemetry
                    # https://support.mozilla.org/t5/Firefox-crashes/Mozilla-Crash-Reporter/ta-p/1715
                    # https://wiki.mozilla.org/Security/Reviews/Firefox6/ReviewNotes/telemetry
                    # https://gecko.readthedocs.io/en/latest/browser/experiments/experiments/manifest.html
                    # https://wiki.mozilla.org/Telemetry/Experiments
                    # https://support.mozilla.org/en-US/questions/1197144
                    # https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/internals/preferences.html#id1
                    "toolkit.telemetry.unified" = false;
                    "toolkit.telemetry.enabled" = false;
                    "toolkit.telemetry.server" = "data:,";
                    "toolkit.telemetry.archive.enabled" = false;
                    "toolkit.telemetry.coverage.opt-out" = true;
                    "toolkit.coverage.opt-out" = true;
                    "toolkit.coverage.endpoint.base" = "";
                    "experiments.supported" = false;
                    "experiments.enabled" = false;
                    "experiments.manifest.uri" = "";
                    "browser.ping-centre.telemetry" = false;
                    # https://mozilla.github.io/normandy/
                    "app.normandy.enabled" = false;
                    "app.normandy.api_url" = "";
                    "app.shield.optoutstudies.enabled" = false;
                    # Disable health reports (basically more telemetry)
                    # https://support.mozilla.org/en-US/kb/firefox-health-report-understand-your-browser-perf
                    # https://gecko.readthedocs.org/en/latest/toolkit/components/telemetry/telemetry/preferences.html
                    "datareporting.healthreport.uploadEnabled" = false;
                    "datareporting.healthreport.service.enabled" = false;
                    "datareporting.policy.dataSubmissionEnabled" = false;

                    # Disable crash reports
                    "breakpad.reportURL" = "";
                    "browser.tabs.crashReporting.sendReport" = false;
                    "browser.crashReports.unsubmittedCheck.autoSubmit2" = false; # don't submit backlogged reports


                    # Disable Form autofill
                    # https://wiki.mozilla.org/Firefox/Features/Form_Autofill
                    "browser.formfill.enable" = false;
                    "extensions.formautofill.addresses.enabled" = false;
                    "extensions.formautofill.available" = "off";
                    "extensions.formautofill.creditCards.available" = false;
                    "extensions.formautofill.creditCards.enabled" = false;
                    "extensions.formautofill.heuristics.enabled" = false;

                    # Compact ui
                    "browser.compactmode.show" = true;
                    "browser.uidensity" = 1;

                    # Bookmark
                    "browser.toolbars.bookmarks.visibility" = "newtab";
                  };
              };
            }
            cfg.profiles;
        };
      };

      mymodules = {
        programs.firejail = {
          wrappedBinaries = {
            firefox = {
              executable = "${getBin config.programs.firefox.package}/bin/firefox";
              profile = "${pkgs.firejail}/etc/firejail/firefox-wayland.profile";
            };
          };
        };
        impermanence = {
          cache.directories = [
            ".cache/mozilla/firefox"
          ];
          state.directories = forEach (attrValues config.programs.firefox.profiles) (profile: { directory = ".mozilla/firefox/${profile.name}"; method = "bindfs"; });
        };
      };

      xdg.configFile = let firejailConfig = myconfig + "/firejail"; in mkIf config.mymodules.programs.firejail.enable {
        "firejail/firefox.local".source = "${firejailConfig}/firefox.local";
        # TODO: Check if running wayland
        "firejail/firefox-wayland.local".source = "${firejailConfig}/firefox-wayland.local";
      };
    }
  ]);
}
