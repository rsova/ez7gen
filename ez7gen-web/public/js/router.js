// angular.module("app").config(function($routeProvider, $locationProvider) {

//   $locationProvider.html5Mode({enabled:true});

//   $routeProvider.when('/login', {
//     templateUrl: 'login.html',
//     controller: 'LoginController'
//   });

//   $routeProvider.when('/home', {
//     templateUrl: 'home.html',
//     controller: 'HomeController'
//   });

//   $routeProvider.when('/$resource/list-of-books', {
//     templateUrl: 'books_resource.html',
//     controller: 'BooksResourceController'
//   });

//   $routeProvider.when('/$http/list-of-books', {
//     templateUrl: 'books_http.html',
//     controller: 'BooksHttpController',
//     resolve: {
//       books: function(BookService) {
//         return BookService.getBooks();
//       }
//     }
//   });

//   $routeProvider.otherwise({ redirectTo: '/login' });

// });
// angular.module("app").config(function($routeProvider, $httpProvider, uiSelectConfig) {
angular.module("app").config(function($routeProvider, $httpProvider) {
    $routeProvider.when('/', {
        templateUrl : 'templates/generate.html',
        controller : 'MainController',
        resolve: {
            'cachedItems': function (service) {
                return service.lookup;
            }
        }
    }).otherwise('views/index.html');

    $httpProvider.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
    //$httpProvider.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";
    // uiSelectConfig.theme = ' selectize';
});

