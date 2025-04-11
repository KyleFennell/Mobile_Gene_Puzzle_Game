extends Container
class_name ItemSlot

@onready var BackgroundTexture = %BackgroundTexture
@onready var RestrictionsTexture = %RestrictionsTexture
@onready var ItemDisplay = %ItemDisplay

@export var dragable: bool = true
@export var dropable: bool = true
@export var infinite: bool = false

signal slot_contence_changed
var item: Item = null
var item_restrictions: ResearchContract.GoalRestrictions

func _ready():
	if item == null:
		ItemDisplay.hide()

func set_item(_item: Item) -> void:
	self.item = _item
	ItemDisplay.set_item(item)
	emit_signal("slot_contence_changed")

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if item != null:
		return data["previous_slot"].dropable
	if not GeneHelpers.item_satisfies_restrictions(data.item, item_restrictions):
		return data["previous_slot"].dropable
	return dropable

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if item != null:
		# swap items
		if data.has("previous_slot") and data["previous_slot"].dropable:
			#can swap item
			data["previous_slot"].successful_drop(item)
			Globals.current_drag = null
		else:
			return
	else:
		# drop item
		data["previous_slot"].successful_drop(null)
		Globals.current_drag = null
		
	set_item(data.item)

func _get_drag_data(_at_position: Vector2) -> Variant:
	if dragable and item != null:
		print(item.genes)
		create_drag_preview()
		ItemDisplay.hide()
		
		var drag_data = {"item": item, "previous_slot": self}
		Globals.current_drag = drag_data
	
		return drag_data
	
	return null
	
func potential_drop(data: Variant):
	ItemDisplay.show()

func successful_drop(new_item: Variant):
	if self.infinite:
		return
	set_item(new_item)
	
func create_drag_preview():
	var drag_preview = ItemDisplay.duplicate(true)
	var tex = drag_preview.get_child(0).get_child(0).texture
	drag_preview.position.x = -tex.get_width()/2
	drag_preview.position.y = -tex.get_height()/2
		
	set_drag_preview(drag_preview)

func has_item() -> bool:
	return item != null
