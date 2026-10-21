extends Node

func _ready():
	print("\n=== RUNNING TESTS ===\n")

	var tests = [
		load("res://tests/map_generator/test_random_hardness.gd").new(),
		load("res://tests/registrys/scene_registry_test.gd").new(),
		load("res://tests/registrys/test_material_registry.gd").new(),
		# später weitere Tests
	]

	for t in tests:
		print("\n Running: ", t.get_test_name())
		t.run()

	print("\n=== ALL TESTS DONE ===\n")
