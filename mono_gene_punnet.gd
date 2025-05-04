extends MarginContainer

var selected_species: Species
var selected_gene1: Gene

func _ready() -> void:
	%SpeciesOptions.item_selected.connect(on_species_selected)
	%Gene1Options.item_selected.connect(on_gene_selected)
	for child in %Parent1Gene1.get_children():
		child.item_selected.connect(on_allele_selected)
	for child in %Parent2Gene1.get_children():
		child.item_selected.connect(on_allele_selected)
	
	%SpeciesOptions.add_item("---")
	
	for species in Database.Speciess.keys():
		%SpeciesOptions.add_item(species)

func on_species_selected(index):
	if index == 0:
		return
	selected_species = Database.Speciess[%SpeciesOptions.get_item_text(index)]
	%Gene1Options.clear()
	%Gene1Options.add_item("---")
	for gene in selected_species.genome.keys():
		%Gene1Options.add_item(gene)

func on_gene_selected(index):
	selected_gene1 = selected_species.genome[%Gene1Options.get_item_text(index)]
	for child in %Parent1Gene1.get_children():
		child.clear()
		child.add_item("-")
		for allele in selected_gene1.alleles:
			child.add_item(allele)
	for child in %Parent2Gene1.get_children():
		child.clear()
		child.add_item("-")
		for allele in selected_gene1.alleles:
			child.add_item(allele)

func on_allele_selected(index):
	var parents: Array[Dictionary] = [
		{
			"species": selected_species.name,
			"genes": {
				selected_gene1.name: ""
			},
		},
		{
			"species": selected_species.name,
			"genes": {
				selected_gene1.name: ""
			},
		}
	]
	
	for child in %Parent1Gene1.get_children():
		parents[0].genes[selected_gene1.name] += child.get_item_text(child.selected)
	for child in %Parent2Gene1.get_children():
		parents[1].genes[selected_gene1.name] += child.get_item_text(child.selected)
	
	if (parents[0].genes.values().all(func(val: String): return val.length() == 2 and "-" not in val) and
		parents[1].genes.values().all(func(val: String): return val.length() == 2 and "-" not in val)):
			update_grid(parents)

func update_grid(parents: Array[Dictionary]):
	var children = GeneHelpers._generate_punnet_children_mono(parents[0], parents[1])
	# top row first column
	# top row alleles
	%p1a1.text = parents[0].genes.values()[0][0]
	%p1a2.text = parents[0].genes.values()[0][1]
	# middle row
	%p2a1.text = parents[1].genes.values()[0][0]
	%child1.set_item(children[0].item)
	%child1.set_text(children[0].gene)
	%child2.set_item(children[1].item)
	%child2.set_text(children[1].gene)
	# bottom row
	%p2a2.text = parents[1].genes.values()[0][1]
	%child3.set_item(children[2].item)
	%child3.set_text(children[2].gene)
	%child4.set_item(children[3].item)
	%child4.set_text(children[3].gene)
