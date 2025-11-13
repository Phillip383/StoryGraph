extends RefCounted
class_name StrategyContext

var _strategy : Strategy

func set_strategy(strategy : Strategy) -> StrategyContext:
	if _strategy:
		destroy()
	_strategy = strategy
	return self

func execute():
	if _strategy:
		_strategy.execute()

func destroy():
	if _strategy:
		_strategy.destroy()
		_strategy = null
