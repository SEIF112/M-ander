extends Node

enum SceneKey {
	APP_ROOT,
	PARAMETER_MENU,
	OPTIONS_MENU,
	SIMULATION_MAIN,
	HEX_MAP,
	MAIN_MENU,
	PRESET_MENU
}

var scenes : Dictionary = {
	SceneKey.APP_ROOT: "res://scenes/app/AppRoot.tscn",
	SceneKey.PARAMETER_MENU: "res://scenes/menus/parameter_input/parameter_input.tscn",
	SceneKey.OPTIONS_MENU: "res://scenes/menus/options/options_menu.tscn",
	SceneKey.SIMULATION_MAIN: "res://scenes/simulation/main/simulation_main.tscn",
	SceneKey.HEX_MAP: "res://scenes/simulation/map/hex_map.tscn",
	SceneKey.MAIN_MENU: "res://scenes/menus/main_menu/main_menu.tscn",
	SceneKey.PRESET_MENU: "res://scenes/menus/preset/preset_menu.tscn"
}

func get_scene(key: SceneKey) -> PackedScene:
	if !scenes.has(key):
		var available := SceneKey.keys()
		var key_name := str(key) 
		var msg := "SceneRegistry ERROR: Unknown scene key '%s'. Available keys: %s" % [key_name, available]
		push_error(msg)
		return null

	return load(scenes[key])
