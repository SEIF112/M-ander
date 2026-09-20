extends VBoxContainer

var min_value: float = 0.0
var max_value: float = 10.0

@export var current_value: float = 5.0

@onready var slider := $RiverSpeedSlider
@onready var spinbox := $RiverSpeed/RiverSpeedValue
func _ready() -> void:
	slider.min_value = min_value
	slider.max_value = max_value
	slider.value = current_value
	
	spinbox.min_value = min_value
	spinbox.max_value = max_value
	spinbox.value = current_value
	
	slider.connect("value_changed", _on_slider_changed)
	spinbox.connect("value_changed", _on_spinbox_changed)


func _on_slider_changed(value):
	current_value = value
	spinbox.value = current_value
	
func _on_spinbox_changed(value):
	current_value = value
	slider.value = current_value
