PRJTAG := featherweight

GIT_DESC := $(shell git describe --tags --always --dirty --match "v[0-9]*")

VERSION_TAG := $(patsubst v%,%,$(GIT_DESC))

.PHONY: all
all: test

.PHONY: test
test:
	docker build -t "erauer/$(PRJTAG)" .
	-docker rm "$(PRJTAG)-$(VERSION_TAG)" -f
	docker run --name "$(PRJTAG)-$(VERSION_TAG)"  --expose 1883 -p 1883:1883 -t "erauer/$(PRJTAG)"  \
			/bin/bash -c "source /usr/local/asdf/asdf.sh && \
			python3 /usr/src/app/integration/interoperability/startbroker.py" &
	while ! echo exit | nc -z 127.0.0.1 1883; do sleep 2; done
	mix test --include external:true
	docker exec	 "$(PRJTAG)-$(VERSION_TAG)" /bin/bash -c 'pgrep -P 1 | xargs kill -s SIGINT'
	wait
