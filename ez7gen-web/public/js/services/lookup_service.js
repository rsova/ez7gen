// lookup_service.js
//http://stackoverflow.com/questions/21919962/share-data-between-angularjs-controllers
angular.module("app").factory('service',[ '$http', function($http) {

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
