extends MarginContainer

@onready var GoalsRow = %GoalsRow
@onready var Breeders = %Breeders
@onready var StartingSeedsPanel = %StartingSeedsPanel

var s_GoalPanel = preload("res://goal_panel.tscn")
var research_contract: ResearchContract = null

signal contract_complete

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reset():
	research_contract = null
	StartingSeedsPanel.reset()
	for child in GoalsRow.get_children():
		child.free()
	update_tooltips({})

func set_research_contract(new_research_contract):
	research_contract = new_research_contract
	StartingSeedsPanel.set_starting_flowers(research_contract.starting_flowers)
	for goal in research_contract.goal_flowers:
		var goal_slot = s_GoalPanel.instantiate()
		GoalsRow.add_child(goal_slot)
		goal_slot.set_goal_restrictions(goal)
		goal_slot.goal_satisfied.connect(on_goal_complete)
	update_tooltips(research_contract.tooltip_data)
	
func update_tooltips(tooltip_data: Dictionary):
	StartingSeedsPanel.update_tooltips(tooltip_data)
	for breeder in Breeders.get_children():
		breeder.update_tooltips(tooltip_data)
	for goal in GoalsRow.get_children():
		goal.update_tooltips(tooltip_data)

func on_goal_complete():
	for goal_panel in GoalsRow.get_children():
		if not goal_panel.locked:
			return
	research_contract.completed = true
	contract_complete.emit()
