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
]).directive('imgCenter', () ->
  {
  scope: {imgCenter: '=', height: "=", width: "="}
  restrict: 'A'
  link: (scope, elm, attrs) ->
    scope.$watch('imgCenter', (newVal, oldVal) ->
      return if angular.isUndefined(newVal) and angular.equals(newVal, oldVal)
      image = new Image()
      image.src = scope.imgCenter if scope.imgCenter
      elm.empty()
      image.onload = ->
        width = this.width
        height = this.height
        elm.css({position: "relative"})
        jQuery(image).addClass(attrs.class)
        if width / height > 1
          jQuery(image).css(
            "position": "absolute"
            "height": "auto"
            "width": "#{elm.parent().width()}px"
            "margin-top": -height * elm.parent().width() / width / 2 + "px"
            "top": "50%"
            "left": "0"
          )
        else
          jQuery(image).css(
            "position": "absolute"
            "height": "#{elm.parent().height()}px"
            "width": "auto"
            "margin-left": -width * elm.parent().height() / height / 2 + "px"
            "left": "50%"
            "top": "0"
          )
        jQuery(image).appendTo(elm)
    , true)
  }
).directive('imgCenter2', () ->
  {
  restrict: 'A'
  link: (scope, elm) ->
    console.log("imgCenter directive: ", arguments)
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
).directive('processFiles', () ->
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
)