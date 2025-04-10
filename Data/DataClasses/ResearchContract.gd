extends Resource
class_name ResearchContract

var name: String = ""
var requirements: Array[String] = []
var starting_flowers: Array[Item] = []
var goal_flowers: Array[ResearchContractGoal] = []
var completed: bool = false

signal contract_complete

class ResearchContractGoal:
	var parents: Array[ResearchContractGoalParent] = []
	var child: Item
	var goal_percent: float

	func _init(research_contract: Dictionary):
		for parent in research_contract.get("parents", []):
			parents.append(ResearchContractGoalParent.new(parent))
		child = Item.new(research_contract.get("child"))
		goal_percent = float(research_contract.get("goal_percent"))

func _init(research_contract: Dictionary):
	self.name = research_contract["name"]
	
	for requirement in research_contract.get("requirements", []):
		requirements.append(requirement)
	for starting_flower in research_contract.get("starting_flowers"):
		starting_flowers.append(Item.new(starting_flower))
	for goal_flower in research_contract.get("goal_flowers"):
		goal_flowers.append(ResearchContractGoal.new(goal_flower))


class ResearchContractGoalParent:
	var modules: Dictionary
	var species: Species
	var genes: Dictionary
	
	func _init(dict: Dictionary):
		modules = dict.get("modules", {})
		species = Database.Speciess.get(dict.get("species"))
		genes = dict.get("genes", {})
