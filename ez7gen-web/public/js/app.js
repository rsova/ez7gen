var app = angular.module('app', ['ngRoute', 'ui.bootstrap', 'ngSanitize', 'ui.select', 'ngAnimate', 'xeditable', 'toastr']);

app.config(function(uiSelectConfig, toastrConfig) {
    //editableOptions.theme = 'bs3';

    uiSelectConfig.theme = 'selectize';
    uiSelectConfig.resetSearchInput = true;
    uiSelectConfig.appendToBody = true;

    angular.extend(toastrConfig, {
        closeButton: true,
        timeOut: 0,
        autoDismiss: false,
        //containerId: 'toast-container',
        //maxOpened: 0,
        newestOnTop: false,
        positionClass: 'toast-bottom-full-width',
        showEasing: 'swing',
        hideEasing: 'linear',
        showMethod: 'fadeIn',
        hideMethod: 'fadeOut',
    });
});

app.run(function(editableOptions) {
    editableOptions.theme = 'bs3';
});
