class_name SimulationTuning
extends Resource

@export_group("Zeit")
@export var ticks_per_year: int = 364
@export var ticks_per_second: float = 6.0   # bei 1x
@export var max_ticks_per_frame: int = 10

@export_group("Fluss")
@export var river_depth: float = 1.0        # bank_balance eines frischen Wassertiles
@export var k_ref: float = 1.0              # Krümmung in Tile-Breiten, ab der der Effekt voll wirkt
@export var jitter: float = 0.2             # Streuung der Erosion (±)
@export var erosion_scale: float = 400.0
@export var deposition_rate: float = 0.002
@export var dead_silt_rate: float = 0.01    # Verlandung pro Tick bei RIVER_DEAD

@export_group("Klima")
@export var groundwater_range := Vector2(-100.0, 0.0)  # an den Slider im Formular anpassen
@export var groundwater_softening: float = 0.3
@export var groundwater_vegetation_min: float = 0.5   # Potenzial bei trockenstem Grundwasser
@export var vegetation_response: float = 0.05         # Anteil pro Tick, mit dem die Vegetation ihr Ziel erreicht

@export_group("Überflutung")
@export var flood_water_factor: float = 3.0
@export var flood_duration_ticks: int = 28  # 4 Wochen
@export var flood_radius: int = 2
@export var flood_chance_per_year: float = 0.5
