'use strict';

// ------------------------------------------------------------
//   Elm interop
// ------------------------------------------------------------

var app = null;
var currentConfig = {};
var configPath = './initial-game-config.json';
var enableJSAI = false;

var startApp = function() {
    var el = $('.game-main')[0];
    // Dispose of old instance
    if (app != null) {
        app.dispose();
    }
    app = Elm.embed(Elm.Snake.Main, el, currentConfig);

    app.ports.info.subscribe(function(info) {
        $('#game-score').text(info.score);
        $('#game-snake-length').text(info.snakeLength);
        var state = info.state;
        var message = 'Error: game state.';
        if (state === 'Start') {
            message = 'Press SPACE to start. Use ARROWS to control.';
        } else if (state === 'Playing') {
            message = '';
        } else if (state === 'Dead') {
            message = 'YOU ARE DEAD. Press SPACE to restart.'
        }
        $('#game-message').text(message);
        $('#game-ai-message').text(info.aiMessage);
    });

    var f = function() {
        app.ports.extInput.send(1);
    }
    setInterval(f, 200);

    if (enableJSAI) {
        app.ports.info.subscribe(function(state) {

        });
    }
};

// ------------------------------------------------------------
//   Load Default Config and Initialize Game
// ------------------------------------------------------------

$.getJSON(configPath, function(config) {
    currentConfig = config;
    // Initial value for external input port
    currentConfig.extInput = 0;
    startApp();
});

// ----------------------------------------
//   Initialize Form Elements
// ----------------------------------------

$('#input-game-fps').slider({
    'min': 1,
    'max': 100,
    'value': 10,
    'scale': 'logarithmic',
    'tooltip_position': 'bottom'
});

$('#input-save-config').click(function() {
    // Game Mode
    var mode = $('input:checked[name=input-mode]').val();
    if (mode === 'elm-ai') {
        currentConfig.gameConfig.enableAI = true;
    } else if (mode === 'js-ai') {
        currentConfig.gameConfig.enableAI = false;
        enableJSAI = true;
    } else {
        currentConfig.gameConfig.enableAI = false;
        enableJSAI = false;
    }
    // Game Speed
    var fps = $('#input-game-fps').slider('getValue');
    currentConfig.gameConfig.fps = fps;
    // Start Game
    startApp();
    // Collapse config panel
    $('#collapse-game-config').collapse();
});
