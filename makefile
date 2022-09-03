install:
	aftman install
	wally install
	mkdir bin

place: install
	rojo build -o "bin/koute.rbxl" test.project.json

model: install
	rojo build -o "bin/koute.rbxm" build.project.json

clean:
	rm -rf bin