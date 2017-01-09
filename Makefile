IMAGE=demo.img


build: FROM_DOCKER_TAG=latest
build: FIRSTBOOT_APPEND=init 0
build: $(IMAGE)
	$(MAKE) run

$(IMAGE):
	virt-builder centos-7.3 \
		--smp 4 --memsize 2048 \
		--output $@ \
		--format qcow2 \
		--size 20G \
		--hostname kubevirt-demo \
		--upload bootstrap-kubevirt.sh:/ \
		--root-password password: \
		--firstboot-command "bash -x /bootstrap-kubevirt.sh ; $(FIRSTBOOT_APPEND)"

run: $(IMAGE)
	qemu-kvm --machine q35 --cpu host --nographic -m 2048 -smp 4 -net nic -net user,hostfwd=:127.0.0.1:9191-:9090,hostfwd=:127.0.0.1:8181-:8080 $(IMAGE)

clean:
	rm -vf $(IMAGE)
