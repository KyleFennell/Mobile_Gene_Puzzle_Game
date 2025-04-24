extends MarginContainer

@onready var DialogueContainer = %DialogueContainer

var saved_contracts = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ResearchContractList.research_contract_clicked.connect(_on_research_contract_clicked)
	%ResearchContainer.contract_complete.connect(_on_contract_complete)
	%DialogueContainer.dialogue_event.connect(_on_dialogue_event)
	%TutorialResearchContainer.event_emit.connect(_on_tutorial_research_conatiner_event)
	
func _on_research_contract_clicked(research_contract_name: String):
	if %ResearchContainer.research_contract != null:
		saved_contracts[%ResearchContainer.research_contract.name] = %ResearchContainer.save_data()
	var research_contract = Database.ResearchContracts.get(research_contract_name)
	%ResearchContainer.reset()
	%ResearchContainer.set_research_contract(research_contract)
	%ContractLabel.text = research_contract.name
	if research_contract_name in saved_contracts:
		%ResearchContainer.load_data(saved_contracts[research_contract_name])
	%ResearchContractList.reload_contract_list({"contract_saves": saved_contracts.keys()})


func _on_contract_complete():
	# naive but it works
	print("unlocking contracts")
	for contract in Database.ResearchContracts.values():
		print(contract.name, contract.requirements)
		var unlocked = true
		for requirement in contract.requirements:
			print("checking contract: %s (%s)" % [requirement, Database.ResearchContracts[requirement].completed])
			if not Database.ResearchContracts[requirement].completed:
				unlocked = false
		if unlocked:
			contract.status = ResearchContract.Status.UNLOCKED
	%ResearchContractList.reload_contract_list({"contract_saves": saved_contracts.keys()})

func _on_dialogue_event(value: String):
	var params = value.split(",")
	match params[0]:
		"show_red_tulip":
			%TutorialResearchContainer.show_red_tulip()
		"show_yellow_tulip":
			%TutorialResearchContainer.show_yellow_tulip()
		"show_blue_tulip":
			%TutorialResearchContainer.show_blue_tulip()

func _on_tutorial_research_conatiner_event(value: Dictionary):
	print("passing on event: ", value)
	%DialogueContainer.process_event_completion(value)
