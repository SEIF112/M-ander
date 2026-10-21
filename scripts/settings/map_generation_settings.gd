class_name MapGenerationSettings
extends Resource

@export var base_material: Enums.TileMaterial = Enums.TileMaterial.EARTH
@export var enabled_materials: Dictionary  # Enums.Material -> bool
@export var seed_value: int
@export var width: int = 20
@export var height: int = 20
