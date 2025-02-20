extends Node

func chain(sig1: Signal, sig2: Signal) -> void:
	persist(sig1, sig2.emit)

func persist(sig: Signal, callable: Callable) -> void:
	if not sig.is_connected(callable):
		sig.connect(callable)

func once(sig: Signal, callable: Callable) -> void:
	if not sig.is_connected(callable):
		sig.connect(callable, CONNECT_ONE_SHOT)

func once_next_frame(callable: Callable) -> void:
	var sig := get_tree().process_frame
	once(sig, callable)
