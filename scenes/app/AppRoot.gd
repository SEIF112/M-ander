extends Node

const _mainMenuScene: String ="res://scenes/menus/main_menu/main_menu.tscn"

func _ready () -> void:
	ScreenManager.register_container($ScreenContainer)
	ScreenManager.switch_to(_mainMenuScene)
