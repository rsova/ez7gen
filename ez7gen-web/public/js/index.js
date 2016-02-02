
var app = angular.module('app', ['ngRoute', 'ui.bootstrap', 'angular.panels', 'ngSanitize', 'ui.select', 'ngAnimate']);

app.config(function($routeProvider, $httpProvider, uiSelectConfig, panelsProvider) {

    //add left option panel
    //panelsProvider
    //    .add({
    //        id: 'left',
    //        position: 'left',
    //        size: '30%',
    //        templateUrl: '../resources/template/left.html',
    //        controller: 'navigation'
    //    });

    //keep routing
    $routeProvider.when('/', {
        templateUrl : 'generate.html/',
        controller : 'main',
        resolve: {
            'cachedItems': function (service) {
                return service.lookup;
            }
        }
    }).otherwise('/index.html');

    $httpProvider.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
    //$httpProvider.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";
    uiSelectConfig.theme = ' selectize';
});

    //http://stackoverflow.com/questions/21919962/share-data-between-angularjs-controllers
app.factory('service',[ '$http', function($http) {

    hl7_versions = [{name: '2.4', code: '2.4'}, {name: 'VAZ 2.4', code: 'vaz2.4'}];

    lookup = function(){
       return $http({
            //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
            method: 'get',
            url: 'http://localhost:4567/lookup/',
        }).then(function(response) {
           return response.data;
        });
    };

    var serviceItems = {
        data: {message:'Lets rumbble...'},
        //versions: hl7_versions,
        cachedItems: null,
        lookup: lookup()
    };

    return serviceItems;
}]);
app.controller('navigation', ['$scope','panels','service', function($scope, panels, service) {
    //$scope.isCollapsed = true;
    //$scope.isCollapsed1 = true;
    //$scope.isCollapsed2 = true;
    $scope.max = 100;
    $scope.step = null||50;

    $scope.random = function() {
        if ($scope.step < 74) {
            type = 'info';
            $scope.step = 75;
        } else if ($scope.step < 99) {
            type = 'warning';
            $scope.step = 100;
        } else {
            type = 'success';
            $scope.step = 50;
        }
    };
    //$scope.showWarning = type === 'danger' || type === 'warning';
    //
    //$scope.dynamic = $scope.value;
    //$scope.type = type;

    //stds = [{name: '2.4', code: '2.4'}, {name: 'VAZ 2.4', code: 'vaz2.4'}];
    stds = [{std:"2.4" , versions: [ {name:"2.4", code:"2.4"}, {name:"VAZ2.4", code:"2.4 schema with VA defined tables and Z segments"}]}]
    $scope.standards = stds

    $scope.leftOpen = function () {
        panels.open("left");
    };

    $scope.setStandards = function(standard){
        service.cachedItems.standard = standard.name ;
        service.cachedItems.versions = standard.versions;
    };
    //$scope.random();
}]);

app.controller('main', ['$scope', '$http', 'service', 'cachedItems','panels',function($scope, $http, service, cachedItems, panels){
    panels.close();

    //fire when controller loaded
    service.cachedItems = null || cachedItems;
    $scope.hl7 = service.data;
    //$scope.versions = service.cachedItems.versions;

    //init select controls
    $scope.standards = service.cachedItems.standards;
    $scope.version = {};
    $scope.event = {};

    $scope.setVersions = function(standard){
        service.cachedItems.std = standard;
        $scope.versions = standard.versions
    };

    //set an appropriate list of message types for a selected version
    $scope.setEvents = function(version){
        $scope.events = (version.code)? service.cachedItems.std.events[version.code] : [{name: 'Version Required', code: ''}];
    };

    //method call to the server to generate hl7
    $scope.generate = function() {
        service.cachedItems.current = {event: $scope.event, version: $scope.version};

        $http({
            //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
            method: 'post',
            url: 'http://localhost:4567/generate/',
            data: { 'version': $scope.version.selected, 'event': $scope.event.selected}

        }).success(function(data) {
            $scope.hl7 = data;
            service.data = data;
        });
    };
}]);

//.controller('validate', ['$scope', '$http', 'service', function($scope, $http, service){
//    $scope.hl7 = service.data
//    $scope.version = service.version.selected.name
//    $scope.event = service.event.selected.name
//
//    $scope.visible = false;
//    $scope.toggle = function() {
//        $scope.visible = !$scope.visible;
//    };
//
//    $scope.validate = function() {
//        $http({
//            //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
//            //use call async as a promise
//            method: 'post',
//            url: 'http://localhost:4567/validate/',
//            //headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//            data: { version: service.version.selected,  hl7: service.data}
//        }).success(function(data) {
//            $scope.response = data;
//            $scope.visible = true;
//        })
//    }
//}])
