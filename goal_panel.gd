extends MarginContainer
class_name GoalPanel

@onready var ParentsContainer = %ParentsContainer
@onready var Parent1: RestrictedItemSlot = %Parent1
@onready var Parent2: RestrictedItemSlot = %Parent2
@onready var Sep = %HSeparator
@onready var Child: RestrictedItemSlot = %Child
@onready var MatchPercent = %MatchPercent

var goal_restrictions: ResearchContract.ResearchContractGoal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Parent1.connect("slot_contence_changed", _on_parent_changed)
	Parent2.connect("slot_contence_changed", _on_parent_changed)
	
func set_goal_restrictions(new_goal_restrictions: ResearchContract.ResearchContractGoal):
	goal_restrictions = new_goal_restrictions
	var parent_restrictions = goal_restrictions.parents
	if len(parent_restrictions) == 0:
		# if the goal just requires a single flower (aka child)
		ParentsContainer.hide()
		Sep.hide()
		MatchPercent.hide()
		Child.fade_restriction()
		
	else:
		# if the goal is a lineage requirement (aka parent)
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

func _on_parent_changed():
	if Parent1.has_item() && Parent2.has_item():
		var child_percents = GeneHelpers.generate_children_with_percentages(Parent1.item, Parent2.item)
		var percent_match = calculate_percent_of_children_match_restrictions(child_percents, goal_restrictions.child) * 100
		set_child_percent_label(percent_match)
		if percent_match >= goal_restrictions.goal_percent:
			print("Valid parent combination found")
	else:
		set_child_percent_label(0)


func calculate_percent_of_children_match_restrictions(child_percents: Array[GeneHelpers._ChildChancePair], restrictions: ResearchContract.GoalRestrictions) -> float:
	var percent_match = 0.0
	for child in child_percents:
		if GeneHelpers.item_satisfies_restrictions(child.child, restrictions):
			percent_match += child.chance
	return percent_match


func set_child_percent_label(percent: float):
	var formatted_text = "%.2f / %.2f%%" % [percent, goal_restrictions.goal_percent]
	MatchPercent.text = formatted_text
