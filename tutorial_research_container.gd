extends MarginContainer

@onready var GoalsRow = %GoalsRow
@onready var Breeders = %Breeders
@onready var StartingSeedsPanel = %StartingSeedsPanel

var s_GoalPanel = preload("res://goal_panel.tscn")
var research_contract: ResearchContract = null

signal contract_complete
signal event_emit

func _ready() -> void:
	%RedTulip.set_item(Item.new({"species": "tulip", "genes": {"colour_1":"RR"}}))
	%YellowTulip.set_item(Item.new({"species": "tulip", "genes": {"colour_1":"YY"}}))
	#%BlueTulip.set_item(Item.new({"species": "tulip", "genes": {"colour_1":"bb"}}))
	add_hover_tracker(%RedTulip, 0.5, func (): event_emit.emit({"hover_flower":"red_tulip"}))
	add_hover_tracker(%YellowTulip, 0.5, func (): event_emit.emit({"hover_flower":"yellow_tulip"}))
	#add_hover_tracker(%BlueTulip, 0.5, func (): event_emit.emit({"hover_flower":"blue_tulip"}))
	%BreedingPanel.parents_changed.connect(func (data): event_emit.emit({"breeder_parent_changed": data}))
	%BreedingPanel.new_child.connect(func (data): event_emit.emit({"breeder_new_child": data}))
	update_tooltips({"known_genes": ["colour_1"]})

func show_red_tulip():
	%RedTulip.show()

func show_yellow_tulip():
	%YellowTulip.show()

func show_breeder():
	%BreedingPanel.show()

func show_rigged_breeder():
	%RiggedBreedingPanel.show()

func reset():
	research_contract = null
	StartingSeedsPanel.reset()
	for breeder in Breeders.get_children():
		breeder.free()
	for child in GoalsRow.get_children():
		child.free()
	update_tooltips({})


func add_hover_tracker(node: Control, duration: float, callback: Callable):
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = duration
	timer.timeout.connect(func ():
		print("hover complete")
		callback.call()
		timer.queue_free()
	)
	node.mouse_entered.connect(timer.start)
	node.mouse_exited.connect(timer.stop)

func add_goal(goal: ResearchContract.ResearchContractGoal):
	var goal_slot = s_GoalPanel.instantiate()
	GoalsRow.add_child(goal_slot)
	goal_slot.set_goal_restrictions(goal)
	goal_slot.goal_satisfied.connect(on_goal_complete)

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
	research_contract.complete()
	contract_complete.emit()

func save_data() -> Dictionary:
	var data = {}
	data.breeders = []
	for breeder in Breeders.get_children():
		data.breeders.append(breeder.save_data())
	data.goals = []
	for goal in GoalsRow.get_children():
		data.goals.append(goal.save_data())
	return data

# requires the research contract to already be set. there is no validation that the loaded data is for the current contract layout
func load_data(data: Dictionary):
	for i in len(data["breeders"]):
		Breeders.get_child(i).load_data(data["breeders"][i])
	for i in len(data["goals"]):
		GoalsRow.get_child(i).load_data(data["goals"][i])
