.PHONY: all clean run

all: run

main.js: $(shell find Snake -type f)
	elm-make ./Snake/Main.elm --output=./main.js

run: main.js
	open ./index.html

clean:
	rm *.js
