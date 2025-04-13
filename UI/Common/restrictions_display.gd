extends Container

@onready var StartingItemTag = %StartingItemTag
@onready var Identification = %Identification
@onready var HiddenItem = %HiddenItem

@onready var ModifiableChildren = %ModifiableChildren

var restrictions: ResearchContract.GoalRestrictions = null

func set_restrictions(_restrictions):
	restrictions = _restrictions
	update_restrictions_display()
	tooltip_text = "Restrictions: " + restrictions._to_string()

func update_restrictions_display() -> void:
	for child in ModifiableChildren.get_children():
		ModifiableChildren.remove_child(child)
	
	var phenotypes = GeneHelpers.get_phenotype(restrictions.species, restrictions.genes)
	phenotypes = GeneHelpers._merge_phenotypes(phenotypes, {"modules": restrictions.modules})
	
	var modules = []
	for module in restrictions.species.modules:
		if module.name in phenotypes.get("modules", {}).keys():
			var module_obj = SpeciesModules.get_module(module["kind"]).new(module, modules)
			var effects = phenotypes.get("modules", {}).get(module.name, {})
			module_obj.create_on(ModifiableChildren)
			module_obj.process_attributes(effects)
