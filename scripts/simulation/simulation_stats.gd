class_name SimulationStats
extends RefCounted

const SAMPLE_INTERVAL := 7   # alle 7 Ticks (eine Woche) ein Messpunkt

var start_water := {}        # Vector2i -> true, der Fluss zu Beginn
var ever_wet := {}           # Vector2i -> true, alles, was je Wasser war (der Mäandergürtel)
var water_now := 0
var eroded_events := 0       # kumuliert: jeder Wechsel Land -> Wasser zählt
var silted_events := 0

var sample_ticks := PackedInt32Array()
var sample_lost := PackedInt32Array()
var sample_water := PackedInt32Array()

var _start_min_x := 0.0
var _start_max_x := 0.0
var _min_x := 0.0
var _max_x := 0.0


func _init(map: MapData) -> void:
	var first := true
	for tile: Tile in map.tiles.values():
		if tile.water_state != Enums.WaterState.RIVER_ACTIVE:
			continue
		var key := Vector2i(tile.axial_q, tile.axial_r)
		start_water[key] = true
		ever_wet[key] = true
		var x := RiverGeometry.tile_x(tile)
		if first:
			_start_min_x = x
			_start_max_x = x
			first = false
		else:
			_start_min_x = minf(_start_min_x, x)
			_start_max_x = maxf(_start_max_x, x)
	water_now = start_water.size()
	_min_x = _start_min_x
	_max_x = _start_max_x
	record_sample(0)


func on_became_water(tile: Tile) -> void:
	eroded_events += 1
	water_now += 1
	ever_wet[Vector2i(tile.axial_q, tile.axial_r)] = true
	var x := RiverGeometry.tile_x(tile)
	_min_x = minf(_min_x, x)
	_max_x = maxf(_max_x, x)


func on_became_land(_tile: Tile) -> void:
	silted_events += 1
	water_now -= 1


func on_tick(tick: int) -> void:
	if tick % SAMPLE_INTERVAL == 0:
		record_sample(tick)


func record_sample(tick: int) -> void:
	sample_ticks.append(tick)
	sample_lost.append(lost_area())
	sample_water.append(water_now)


## Mäandergürtel ohne den Startfluss: Land, das der Fluss je erreicht hat
func lost_area() -> int:
	return ever_wet.size() - start_water.size()


## Ausbreitung über den Startfluss hinaus, in Tile-Breiten
func spread_left() -> float:
	return maxf(_start_min_x - _min_x, 0.0)


func spread_right() -> float:
	return maxf(_max_x - _start_max_x, 0.0)
