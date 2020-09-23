N_PROC := $(shell nproc)

default: install

root:
ifneq ($(shell id -u), 0)
	@echo "You must be root to perform this action."
	@false
endif

install: root
	dnf install -y livecd-tools git zip

build: root clean
	./build.sh

clean: root
	rm -rf fedora-kickstarts/ Fedora-SoC/ files/
	git checkout files/

run: root
	qemu-kvm -smp $(N_PROC) -m 2G -cdrom fedora-kickstarts/Fedora-SoC-Mac.iso

release: root
	mkdir -p releases/
	cp fedora-kickstarts/Fedora-SoC.iso releases/Fedora-SoC-Mac-$(shell date +"%Y_%m_%d_%I_%M_%p").iso
