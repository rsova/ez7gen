
//var app = angular.module('app', ['ngRoute', 'ui.bootstrap', 'angular.panels', 'ngSanitize', 'ui.select', 'ngAnimate']);
var app = angular.module('app', ['ngRoute', 'ui.bootstrap', 'ngSanitize', 'ui.select', 'ngAnimate','xeditable']);

app.run(function(editableOptions) {
    editableOptions.theme = 'bs3';
});

//app.config(function($routeProvider, $httpProvider, uiSelectConfig, panelsProvider) {
app.config(function($routeProvider, $httpProvider, uiSelectConfig) {

    //add left option panel
    //panelsProvider
    //    .add({
    //        id: 'left',
    //        position: 'left',
    //        size: '30%',
    //        templateUrl: '../resources/template/left.html',
    //        controller: 'navigation'
    //    });

    //routing
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

    //hl7_versions = [{name: '2.4', code: '2.4'}, {name: 'VAZ 2.4', code: 'vaz2.4'}];

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
        data: {message:"Let's rumble..."},
        //versions: hl7_versions,
        cachedItems: null,
        lookup: lookup()
    };

    return serviceItems;
}]);
app.controller('main', ['$scope', '$http', 'service', 'cachedItems',function($scope, $http, service, cachedItems){
    //panels.close();

    //fire when controller loaded
    service.cachedItems = null || cachedItems;
    $scope.hl7 = service.data;
    //$scope.versions = service.cachedItems.versions;

    //init select controls
    $scope.std = {};
    $scope.version = {};
    $scope.event = {};
    $scope.subGroup = {};
    $scope.subGroupVisible = false;

    //set standards select
    $scope.standards = service.cachedItems.standards;

    $scope.setVersions = function(standard){
        service.cachedItems.standard = standard;
        $scope.versions = standard.versions
    };

    //set an appropriate list of message types for a selected version
    $scope.setEvents = function(version){
        $scope.events = (version.code)? service.cachedItems.standard.events[version.code] : [{name: 'Version Required', code: ''}];

        if($scope.events[0].name != 'Version Required'){
            $scope.subGroups = [];
            var unique = {};
            for( var i in $scope.events ){
                if( typeof(unique[$scope.events[i].group]) == "undefined"){
                    $scope.subGroups.push({name: $scope.events[i].group, code: ''});
                }
                unique[$scope.events[i].group] = 0;
            }
        }

        $scope.subGroupVisible = ($scope.subGroups && $scope.subGroups.length >1)?true : false;
        $scope.subGroup = {};
        $scope.event = {};
    };

    $scope.groupFilterFn = function (groups){
        //return groups.reverse();
        if( typeof($scope.subGroup.selected) == "undefined"){
            return groups;
        }else{
            filtered = groups.filter(function(g) { return g.name == $scope.subGroup.selected.name; });
            $scope.event = {};
            return filtered;
        }
        //return filtered;
    };

    //function to apply filter change that happened via another control selection
    $scope.setSubGroup = function(group){
        //this is a quick way of making change that model 'dirty'
        //forces select control for message types to see the change in the model and fire the filter function
        $scope.events[0] = cloneObject($scope.events[0])
    }

    //method call to the server to generate hl7
    $scope.generate = function() {
        service.cachedItems.current = {event: $scope.event, version: $scope.version};

        $http({
            //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
            method: 'post',
            url: 'http://localhost:4567/generate/',
            data: { 'std': $scope.std.selected.std, 'version': $scope.version.selected, 'event': $scope.event.selected }

        }).success(function(data) {
            $scope.hl7 = data;
            service.data = data;
        });
    };

    $scope.validate = function() {
        $http({
            //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
            //use call async as a promise
            method: 'post',
            url: 'http://localhost:4567/validate/',
            //headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            data: { version: $scope.version.selected,  hl7: service.data}
        }).success(function(data) {
            $scope.response = data;
            $scope.visible = true;
        })
    };

    $scope.visible = false;
    $scope.toggle = function() {
        $scope.visible = !$scope.visible;
    };


    // recursive function to clone an object. If a non object parameter
    // is passed in, that parameter is returned and no recursion occurs.
    function cloneObject(obj) {
        if (obj === null || typeof obj !== 'object') {
            return obj;
        }

        var temp = obj.constructor(); // give temp the original obj's constructor
        for (var key in obj) {
            temp[key] = cloneObject(obj[key]);
        }

        return temp;
    }

}]);
