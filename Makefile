.PHONY: all clean run

all: run

game.js: $(shell find Snake -type f)
	elm-make ./Snake/Main.elm --output=./game.js

run: game.js
	open ./index.html

clean:
	rm *.js
