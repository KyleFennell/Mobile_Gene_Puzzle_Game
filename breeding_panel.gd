extends MarginContainer

@onready var Parent1 = %Parent1
@onready var Parent2 = %Parent2

@onready var Children = %Children

@onready var Progress = %ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Parent1.connect("slot_contence_changed", _parent_changed)
	Parent2.connect("slot_contence_changed", _parent_changed)
	Progress.connect("timeout", breeding_finished)
	for child in Children.get_children():
		child.slot_contence_changed.connect(_child_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _parent_changed():
	if Parent1.has_item() and Parent2.has_item():
		start_breeding()
	else:
		stop_breeding()

func _child_changed():
	_parent_changed()

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
		return
	Progress.start()
	
func stop_breeding():
	Progress.stop()
	
func breeding_finished():
	if not has_free_child():
		stop_breeding()
		return
	var child_slot = get_free_child()
	var child_item = GeneHelpers.generate_child(Parent1.item, Parent2.item)
	child_slot.set_item(child_item)
	start_breeding()

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
