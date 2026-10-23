class_name MapGenerationSettings
extends Resource

@export var base_material: Enums.TileMaterial = Enums.TileMaterial.EARTH
@export var enabled_materials: Dictionary = {
	Enums.TileMaterial.SAND: true,
	Enums.TileMaterial.GRAVEL: true,
	Enums.TileMaterial.EARTH: true,
	Enums.TileMaterial.STONE: true,
}
@export var seed_value: int = 0   # 0 = zufälligen Seed wählen
@export var width: int = 15
@export var height: int = 15

@export_group("Cluster")
@export var max_cluster_count: int = (width * height) / 10 # TODO Formel finden, für gleichmäßige Tileanzahl abhängik von Mapgröße und enabled_materials
@export var cluster_min_share: float = 0.01   # Anteil der Kartenfläche
@export var cluster_max_share: float = 0.10
@export var cluster_grow_chance: float = 0.5  # hoch = kompakt, niedrig = verästelt

@export_group("Fluss")
@export var river_amplitude: float = 3.0      # in Tile-Breiten, 0 = gerade
@export var river_wavelength: float = 14.0    # in Zeilen pro Schwingung
