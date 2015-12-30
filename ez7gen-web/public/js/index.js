
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
    .factory('Payload', function($http) {

        hl7_versions = [
            {name: '2.4', code: '2.4'},
            {name: 'VAZ 2.4', code: 'vaz2.4'}
        ];
        hl7_events  = {};
        //hl7_events.zseg = [{name: 'ADT_A01', code: 'ADT_A01'}];
        //hl7_events.adm = [{name: 'ADT_A02', code: 'ADT_A02'}];

        lookup = function(){
            $http({
                //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
                //use call async as a promise
                method: 'post',
                url: 'http://localhost:4567/lookup/',
                //headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                data: { 'versions': hl7_versions}
            }).success(function(data) {
                //resp = data;
                hl7_events.adm = data.adm
                hl7_events.zseg = data.zseg
            })
        };
        //    hl7_events = {
        //        zseg:[
        //            {name: 'ADT_A01', code: 'ADT_A01'}
        //        ],
        //        adm:[
        //            {name: 'ADT_A01', code: 'ADT_A01'},
        //            {name: 'ADT_A02', code: 'ADT_A02'},
        //        ]
        //};

        // initiate message
        //return {data:{message:'Lets rumbble...'}, versions: hl7_versions, events: hl7_events};
        return {
            data:{message:'Lets rumbble...'},
            versions: hl7_versions,
            setData: lookup(),
            events: hl7_events
        };

    })
    .controller('navigation', function($scope) {
        $scope.isCollapsed = true;
        $scope.isCollapsed1 = true;
        $scope.isCollapsed2 = true;
    })
    .controller('validate', function($scope,$http, Payload){
        $scope.payload = Payload.data
        $scope.version = Payload.version.selected.name
        $scope.event = Payload.event.selected.name

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
                data: { 'version': Payload.version, 'event': Payload.event, 'payload': Payload.data}
            }).success(function(data) {
                $scope.response = data;
                $scope.visible = true;
            })
        }
    })
    .controller('main', function($scope, $http, Payload){

        $scope.event = {};
        $scope.version = {};

        $scope.versions = Payload.versions;
        $scope.setEvents = function(version){
            if(version.code =='2.4'){
                $scope.events = Payload.events.adm;
            }else if(version.code =='vaz2.4'){
                $scope.events = Payload.events.zseg;
            }else{
                $scope.events = [{name: 'Version Required', code: ''}];
            }
        };

        //save state between requests
        Payload.event = $scope.event;
        Payload.version = $scope.version;

        $scope.generate = function() {
            $http({
                //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
                //use call async as a promise
                method: 'post',
                url: 'http://localhost:4567/generate/',
                //headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                data: { 'version': Payload.version, 'event': Payload.event}
            })
                .success(function(data) {
                    $scope.payload = data;
                    Payload.data = data;
                });

        }

        //fire when controller loaded
        //$scope.generate();
        $scope.payload = Payload.data
    });
   



