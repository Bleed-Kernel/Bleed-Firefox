FIREFOX_VERSION = 153.6.0
FIREFOX_URL     = https://archive.mozilla.org/pub/firefox/releases/$(FIREFOX_VERSION)esr
FIREFOX_TARBALL = external/firefox-$(FIREFOX_VERSION)esr.source.tar.xz
FIREFOX_SRC     = external/firefox-$(FIREFOX_VERSION)
FIREFOX_OBJ     = external/obj-bleed
FIREFOX_PATCH   = patches/firefox-bleed.patch
OBJCOPY        ?= /opt/homebrew/opt/llvm@22/bin/llvm-objcopy
MACH = cd $(FIREFOX_SRC) && PATH="$(HOME)/.cargo/bin:$$PATH" MOZCONFIG=$(CURDIR)/mozconfig ./mach

.PHONY: firefox-source firefox-configure firefox-build firefox-package firefox-patch toolchain

$(FIREFOX_TARBALL):
	@mkdir -p external
	curl -sSfL -o $@ $(FIREFOX_URL)/source/firefox-$(FIREFOX_VERSION)esr.source.tar.xz
	curl -sSfL -o external/SHA256SUMS $(FIREFOX_URL)/SHA256SUMS
	cd external && grep " source/firefox-$(FIREFOX_VERSION)esr.source.tar.xz$$" SHA256SUMS | sed 's| source/| |' | shasum -a 256 -c

# unpacked once, the marker is what mkpatch.sh compares against so it goes down before
# the patch does. never unpack over a tree that has work in it
FIREFOX_UNPACKED = external/.firefox-$(FIREFOX_VERSION)-unpacked

$(FIREFOX_UNPACKED): | $(FIREFOX_TARBALL)
	@if [ -d $(FIREFOX_SRC) ]; then echo "$(FIREFOX_SRC) is already there, not unpacking over it"; exit 1; fi
	tar -xJf $(FIREFOX_TARBALL) -C external
	touch $@
	cd $(FIREFOX_SRC) && patch -p1 --batch --forward < $(CURDIR)/$(FIREFOX_PATCH)

firefox-source: $(FIREFOX_UNPACKED)

# the patch is made from the tree, run this after changing firefox
firefox-patch:
	patches/mkpatch.sh

toolchain:
	@$(MAKE) -C toolchain --no-print-directory

firefox-configure: firefox-source toolchain
	$(MACH) configure

FIREFOX_LOG = $(CURDIR)/external/firefox-build.log

FIREFOX_JOBS ?= 4
FIREFOX_NICE ?= 10

firefox-build: firefox-source toolchain
	touch $(FIREFOX_LOG).start
	cd $(FIREFOX_SRC) && PATH="$(HOME)/.cargo/bin:$$PATH" MOZCONFIG=$(CURDIR)/mozconfig nice -n $(FIREFOX_NICE) ./mach --log-file $(FIREFOX_LOG) build --keep-going $(if $(FIREFOX_JOBS),-j$(FIREFOX_JOBS))

firefox-package:
	-cd $(FIREFOX_SRC) && PATH="$(HOME)/.cargo/bin:$$PATH" MOZCONFIG=$(CURDIR)/mozconfig nice -n $(FIREFOX_NICE) ./mach package > $(CURDIR)/external/firefox-package.log 2>&1
	@test -f $(FIREFOX_OBJ)/dist/firefox/libxul.so && \
		! test $(FIREFOX_OBJ)/dist/bin/libxul.so -nt $(FIREFOX_OBJ)/dist/firefox/libxul.so || \
		{ echo "firefox-package failed, see external/firefox-package.log"; exit 1; }
	@# browser/defaults/preferences is read after browser/omni.ja, so these win over firefox.js
	@rm -f $(FIREFOX_OBJ)/dist/firefox/defaults/pref/bleed.js
	@mkdir -p $(FIREFOX_OBJ)/dist/firefox/browser/defaults/preferences
	cp prefs/bleed.js $(FIREFOX_OBJ)/dist/firefox/browser/defaults/preferences/bleed.js
	@mkdir -p $(FIREFOX_OBJ)/dist/firefox/distribution
	cp prefs/policies.json $(FIREFOX_OBJ)/dist/firefox/distribution/policies.json
	@# the desktop and start menu read the name and icons out of the launchers elf sections
	$(OBJCOPY) $(foreach s,app:app.txt icon:icon.png icon16:icon-16.png icon32:icon-32.png icon48:icon-48.png,\
		--remove-section .bleed.$(word 1,$(subst :, ,$(s))) \
		--add-section .bleed.$(word 1,$(subst :, ,$(s)))=res/$(word 2,$(subst :, ,$(s))) \
		--set-section-flags .bleed.$(word 1,$(subst :, ,$(s)))=noload,readonly) \
		$(FIREFOX_OBJ)/dist/firefox/firefox
	@echo "[FIREFOX] packaged in $(FIREFOX_OBJ)/dist/firefox"

BPM_REPO = https://github.com/Bleed-Kernel/Bleed-BPM.git
BPM_DIR ?= $(if $(wildcard ../Bleed-BPM/mkbpkg.sh),../Bleed-BPM,external/Bleed-BPM)
FIREFOX_BPKG = bin/firefox-$(FIREFOX_VERSION).bpkg

FIREFOX_PKG_DIR = $(FIREFOX_OBJ)/dist/firefox

.PHONY: firefox-bpkg
firefox-bpkg:
	@test -f $(FIREFOX_PKG_DIR)/libxul.so || { echo "no packaged firefox, make firefox-package first"; exit 1; }
	@rm -f $(FIREFOX_BPKG)
	@$(MAKE) --no-print-directory $(FIREFOX_BPKG)

$(FIREFOX_BPKG): $(FIREFOX_PKG_DIR)/libxul.so $(FIREFOX_PKG_DIR)/firefox $(FIREFOX_PKG_DIR)/omni.ja $(FIREFOX_PKG_DIR)/browser/omni.ja prefs/bleed.js prefs/policies.json
	@[ -d $(BPM_DIR) ] || git clone $(BPM_REPO) $(BPM_DIR)
	@mkdir -p bin
	$(BPM_DIR)/mkbpkg.sh -n firefox -v $(FIREFOX_VERSION) -d "Mozilla Firefox $(FIREFOX_VERSION) ESR" \
		-o $@ $(FIREFOX_PKG_DIR)

.PHONY: bpkg
bpkg:
	@test -n "$(BPKG_OUT)" || { echo "make bpkg BPKG_OUT=<folder the .bpkg goes in>"; exit 1; }
	@if [ ! -f $(FIREFOX_PKG_DIR)/libxul.so ]; then \
		echo "[FIREFOX] no packaged firefox here, leaving it out (make firefox-build firefox-package first)"; \
		rm -f $(BPKG_OUT)/firefox-*.bpkg; \
		exit 0; \
	fi
	@$(MAKE) --no-print-directory $(FIREFOX_BPKG)
	@rm -f $(BPKG_OUT)/firefox-*.bpkg
	@ln $(FIREFOX_BPKG) $(BPKG_OUT)/ 2>/dev/null || cp $(FIREFOX_BPKG) $(BPKG_OUT)/
