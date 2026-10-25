extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var map := MapManager.create_map(SimulationManager.simulation_settings)
	var hex_map := SceneRegistry.get_scene(SceneRegistry.SceneKey.HEX_MAP).instantiate()
	add_child(hex_map)
	hex_map.render_map(map)

	# linke 70 % des Fensters für die Karte, der Rest ist für die Buttons aus Frame 2
	var screen := get_viewport_rect().size
	hex_map.fit_to_rect(Rect2(Vector2(20, 20), screen * Vector2(0.7, 1.0) - Vector2(40, 40)))
	print("Seed dieser Karte: ", map.seed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_menu_pressed() -> void:
	ScreenManager.switch_to(SceneRegistry.SceneKey.MAIN_MENU)
