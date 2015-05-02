# Build Vagrant boxes running Fedora x86_64 using Packer and VirtualBox

# The Fedora release to build
fedora_release := 21

# Packer requires a checksum for each ISO image
# This is for 'Fedora-Server-netinst-x86_64-21.iso'
iso_sha256 := a6a2e83bb409d6b8ee3072ad07faac0a54d79c9ecbe3a40af91b773e2d843d8e

# Bump the box version to rebuild a box
boxver := 1

# Where to store the tree of box files
output_dir := boxes

# Box name and path
box_name := fedora-$(fedora_release)@$(boxver)
box_path := $(output_dir)/$(box_name).box

# Build boxes without launching the VirtualBox GUI
headless ?= false

all:
	$(shell which packer) build \
	    -var box_name=$(box_name) \
	    -var headless=$(headless) \
	    -var iso_sha256=$(iso_sha256) \
	    -var output_dir=$(output_dir) \
	    -var release=$(fedora_release) \
	    template.json

.PHONY: clean
clean:
	rm -rf $(output_dir)
