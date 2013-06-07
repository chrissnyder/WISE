{Controller} = require 'spine'

class ImageViewer extends Controller
  events:
    'change input[type="range"]' : 'scrub'
    'mousedown input[type="range"]' : 'scrub'
    'click button.play' : 'play'
    'click button.stop' : 'stop'

  wavelengths: [
    'dssdss2blue',
    'dssdss2red',
    'dssdss2ir',
    'wise4',
    'wise3',
    'wise2',
    'wise1',
    '2massj',
    '2massh',
    '2massk'
  ]

  constructor: ->
    super

  preloadImages: (subject, cb) =>
    @images = []
    loadedImages = 0

    inc = =>
      loadedImages = loadedImages + 1
      if (loadedImages is subject.metadata.files.length)
        cb()

    for src in @subjectWavelengths(subject) 
      img = new Image
      img.src = src
      img.onload = inc
      @images.push img

  subjectWavelengths: (subject) =>
    srcs = []
    for wavelength in @wavelengths when subject.location[wavelength]?
      srcs.push subject.location[wavelength] 
    srcs

  drawImage: (img) =>
    canvas = document.getElementById('viewer')
    ctx = canvas.getContext('2d')
    ctx.clearRect(0, 0, canvas.width, canvas.height)
    ctx.drawImage(img, 0, 0, canvas.width, canvas.height)

  animate: =>
    if @animateImages
      imageNo = parseInt(@$('input[type="range"]').val())
      if imageNo + 1 >= @images.length 
        imageNo = 0 
      else 
        imageNo = imageNo + 1
      @drawImage(@images[imageNo])
      @$('input[type="range"]').val(imageNo)
      setTimeout(@animate, 500)

  stop: =>
    $('button.stop').text('play').removeClass('stop').addClass('play')
    @animateImages = false

  play: (e) =>
    @$('button.play').text('stop').removeClass('play').addClass('stop')
    @animateImages = true
    @animate()

  scrub: (e) =>
    if (e.type is 'mousedown') 
      @$('input[type="range"]').on('mousemove', @scrub)
        .on('mouseup', -> @.off('mousemove mouseup'))
    imageNo = $('input[type="range"]').val()
    @drawImage(@images[imageNo])

  activateControls: =>
    @$('button.play').removeAttr 'disabled'
    @$('input[type="range"]').removeAttr 'disabled'

  deactivateControls: =>
    @$('button.play').attr 'disabled', 'disabled'
    @$('input[type="range"]').attr 'disabled', 'disabled'

  setupSubject: (subject) =>
    return if !subject
    @deactivateControls()
    @$('input[type="range"]').val 0
    @preloadImages(subject, =>
      @$('.loading').hide()
      @activateControls()
      @drawImage(@images[0])) if subject? 

module.exports = ImageViewer
