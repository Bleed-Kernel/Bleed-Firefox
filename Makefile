BLIBC_DIR  ?= $(if $(wildcard ../blibc/include/bleed),../blibc,external/blibc)
BLIBC_REPO  = https://github.com/Bleed-Kernel/blibc.git

CC      = x86_64-elf-gcc
SYSROOT = $(BLIBC_DIR)/sysroot

CFLAGS = \
	-ffreestanding \
	-fno-stack-protector \
	-fno-stack-check \
	-nostdlib \
	-nostdinc \
	-no-pie \
	-m64 \
	-O2 \
	-Wall -Wextra \
	-I$(SYSROOT)/include \
	-I$(SYSROOT)/include/bleed

LDFLAGS = -static -nostdlib -no-pie -m64

.DEFAULT_GOAL := all

include firefox.mk
include $(if $(wildcard ../Bleed-LibCXX/cxx.mk),../Bleed-LibCXX/cxx.mk,external/Bleed-LibCXX/cxx.mk)

.PHONY: all blibc clean

# firefox itself is big enough to only ever be built on purpose, see firefox.mk
all: toolchain

blibc:
	@if [ ! -d "$(BLIBC_DIR)" ]; then git clone $(BLIBC_REPO) $(BLIBC_DIR); fi
	@$(MAKE) -C $(BLIBC_DIR) --no-print-directory

clean:
	rm -rf bin build
