@tool
class_name BoardCellData extends Resource

enum CounterPresence { BLACK, WHITE, NONE }

@export
var counter_presence := CounterPresence.NONE

func has_counter() -> bool:
	return counter_presence != CounterPresence.NONE

func is_black() -> bool:
	return counter_presence == CounterPresence.BLACK

func is_white() -> bool:
	return counter_presence == CounterPresence.WHITE
