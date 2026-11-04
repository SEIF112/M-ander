class_name MaterialData
extends Resource

@export var material_type: Enums.TileMaterial
@export var display_name: String
@export var hardness_min: float
@export var hardness_max: float
@export var color: Color
## Wirkung der Vegetationsdichte auf den Widerstand: + stabilisiert, - lockert
@export var vegetation_effect : float
#0-1 wobei 1 max ist
@export var vegetation_potential: float
## Faktor auf den Widerstand unter 0 °C (1.0 = kein Effekt)
@export var freeze_factor :float = 1.0
