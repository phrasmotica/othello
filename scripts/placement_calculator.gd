@tool
class_name PlacementCalculator extends Node

@export
var state_tracker: BoardStateTracker

@export
var ray_calculator: RayCalculator

func can_place(idx: int, colour: BoardStateData.CounterType) -> bool:
	if state_tracker.has_counter(idx):
		return false

	var rays := ray_calculator.get_rays(idx, colour)
	return rays.size() > 0
