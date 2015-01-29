angular.module('app', ['angularFileUpload', 'ng-sortable']).config([
  '$interpolateProvider', ($interpolateProvider) ->
    $interpolateProvider.startSymbol('[[')
    $interpolateProvider.endSymbol(']]')
]).controller('CreativesController', ['$scope', '$upload', ($scope, $upload) ->
  $scope.images = []
  $scope.headers = [
    'super bla-bla-bla header',
    'you can frop here a text file with ";" as separator',
    'Or you can Drag here selected column from excel'
  ]
  $scope.texts = [
    'A am a bla-bla-bla text',
    'you can frop here a text file with ";" as separator',
    'Or you can Drag here selected column from excel'
  ]
  $scope.imagesSortable = {
    group: {name: 'imagesSortable', pull: 'clone', put: true}
    ghostClass: "creatives_image-drag-ghost"
    animation: 150
  }
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
  $scope.imagesSortableTarget = {
    group: {name: 'imagesSortableTarget', put: ['imagesSortable'], pull: false}
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
  $scope.resImages = []
  $scope.resHeadlines = []
  $scope.resTexts = []
  $scope.files = []
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
  $scope.$watch('resImages', (newVal, oldVal) ->
    return if angular.equals(newVal, oldVal)
    console.log("New resTexts: ", newVal)
    $scope.constructed.img = newVal.splice(-1)[0]
    $scope.resImages = [$scope.constructed.img] if $scope.constructed.img
  , true)
  $scope.$watch('constructed', (newVal, oldVal) ->
    return if angular.equals(newVal, oldVal)
    console.log("New resconstructed: ", newVal)
  , true)
  $scope.$watch('files', (newVal, oldVal) ->
    return if angular.equals(newVal, oldVal)
    $scope.$broadcast("processFiles", newVal)
    console.log("New files: ", newVal)
  , true)
  $scope.$watch('images', (newVal, oldVal) ->
    return if angular.equals(newVal, oldVal)
    console.log("New images urls: ", newVal)
  , true)
  $scope.fileDropped = ($files, $event, $rejectedFiles) ->
    console.log("File dropped: ", arguments)
  $scope.activeTab = "images"
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
            "width": "#{scope.width}px"
            "margin-top": -height * scope.width / width / 2 + "px"
            "top": "50%"
            "left": "0"
          )
        else
          jQuery(image).css(
            "position": "absolute"
            "height": "#{scope.height}px"
            "width": "auto"
            "margin-left": -width * scope.height / height / 2 + "px"
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
            scope[scope.activeTab].push(e.target.result)
          reader.readAsDataURL(file)
        if file.type.match(textType)
          reader.onload = (e) ->
            text = e.target.result
            scope[scope.activeTab] = text.split(";")
          reader.readAsText(file)
      )
    )
    elm[0].ondrop = (e) ->
      console.log("On Drop: ", e)
      textData = event.dataTransfer.getData ("Text")
      scope[scope.activeTab] = textData.split("\n") if textData
  }
).directive('stringAdd', () ->
  {
  restrict: 'A'
  link: (scope, elm, attrs) ->
    scope.keyPress = (name, string, e) ->
      if e.keyCode is 13
        scope[name.slice(0, -1)] = undefined
        scope[name].push(string)
    scope.onBlur = (item, e) ->
      return
  }
)