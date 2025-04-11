extends VBoxContainer

signal research_contract_clicked
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for contract in Database.ResearchContracts.values():
		var label = Label.new()
		label.mouse_filter = Control.MOUSE_FILTER_PASS
		label.text = contract.name
		label.gui_input.connect(print)
		label.gui_input.connect(Helpers.element_clicked_event.bind(contract.name, research_contract_clicked))
		self.add_child(label)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
