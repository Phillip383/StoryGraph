extends GutTest

## Creates a level, asserts if the file doesn't exist.
func test_create_level():
	var path = await StaticTestUtils.create_level("test")
	assert_file_exists(path)

## Loops the test's levels directory checking for correct id's
func test_level_ids():
	var seen_ids: Array = []
	var dir = DirAccess.open(StaticTestUtils.LEVEL_DIR)
	var files = dir.get_files()

	for file in files:
		var buffer: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(file))
		if buffer:
			var id = buffer["id"];
			assert_has(seen_ids, id, "Duplicate Level ID")

func test_add_node():
	pass

func test_level_layers():
	pass
