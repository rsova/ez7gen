var app = angular.module('app', ['ngRoute', 'ui.bootstrap', 'ngSanitize', 'ui.select', 'ngAnimate', 'xeditable']);

app.run(function(editableOptions, uiSelectConfig) {
    editableOptions.theme = 'bs3';
    uiSelectConfig.theme = ' selectize';
});

