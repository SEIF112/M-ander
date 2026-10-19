extends Control

var _parameterMenuScene: String = "res://scenes/menus/parameter_input/parameter_input.tscn"
var _optionMenuScene: String = "res://scenes/menus/options/options_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var map := MapData.new()
	map.generate_empty(5, 5)
	print("Anzahl Tiles: ", map.tiles.size())
	
	print("test ", HexMath.hex_corners(Vector2(0,0), 30))
	
	var neighbors := map.get_neighbors(2, 2)
	print("Nachbarn von (0,2): ", neighbors.size())
	for n in neighbors:
		print("  -> (", n.axial_q, ", ", n.axial_r, ")")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_simulation_pressed() -> void:
	ScreenManager.switch_to(_parameterMenuScene)


func _on_options_pressed() -> void:
	ScreenManager.switch_to(_optionMenuScene)
