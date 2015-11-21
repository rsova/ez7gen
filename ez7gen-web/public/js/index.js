
angular.module('app', [ 'ngRoute', 'ui.bootstrap', 'ngSanitize', 'ui.select' ])
  .config(function($routeProvider, $httpProvider) {

	$routeProvider.when('/', {
		templateUrl : 'generate.html',
		controller : 'main'
	}).when('/edit', {
		templateUrl : 'edit.html',
		controller : 'navigation'
	}).when('/validate', {
		templateUrl : 'validate.html',
		controller : 'validate'
	}).otherwise('/');

    $httpProvider.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
    //$httpProvider.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";
    })
    //http://stackoverflow.com/questions/21919962/share-data-between-angularjs-controllers
    .factory('Payload', function() {
        return {data:{message:'Lets rumbble...'}};
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
	  }

      $scope.validate = function() {
          $http({
              //http://stackoverflow.com/questions/12505760/processing-http-response-in-service
              //use call async as a promise
              method: 'post',
              url: 'http://localhost:4567/validate/',
              //headers: {'Content-Type': 'application/x-www-form-urlencoded'},
              data: { 'version': Payload.version, 'event': Payload.event}
          })
          //.success(function(data) {
              .success(function(data) {
                  $scope.payload = data;
                  Payload.data = data;
              })

      }
  })
  .controller('main', function($scope, $http, Payload){

        $scope.event = {};
        $scope.version = {};
        $scope.versions = [
            {name:'2.4', code:'2.4'},
            {name:'VAZ 2.4', code:'vaz2.4'},
        ]

        $scope.events = [
            {name:'ADT_A01', code:'ADT_A01'},
            {name:'ADT_A02', code:'ADT_A02'},
            {name:'ADT_A03', code:'ADT_A03'},
            {name:'ADT_A04', code:'ADT_A04'},
            {name:'ADT_A05', code:'ADT_A05'},
            {name:'ADT_A06', code:'ADT_A06'},
            {name:'ADT_A07', code:'ADT_A07'},
            {name:'ADT_A08', code:'ADT_A08'},
            {name:'ADT_A09', code:'ADT_A09'},
            {name:'ADT_A10', code:'ADT_A10'},
            {name:'ADT_A11', code:'ADT_A11'},
            {name:'ADT_A12', code:'ADT_A12'},
            {name:'ADT_A13', code:'ADT_A13'},
            {name:'ADT_A14', code:'ADT_A14'},
            {name:'ADT_A15', code:'ADT_A15'},
            {name:'ADT_A16', code:'ADT_A16'},
            {name:'ADT_A17', code:'ADT_A17'},
            {name:'ADT_A18', code:'ADT_A18'},
            {name:'ADT_A19', code:'ADT_A19'},
            {name:'ADT_A20', code:'ADT_A20'},
            {name:'ADT_A21', code:'ADT_A21'},
            {name:'ADT_A22', code:'ADT_A22'},
            {name:'ADT_A23', code:'ADT_A23'},
            {name:'ADT_A24', code:'ADT_A24'},
            {name:'ADT_A25', code:'ADT_A25'},
            {name:'ADT_A26', code:'ADT_A26'},
            {name:'ADT_A27', code:'ADT_A27'},
            {name:'ADT_A28', code:'ADT_A28'},
            {name:'ADT_A29', code:'ADT_A29'},
            {name:'ADT_A30', code:'ADT_A30'},
            {name:'ADT_A31', code:'ADT_A31'},
            {name:'ADT_A32', code:'ADT_A32'},
            {name:'ADT_A33', code:'ADT_A33'},
            {name:'ADT_A34', code:'ADT_A34'},
            {name:'ADT_A35', code:'ADT_A35'},
            {name:'ADT_A36', code:'ADT_A36'},
            {name:'ADT_A37', code:'ADT_A37'},
            {name:'ADT_A38', code:'ADT_A38'},
            {name:'ADT_A39', code:'ADT_A39'},
            {name:'ADT_A40', code:'ADT_A40'},
            {name:'ADT_A41', code:'ADT_A41'},
            {name:'ADT_A42', code:'ADT_A42'},
            {name:'ADT_A43', code:'ADT_A43'},
            {name:'ADT_A44', code:'ADT_A44'},
            {name:'ADT_A45', code:'ADT_A45'},
            {name:'ADT_A46', code:'ADT_A46'},
            {name:'ADT_A47', code:'ADT_A47'},
            {name:'ADT_A48', code:'ADT_A48'},
            {name:'ADT_A49', code:'ADT_A49'},
            {name:'ADT_A50', code:'ADT_A50'},
            {name:'ADT_A51', code:'ADT_A51'},
            {name:'ADT_A52', code:'ADT_A52'},
            {name:'ADT_A53', code:'ADT_A53'},
            {name:'ADT_A54', code:'ADT_A54'},
            {name:'ADT_A55', code:'ADT_A55'},
            {name:'ADT_A56', code:'ADT_A56'},
            {name:'ADT_A57', code:'ADT_A57'},
            {name:'ADT_A58', code:'ADT_A58'},
            {name:'ADT_A59', code:'ADT_A59'},
            {name:'ADT_A60', code:'ADT_A60'},
            {name:'ADT_A61', code:'ADT_A61'},
            {name:'QBP_Q21', code:'QBP_Q21'},
            {name:'QBP_Q22', code:'QBP_Q22'},
            {name:'QBP_Q23', code:'QBP_Q23'},
            {name:'QBP_Q24', code:'QBP_Q24'},
            {name:'RSP_K21', code:'RSP_K21'},
            {name:'RSP_K22', code:'RSP_K22'},
            {name:'RSP_K23', code:'RSP_K23'},
            {name:'RSP_K24', code:'RSP_K24'}      ];

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
      //.success(function(data) {
      .success(function(data) {
            $scope.payload = data;
            Payload.data = data;
        })

    }
   
    //fire when controller loaded
    //$scope.generate();
    $scope.payload = Payload.data
  });
   



