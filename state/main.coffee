class StopWatchView

  constructor: (@app, el)->
    @$el = $(el)
    @$('.buttons button.action').click (event)=>
      @clickedButton(event)

  $: (options)->
    @$el.find(options)

  clickedButton: (event)->
    @app.clickedActionButton()

  getButton: (index)->
    @$(".buttons li:eq(#{index}) button")

  decoratePlayButton: (index)->
    @getButton(index).text('play')

  decorateStopButton: (index)->
    @getButton(index).text('stop')

  updateDisplay: ()->
    @$('.display').text(@app.now)


class StopWatch

  setup: (el)->
    @view = new StopWatchView(@, $(el))

    @statuses =
      stop : new StopStatus(@, @view)
      playing : new PlayingStatus(@, @view)

    @changeStatus @statuses.stop

  clickedActionButton: ()->
    @status.clickedActionButton()

  start: ()->
    @now = new Date()
    @changeStatus(@statuses.playing)

    @timer = setInterval ()=>
      @now = new Date()
      @view.updateDisplay()
    ,
      200

  stop: ()->
    clearInterval(@timer)
    @changeStatus(@statuses.stop)

  changeStatus: (next)->
    @status = next
    @status.onBeforeChangeStatus()

class StopStatus

  constructor: (@app, @view)->

  onBeforeChangeStatus: ()->
    @view.decoratePlayButton 0

  clickedActionButton: ()->
    @app.start()

class PlayingStatus

  constructor: (@app, @view)->

  onBeforeChangeStatus: ()->
    @view.decorateStopButton 0

  clickedActionButton: ()->
    @app.stop()


$ ()->
  stopWatch = new StopWatch()
  stopWatch.setup($('.stopwatch'))
