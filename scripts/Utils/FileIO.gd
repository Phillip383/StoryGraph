class_name FileIO
extends RefCounted


func _init() -> void:
    pass

func open_file(path : String):
    pass

func save_file(path : String):
    if FileAccess.file_exists(path):
        var contents = JSON.parse_string(FileAccess.get_file_as_string(path))
        var file = FileAccess.open(path, FileAccess.WRITE)
        file.store_string(contents)
        file.close()
    else:
        ## TODO: Add a path selector to the unsaved file window, await the submit, get the path, call save again.
        ## Moving forward, all file's will be .json extension.
        pass

func delete_file(path : String):
    pass

func move_file(path : String):
    pass

func rename_file(path : String):
    pass