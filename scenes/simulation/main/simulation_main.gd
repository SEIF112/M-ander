extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("entered map scene")
	var map := MapData.new()
	map.generate_empty(13,11)
	  # 2. HexMap-Szene laden (über Enum)
	var hex_map_scene: PackedScene = SceneRegistry.get_scene(SceneRegistry.SceneKey.HEX_MAP)
	if hex_map_scene == null:
		push_error("Could not load hex_map scene")
		return

	# 3. Instanz erzeugen
	var hex_map := hex_map_scene.instantiate()

	# 4. Position setzen (Offset, damit es nicht abgeschnitten ist)
	hex_map.position = Vector2(100, 100)

	# 5. In Szene einhängen
	add_child(hex_map)

	# 6. Karte rendern
	hex_map.render_map(map)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
