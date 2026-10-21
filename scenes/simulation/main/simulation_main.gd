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
	
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var rng2 := RandomNumberGenerator.new()
	rng2.seed = 42
	
	var min_output : Array[float]
	var test1: float
	var max_output: Array[float]
	var material1 : MaterialData = ResourceLoader.load("res://resources/materials/earth.tres")
	
	for n in 10:
		print("Round ",n)
		test1 = MapGenerator.roll_hardness(material1,0.0,20.0,rng )
		print(test1)
		test1 = MapGenerator.roll_hardness(material1,0.0,20.0,rng2 )
		print(test1)
		
	for n in 1000:
		test1 = MapGenerator.roll_hardness(material1,0.0,20.0,rng )
		min_output.append(test1)
		test1 = MapGenerator.roll_hardness(material1,80.0,100.0,rng)
		max_output.append(test1)
	
	print("Min output was between: ", min_output.min(), "and", min_output.max())
	print("Max output was between: ", max_output.min(), "and", max_output.max())
	
	max_output.clear()
	min_output.clear()
	
	
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
