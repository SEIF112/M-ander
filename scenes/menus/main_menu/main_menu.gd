extends Control

var _parameterMenuScene: String = "res://scenes/menus/parameter_input/parameter_input.tscn"
var _optionMenuScene: String = "res://scenes/menus/options/options_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_simulation_pressed() -> void:
	ScreenManager.switch_to(_parameterMenuScene)


func _on_options_pressed() -> void:
	ScreenManager.switch_to(_optionMenuScene)
