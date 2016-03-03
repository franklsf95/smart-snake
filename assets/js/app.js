'use strict';

// ------------------------------------------------------------
//   Elm interop
// ------------------------------------------------------------

var currentApp = null;
var currentConfig = {};
var $anchor = $('#game-anchor');

var startApp = function() {
    var el = $('.game-main')[0];
    // Dispose of old instance
    if (currentApp != null) {
        currentApp.dispose();
    }
    currentApp = Elm.embed(Elm.Snake.Main, el, currentConfig);

    currentApp.ports.info.subscribe(function(info) {
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
};

// ------------------------------------------------------------
//   Load Default Config and Initialize Game
// ------------------------------------------------------------

var configPath = './initial-game-config.json';

$.getJSON(configPath, function(config) {
    currentConfig = config;
    startApp();
});

// ----------------------------------------
//   Initialize Form Elements
// ----------------------------------------

$("#input-game-fps").slider({
    'min': 1,
    'max': 100,
    'value': 30,
    'tooltip_position': 'bottom'
});

$('#input-save-config').click(function() {
    var fps = $("#input-game-fps").slider('getValue');
    currentConfig.gameConfig.fps = fps;
    startApp();
});
