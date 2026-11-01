# (C) 2026, Cornell University
# All rights reserved.

QEMU        = qemu-system-riscv32

ifeq ($(TOOLCHAIN), DEBIAN)
# Use Debian's native RISC-V toolchain.
# The riscv64-unknown-elf packages target rv32 via -march/-mabi below.
# They use picolibc as the default C library, which GCC already searches.
RISCV_CC    = riscv64-unknown-elf-gcc
OBJDUMP     = riscv64-unknown-elf-objdump
OBJCOPY     = riscv64-unknown-elf-objcopy
else ifeq ($(TOOLCHAIN), GNU)
# Use the official GNU toolchain.
# https://github.com/riscv-collab/riscv-gnu-toolchain
RISCV_CC    = riscv32-unknown-elf-gcc
OBJDUMP     = riscv32-unknown-elf-objdump
OBJCOPY     = riscv32-unknown-elf-objcopy
else
# Use the pre-compiled GNU toolchain binaries from xPack.
# https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases
RISCV_CC    = riscv-none-elf-gcc
OBJDUMP     = riscv-none-elf-objdump
OBJCOPY     = riscv-none-elf-objcopy
endif

LDFLAGS     = -nostdlib -lc -lgcc
CFLAGS      = -march=rv32ima_zicsr -mabi=ilp32 -mcmodel=medlow -Wl,--gc-sections -ffunction-sections -fdata-sections -fdiagnostics-show-option -fno-builtin
DEBUG_FLAGS = --source --all-headers --demangle --line-numbers --wide

all:
	@printf "$(YELLOW)-------- Compile Hello, World! --------$(END)\n"
	$(RISCV_CC) $(CFLAGS) hello.s hello.c -Thello.lds $(LDFLAGS) -o hello.elf
	$(OBJDUMP) $(DEBUG_FLAGS) hello.elf > hello.lst
	$(OBJCOPY) -O binary hello.elf hello.bin

qemu: all
	@printf "$(YELLOW)-------- Run Hello-World on QEMU --------$(END)\n"
	$(QEMU) -nographic -machine virt -smp 1 -m 4M -bios hello.bin

clean:
	rm -f hello.bin hello.lst hello.elf
	rm -f thread.bin thread.lst thread.elf
	rm -rf build tools/egos.bin tools/mkfs tools/disk.img tools/fpgaROM.bin tools/qemuROM.bin

GREEN = \033[1;32m
YELLOW = \033[1;33m
CYAN = \033[1;36m
END = \033[0m
