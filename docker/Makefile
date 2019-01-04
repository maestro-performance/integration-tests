all: image

clean:
	docker rmi -f maestro-test-client || true

image: clean
	docker build -t maestro-test-client .