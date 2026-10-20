extends Node

func _ready () -> void:
	ScreenManager.register_container($ScreenContainer)
	ScreenManager.switch_to(SceneRegistry.SceneKey.MAIN_MENU)
