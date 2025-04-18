extends VBoxContainer

signal research_contract_clicked

var debug_show_all = false

func _ready() -> void:
	reload_contract_list()

func reset():
	for child in get_children():
		child.queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_debug"):
		debug_show_all = !debug_show_all
		reload_contract_list()

func reload_contract_list(filter_options: Dictionary = {}) -> void:
	reset()
	for contract in Database.ResearchContracts.values():
		if contract_matches_filter(contract, filter_options):
			var label = Label.new()
			label.mouse_filter = Control.MOUSE_FILTER_PASS
			label.text = contract.name
			if contract.completed:
				label.text += " (Complete)"
			elif contract.name in filter_options.get("contract_saves", []):
				label.text += " (In Progress)"
			label.gui_input.connect(Helpers.element_clicked_event.bind(contract.name, research_contract_clicked))
			self.add_child(label)

func contract_matches_filter(contract: ResearchContract, filter_options: Dictionary):
	if debug_show_all:
		return true
	return contract.status != contract.Status.LOCKED and filter_options.get("unlocked", true)
