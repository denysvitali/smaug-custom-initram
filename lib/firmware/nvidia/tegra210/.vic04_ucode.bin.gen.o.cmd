cmd_firmware/nvidia/tegra210/vic04_ucode.bin.gen.o := /toolchain/o/bin/aarch64-linux-android-gcc -Wp,-MD,firmware/nvidia/tegra210/.vic04_ucode.bin.gen.o.d  -nostdinc -isystem /toolchain/o/bin/../lib/gcc/aarch64-linux-android/4.9.x/include -I./arch/arm64/include -I./arch/arm64/include/generated  -I./include -I./arch/arm64/include/uapi -I./arch/arm64/include/generated/uapi -I./include/uapi -I./include/generated/uapi -include ./include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -D__ASSEMBLY__ -fno-PIE -DCONFIG_BROKEN_GAS_INST=1 -mabi=lp64 -DCC_HAVE_ASM_GOTO   -c -o firmware/nvidia/tegra210/vic04_ucode.bin.gen.o firmware/nvidia/tegra210/vic04_ucode.bin.gen.S

source_firmware/nvidia/tegra210/vic04_ucode.bin.gen.o := firmware/nvidia/tegra210/vic04_ucode.bin.gen.S

deps_firmware/nvidia/tegra210/vic04_ucode.bin.gen.o := \

firmware/nvidia/tegra210/vic04_ucode.bin.gen.o: $(deps_firmware/nvidia/tegra210/vic04_ucode.bin.gen.o)

$(deps_firmware/nvidia/tegra210/vic04_ucode.bin.gen.o):
