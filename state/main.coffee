class StopStatus

  constructor: (@app, @view)->

  onBeforeChangeStatus: ()->
    @view.decoratePlayButton 0
    @view.decorateDisabledLapButton 1

  clickedMainButton: ()->
    @app.start()

  clickedSubButton: ()->
    # nop

class PauseStatus

  constructor: (@app, @view)->

  onBeforeChangeStatus: ()->
    @view.decoratePlayButton 0
    @view.decorateResetButton 1

  clickedMainButton: ()->
    @app.start()

  clickedSubButton: ()->
    @app.reset()

class PlayingStatus

  constructor: (@app, @view)->

  onBeforeChangeStatus: ()->
    @view.decorateStopButton 0
    @view.decorateLapButton 1

  clickedMainButton: ()->
    @app.pause()

  clickedSubButton: ()->
    @app.lap()


class StopWatch

  constructor: ()->
    @counter = 0
    @lastLap = 0

  setup: (el)->
    @view = new StopWatchView(@, $(el))

    @statuses =
      stop : new StopStatus(@, @view)
      pause : new PauseStatus(@, @view)
      playing : new PlayingStatus(@, @view)

    @changeStatus @statuses.stop

  clickedMainButton: ()->
    @status.clickedMainButton()

  clickedSubButton: ()->
    @status.clickedSubButton()

  start: ()->
    @changeStatus(@statuses.playing)

    @timer = setInterval ()=>
      @counter++
      @view.updateDisplay()
    ,
      100

  pause: ()->
    clearInterval(@timer)
    @changeStatus(@statuses.pause)

  reset: ()->
    @counter = 0
    @view.reset()
    @changeStatus(@statuses.stop)

  lap: ()->
    lap = @counter - @lastLap
    @lastLap = @counter
    @view.addLap(lap)

  changeStatus: (next)->
    @status = next
    @status.onBeforeChangeStatus()


class StopWatchView

  constructor: (@app, el)->
    @$el = $(el)
    @$('.buttons button.main').click (event)=>
      @app.clickedMainButton()

    @$('.buttons button.sub').click (event)=>
      @app.clickedSubButton()

  $: (options)->
    @$el.find(options)

  getButton: (index)->
    @$(".buttons li:eq(#{index}) button")

  decoratePlayButton: (index)->
    @getButton(index).text('play').removeAttr('disabled')

  decorateStopButton: (index)->
    @getButton(index).text('stop').removeAttr('disabled')

  decorateResetButton: (index)->
    @getButton(index).text('reset').removeAttr('disabled')

  decorateLapButton: (index)->
    @getButton(index).text('lap').removeAttr('disabled')

  decorateDisabledLapButton: (index)->
    @getButton(index).text('lap').attr('disabled', true)

  updateDisplay: ()->
    @$('.display').text(@app.counter)

  addLap: (lap)->
    $("<li>#{lap}</li>").prependTo(@$('.laps'))

  clearLaps: ()->
    @$('.laps').empty()

  reset: ()->
    @updateDisplay()
    @clearLaps()

$ ()->
  stopWatch = new StopWatch()
  stopWatch.setup($('.stopwatch'))
