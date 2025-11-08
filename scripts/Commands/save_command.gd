class_name SaveCommand
extends Command


func _init(active_level : Level) -> void:
    var level_data = active_level.save_level()

func execute() -> void:
    save()

func save():
    pass
