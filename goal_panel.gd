extends MarginContainer
class_name GoalPanel

enum GOAL_TYPE {LINEAGE, INDIVIDUAL}

@onready var ParentsContainer = %ParentsContainer
@onready var Parent1: RestrictedItemSlot = %Parent1
@onready var Parent2: RestrictedItemSlot = %Parent2
@onready var Child: RestrictedItemSlot = %Child
@onready var Sep = %HSeparator
@onready var MatchPercent = %MatchPercent

var goal_restrictions: ResearchContract.ResearchContractGoal
var goalType: GOAL_TYPE
var locked: bool = false

signal goal_satisfied

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Parent1.slot_contence_changed.connect(_on_slot_changed)
	Parent2.slot_contence_changed.connect(_on_slot_changed)
	Child.slot_contence_changed.connect(_on_slot_changed)
	
func set_goal_restrictions(new_goal_restrictions: ResearchContract.ResearchContractGoal):
	goal_restrictions = new_goal_restrictions
	var parent_restrictions = goal_restrictions.parents
	if len(parent_restrictions) == 0:
		# if the goal just requires a single flower (aka child)
		goalType = GOAL_TYPE.INDIVIDUAL
		ParentsContainer.hide()
		Sep.hide()
		MatchPercent.hide()
		Child.fade_restriction()
	else:
		# if the goal is a lineage requirement (aka parent)
		goalType = GOAL_TYPE.LINEAGE
		Parent1.set_item_restrictions(parent_restrictions[0])
		Parent1.fade_restriction()
		Parent2.set_item_restrictions(parent_restrictions[1])
		Parent2.fade_restriction()
		Child.dropable = false
	
	Child.set_item_restrictions(goal_restrictions.child)
	set_child_percent_label(0)


func update_tooltips(tooltip_data: Dictionary):
	Parent1.update_tooltips(tooltip_data)
	Parent2.update_tooltips(tooltip_data)
	Child.update_tooltips(tooltip_data)

func calculate_child_match_percent() -> float:
	if Parent1.has_item() && Parent2.has_item():
		var child_percents = GeneHelpers.generate_children_with_percentages(Parent1.item, Parent2.item)
		var percent_match = calculate_percent_of_children_match_restrictions(child_percents, goal_restrictions.child) * 100
		return percent_match
	else:
		return 0

func calculate_percent_of_children_match_restrictions(child_percents: Array[GeneHelpers._ChildChancePair], restrictions: ResearchContract.GoalRestrictions) -> float:
	var percent_match = 0.0
	for child in child_percents:
		if GeneHelpers.item_satisfies_restrictions(child.child, restrictions):
			percent_match += child.chance
	return percent_match


func set_child_percent_label(percent: float):
	var formatted_text = "%.2f / %.2f%%" % [percent, goal_restrictions.goal_percent]
	MatchPercent.text = formatted_text

func _on_slot_changed():
	match goalType:
		GOAL_TYPE.LINEAGE:
			var match_percent = calculate_child_match_percent()
			set_child_percent_label(match_percent)
			if match_percent >= goal_restrictions.goal_percent:
				lock_goal()
				goal_satisfied.emit()
		GOAL_TYPE.INDIVIDUAL:
			if Child.has_item():
				lock_goal()
				goal_satisfied.emit()

func lock_goal():
	locked = true
	Parent1.lock()
	Parent2.lock()
	Child.lock()
	goal_satisfied.emit()

func save_data() -> Dictionary:
	var data = {}
	data.parent1 = Parent1.item
	data.parent2 = Parent2.item
	data.child = Child.item
	data.locked = locked
	return data

func load_data(data: Dictionary):
	Parent1.set_item(data["parent1"])
	Parent2.set_item(data["parent2"])
	Child.set_item(data["child"])
	locked = data["locked"]
	
	
	
	
	
	
