extends Node2D

func _ready() -> void:
	var sim := SimulationManager
	var resume := sim.resume_pending and sim.has_run()
	sim.resume_pending = false

	var map: MapData
	if resume:
		map = sim.changer.map
	else:
		map = MapManager.create_map(sim.simulation_settings, sim.simulation_tuning)

	var hex_map := SceneRegistry.get_scene(SceneRegistry.SceneKey.HEX_MAP).instantiate()
	add_child(hex_map)
	hex_map.render_map(map)
	var screen := get_viewport_rect().size
	hex_map.fit_to_rect(Rect2(Vector2(20, 20), screen * Vector2(0.7, 1.0) - Vector2(40, 40)))

	%PauseButton.pressed.connect(func(): sim.set_running(not sim.running))
	%SpeedSlider.value_changed.connect(_on_speed_changed)
	%EvaluationButton.pressed.connect(_on_evaluation_pressed)
	%EndButton.pressed.connect(_on_end_pressed)
	%MainMenuButton.pressed.connect(_on_main_menu_pressed)
	sim.tick_advanced.connect(_on_tick_advanced)
	sim.state_changed.connect(_on_state_changed)

	%SpeedSlider.value = sim.speed
	_on_speed_changed(%SpeedSlider.value)
	if resume:
		sim.set_running(true)
	else:
		sim.start(map)
	_on_tick_advanced(0)


func _exit_tree() -> void:
	var sim := SimulationManager
	if sim.tick_advanced.is_connected(_on_tick_advanced):
		sim.tick_advanced.disconnect(_on_tick_advanced)
	if sim.state_changed.is_connected(_on_state_changed):
		sim.state_changed.disconnect(_on_state_changed)
	sim.set_running(false)


func _on_tick_advanced(_tick: int) -> void:
	var sim := SimulationManager
	if sim.changer == null:
		return
	%YearLabel.text = "Jahr %.1f  |  Wasser: %d" % [sim.elapsed_years(), sim.changer.stats.water_now]


func _on_state_changed(running: bool) -> void:
	%PauseButton.text = "Pause" if running else "Weiter"


func _on_speed_changed(value: float) -> void:
	SimulationManager.set_speed(value)
	%SpeedLabel.text = "%dx" % int(value)


func _on_evaluation_pressed() -> void:
	SimulationManager.resume_pending = true
	ScreenManager.switch_to(SceneRegistry.SceneKey.EVALUATION)


func _on_end_pressed() -> void:
	SimulationManager.finish_run()
	ScreenManager.switch_to(SceneRegistry.SceneKey.EVALUATION)


func _on_main_menu_pressed() -> void:
	SimulationManager.discard_run()
	ScreenManager.switch_to(SceneRegistry.SceneKey.MAIN_MENU)
