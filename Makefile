DOCKER = docker
IMAGE = kylemanna/aosp:4.4-kitkat

aosp: Dockerfile
	$(DOCKER) build -t $(IMAGE) .

all: aosp

.PHONY: all
