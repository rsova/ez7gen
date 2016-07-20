var app = angular.module('app', ['ngRoute', 'ui.bootstrap', 'ngSanitize', 'ui.select', 'ngAnimate', 'xeditable', 'toastr']);

app.run(function(editableOptions, uiSelectConfig) {
    editableOptions.theme = 'bs3';
    uiSelectConfig.theme = ' selectize';

});

app.config(function(toastrConfig) {
    angular.extend(toastrConfig, {
        closeButton: true,
        timeOut: 0,
        autoDismiss: false,
        containerId: 'toast-container',
        //maxOpened: 0,
        newestOnTop: false,
        positionClass: 'toast-bottom-full-width',
        //preventDuplicates: false,
        //preventOpenDuplicates: false,
        //target: 'body',
        showEasing: 'swing',
        hideEasing: 'linear',
        showMethod: 'fadeIn',
        hideMethod: 'fadeOut'
    });
});



//options = {
//    closeButton: true,
//    timeOut: 0,
//    //extendedTimeOut: 1000,
//    positionClass :'toast-bottom-full-width',
//    showEasing: 'swing',
//    hideEasing: 'linear',
//    showMethod: 'fadeIn',
//    hideMethod: 'fadeOut'
//}