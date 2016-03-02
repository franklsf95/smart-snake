'use strict';

var configPath = './initial-game-config.json';

$.getJSON(configPath, function(initialValues) {
    var el = $('.game-main')[0];
    var snakeApp = Elm.embed(Elm.Snake.Main, el, initialValues);

    snakeApp.ports.info.subscribe(function(info) {
        $('#game-score').text(info.score);
        $('#game-snake-length').text(info.snakeLength);
        var state = info.state;
        var message = "Error: game state.";
        if (state === "Start") {
            message = "Press SPACE to start. Use ARROWS to control.";
        } else if (state === "Playing") {
            message = "";
        } else if (state === "Dead") {
            message = "YOU ARE DEAD. Press SPACE to restart."
        }
        $('#game-message').text(message);
        $('#game-ai-message').text(info.aiMessage);
    });
});
