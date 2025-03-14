include .env
IMAGE_NAME=ghcr.io/dimension-studio/ayon-ash
VERSION=$(shell python -c "from ash.version import __version__; print(__version__, end='')")

run: build
	docker run \
		-d --rm \
		--name ayon-docker-ash \
		--hostname ash_worker_01 \
		-v $(shell pwd)/ash:/ash/ash \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-e AYON_API_KEY=${AYON_API_KEY} \
		-e AYON_SERVER_URL=${AYON_SERVER_URL} \
		-e GHCR_TOKEN=${GHCR_TOKEN} \
		-e GHCR_USERNAME=${GHCR_USERNAME} \
		--log-driver=syslog \
		--log-opt syslog-address=udp://localhost:514 \
		$(IMAGE_NAME):latest

check:
	sed -i "s/^version = \".*\"/version = \"$(VERSION)\"/" pyproject.toml
	poetry run black .
	poetry run ruff --fix .
	poetry run mypy .

build: check
	docker build -t $(IMAGE_NAME):latest -t $(IMAGE_NAME):$(VERSION) .

dist: build
	docker push ghcr.io/dimension-studio/ayon-ash:$(VERSION)
	docker push ghcr.io/dimension-studio/ayon-ash:latest
