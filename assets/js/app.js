'use strict';

// ------------------------------------------------------------
//   Elm interop
// ------------------------------------------------------------

var app = null;
var currentConfig = {};
var configPath = './initial-game-config.json';
var enableJSAI = false;

var startApp = function() {
    var el = $('#game-main')[0];
    // Dispose of old instance
    if (app != null) {
        app.dispose();
    }
    // New random seed
    if (currentConfig.gameConfig.trueRandom) {
        currentConfig.gameConfig.randomSeed = Date.now();
    }
    app = Elm.embed(Elm.Snake.Main, el, currentConfig);

    app.ports.info.subscribe(function(info) {
        $('#game-score').text(info.score);
        $('#game-snake-length').text(info.snakeLength);
        var state = info.state;
        var message = 'Error: game state.';
        if (state === 'Start') {
            $('#game-overlay').css({opacity: 1});
            message = 'Press SPACE to start. <br> Use ARROWS to control.';
        } else if (state === 'Playing') {
            $('#game-overlay').css({opacity: 0});
            message = '';
        } else if (state === 'Dead') {
            $('#game-overlay').css({opacity: 0.5});
            message = 'YOU ARE DEAD. <br> Press SPACE to restart.'
        }
        $('#game-overlay-message').html(message);
        $('#game-ai-message').text(info.aiMessage);
    });

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

$('#input-mode-human').click(function() {
    $('#input-game-fps').slider('setValue', 10);
});

$('#input-mode-elm-ai').click(function() {
    $('#input-game-fps').slider('setValue', 60);
});

$('#input-mode-js-ai').click(function() {
    $('#input-game-fps').slider('setValue', 60);
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
    // Game Randomness
    var randomMode = $('input:checked[name=input-random]').val();
    if (randomMode === 'random-yes') {
        currentConfig.gameConfig.trueRandom = true;
    } else if (randomMode == 'random-no') {
        currentConfig.gameConfig.trueRandom = false;
    }
    // Start Game
    startApp();
    // Collapse config panel
    $('#collapse-game-config').collapse();
});
