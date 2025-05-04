extends MarginContainer

var selected_species
var selected_gene1
var selected_gene2


func _ready() -> void:
	%SpeciesOptions.item_selected.connect(on_species_selected)
	%Gene1Options.item_selected.connect(on_gene_1_selected)
	for child in %Parent1Gene1.get_children():
		child.item_selected.connect(on_allele_selected)
	for child in %Parent2Gene1.get_children():
		child.item_selected.connect(on_allele_selected)
	%Gene2Options.item_selected.connect(on_gene_2_selected)
	for child in %Parent1Gene2.get_children():
		child.item_selected.connect(on_allele_selected)
	for child in %Parent2Gene2.get_children():
		child.item_selected.connect(on_allele_selected)
	
	%SpeciesOptions.add_item("---")
	%Gene1Options.add_item("---")
	%Gene2Options.add_item("---")
	for container in [%Parent1Gene1, %Parent1Gene2,%Parent2Gene1, %Parent2Gene2]:
		for child in container.get_children():
			child.add_item("-")
			
	for species in Database.Speciess.keys():
		%SpeciesOptions.add_item(species)

func on_species_selected(index):
	if index == 0:
		return
	selected_species = Database.Speciess[%SpeciesOptions.get_item_text(index)]
	reset_gene_options(%Gene1Options)
	reset_gene_options(%Gene2Options)

func reset_gene_options(node: OptionButton):
	node.clear()
	node.add_item("---")
	for gene in selected_species.genome.keys():
		node.add_item(gene)

func on_gene_1_selected(index):
	for i in %Gene2Options.item_count:
		%Gene2Options.set_item_disabled(i, false)
	%Gene2Options.set_item_disabled(index, true)
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

func on_gene_2_selected(index):
	for i in %Gene1Options.item_count:
		%Gene1Options.set_item_disabled(i, false)
	%Gene1Options.set_item_disabled(index, true)
	selected_gene2 = selected_species.genome[%Gene1Options.get_item_text(index)]
	for child in %Parent1Gene2.get_children():
		child.clear()
		child.add_item("-")
		for allele in selected_gene2.alleles:
			child.add_item(allele)
	for child in %Parent2Gene2.get_children():
		child.clear()
		child.add_item("-")
		for allele in selected_gene2.alleles:
			child.add_item(allele)

func on_allele_selected(index):
	var parents: Array[Dictionary] = [
		{
			"species": selected_species.name,
			"genes": {
				selected_gene1.name: "",
				selected_gene2.name: ""
			},
		},
		{
			"species": selected_species.name,
			"genes": {
				selected_gene1.name: "",
				selected_gene2.name: ""
			},
		}
	]
	
	for child in %Parent1Gene1.get_children():
		parents[0].genes[selected_gene1.name] += child.get_item_text(child.selected)
	for child in %Parent2Gene1.get_children():
		parents[1].genes[selected_gene1.name] += child.get_item_text(child.selected)
	for child in %Parent1Gene2.get_children():
		parents[0].genes[selected_gene2.name] += child.get_item_text(child.selected)
	for child in %Parent2Gene2.get_children():
		parents[1].genes[selected_gene2.name] += child.get_item_text(child.selected)
	
	var len_2 = func (val): return val.length() == 2 and "-" not in val
	
	if (parents[0].genes.values().all(len_2) and
		parents[1].genes.values().all(len_2)):
			update_grid(parents)

func update_grid(parents: Array[Dictionary]):
	var children = GeneHelpers._generate_punnet_children_di(parents[0], parents[1])
	
	%p1a11.text = "".join([parents[0].genes.values()[0][0], parents[0].genes.values()[1][0]])
	%p1a12.text = "".join([parents[0].genes.values()[0][0], parents[0].genes.values()[1][1]])
	%p1a21.text = "".join([parents[0].genes.values()[0][1], parents[0].genes.values()[1][0]])
	%p1a22.text = "".join([parents[0].genes.values()[0][1], parents[0].genes.values()[1][1]])
	# 1st row
	%p2a11.text = "".join([parents[1].genes.values()[0][0], parents[1].genes.values()[1][0]])
	%child1.set_item(children[0].item)
	%child1.set_text(children[0].gene)
	%child2.set_item(children[1].item)
	%child2.set_text(children[1].gene)
	%child3.set_item(children[2].item)
	%child3.set_text(children[2].gene)
	%child4.set_item(children[3].item)
	%child4.set_text(children[3].gene)
	# 2nd row
	%p2a12.text = "".join([parents[1].genes.values()[0][0], parents[1].genes.values()[1][1]])
	%child5.set_item(children[4].item)
	%child5.set_text(children[4].gene)
	%child6.set_item(children[5].item)
	%child6.set_text(children[5].gene)
	%child7.set_item(children[6].item)
	%child7.set_text(children[6].gene)
	%child8.set_item(children[7].item)
	%child8.set_text(children[7].gene)
	# 3rd row
	%p2a21.text = "".join([parents[1].genes.values()[0][1], parents[1].genes.values()[1][0]])
	%child9.set_item(children[8].item)
	%child9.set_text(children[8].gene)
	%child10.set_item(children[9].item)
	%child10.set_text(children[9].gene)
	%child11.set_item(children[10].item)
	%child11.set_text(children[10].gene)
	%child12.set_item(children[11].item)
	%child12.set_text(children[11].gene)
	# 4th row
	%p2a22.text = "".join([parents[1].genes.values()[0][1], parents[1].genes.values()[1][1]])
	%child13.set_item(children[12].item)
	%child13.set_text(children[12].gene)
	%child14.set_item(children[13].item)
	%child14.set_text(children[13].gene)
	%child15.set_item(children[14].item)
	%child15.set_text(children[14].gene)
	%child16.set_item(children[15].item)
	%child16.set_text(children[15].gene)
