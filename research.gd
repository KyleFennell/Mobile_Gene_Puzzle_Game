extends VBoxContainer

signal research_contract_clicked
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reload_contract_list()

func reset():
	for child in get_children():
		child.queue_free()

func reload_contract_list(filter_options: Dictionary = {}) -> void:
	reset()
	for contract in Database.ResearchContracts.values():
		if contract_matches_filter(contract, filter_options):
			var label = Label.new()
			label.mouse_filter = Control.MOUSE_FILTER_PASS
			label.text = contract.name
			label.gui_input.connect(Helpers.element_clicked_event.bind(contract.name, research_contract_clicked))
			self.add_child(label)

func contract_matches_filter(contract: ResearchContract, filter_options: Dictionary):
	return contract.status != contract.Status.LOCKED and filter_options.get("unlocked", true)
