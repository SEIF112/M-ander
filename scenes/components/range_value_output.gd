extends Control

@export var min_value: float
@export var max_value: float

@export var min_output: float 
@export var max_output: float 

@export var label_text: String

@onready var slider:= $VBoxContainer/HRangeSlider
@onready var label:= $VBoxContainer/HBoxContainer/Label
@onready var max_value_spinbox:= $VBoxContainer/HBoxContainer/MaxValue
@onready var min_value_spinbox:= $VBoxContainer/HBoxContainer/MinValue


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slider.minimum = min_value
	slider.maximum = max_value
	slider.range_begin = min_output
	slider.range_end = max_output
	slider.range_min_size = 1
	
	min_value_spinbox.min_value = min_value
	min_value_spinbox.max_value = max_value
	min_value_spinbox.value = min_output
	
	max_value_spinbox.min_value = min_value
	max_value_spinbox.max_value = max_value
	max_value_spinbox.value = max_output
	
	label.text = label_text
	
	min_value_spinbox.value_changed.connect(_on_min_spinbox_changed)
	max_value_spinbox.value_changed.connect(_on_max_spinbox_changed)
	slider.changed.connect(_on_slider_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _on_slider_changed(min_range: float, max_range: float):
	min_output = min_range
	max_output = max_range
	
	max_value_spinbox.value = max_range
	min_value_spinbox.value = min_range
	

func _on_min_spinbox_changed(value):
	min_output = value
	slider.range_begin = value

func _on_max_spinbox_changed(value):
	max_output = value
	slider.range_end = value
