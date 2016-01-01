
angular.module('app', [ 'ngRoute', 'ui.bootstrap', 'ngSanitize', 'ui.select' ])
    .config(function($routeProvider, $httpProvider) {

        $routeProvider.when('/', {
            templateUrl : 'generate.html/',
            controller : 'main'
        }).when('/edit', {
            templateUrl : 'edit.html/',
            controller : 'navigation'
        }).when('/validate', {
            templateUrl : 'validate.html/',
            controller : 'validate'
        }).otherwise('/index.html');

        $httpProvider.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
        //$httpProvider.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";
    })
    //http://stackoverflow.com/questions/21919962/share-data-between-angularjs-controllers
    .factory('dataService', function($http) {

        hl7_versions = [
            {name: '2.4', code: '2.4'},
            {name: 'VAZ 2.4', code: 'vaz2.4'}
        ];
        hl7_events  = {};
        //hl7_events.zseg = [{name: 'ADT_A01', code: 'ADT_A01'}];
        //hl7_events.adm = [{name: 'ADT_A02', code: 'ADT_A02'}];

        //lookup = function(){
        //    $http({
        //        //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
        //        //use call async as a promise
        //        method: 'post',
        //        url: 'http://localhost:4567/lookup/',
        //        //headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        //        data: { 'versions': hl7_versions}
        //    }).success(function(data) {
        //        //resp = data;
        //        hl7_events = data.message
        //    })
        //};
        //    hl7_events = {
        //        zseg:[
        //            {name: 'ADT_A01', code: 'ADT_A01'}
        //        ],
        //        adm:[
        //            {name: 'ADT_A01', code: 'ADT_A01'},
        //            {name: 'ADT_A02', code: 'ADT_A02'},
        //        ]
        //};
        lookup = function(){
               return $http({
                    //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
                    //use call async as a promise
                    method: 'post',
                    url: 'http://localhost:4567/lookup/',
                    //headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    data: { 'versions': hl7_versions}
                }).then(function(response) {
                   return response.data;
                });
            };

        // initiate message
        //return {data:{message:'Lets rumbble...'}, versions: hl7_versions, events: hl7_events};
        return {
            data:{message:'Lets rumbble...'},
            versions: hl7_versions,
            events: lookup()
        };

    })
    .controller('navigation', function($scope) {
        $scope.isCollapsed = true;
        $scope.isCollapsed1 = true;
        $scope.isCollapsed2 = true;
    })
    .controller('validate', function($scope,$http, dataService){
        $scope.payload = dataService.data
        $scope.version = dataService.version.selected.name
        $scope.event = dataService.event.selected.name

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
                data: { 'version': dataService.version, 'event': dataService.event, 'payload': dataService.data}
            }).success(function(data) {
                $scope.response = data;
                $scope.visible = true;
            })
        }
    })
    .controller('main', function($scope, $http, dataService){

        $scope.event = {};
        $scope.version = {};
        $scope.cache = {};

        var promise = dataService.events;
        promise.then(function(result) { $scope.cache = result; });

        $scope.versions = dataService.versions;
        $scope.setEvents = function(version){
            if(version.code =='2.4'){
                $scope.events = $scope.cache.adm;
            }else if(version.code =='vaz2.4'){
                $scope.events = $scope.cache.zseg;
            }else{
                $scope.events = [{name: 'Version Required', code: ''}];
            }
        };

        //save state between requests
        dataService.event = $scope.event;
        dataService.version = $scope.version;

        $scope.generate = function() {
            $http({
                //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
                //use call async as a promise
                method: 'post',
                url: 'http://localhost:4567/generate/',
                //headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                data: { 'version': dataService.version, 'event': dataService.event}
            })
                .success(function(data) {
                    $scope.payload = data;
                    dataService.data = data;
                });

        }

        //fire when controller loaded
        //$scope.generate();
        $scope.payload = dataService.data
    });
   



