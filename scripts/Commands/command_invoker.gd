class_name CommandInvoker
extends RefCounted


var _command : Command

func set_command(command : Command) -> CommandInvoker:
	_command = command
	return self

func execute_command():
	_command.execute()
	return _command
