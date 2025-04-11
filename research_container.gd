extends MarginContainer

@onready var GoalsRow = %GoalsRow
@onready var StartingSeedsPanel = %StartingSeedsPanel

var s_GoalPanel = preload("res://goal_panel.tscn")

var research_contract: ResearchContract = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reset():
	research_contract = null
	for child in StartingSeedsPanel.get_children():
		child.queue_free()
	for child in GoalsRow.get_children():
		child.queue_free()

func set_research_contract(new_research_contract):
	research_contract = new_research_contract
	StartingSeedsPanel.set_starting_flowers(research_contract.starting_flowers)
	for goal in research_contract.goal_flowers:
		var goal_slot = s_GoalPanel.instantiate()
		GoalsRow.add_child(goal_slot)
		goal_slot.set_goal_restrictions(goal)
