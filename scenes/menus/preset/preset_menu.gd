extends Control

var _name_edit: LineEdit
var _list: ItemList
var _status: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(box)

	_add_label(box, "Presets")

	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size = Vector2(420, 0)
	box.add_child(_status)

	_add_label(box, "Aktuelle Karteneinstellungen speichern")
	var save_row := HBoxContainer.new()
	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "Preset-Name"
	_name_edit.custom_minimum_size.x = 250
	save_row.add_child(_name_edit)
	var save_button := Button.new()
	save_button.text = "Speichern"
	save_button.pressed.connect(_on_save_pressed)
	save_row.add_child(save_button)
	box.add_child(save_row)

	_add_label(box, "Gespeicherte Presets")
	_list = ItemList.new()
	_list.custom_minimum_size = Vector2(300, 160)
	_list.item_selected.connect(func(index: int): _name_edit.text = _list.get_item_text(index))
	box.add_child(_list)

	var load_row := HBoxContainer.new()
	var load_button := Button.new()
	load_button.text = "Laden"
	load_button.pressed.connect(_on_load_pressed)
	load_row.add_child(load_button)
	var delete_button := Button.new()
	delete_button.text = "Löschen"
	delete_button.pressed.connect(_on_delete_pressed)
	load_row.add_child(delete_button)
	box.add_child(load_row)

	var back := Button.new()
	back.text = "Zurück"
	back.pressed.connect(func(): ScreenManager.switch_to(SceneRegistry.SceneKey.MAIN_MENU))
	box.add_child(back)

	_refresh_list()


func _add_label(parent: Node, text: String) -> void:
	var label := Label.new()
	label.text = text
	parent.add_child(label)


func _refresh_list() -> void:
	_list.clear()
	for preset_name in PresetStore.list_presets():
		_list.add_item(preset_name)


func _show(text: String, is_error := false) -> void:
	_status.text = text
	_status.add_theme_color_override("font_color", Color(1.0, 0.6, 0.3) if is_error else Color.LIGHT_GREEN)


func _on_save_pressed() -> void:
	var gen := MapManager.gen_settings
	if gen.seed_value == 0:
		_show("Speichern nicht möglich: Der Seed steht auf 0 (zufällig). Trage im Optionsmenü einen Seed ein oder nutze \"Zufällig würfeln\" und gehe mit \"Zurück\" ins Menü.", true)
		return
	var preset_name := _name_edit.text.strip_edges().validate_filename()
	if preset_name.is_empty():
		_show("Bitte einen Namen eingeben.", true)
		return

	var existed := PresetStore.list_presets().has(preset_name)
	var preset := MapPreset.new()
	preset.preset_name = preset_name
	preset.gen_settings = gen.duplicate(true)
	preset.sim_settings = SimulationManager.simulation_settings.duplicate(true)
	var err := PresetStore.save_preset(preset)
	if err != OK:
		_show("Speichern fehlgeschlagen (Fehler %d)." % err, true)
		return
	_show("Preset \"%s\" %s." % [preset_name, "überschrieben" if existed else "gespeichert"])
	_refresh_list()


func _on_load_pressed() -> void:
	var selected := _list.get_selected_items()
	if selected.is_empty():
		_show("Bitte ein Preset auswählen.", true)
		return
	var preset := PresetStore.load_preset(_list.get_item_text(selected[0]))
	if preset == null or preset.gen_settings == null or preset.sim_settings == null:
		_show("Das Preset konnte nicht geladen werden.", true)
		return

	MapManager.gen_settings = preset.gen_settings.duplicate(true)
	SimulationManager.simulation_settings = preset.sim_settings.duplicate(true)

	var text := "Preset \"%s\" geladen (Seed %d)." % [preset.preset_name, preset.gen_settings.seed_value]
	if preset.generator_version != MapPreset.GENERATOR_VERSION:
		text += " Achtung: Es wurde mit einer älteren Generator-Version gespeichert, die Karte kann abweichen."
	_show(text)


func _on_delete_pressed() -> void:
	var selected := _list.get_selected_items()
	if selected.is_empty():
		_show("Bitte ein Preset auswählen.", true)
		return
	var preset_name := _list.get_item_text(selected[0])
	PresetStore.delete_preset(preset_name)
	_show("Preset \"%s\" gelöscht." % preset_name)
	_refresh_list()
