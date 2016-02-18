'use strict';

var el = document.getElementsByClassName('game-main')[0];
var snakeApp = Elm.embed(Elm.Snake.Main, el);

snakeApp.ports.info.subscribe(function(info) {
    document.getElementById('game-score').innerHTML = info.score;
    document.getElementById('game-snake-length').innerHTML = info.snakeLength;
    var state = info.state;
    var message = "Error: game state.";
    if (state === "Start") {
        message = "Press SPACE to start. Use ARROWS to control.";
    } else if (state === "Playing") {
        message = "";
    } else if (state === "Dead") {
        message = "YOU ARE DEAD. Press SPACE to restart."
    }
    document.getElementById('game-message').innerHTML = message;
    document.getElementById('game-ai-message').innerHTML = info.aiMessage;
});
