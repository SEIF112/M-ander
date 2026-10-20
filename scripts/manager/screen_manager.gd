extends Node

var _container : Node = null
var _current_screen : Node = null

func register_container(container : Node) -> void:
	_container = container

func switch_to(key: SceneRegistry.SceneKey) -> void:
	if _current_screen != null:
		_current_screen.queue_free()

	var packed_scene: PackedScene = SceneRegistry.get_scene(key)
	if packed_scene == null:
		return

	var new_screen := packed_scene.instantiate()
	_container.add_child(new_screen)
	_current_screen = new_screen
