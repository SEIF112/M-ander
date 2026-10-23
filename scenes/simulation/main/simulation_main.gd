extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("entered map scene")
	var gen_settings := MapGenerationSettings.new()
	var sim_settings := SimulationSettings.new()
	var map := MapData.new()
	
	map = MapGenerator.generate(gen_settings,sim_settings)
	
	var hex_map = SceneRegistry.get_scene(SceneRegistry.SceneKey.HEX_MAP).instantiate()
	add_child(hex_map)
	hex_map.position = Vector2(100, 100)
	hex_map.render_map(map)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
