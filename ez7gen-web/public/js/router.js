// angular.module("app").config(function($routeProvider, $httpProvider, uiSelectConfig) {
angular.module("app").config(function($routeProvider, $httpProvider) {
    $routeProvider.when('/', {
        templateUrl : 'templates/generate.html',
        controller : 'MainController',
        resolve: {
            'cachedItems': function (lookup_service) {
                return lookup_service.lookup;
            }
        }
    }).otherwise('views/index.html');

    $httpProvider.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
    // $httpProvider.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";
    // uiSelectConfig.theme = ' selectize';
});

