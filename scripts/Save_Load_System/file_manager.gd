extends Node

##SIGNALS
signal level_create_requested()
signal on_level_load_request(_level_data)
signal post_level_load(_level : Level)

signal project_changed()

signal level_deleted(_name : StringName)
signal level_renamed(_old_name : StringName, _new_name : StringName)

# signal template_create_requested()
# signal on_template_load_request(_template)
