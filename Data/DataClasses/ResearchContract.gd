extends Resource
class_name ResearchContract

var name: String = ""
var requirements: Array[String] = []
var starting_flowers: Array[Item] = []
var goal_flowers: Array[ResearchContractGoal] = []
var tooltip_data: Dictionary
var completed: bool = false

signal contract_complete

class ResearchContractGoal:
	var parents: Array[GoalRestrictions] = []
	var child: GoalRestrictions
	var goal_percent: float

	func _init(research_contract: Dictionary):
		for parent in research_contract.get("parents", []):
			parents.append(GoalRestrictions.new(parent))
		child = GoalRestrictions.new(research_contract.get("child"))
		goal_percent = float(research_contract.get("goal_percent"))


func _init(research_contract: Dictionary):
	self.name = research_contract["name"]
	
	for requirement in research_contract.get("requirements", []):
		requirements.append(requirement)
	for starting_flower in research_contract.get("starting_flowers"):
		starting_flowers.append(Item.new(starting_flower))
	for goal_flower in research_contract.get("goal_flowers"):
		goal_flowers.append(ResearchContractGoal.new(goal_flower))
	tooltip_data = research_contract.get("tooltip_data", {})


class GoalRestrictions:
	var modules: Dictionary
	var species: Species
	var genes: Dictionary
	
	func _init(dict: Dictionary):
		modules = dict.get("modules", {})
		species = Database.Speciess.get(dict.get("species"))
		genes = dict.get("genes", {})
	
	func get_tooltip(tooltip_data) -> String:
		var st = "Species: %s" % species.name
		for gene in tooltip_data.get("known_genes", genes):
			if gene in genes:
				st += "\n%s: %s" % [gene, genes[gene]]
		return st
	
	func _to_string() -> String:
		var st = "Species: %s" % species.name
		for gene in genes:
			st += "\n%s: %s" % [gene, genes[gene]]
		return st
