extends Resource
class_name Item

var genes = {}
var modules = []
var identified = false
var is_starting_item = false
var is_hidden = false
var species: Species = null

func _init(dict, is_identified=false, starting_item=false):
	if "species" in dict:
		species = Database.Speciess[dict.get("species")]
	genes = dict.get("genes", {})
	identified = dict.get("identified", is_identified)
	self.is_starting_item = starting_item
	if self.species != null:
		fill_default_genes()
	for module in species.modules:
		modules.append(SpeciesModules.get_module(module["kind"]).new(module, modules))

func full_duplicate() -> Item:
	return Item.new({
			"genes": genes.duplicate(true)
		}, 
		identified, is_starting_item
	)

func fill_default_genes():
	for gene in self.species.genome:
		if not gene in self.genes.keys():
			self.genes[gene] = self.species.genome[gene].default

func equals(other: Item, idenfied_relevant: bool=false) -> bool:
	if not other is Item:
		return false
	if idenfied_relevant and other.identified != identified:
		return false
	return GeneHelpers.genes_match(self.genes, other.genes)

func phenotype_equals(other: Item) -> bool:
	if not other is Item:
		return false
	
	var self_phenotype = GeneHelpers.get_phenotype(self.species, self.genes)
	var other_phenotype = GeneHelpers.get_phenotype(other.species, other.genes)
	
	return GeneHelpers.phenotypes_match(self_phenotype, other_phenotype)

func identify():
	identified = true
	species.identify(genes)
