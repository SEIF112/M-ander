extends TestBase
class_name TestSceneRegistry

func _init():
	_name = "SceneRegistry Tests"

func run():
	test_valid_key_loads_scene()
	test_invalid_key_returns_null()

# ---------------------------------------------------------
# 1) Gültiger Key → Scene wird geladen
# ---------------------------------------------------------
func test_valid_key_loads_scene():
	var registry = preload("res://core/scene_registry.gd").new()

	var scene = registry.get_scene(registry.SceneKey.APP_ROOT)

	assert_equal(scene is PackedScene, true, "Valid key loads a PackedScene")

# ---------------------------------------------------------
# 2) Ungültiger Key → null + Error
# ---------------------------------------------------------
func test_invalid_key_returns_null():
	var registry = preload("res://core/scene_registry.gd").new()

	var scene = registry.get_scene(999)  # absichtlich ungültig

	assert_equal(scene == null, true, "Invalid key returns null")
