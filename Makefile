install:
	luarocks install busted
	luarocks install penlight

test:
	busted

docker:
	docker build -t tetris-image .
