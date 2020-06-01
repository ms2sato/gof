class StopWatch{
  setup(el) {
    this.view = new StopWatchView(this, $(el));
    this.statuses = {
      stop: new StopStatus(this, this.view),
      pause: new PauseStatus(this, this.view),
      running: new RunningStatus(this, this.view)
    }
    this.reset();
  }

  clickedMainButton() {
    this.status.clickedMainButton();
  }

  clickedSubButton() {
    this.status.clickedSubButton();
  }

  run() {
    var _this = this;
    this.changeStatus(this.statuses.running);
    this.timer = setInterval(function () {
      _this.counter++;
      _this.view.updateDisplay();
    }, 100);
  }

  pause() {
    clearInterval(this.timer);
    this.changeStatus(this.statuses.pause);
  }

  reset() {
    this.counter = 0;
    this.lastLap = 0;
    this.view.reset();
    this.changeStatus(this.statuses.stop);
  }

  lap() {
    var lap;
    lap = this.counter - this.lastLap;
    this.lastLap = this.counter;
    this.view.addLap(lap);
  }

  changeStatus(next) {
    this.status = next;
    this.status.onBeforeChangeStatus();
  }
}

class StopStatus {
  constructor(app, view) {
    this.app = app;
    this.view = view;
  }

  onBeforeChangeStatus() {
    this.view.updateDisplay();
    this.view.decorateRunButton('main');
    this.view.decorateDisabledLapButton('sub');
  }

  clickedMainButton() {
    this.app.run();
  }

  clickedSubButton() { };
}

class PauseStatus {
  constructor(app, view) {
    this.app = app;
    this.view = view;
  }

  onBeforeChangeStatus() {
    this.view.decorateRunButton('main');
    this.view.decorateResetButton('sub');
  }

  clickedMainButton() {
    this.app.run();
  }

  clickedSubButton() {
    this.app.reset();
  }
}

class RunningStatus {
  constructor(app, view) {
    this.app = app;
    this.view = view;
  }

  onBeforeChangeStatus() {
    this.view.decorateStopButton('main');
    this.view.decorateLapButton('sub');
  }

  clickedMainButton() {
    this.app.pause();
  }

  clickedSubButton() {
    this.app.lap();
  }
}

class StopWatchView {
  constructor(app, el) {
    var _this = this;
    this.app = app;
    this.$el = $(el);
    this.$('.buttons button.main').click(function (event) {
      _this.app.clickedMainButton();
    });
    this.$('.buttons button.sub').click(function (event) {
      _this.app.clickedSubButton();
    });
  }

  $(options) {
    return this.$el.find(options);
  }

  getButton(name) {
    return this.$(".buttons button." + name);
  }

  decorateRunButton(name) {
    this.getButton(name).text('run').removeAttr('disabled');
  }

  decorateStopButton(name) {
    this.getButton(name).text('stop').removeAttr('disabled');
  }

  decorateResetButton(name) {
    this.getButton(name).text('reset').removeAttr('disabled');
  }

  decorateLapButton(name) {
    this.getButton(name).text('lap').removeAttr('disabled');
  }

  decorateDisabledLapButton(name) {
    this.getButton(name).text('lap').attr('disabled', true);
  }

  updateDisplay() {
    this.$('.display').text(this.app.counter);
  }

  addLap(lap) {
    $("<li>" + lap + "</li>").prependTo(this.$('.laps'));
  }

  clearLaps() {
    this.$('.laps').empty();
  }

  reset() {
    this.updateDisplay();
    this.clearLaps();
  }
}

$(function () {
  var stopWatch;
  stopWatch = new StopWatch();
  stopWatch.setup($('.stopwatch'));
});
