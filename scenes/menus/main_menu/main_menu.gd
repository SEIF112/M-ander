extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_simulation_pressed() -> void:
	ScreenManager.switch_to(SceneRegistry.SceneKey.PARAMETER_MENU)


func _on_options_pressed() -> void:
	ScreenManager.switch_to(SceneRegistry.SceneKey.OPTIONS_MENU)


func _on_presets_pressed() -> void:
	ScreenManager.switch_to(SceneRegistry.SceneKey.PRESET_MENU)
