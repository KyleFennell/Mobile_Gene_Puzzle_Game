extends MarginContainer

@onready var ContractLabel = %ContractLabel
@onready var ResearchContainer = %ResearchContainer
@onready var ResearchContractList = %ResearchContractList

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ResearchContractList.research_contract_clicked.connect(on_research_contract_clicked)
	
func on_research_contract_clicked(research_contract_name: String):
	var research_contract = Database.ResearchContracts.get(research_contract_name)
	ResearchContainer.reset()
	ResearchContainer.set_research_contract(research_contract)
	ContractLabel.text = research_contract.name
