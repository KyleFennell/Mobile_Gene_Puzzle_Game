extends MarginContainer

@onready var Parent1 = %Parent1
@onready var Parent2 = %Parent2
@onready var Children = %Children
@onready var Progress = %ProgressBar

var rigged_instances: Dictionary = {}

signal parents_changed
signal new_child

class RiggedBreedingInstance:
	var parent1: Item
	var parent2: Item
	var child_list: Array
	func _init(p1, p2, children):
		parent1 = p1
		parent2 = p2
		child_list = children
	func has_children_remaining():
		return child_list.size()
	func get_next_child() -> Item:
		return child_list.pop_front()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Parent1.connect("slot_contence_changed", _parent_changed)
	Parent2.connect("slot_contence_changed", _parent_changed)
	Progress.connect("timeout", breeding_finished)
	for child in Children.get_children():
		child.slot_contence_changed.connect(_child_changed)
	rigged_instances = {
		"blue_on_three": RiggedBreedingInstance.new(
			Item.new({"species": "tulip", "genes": {"colour_1": "Rb"}}),
			Item.new({"species": "tulip", "genes": {"colour_1": "Rb"}}),
			[
				Item.new({"species": "tulip", "genes": {"colour_1": "RR"}}),
				Item.new({"species": "tulip", "genes": {"colour_1": "Rb"}}),
				Item.new({"species": "tulip", "genes": {"colour_1": "bb"}})
			]
		),
	}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _parent_changed():
	stop_breeding()
	if Parent1.has_item() and Parent2.has_item():
		start_breeding()
	parents_changed.emit([Parent1.item, Parent2.item])

func _child_changed():
	if has_free_child():
		start_breeding()
	else:
		stop_breeding()

func reset():
	Parent1.set_item(null)
	Parent2.set_item(null)
	for child in Children.get_children():
		child.set_item(null)
	stop_breeding()
	
func update_tooltips(tooltip_data: Dictionary):
	Parent1.update_tooltips(tooltip_data)
	Parent2.update_tooltips(tooltip_data)
	for child in Children.get_children():
		child.update_tooltips(tooltip_data)

func start_breeding():
	if not has_free_child():
		stop_breeding()
	if Progress.is_running():
		return
	if Parent1.has_item() and Parent2.has_item() and has_free_child():
		Progress.start()
	
func stop_breeding():
	Progress.stop()
	
func breeding_finished():
	var child_slot = get_free_child()
	var child_item = get_rigged_child()
	if not child_item:
		print("regular child generated")
		child_item = GeneHelpers.generate_child(Parent1.item, Parent2.item)
	child_slot.set_item(child_item)
	new_child.emit(child_item)
	if has_free_child():
		start_breeding()
	else:
		stop_breeding()

func get_rigged_child() -> Item:
	for instance in rigged_instances.values():
		if instance.has_children_remaining() and valid_rig(instance):
			print("successfully found rigging instance")
			return instance.get_next_child()
	return null

func valid_rig(rig: RiggedBreedingInstance) -> bool:
	return (
		(
			GeneHelpers.genes_match(rig.parent1.genes, Parent1.item.genes) and 
			GeneHelpers.genes_match(rig.parent2.genes, Parent2.item.genes)
		) or (
			GeneHelpers.genes_match(rig.parent1.genes, Parent2.item.genes) and 
			GeneHelpers.genes_match(rig.parent2.genes, Parent1.item.genes)
		)
	)

func has_free_child() -> bool:
	for child in Children.get_children():
		if not child.has_item():
			return true
	return false

func get_free_child() -> ItemSlot:
	for child in Children.get_children():
		if not child.has_item():
			return child
	return null

func save_data() -> Dictionary:
	var data = {}
	data.parent1 = Parent1.item
	data.parent2 = Parent2.item
	data.children = []
	for child in Children.get_children():
		data.children.append(child.item)
	data.progress = Progress.save_data()
	return data

func load_data(data: Dictionary):
	Parent1.set_item(data["parent1"])
	Parent2.set_item(data["parent2"])
	for i in len(data["children"]):
		Children.get_child(i).set_item(data["children"][i])
	Progress.load_data(data["progress"])
	
