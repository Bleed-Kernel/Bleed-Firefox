pref("fission.autostart", false);
pref("dom.ipc.processCount", 1);
pref("dom.ipc.processCount.webIsolated", 1);
pref("dom.ipc.processPrelaunch.enabled", false);
pref("dom.ipc.keepProcessesAlive.web", 0);
pref("browser.tabs.remote.separatePrivilegedContentProcess", false);
pref("browser.tabs.remote.separatePrivilegedMozillaWebContentProcess", false);
pref("browser.tabs.remote.separateFileUriProcess", false);
pref("extensions.webextensions.remote", false);
pref("network.process.enabled", false);
pref("media.rdd-process.enabled", false);
pref("media.utility-process.enabled", false);
pref("media.allow-audio-non-utility", true);
pref("media.cubeb.sandbox", false);

// first run, the profile is new every boot
pref("browser.startup.homepage", "about:blank");
pref("browser.startup.page", 1);
pref("browser.newtabpage.enabled", false);
pref("browser.newtab.preload", false);
pref("browser.startup.homepage.abouthome_cache.enabled", false);
pref("browser.aboutwelcome.enabled", false);
pref("browser.shell.checkDefaultBrowser", false);
pref("startup.homepage_welcome_url", "");
pref("startup.homepage_welcome_url.additional", "");
pref("startup.homepage_override_url", "");
pref("browser.startup.homepage_override.mstone", "ignore");
pref("datareporting.policy.firstRunURL", "");
pref("datareporting.policy.dataSubmissionPolicyBypassNotification", true);
pref("toolkit.telemetry.reportingpolicy.firstRun", false);
pref("browser.toolbars.bookmarks.visibility", "never");
pref("browser.bookmarks.addedImportButton", true);
pref("browser.backup.enabled", false);
pref("browser.backup.scheduled.enabled", false);

// telemetry, studies and experiments
pref("datareporting.healthreport.uploadEnabled", false);
pref("datareporting.policy.dataSubmissionEnabled", false);
pref("datareporting.usage.uploadEnabled", false);
pref("toolkit.telemetry.enabled", false);
pref("toolkit.telemetry.unified", false);
pref("toolkit.telemetry.archive.enabled", false);
pref("toolkit.telemetry.newProfilePing.enabled", false);
pref("toolkit.telemetry.firstShutdownPing.enabled", false);
pref("toolkit.telemetry.shutdownPingSender.enabled", false);
pref("toolkit.telemetry.updatePing.enabled", false);
pref("toolkit.telemetry.bhrPing.enabled", false);
pref("app.normandy.enabled", false);
pref("app.shield.optoutstudies.enabled", false);
pref("messaging-system.rsexperimentloader.enabled", false);
pref("nimbus.rollouts.enabled", false);
pref("browser.ping-centre.telemetry", false);
pref("browser.newtabpage.activity-stream.telemetry", false);
pref("browser.newtabpage.activity-stream.feeds.telemetry", false);

// network services that poll or need things bleed doesnt do yet
pref("network.http.http3.enable", false);
pref("network.captive-portal-service.enabled", false);
pref("network.connectivity-service.enabled", false);
pref("network.prefetch-next", false);
pref("network.dns.disablePrefetch", true);
pref("network.predictor.enabled", false);
pref("network.http.speculative-parallel-limit", 0);
pref("browser.urlbar.speculativeConnect.enabled", false);
pref("browser.places.speculativeConnect.enabled", false);
pref("browser.region.network.url", "");
pref("browser.region.update.enabled", false);
pref("geo.provider.network.url", "");
pref("dom.push.connection.enabled", false);
pref("browser.safebrowsing.malware.enabled", false);
pref("browser.safebrowsing.phishing.enabled", false);
pref("browser.safebrowsing.downloads.enabled", false);
pref("browser.safebrowsing.downloads.remote.enabled", false);
pref("browser.safebrowsing.blockedURIs.enabled", false);
pref("identity.fxaccounts.enabled", false);
pref("extensions.pocket.enabled", false);
pref("extensions.getAddons.cache.enabled", false);
pref("extensions.htmlaboutaddons.recommendations.enabled", false);
pref("extensions.systemAddon.update.enabled", false);
pref("browser.discovery.enabled", false);
pref("app.update.auto", false);
pref("browser.search.update", false);
pref("browser.urlbar.quicksuggest.enabled", false);
pref("browser.urlbar.trending.featureGate", false);
pref("browser.translations.enable", false);
pref("browser.ml.enable", false);
pref("browser.ml.chat.enabled", false);

// less work per frame and on disk
pref("general.smoothScroll", false);
pref("toolkit.cosmeticAnimations.enabled", false);
pref("ui.prefersReducedMotion", 1);
pref("browser.cache.disk.enable", false);
pref("browser.sessionstore.interval", 60000);

// no drm. widevine (and openh264) are linux glibc blobs firefox downloads
pref("media.eme.enabled", false);
pref("media.gmp-widevinecdm.enabled", false);
pref("media.gmp-widevinecdm.visible", false);
pref("media.gmp-gmpopenh264.enabled", false);
pref("media.gmp-manager.updateEnabled", false);
pref("media.gmp-provider.enabled", false);

// everything is drawn by the cpu (software webrender, no gpu driver yet
pref("layout.frame_rate", 30);
pref("general.smoothScroll", false);
pref("ui.prefersReducedMotion", 1);
pref("toolkit.cosmeticAnimations.enabled", false);
pref("media.eme.enabled", false);
pref("media.gmp-widevinecdm.enabled", false);
pref("media.gmp-widevinecdm.visible", false);
pref("media.gmp-gmpopenh264.enabled", false);
pref("media.gmp-manager.updateEnabled", false);
pref("media.gmp-provider.enabled", false);
