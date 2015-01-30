angular.module('app', ['angularFileUpload', 'ng-sortable']).config([
  '$interpolateProvider', ($interpolateProvider) ->
    $interpolateProvider.startSymbol('[[')
    $interpolateProvider.endSymbol(']]')
]).controller('CreativesController', ['$scope', '$upload', ($scope, $upload) ->
  $scope.activeTab = "images"
  $scope.imageResults = []
  $scope.headlineResults = []
  $scope.textResults = []
  $scope.files = []
  $scope.readyAds = []
  $scope.images = [
    'img/image1.jpeg'
    'img/image2.jpeg'
    'img/image3.jpeg'
    'img/image4.jpeg'
  ]
  $scope.headers = [
    'Header header header header',
    'You can drop here a text file with ";" as separator',
    'Or you can Drag here selected text from any text editors (strings should be separated by \';\')'
  ]
  $scope.texts = [
    'Text text text text text',
    'You can drop here a text file with ";" as separator',
    'Or you can Drag here selected text from any text editors (strings should be separated by \';\')'
  ]
  $scope.imagesSortable = {
    group: {name: 'imagesSortable', pull: 'clone', put: true}
    ghostClass: "creatives_image-drag-ghost"
    animation: 150
  }
  strings = {
    group: {name: 'headlineStrings', pull: 'clone', put: true}
    handle: ".creatives_string-drag-handle"
    ghostClass: "creatives_string-drag-ghost"
    animation: 150
  }
  $scope.headlineStrings = angular.extend({}, strings)
  $scope.textStrings = angular.extend({}, strings, {group: {name: 'textStrings', pull: 'clone', put: true}})
  $scope.imagesSortableTarget = {group: {name: 'imagesSortableTarget', put: ['imagesSortable'], pull: false}}
  $scope.headlineStringsTarget = {group: {name: 'headlineStringsTarget', put: ['headlineStrings'], pull: false}}
  $scope.textStringsTarget = {group: {name: 'textStringsTarget', put: ['textStrings'], pull: false}}
  $scope.constructed = { image: "", headline: "", text: "" }
  processItem = (name, newVal, oldVal) ->
    return if angular.equals(newVal, oldVal)
    angular.forEach(newVal, (val) ->
      if oldVal.indexOf(val) is -1
        $scope.constructed[name] = val
        $scope[name + 'Results'] = [$scope.constructed[name]] if $scope.constructed[name]
    )
  $scope.$watch('headlineResults', (newVal, oldVal) ->
    processItem('headline', newVal, oldVal)
  , true)
  $scope.$watch('textResults', (newVal, oldVal) ->
    processItem('text', newVal, oldVal)
  , true)
  $scope.$watch('imageResults', (newVal, oldVal) ->
    processItem('image', newVal, oldVal)
  , true)
  $scope.$watch('constructed', (newVal, oldVal) ->
    return if angular.equals(newVal, oldVal)
    if newVal.image and newVal.headline and newVal.text
      $scope.readyAds.unshift(angular.extend({}, newVal))
      console.log("New res ad constructed: ", newVal)
  , true)
  $scope.$watch('files', (newVal, oldVal) ->
    return if angular.equals(newVal, oldVal)
    $scope.$broadcast("processFiles", newVal)
  , true)
]).directive('processFiles', () ->
  {
  restrict: 'A'
  link: (scope, elm) ->
    scope.$on("processFiles", (e, files) ->
      console.log("Should process these files: ", files)
      angular.forEach(files, (file) ->
        imageType = /image.*/
        textType = /text.*/
        reader = new FileReader()
        if file.type.match(imageType)
          reader.onload = (e) ->
            scope.$apply(->
              scope[scope.activeTab].push(e.target.result)
            )
            console.info("Result of upload: ", scope[scope.activeTab])
          reader.readAsDataURL(file)
        if file.type.match(textType)
          reader.onload = (e) ->
            text = e.target.result
            scope[scope.activeTab] = text.split(";")
          reader.readAsText(file)
      )
    )
#    elm[0].ondrop = (e) ->
#      console.log("On Drop: ", e)
#      textData = event.dataTransfer.getData ("Text")
#      scope[scope.activeTab] = textData.split("\n") if textData
  }
).directive('stringAdd', () ->
  {
  restrict: 'A'
  link: (scope, elm, attrs) ->
    scope.keyPress = (name, string, e) ->
      if e.keyCode is 13
        e.preventDefault()
        scope[name.slice(0, -1)] = undefined
        if string and string.indexOf(";")
          scope[name] = scope[name].concat(string.split(";"))
        else
          scope[name] = scope[name].concat(string.split("\n"))
    scope.onBlur = (item, e) ->
      return
  }
).directive('editable', () ->
  {
  restrict: 'C'
  scope: {value: "="}
  compile: (elm, attrs) ->
    field = jQuery("<textarea class='editable-field' ng-model='#{attrs.value}'>")
    elm.append(field)
    return (scope, elm, attrs) ->
      elm.find(".editable-field").css("padding", elm.css("padding"))
      elm.find(".editable-field").css("text-align", elm.css("text-align"))
      elm.find(".editable-field").focus((e) ->
        oldValue = jQuery(this).val()
        jQuery(this).keydown((e) ->
          if e.keyCode is 13
            e.preventDefault()
            jQuery(this).blur()
          if e.keyCode is 27
            e.preventDefault()
            scope.$apply(->
              scope.value = oldValue
            )
            jQuery(this).blur()
        )
      )
  }
)