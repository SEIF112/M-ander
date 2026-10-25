extends Control

const SINGLE_VALUE_INPUT := preload("res://scenes/components/single_output.tscn") 

var _settings: MapGenerationSettings
var _base_option: OptionButton
var _material_boxes := {}   # Enums.TileMaterial -> CheckBox
var _seed_box: SpinBox
var _inputs := {}           # String -> SingleValueInput


func _ready() -> void:
	print("optionen entered")
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_settings = MapManager.gen_settings

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)

	_add_label(list, "Karteneinstellungen")
	_build_base_material(list)
	_build_material_checks(list)
	_build_seed(list)
	_add_number(list, "width", "Breite (Tiles)", 5, 60, _settings.width, 1)
	_add_number(list, "height", "Höhe (Tiles)", 5, 60, _settings.height, 1)

	_add_label(list, "Startfluss")
	_add_number(list, "river_amplitude", "Mäanderstärke", 0, 8, _settings.river_amplitude, 0.5)
	_add_number(list, "river_wavelength", "Wellenlänge (Zeilen)", 6, 40, _settings.river_wavelength, 1)

	_add_label(list, "Bodenflecken")
	_add_number(list, "max_cluster_count", "Max. Flecken pro Material", 1, 8, _settings.max_cluster_count, 1)
	_add_number(list, "cluster_grow_chance", "Kompaktheit", 0.1, 1.0, _settings.cluster_grow_chance, 0.05)

	var buttons := HBoxContainer.new()
	list.add_child(buttons)
	var reset := Button.new()
	reset.text = "Standardwerte"
	reset.pressed.connect(_on_reset_pressed)
	buttons.add_child(reset)
	var back := Button.new()
	back.text = "Zurück"
	back.pressed.connect(_on_back_pressed)
	buttons.add_child(back)


# ---------- Aufbau ----------

func _add_label(parent: Node, text: String) -> void:
	var label := Label.new()
	label.text = text
	parent.add_child(label)


func _add_number(parent: Node, key: String, label: String, min_v: float, max_v: float,
		value: float, step: float) -> void:
	var input := SINGLE_VALUE_INPUT.instantiate()
	input.label_text = label
	input.min_value = min_v
	input.max_value = max_v
	input.current_value = value
	input.step = step
	parent.add_child(input)   # _ready() der Komponente läuft hier, danach sind die Werte gesetzt
	_inputs[key] = input


func _build_base_material(parent: Node) -> void:
	_add_label(parent, "Basismaterial")
	_base_option = OptionButton.new()
	for material in Enums.TileMaterial.values():
		_base_option.add_item(MaterialRegestry.get_material_data(material).display_name, material)
	_base_option.select(_base_option.get_item_index(_settings.base_material))
	_base_option.item_selected.connect(_on_base_changed)
	parent.add_child(_base_option)


func _build_material_checks(parent: Node) -> void:
	_add_label(parent, "Vorkommende Materialien")
	for material in Enums.TileMaterial.values():
		var box := CheckBox.new()
		box.text = MaterialRegestry.get_material_data(material).display_name
		box.button_pressed = _settings.enabled_materials.get(material, false)
		_material_boxes[material] = box
		parent.add_child(box)
	_update_checkboxes()


func _build_seed(parent: Node) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = "Seed (0 = bei jedem Start zufällig)"
	row.add_child(label)

	_seed_box = SpinBox.new()
	_seed_box.min_value = 0
	_seed_box.max_value = 999999999
	_seed_box.step = 1
	_seed_box.value = _settings.seed_value
	row.add_child(_seed_box)

	var random_button := Button.new()
	random_button.text = "Zufällig würfeln"
	random_button.pressed.connect(_on_random_seed_pressed)
	row.add_child(random_button)

	# Praktisch, um eine gelungene Karte zu wiederholen
	if MapManager.current_map != null:
		var last_button := Button.new()
		last_button.text = "Seed der letzten Karte"
		last_button.pressed.connect(func(): _seed_box.value = MapManager.current_map.seed)
		row.add_child(last_button)

	parent.add_child(row)


func _on_random_seed_pressed() -> void:
	# Ab 1, damit nie versehentlich die 0 ("zufällig bei jedem Start") herauskommt
	_seed_box.value = randi_range(1, 999999999)


# ---------- Verhalten ----------

func _on_base_changed(_index: int) -> void:
	_update_checkboxes()


## Das Basismaterial ist immer angehakt und nicht abwählbar.
func _update_checkboxes() -> void:
	var base := _base_option.get_selected_id()
	for material in _material_boxes:
		var box: CheckBox = _material_boxes[material]
		if material == base:
			box.button_pressed = true
			box.disabled = true
		else:
			box.disabled = false


func _apply() -> void:
	_settings.base_material = _base_option.get_selected_id() as Enums.TileMaterial
	for material in _material_boxes:
		_settings.enabled_materials[material] = _material_boxes[material].button_pressed
	_settings.enabled_materials[_settings.base_material] = true
	_settings.seed_value = int(_seed_box.value)
	_settings.width = int(_inputs["width"].current_value)
	_settings.height = int(_inputs["height"].current_value)
	_settings.river_amplitude = _inputs["river_amplitude"].current_value
	_settings.river_wavelength = _inputs["river_wavelength"].current_value
	_settings.max_cluster_count = int(_inputs["max_cluster_count"].current_value)
	_settings.cluster_grow_chance = _inputs["cluster_grow_chance"].current_value


func _on_back_pressed() -> void:
	_apply()
	ScreenManager.switch_to(SceneRegistry.SceneKey.MAIN_MENU)


func _on_reset_pressed() -> void:
	MapManager.gen_settings = MapGenerationSettings.new()
	# Szene neu laden, indem wir sie über den ScreenManager neu einhängen.
	# Nicht get_tree().reload_current_scene(): current_scene ist hier AppRoot!
	ScreenManager.switch_to(SceneRegistry.SceneKey.OPTIONS_MENU)
