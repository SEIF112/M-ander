extends VBoxContainer

@export var min_value: float
@export var max_value: float

@export var current_value: float

@export var label_text: String

@onready var slider := $Slider
@onready var spinbox := $InputField/ValueBox
@onready var label := $InputField/Label

func _ready() -> void:
	slider.min_value = min_value
	slider.max_value = max_value
	slider.value = current_value
	
	spinbox.min_value = min_value
	spinbox.max_value = max_value
	spinbox.value = current_value
	
	label.text = label_text
	
	slider.value_changed.connect(_on_slider_changed)
	spinbox.value_changed.connect(_on_spinbox_changed)



func _on_slider_changed(value):
	current_value = value
	spinbox.value = current_value
	
func _on_spinbox_changed(value):
	current_value = value
	slider.value = current_value
