
angular.module('app', ['ngRoute', 'ui.bootstrap', 'ngSanitize', 'ui.select', 'ngAnimate'])
    .config(function($routeProvider, $httpProvider, uiSelectConfig) {

        $routeProvider.when('/', {
            templateUrl : 'generate.html/',
            controller : 'main',
            resolve: {
                'cachedItems': function (service) {
                    return service.lookup;//.then(function(result){return result});
                    //var deferred = $q.defer();
                    // $http({
                    //    //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
                    //    method: 'get',
                    //    url: 'http://localhost:4567/lookup/',
                    //    //headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    //}).success(function (response) {
                    //     //return response;
                    //     deferred.resolve(response);
                    // });
                    //return deferred.promise;
                }
                //delay: function($q, $defer) {
                //    var delay = $q.defer();
                //    $defer(delay.resolve, 1000);
                //    return delay.promise;
                //}
            }
        }).when('/edit', {
            templateUrl : 'edit.html/',
            controller : 'navigation'
        }).when('/validate', {
            templateUrl : 'validate.html/',
            controller : 'validate'
        }).otherwise('/index.html');

        $httpProvider.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
        //$httpProvider.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";
        uiSelectConfig.theme = ' selectize';
    })
    //http://stackoverflow.com/questions/21919962/share-data-between-angularjs-controllers
    .factory('service',[ '$http', function($http) {

        hl7_versions = [{name: '2.4', code: '2.4'}, {name: 'VAZ 2.4', code: 'vaz2.4'}];

        lookup = function(){
           return $http({
                //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
                method: 'get',
                url: 'http://localhost:4567/lookup/',
                //headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                //data: { versions: hl7_versions}
            }).then(function(response) {
               //service.cachedItems = response.data
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

    }])
    .controller('navigation', ['$scope', function($scope) {
        $scope.isCollapsed = true;
        $scope.isCollapsed1 = true;
        $scope.isCollapsed2 = true;

        $scope.max = 100;
        $scope.value = null||25;

        $scope.random = function() {
            //var value = Math.floor(Math.random() * 100 + 1);
            //var type;

            if ($scope.value < 49) {
                type = 'success';
                $scope.value = 50;
            } else if($scope.value < 74) {
                type = 'info';
                $scope.value = 75;
            } else if($scope.value < 99) {
                type = 'warning';
                $scope.value = 100;
            } else {
                type = 'success';
                $scope.value = 50;
            }

            //$scope.showWarning = type === 'danger' || type === 'warning';

            $scope.dynamic = $scope.value;
            $scope.type = type;
        };

        $scope.random();
    }])
    .controller('validate', ['$scope', '$http', 'service', function($scope, $http, service){
        $scope.hl7 = service.data
        $scope.version = service.version.selected.name
        $scope.event = service.event.selected.name

        $scope.visible = false;
        $scope.toggle = function() {
            $scope.visible = !$scope.visible;
        };

        $scope.validate = function() {
            $http({
                //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
                //use call async as a promise
                method: 'post',
                url: 'http://localhost:4567/validate/',
                //headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                data: { version: service.version.selected,  hl7: service.data}
            }).success(function(data) {
                $scope.response = data;
                $scope.visible = true;
            })
        }
    }])
    .controller('main', function($scope, $http, service, cachedItems){

                //fire when controller loaded
                //$scope.hl7 = service.data;
                service.cachedItems = null || cachedItems;
                //$scope.x = cachedItems;
                $scope.hl7 = service.data;
                $scope.versions = service.cachedItems.versions;
                $scope.version = {};
                $scope.event = {};


               $scope.setEvents = function(version){
                    $scope.events = (version.code)?service.cachedItems.events[version.code]:[{name: 'Version Required', code: ''}];
                };
                //set an appropriate list of message types for a selected version

                //method to the server to generate hl7
                $scope.generate = function() {
                    service.cachedItems.current = {event: $scope.event, version: $scope.version};
                    //service.event = $scope.event;
                    //service.version = $scope.version;
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
                //save state between requests

                //call on load
                //call to get events is async, and returns a promise,
                //then() call on promise gets the result and sets service events value so it can be shared among controllers.
                //service.lookup().then(function(result){service.cashedItems = result});
                //$scope.versions = service.cashedItems.versions;

            });




