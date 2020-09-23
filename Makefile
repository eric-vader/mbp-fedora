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
	./build-mbp.sh

clean: root
	rm -rf fedora-kickstarts/ Fedora-SoC/ files/ packages.aunali1.com/ fedora-live-soc.ks
	git checkout files/
	chown Eric_Vader:Eric_Vader -R .

run: root
	qemu-kvm -smp $(N_PROC) -m 2G -cdrom fedora-kickstarts/Fedora-SoC-Mac.iso

release: root
	mkdir -p releases/
	cp fedora-kickstarts/Fedora-SoC-Mac.iso releases/Fedora-SoC-Mac-$(shell cd Fedora-SoC; git rev-parse --short HEAD).iso
