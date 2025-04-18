extends MarginContainer

@onready var StartingSeeds = %StartingSeeds
var s_ItemSlot = preload("res://UI/Common/ItemSlot.tscn")
var starting_flowers: Array[Item] = []

func set_starting_flowers(starting_flowers: Array[Item]):
	self.starting_flowers = starting_flowers
	for starting_flower in self.starting_flowers:
		var slot = s_ItemSlot.instantiate()
		StartingSeeds.add_child(slot)
		slot.set_item(starting_flower)
		slot.infinite = true
		slot.dropable = false
		slot.tooltip_enabled = true

func reset():
	for child in StartingSeeds.get_children():
		child.queue_free()

func update_tooltips(tooltip_data: Dictionary):
	for child in StartingSeeds.get_children():
		child.update_tooltips(tooltip_data)
