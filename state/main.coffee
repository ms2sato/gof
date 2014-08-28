class StopWatch

  setup: (el)->
    @view = new StopWatchView(@, $(el))

    @statuses =
      stop: new StopStatus(@, @view)
      pause: new PauseStatus(@, @view)
      running: new RunningStatus(@, @view)

    @reset()

  clickedMainButton: ->
    @status.clickedMainButton()

  clickedSubButton: ->
    @status.clickedSubButton()

  run: ->
    @changeStatus(@statuses.running)

    @timer = setInterval ()=>
      @counter++
      @view.updateDisplay()
    ,
      100

  pause: ->
    clearInterval(@timer)
    @changeStatus(@statuses.pause)

  reset: ->
    @counter = 0
    @lastLap = 0
    @view.reset()
    @changeStatus(@statuses.stop)

  lap: ->
    lap = @counter - @lastLap
    @lastLap = @counter
    @view.addLap(lap)

  changeStatus: (next)->
    @status = next
    @status.onBeforeChangeStatus()

class StopStatus

  constructor: (@app, @view)->

  onBeforeChangeStatus: ->
    @view.updateDisplay()
    @view.decorateRunButton 'main'
    @view.decorateDisabledLapButton 'sub'

  clickedMainButton: ->
    @app.run()

  clickedSubButton: ->
    # nop

class PauseStatus

  constructor: (@app, @view)->

  onBeforeChangeStatus: ->
    @view.decorateRunButton 'main'
    @view.decorateResetButton 'sub'

  clickedMainButton: ->
    @app.run()

  clickedSubButton: ->
    @app.reset()

class RunningStatus

  constructor: (@app, @view)->

  onBeforeChangeStatus: ->
    @view.decorateStopButton 'main'
    @view.decorateLapButton 'sub'

  clickedMainButton: ->
    @app.pause()

  clickedSubButton: ->
    @app.lap()


class StopWatchView

  constructor: (@app, el)->
    @$el = $(el)
    @$('.buttons button.main').click (event)=>
      @app.clickedMainButton()

    @$('.buttons button.sub').click (event)=>
      @app.clickedSubButton()

  $: (options)->
    @$el.find(options)

  getButton: (name)->
    @$(".buttons button.#{name}")

  decorateRunButton: (name)->
    @getButton(name).text('run').removeAttr('disabled')

  decorateStopButton: (name)->
    @getButton(name).text('stop').removeAttr('disabled')

  decorateResetButton: (name)->
    @getButton(name).text('reset').removeAttr('disabled')

  decorateLapButton: (name)->
    @getButton(name).text('lap').removeAttr('disabled')

  decorateDisabledLapButton: (name)->
    @getButton(name).text('lap').attr('disabled', true)

  updateDisplay: ->
    @$('.display').text(@app.counter)

  addLap: (lap)->
    $("<li>#{lap}</li>").prependTo(@$('.laps'))

  clearLaps: ->
    @$('.laps').empty()

  reset: ->
    @updateDisplay()
    @clearLaps()

$ ()->
  stopWatch = new StopWatch()
  stopWatch.setup($('.stopwatch'))
