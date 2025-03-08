class_name PlayCalculator extends Node

class AvailablePlays extends Resource:
	@export
	var plays: Array[int] = []

	func can_play() -> bool:
		return plays.size() > 0

@export
var state_tracker: BoardStateTracker

@export
var placement_calculator: PlacementCalculator

func can_play(colour: BoardStateData.CounterType) -> bool:
	return _get_plays_for(colour).can_play()

func both_cannot_play() -> bool:
	return not (
		can_play(BoardStateData.CounterType.BLACK) or
		can_play(BoardStateData.CounterType.WHITE)
	)

func _get_plays_for(colour: BoardStateData.CounterType) -> AvailablePlays:
	var plays: Array[int] = []

	for idx: int in state_tracker.get_indexes():
		if placement_calculator.can_place(idx, colour):
			plays.append(idx)

	var result := AvailablePlays.new()
	result.plays = plays

	return result
