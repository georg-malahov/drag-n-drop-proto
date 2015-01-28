angular.module('app', ['angularFileUpload', 'ng-sortable']).config([
  '$interpolateProvider', ($interpolateProvider) ->
    $interpolateProvider.startSymbol('[[')
    $interpolateProvider.endSymbol(']]')
]).controller('CreativesController', ['$scope', '$upload', ($scope, $upload) ->
  $scope.headlineStrings = {
    group: {name: 'headlineStrings', pull: 'clone', put: true}
    handle: ".creatives_string-drag-handle"
    ghostClass: "creatives_string-drag-ghost"
    animation: 150
  }
  $scope.textStrings = {
    group: {name: 'textStrings', pull: 'clone', put: true}
    handle: ".creatives_string-drag-handle"
    ghostClass: "creatives_string-drag-ghost"
    animation: 150
  }
  $scope.headlineStringsTarget = {
    group: {name: 'headlineStringsTarget', put: ['headlineStrings'], pull: false}
  }
  $scope.textStringsTarget = {
    group: {name: 'textStringsTarget', put: ['textStrings'], pull: false}
  }
  $scope.constructed = {
    img: ""
    headline: ""
    text: ""
  }
  $scope.resHeadlines = []
  $scope.resTexts = []
  $scope.$watch('resHeadlines', (newVal, oldVal) ->
    return if angular.equals(newVal, oldVal)
    console.log("New resHeadlines: ", newVal)
    $scope.constructed.headline = newVal.splice(-1)[0]
    $scope.resHeadlines = [$scope.constructed.headline] if $scope.constructed.headline
  , true)
  $scope.$watch('resTexts', (newVal, oldVal) ->
    return if angular.equals(newVal, oldVal)
    console.log("New resTexts: ", newVal)
    $scope.constructed.text = newVal.splice(-1)[0]
    $scope.resTexts = [$scope.constructed.text] if $scope.constructed.text
  , true)
  $scope.$watch('constructed', (newVal, oldVal) ->
    return if angular.equals(newVal, oldVal)
    console.log("New resconstructed: ", newVal)
  , true)
  $scope.headers = [
    'super bla-bla header 1',
    'super bla-bla header 2',
    'super bla-bla header 3',
    'super bla-bla header 4',
    'super bla-bla header 5',
    'super bla-bla header 6',
    'super bla-bla header 7',
    'super bla-bla header 8',
    'super bla-bla header 9',
    'super bla-bla header 10',
    'super bla-bla header 11',
    'super bla-bla header 12'
  ]
  $scope.texts = [
    'super bla-bla text 1',
    'super bla-bla text 2',
    'super bla-bla text 3',
    'super bla-bla text 4',
    'super bla-bla text 5',
    'super bla-bla text 6'
  ]
  $scope.activeTab = "headers"
]).directive('imgCenter', () ->
  {
  restrict: 'A'
  link: (scope, elm) ->
    elm.load(->
      width = this.naturalWidth
      height = this.naturalHeight
      elm.parent().css({position: "relative"})
      if width / height > 1
        elm.css(
          "position": "absolute"
          "height": "auto"
          "width": "#{elm.parent().width()}px"
          "margin-top": -height * elm.parent().width() / width / 2 + "px"
          "top": "50%"
          "left": "0"
        )
      else
        elm.css(
          "position": "absolute"
          "height": "#{elm.parent().height()}px"
          "width": "auto"
          "margin-left": -width * elm.parent().height() / height / 2 + "px"
          "left": "50%"
          "top": "0"
        )
    )
  }
)