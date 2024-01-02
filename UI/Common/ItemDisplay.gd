extends Container

@onready var StartingItemTag = %StartingItemTag
@onready var MainTexture = %MainTexture
@onready var Identification = %Identification
@onready var InnerTexture = %InnerTexture
@onready var HiddenItem = %HiddenItem

@onready var ModifiableChildren = %ModifiableChildren

var item: Item = null

func _ready():
	MainTexture.texture = MainTexture.texture.duplicate()
	Identification.texture = Identification.texture.duplicate()
	InnerTexture.texture = InnerTexture.texture.duplicate()
	HiddenItem.get_child(0).texture = MainTexture.texture
	Events.allele_discovered.connect(update_item_display)
	
func update_item_display() -> void:
	# update the textures and tags based on self.item
	for child in ModifiableChildren.get_children():
		ModifiableChildren.remove_child(child)
	
	
	if self.item == null:
		hide()
		Identification.hide()
		StartingItemTag.hide()
		#InnerTexture.hide()
		return
	
	show()
	
		
		
	## undiscovered seed
	#if GeneHelpers.is_hidden(item):
		#HiddenItem.show()
		#return
	#HiddenItem.hide()
	#
	## 
	var phenotypes = GeneHelpers.get_phenotype(item.species, item.genes)
	if item is GoalItem and item.properties:
		phenotypes = item.properties
		
	var modules = {}
	for module in self.item.modules:
		var effects = phenotypes.get(module.name, {})
		module.process_attributes(effects)
		module.create_on(ModifiableChildren)
		
	#if item.is_starting_item:
		#StartingItemTag.show()
	#
	if item.identified:
		var raw_genotype = GeneHelpers.get_raw_genotype(item.genes)
		#var id = Database.Levels[Globals.current_level].identifications[raw_genotype]
		var id = item.species.identifications[raw_genotype]
		Identification.show()
		Identification.texture.set_colour(id)

func set_item(_item: Item) -> void:
	self.item = _item
	update_item_display()
