extends Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var sim := SimulationManager

	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 16)
	add_child(row)

	var graph := LineGraph.new()
	graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	graph.size_flags_stretch_ratio = 2.0
	row.add_child(graph)

	var side := VBoxContainer.new()
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(side)

	var info := Label.new()
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(info)

	var to_menu := Button.new()
	to_menu.text = "Zurück zum Hauptmenü"
	to_menu.pressed.connect(_on_menu_pressed)
	side.add_child(to_menu)

	if sim.has_run() and not sim.run_finished:
		var to_sim := Button.new()
		to_sim.text = "Zurück zur Simulation"
		to_sim.pressed.connect(_on_back_to_simulation_pressed)
		side.add_child(to_sim)

	if not sim.has_run():
		info.text = "Keine Simulation vorhanden."
		return
	_fill(graph, info)


func _fill(graph: LineGraph, info: Label) -> void:
	var sim := SimulationManager
	var changer := sim.changer
	var stats := changer.stats
	var per_year := float(sim.simulation_tuning.ticks_per_year)

	var xs := PackedFloat32Array()
	var ys := PackedFloat32Array()
	for i in stats.sample_ticks.size():
		xs.append(stats.sample_ticks[i] / per_year)
		ys.append(stats.sample_lost[i])
	# aktuellen Stand als letzten Punkt anhängen, ohne die Statistik zu verändern
	var last := stats.sample_ticks.size() - 1
	if stats.sample_ticks[last] != changer.tick:
		xs.append(changer.tick / per_year)
		ys.append(stats.lost_area())
	graph.set_data(xs, ys)

	info.text = "Auswertung\n\nGesamtzeit: %.1f Jahre\nErodierte Fläche: %d Tiles\nVerlorene Fläche: %d Tiles\nAusbreitung links: %.1f Tiles\nAusbreitung rechts: %.1f Tiles\nWasser: %d Tiles (Start: %d)\nSeed: %d\n" % [
		sim.elapsed_years(), stats.eroded_events, stats.lost_area(),
		stats.spread_left(), stats.spread_right(),
		stats.water_now, stats.start_water.size(), changer.map.seed]


func _on_menu_pressed() -> void:
	SimulationManager.discard_run()
	ScreenManager.switch_to(SceneRegistry.SceneKey.MAIN_MENU)


func _on_back_to_simulation_pressed() -> void:
	SimulationManager.resume_pending = true
	ScreenManager.switch_to(SceneRegistry.SceneKey.SIMULATION_MAIN)
