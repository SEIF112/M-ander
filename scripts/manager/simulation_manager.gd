extends Node

signal tick_advanced(tick: int)
signal state_changed(running: bool)

const MIN_SPEED := 1.0
const MAX_SPEED := 16.0

var simulation_settings: SimulationSettings = SimulationSettings.new()
var simulation_tuning: SimulationTuning = SimulationTuning.new()

var changer: MapChanger
var running := false
var speed := 1.0
var resume_pending := false   # kommt aus der Auswertung zurück in die laufende Simulation
var run_finished := false     # "Simulation beenden" wurde gedrückt
var _clock := TickClock.new()


func start(map: MapData) -> void:
	changer = MapChanger.new(map, simulation_settings, simulation_tuning)
	_clock.reset()
	resume_pending = false
	run_finished = false
	set_running(true)


func has_run() -> bool:
	return changer != null


func finish_run() -> void:
	set_running(false)
	run_finished = true


func discard_run() -> void:
	running = false
	changer = null
	resume_pending = false
	run_finished = false


func set_running(value: bool) -> void:
	if changer == null:
		return
	running = value
	state_changed.emit(running)


func set_speed(value: float) -> void:
	speed = clampf(value, MIN_SPEED, MAX_SPEED)


func step_once() -> void:
	if changer == null:
		return
	changer.step()
	tick_advanced.emit(changer.tick)


func elapsed_years() -> float:
	if changer == null:
		return 0.0
	return float(changer.tick) / simulation_tuning.ticks_per_year


func _process(delta: float) -> void:
	if not running or changer == null:
		return
	var ticks := _clock.advance(delta, simulation_tuning.ticks_per_second, speed, simulation_tuning.max_ticks_per_frame)
	for i in ticks:
		changer.step()
	if ticks > 0:
		tick_advanced.emit(changer.tick)
