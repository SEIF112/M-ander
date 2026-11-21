extends TestBase
class_name TestTickClock

func _init():
	_name = "Tick clock"

func run() -> void:
	var clock := TickClock.new()
	assert_equal(clock.advance(1.0, 6.0, 1.0, 100), 6, "1x: 6 ticks per second")
	assert_equal(clock.advance(1.0, 6.0, 16.0, 200), 96, "16x: 96 ticks per second")

	clock = TickClock.new()
	var total := clock.advance(0.25, 6.0, 1.0, 100) + clock.advance(0.25, 6.0, 1.0, 100)
	assert_equal(total, 3, "Fractions of a tick are carried over, none are lost")

	clock = TickClock.new()
	assert_equal(clock.advance(10.0, 6.0, 1.0, 10), 10, "Ticks per frame are capped")
	assert_equal(clock.advance(0.0, 6.0, 1.0, 10), 0, "Surplus above the cap is dropped, no catch-up loop")
	assert_equal(clock.advance(0.0, 6.0, 1.0, 10), 0, "Nothing happens without elapsed time")

	var tuning := SimulationTuning.new()
	var seconds_per_year := float(tuning.ticks_per_year) / tuning.ticks_per_second
	assert_equal(seconds_per_year >= 50.0 and seconds_per_year <= 70.0, true, "One year takes about one minute at 1x")
	assert_equal(seconds_per_year / 16.0 < 5.0, true, "One year takes under 5 seconds at 16x")
