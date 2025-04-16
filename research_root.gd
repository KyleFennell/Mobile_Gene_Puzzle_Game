extends MarginContainer

@onready var ContractLabel = %ContractLabel
@onready var ResearchContainer = %ResearchContainer
@onready var ResearchContractList = %ResearchContractList

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ResearchContractList.research_contract_clicked.connect(on_research_contract_clicked)
	ResearchContainer.contract_complete.connect(on_contract_complete)
	
func on_research_contract_clicked(research_contract_name: String):
	var research_contract = Database.ResearchContracts.get(research_contract_name)
	ResearchContainer.reset()
	ResearchContainer.set_research_contract(research_contract)
	ContractLabel.text = research_contract.name

func on_contract_complete():
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
	ResearchContractList.reload_contract_list()
