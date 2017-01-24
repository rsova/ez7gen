// main.js
angular.module("app").controller('MainController', ['$scope', '$http', 'toastr', 'lookup_service', 'cachedItems',function($scope, $http, toastr, lookup_service, cachedItems){
    //panels.close();

    // when controller loaded, the service has already fired and fetched app data
    lookup_service.cachedItems = null || cachedItems;
    $scope.hl7 = lookup_service.data;

    //init select controls
    $scope.std = {};
    $scope.version = {};
    $scope.event = {};
    $scope.subGroup = {};
    $scope.template = {};


    $scope.useTemplate = false;
    $scope.useExVal = true;
    $scope.hasTemplates = false;
    $scope.visible = false;

    $scope.showUseExVal = false;
    $scope.subGroupVisible = false;

    //set standards select
    $scope.standards = lookup_service.cachedItems.standards;

    // Methods

    // Set versions drop-down for selected standard
    $scope.setVersions = function(standard){
        lookup_service.cachedItems.standard = standard;
        $scope.versions = standard.versions
    };

    //Set an appropriate list of message types for a selected version
    $scope.setEvents = function(version){
        $scope.events = (version.code)? lookup_service.cachedItems.standard.events[version.code] : [{name: 'Version Required', code: ''}];
        $scope.hasTemplates = false;
        $scope.event = {};
    };

    // Check if event has templates
    $scope.onEventSelect = function(event){
        $scope.showUseExVal = false;
        $scope.useExVal = true;
        $scope.template = {};
        //Checks for undefined needed when user resets the control by CTL + Delete
        isTemplateEnabled = (typeof event === "undefined")? false : event.templates
        isCustom =  (typeof $scope.version.selected === "undefined")? false : !$scope.version.selected.base;
        $scope.hasTemplates = isCustom && isTemplateEnabled;
    }


    // Method call to the server to generate hl7
    $scope.generate = function() {
        lookup_service.cachedItems.current = {event: $scope.event, version: $scope.version};

        //handle case when template file is not set
        var templateFile = false;
        try {templateFile = $scope.template.selected.file} catch(e){} //do noting

        //var url = $location.url();
        //console.log(url)
        $http({
            //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
            method: 'post',
            //url: 'http://localhost:4567/generate/',
            url: 'generate/',
            data: { 'std': $scope.std.selected.std, 'version': $scope.version.selected, 'event': $scope.event.selected , 'useTemplate': templateFile, 'useExVal': $scope.useExVal}

        }).success(function(data) {
            $scope.hl7 = data;
            lookup_service.data = data;
        });
    };

    // Method call to the server to validate hl7
    $scope.validate = function() {

        $http({
            //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
            //use call async as a promise
            method: 'post',
            url: 'validate/',
            //headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            data: { std : $scope.std.selected.std, version: $scope.version.selected,  hl7: lookup_service.data}
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
            //this should never happen, the back end is running on the same server
            toastr.error('Error!', "Oops something went wrong...");
        })
    };

    // Method to hide and show responce from Ensemble
    $scope.toggle = function() {
        $scope.visible = !$scope.visible;
    };

    //Method to set handle clean up when template selected
    $scope.onTemplateSelected = function(){
        $scope.showUseExVal = true;
    }

}]);