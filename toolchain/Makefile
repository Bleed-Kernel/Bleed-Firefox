# a sysroot + clang wrapper that make bleed look like any linux cross target, for code with
# its own build system (firefox). x86_64-unknown-linux-musl headers and libs are blibc and
# libc++, libgcc is compiler-rts builtins, libgcc_s is libc++.so (it has libunwind in it)
BLIBC_DIR  ?= $(if $(wildcard ../../blibc/include/bleed),../../blibc,../external/blibc)
LIBCXX_DIR ?= $(if $(wildcard ../../Bleed-LibCXX/Makefile),../../Bleed-LibCXX,../external/Bleed-LibCXX)
LLVM_BIN   ?= /opt/homebrew/opt/llvm@22/bin
# libcrime for the widget code, a sibling Crime-Scene checkout when theres one (never pulled)
CRIME_DIR  ?= $(if $(wildcard ../../Crime-Scene/include/crime/crime.h),../../Crime-Scene,../external/crime-scene)
CRIME_REPO  = https://github.com/Bleed-Kernel/Crime-Scene

SYSROOT = sysroot
# built fresh in here, then only files that really changed go into sysroot so a blibc
# rebuild doesnt make every header look new and recompile all of firefox
STAGE   = sysroot.stage
BLIBC   = $(BLIBC_DIR)/sysroot
LIBCXX  = $(LIBCXX_DIR)/sysroot

# linux splits libc up, here its all libc.so so the rest are empty
EMPTY_LIBS = libm libpthread libdl librt libutil libcrypt libresolv libgcc_eh

.PHONY: all clean crime
all: crime $(SYSROOT)/.done

crime:
	@if [ ! -f $(CRIME_DIR)/include/crime/crime.h ]; then git clone $(CRIME_REPO) $(CRIME_DIR); \
	elif [ "$(CRIME_DIR)" = ../external/crime-scene ]; then cd $(CRIME_DIR) && git pull --ff-only -q; fi

CRIME_SRC = $(wildcard $(CRIME_DIR)/lib/*.c)

# libcrime built position independent for libxul, against the sysroots blibc like everything else
$(SYSROOT)/.done: $(BLIBC)/lib/libc.so $(LIBCXX)/lib/libc++.so $(LIBCXX)/lib/libclang_rt.builtins-x86_64.a crt/*.S Makefile \
                  $(CRIME_SRC) $(CRIME_DIR)/include/crime/crime.h
	rm -rf $(STAGE)
	mkdir -p $(STAGE)/usr/include $(STAGE)/usr/lib $(STAGE)/lib
	cp -R $(BLIBC)/include/ $(STAGE)/usr/include/
	cp -R $(LIBCXX)/include/c++ $(STAGE)/usr/include/
	cp $(BLIBC)/lib/libc.so $(LIBCXX)/lib/libc++.so $(STAGE)/usr/lib/
	cp $(LIBCXX)/lib/libclang_rt.builtins-x86_64.a $(STAGE)/usr/lib/libgcc.a
	echo 'INPUT(libc++.so)' > $(STAGE)/usr/lib/libgcc_s.so
	echo 'INPUT(libc++.so)' > $(STAGE)/usr/lib/libc++abi.so
	for l in $(EMPTY_LIBS); do $(LLVM_BIN)/llvm-ar rc $(STAGE)/usr/lib/$$l.a; done
	$(LLVM_BIN)/clang --target=x86_64-unknown-linux-musl -c crt/crt1.S -o $(STAGE)/usr/lib/crt1.o
	cp $(STAGE)/usr/lib/crt1.o $(STAGE)/usr/lib/Scrt1.o
	$(LLVM_BIN)/clang --target=x86_64-unknown-linux-musl -c crt/crtbegin.S -o $(STAGE)/usr/lib/crtbegin.o
	cp $(STAGE)/usr/lib/crtbegin.o $(STAGE)/usr/lib/crtbeginS.o
	$(LLVM_BIN)/clang --target=x86_64-unknown-linux-musl -c crt/empty.S -o $(STAGE)/usr/lib/crti.o
	for o in crtn crtend crtendS; do cp $(STAGE)/usr/lib/crti.o $(STAGE)/usr/lib/$$o.o; done
	mkdir -p $(STAGE)/usr/include/crime $(STAGE)/crime
	cp $(CRIME_DIR)/include/crime/crime.h $(STAGE)/usr/include/crime/
	for c in $(CRIME_SRC); do \
		$(LLVM_BIN)/clang --target=x86_64-unknown-linux-musl --sysroot=$(STAGE) -D__bleed__=1 -fPIC -O2 \
			-isystem $(STAGE)/usr/include/bleed -c $$c -o $(STAGE)/crime/$$(basename $$c .c).o || exit 1; \
	done
	$(LLVM_BIN)/llvm-ar rcs $(STAGE)/usr/lib/libcrime.a $(STAGE)/crime/*.o
	rm -rf $(STAGE)/crime
	mkdir -p $(SYSROOT)
	rsync -rlpD --checksum --delete $(STAGE)/ $(SYSROOT)/ --exclude .done
	rm -rf $(STAGE)
	touch $@

clean:
	rm -rf $(SYSROOT) $(STAGE)
