extends TestBase
class_name TestSimulationStats

func _init():
	_name = "Simulation stats"

func _near(a: float, b: float) -> bool:
	return absf(a - b) < 0.0001

func run() -> void:
	var map := MapData.new()
	map.generate_empty(8, 6)
	for r in 6:
		map.get_tile(3, r).water_state = Enums.WaterState.RIVER_ACTIVE
	# x-Positionen des Startflusses: 3.0 bis 5.5

	var stats := SimulationStats.new(map)
	assert_equal(stats.water_now, 6, "Start water is counted")
	assert_equal(stats.lost_area(), 0, "No lost area at the start")
	assert_equal(_near(stats.spread_left(), 0.0) and _near(stats.spread_right(), 0.0), true, "No spread at the start")
	assert_equal(stats.sample_ticks.size(), 1, "Tick 0 is recorded as the first sample")

	stats.on_became_water(map.get_tile(5, 2))   # x = 6.0, rechts vom Startfluss
	assert_equal(stats.lost_area(), 1, "New water outside the start river is lost area")
	assert_equal(_near(stats.spread_right(), 0.5), true, "Spread to the right is measured in tile widths")
	assert_equal(_near(stats.spread_left(), 0.0), true, "No spread to the left yet")

	stats.on_became_water(map.get_tile(1, 2))   # x = 2.0, links vom Startfluss
	assert_equal(_near(stats.spread_left(), 1.0), true, "Spread to the left is measured")

	stats.on_became_land(map.get_tile(3, 2))
	stats.on_became_water(map.get_tile(3, 2))
	assert_equal(stats.lost_area(), 2, "A start tile that silts up and erodes again is not lost area")
	assert_equal(stats.eroded_events, 3, "Every land-to-water change counts as erosion")
	assert_equal(stats.water_now, 8, "Water counter follows the changes")

	stats.on_tick(3)
	assert_equal(stats.sample_ticks.size(), 1, "No sample between measuring points")
	stats.on_tick(SimulationStats.SAMPLE_INTERVAL)
	assert_equal(stats.sample_ticks.size(), 2, "A sample is recorded at every interval")
	assert_equal(stats.sample_lost[1], 2, "Sample stores the current lost area")
