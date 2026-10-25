class_name PresetStore
extends RefCounted

const DIR := "user://presets"


static func _path(preset_name: String) -> String:
	return "%s/%s.tres" % [DIR, preset_name.validate_filename()]


static func save_preset(preset: MapPreset) -> Error:
	DirAccess.make_dir_recursive_absolute(DIR)
	return ResourceSaver.save(preset, _path(preset.preset_name))


static func load_preset(preset_name: String) -> MapPreset:
	var path := _path(preset_name)
	if not FileAccess.file_exists(path):
		return null
	# CACHE_MODE_IGNORE: sonst liefert Godot evtl. ein veraltetes, im Speicher gehaltenes Objekt
	return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as MapPreset


static func list_presets() -> PackedStringArray:
	var names := PackedStringArray()
	if not DirAccess.dir_exists_absolute(DIR):
		return names
	for file in DirAccess.get_files_at(DIR):
		if file.ends_with(".tres"):
			names.append(file.get_basename())
	return names


static func delete_preset(preset_name: String) -> void:
	DirAccess.remove_absolute(_path(preset_name))
