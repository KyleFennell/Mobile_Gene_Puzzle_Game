extends Container

@onready var StartingItemTag = %StartingItemTag
@onready var Identification = %Identification
@onready var HiddenItem = %HiddenItem

@onready var ModifiableChildren = %ModifiableChildren

var item: Item = null
var tween = create_tween()

func _ready():
	Identification.texture= Identification.texture.duplicate()
	Events.allele_discovered.connect(update_item_display)

func update_item_display() -> void:
	# update the textures and tags based on self.item
	for child in ModifiableChildren.get_children():
		ModifiableChildren.remove_child(child)

	#HiddenItem.get_child(0).texture = ModifiableChildren.get_child(0).texture
	
	if self.item == null:
		tween.kill()
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

	var phenotypes = GeneHelpers.get_phenotype(item.species, item.genes)
	if item is GoalItem and item.properties:
		phenotypes = item.properties
		
	var modules = {}
	for module in self.item.modules:
		var effects = phenotypes.get("modules", {}).get(module.name, {})
		module.create_on(ModifiableChildren)
		module.process_attributes(effects)

	#if item.is_starting_item:
		#StartingItemTag.show()
	#
	if item.identified:
		var raw_genotype = GeneHelpers.get_raw_genotype(item.species, item.genes)
		#var id = Database.Levels[Globals.current_level].identifications[raw_genotype]
		var id = item.species.identifications[raw_genotype]["phen_het_id"]
		var purity = GeneHelpers.get_heterozygous_count(item.genes)
		Identification.show()
		var sub_tex = id+(min(purity,5)*3*16)
		Identification.texture.set_colour(sub_tex)
				 
func set_item(_item: Item) -> void:
	self.item = _item
	update_item_display()
