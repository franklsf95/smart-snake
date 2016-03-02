.PHONY: all clean run

all: run

game.js: $(shell find Snake -type f)
	elm-make ./Snake/Main.elm --output=./game.js

run: game.js
	python3 -m http.server &
	open http://0.0.0.0:8000/

clean:
	rm *.js
