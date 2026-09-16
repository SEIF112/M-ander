extends Node

var _container : Node = null
var _current_screen : Node = null

func register_container(container : Node) -> void:
	_container = container


func switch_to(scene_path : String) -> void:
	if _current_screen != null:
		_current_screen.queue_free()
		
	var new_screen: Node = load(scene_path).instantiate()
	_container.add_child(new_screen)
	_current_screen = new_screen
