// main.js
angular.module("app").controller('MainController', ['$scope', '$http', 'toastr', 'lookup_service', 'cachedItems',function($scope, $http, toastr, lookup_service, cachedItems){
    //panels.close();

    //fire when controller loaded
    lookup_service.cachedItems = null || cachedItems;
    $scope.hl7 = lookup_service.data;
    //$scope.versions = lookup_service.cachedItems.versions;
    //init select controls
    $scope.std = {};
    $scope.version = {};
    $scope.event = {};
    $scope.subGroup = {};
    $scope.subGroupVisible = false;
    $scope.useTemplate = false;
    $scope.useExVal = false;

    //set standards select
    $scope.standards = lookup_service.cachedItems.standards;

    $scope.setVersions = function(standard){
        lookup_service.cachedItems.standard = standard;
        $scope.versions = standard.versions
    };

    //set an appropriate list of message types for a selected version
    $scope.setEvents = function(version){
        $scope.events = (version.code)? lookup_service.cachedItems.standard.events[version.code] : [{name: 'Version Required', code: ''}];

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

    //$scope.groupFilterFn = function (item){
    //    if (item.name[0] >= 'A' && item.name[0] <= 'M')
    //        return 'From A - M';
    //
    //    if (item.name[0] >= 'N' && item.name[0] <= 'Z')
    //        return 'From N - Z';
    //};

    //function to apply filter change that happened via another control selection
    $scope.setSubGroup = function(group){
        //this is a quick way of making change that model 'dirty'
        //forces select control for message types to see the change in the model and fire the filter function
        $scope.events[0] = cloneObject($scope.events[0])
    }

    //method call to the server to generate hl7
    $scope.generate = function() {
        lookup_service.cachedItems.current = {event: $scope.event, version: $scope.version};

        //var url = $location.url();
        //console.log(url)
        $http({
            //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
            method: 'post',
            url: 'http://localhost:4567/generate/',
            data: { 'std': $scope.std.selected.std, 'version': $scope.version.selected, 'event': $scope.event.selected , 'useTemplate': $scope.useTemplate, 'useExVal': $scope.useExVal}

        }).success(function(data) {
            $scope.hl7 = data;
            lookup_service.data = data;
        });
    };

    $scope.validate = function() {

        $http({
            //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
            //use call async as a promise
            method: 'post',
            url: 'http://localhost:4567/validate/',
            //headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            data: { version: $scope.version.selected,  hl7: lookup_service.data}
        }).success(function(data) {
            $scope.response = data;
            $scope.visible = true;

            if(data.errors) {
                toastr.error('Validation Error', '');

                errors = data.errors;
                angular.forEach(errors, function (value) {
                    toastr.info(value, '');
                })
            }else{
                toastr.success('Validation Success', '');
            }

        }).error(function(data) {
            //this should never happen, the back end id running on the same server
            toastr.error('Error!', "Oops something went wrong...");
        })
    };

    $scope.visible = false;
    $scope.toggle = function() {
        $scope.visible = !$scope.visible;
    };

    $scope.beta = false;
    $scope.betaToggle = function() {
        $scope.beta = !$scope.beta;
        if(!$scope.beta){
            $scope.useTemplate = false;
            $scope.useExVal = false;
        }

    }
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