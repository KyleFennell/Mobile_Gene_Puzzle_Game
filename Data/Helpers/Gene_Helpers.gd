extends Node
class_name GeneHelpers

static func get_phenotype(species: Species, genes: Dictionary):
	var matching_phenotypes = {}

	# get phenotypes for genes
	for gene in genes:
		var phenotypes = species.genome[gene].phenotypes
		for phenotype in phenotypes:
			if alleles_match(phenotype, genes[gene]):
				_merge_phenotypes(matching_phenotypes, phenotypes[phenotype].duplicate(true))
				break;
	
	for interaction in species.interactions:
		var results = interaction.process_interaction(matching_phenotypes.get("interactions", []))
		_merge_phenotypes(matching_phenotypes, results)
	
	return matching_phenotypes

static func _merge_phenotypes(p1: Dictionary, p2: Dictionary):
	# merge modules dictionary
	if "modules" in p1 and "modules" in p2:
		p1["modules"].merge(p2["modules"])
		for module in p2["modules"]:
			#overwrite existing values
			p1["modules"][module].merge(p2["modules"][module], true)
	elif "modules" in p2:
		p1["modules"] = p2["modules"]
	# merge new uniqu interactions into array
	if "interactions" in p1 and "interactions" in p2:
		#p1["interactions"].append_array(p2["interactions"])
		for i in p2["interactions"]:
			if not i in p1["interactions"]:
				p1["interactions"].append(i)
	elif "interactions" in p2:
		p1["interactions"] = p2["interactions"]


static func generate_child(p1: Item, p2: Item)-> Item:
	#generates a random child from two parents mutations included
	var child = _generate_combo_child(p1, p2)
	return _generate_genetic_child(p1, p2) if child == null else child


static func _generate_genetic_child(p1: Item, p2: Item) -> Item:
	var child = {"genes": {}}
	for gene in p1.genes:
		var new_gene = p1.genes[gene][randi()%2] + p2.genes[gene][randi()%2]
		child["genes"][gene] = sort_gene(new_gene, p1.species.genome[gene].alleles)
		child["species"] = p1.species.name
	return Item.new(child)


static func _generate_combo_child(p1: Item, p2: Item) -> Item:
	# attempts to generate a mutated child.
	# returns null if no mutation is generated
	var possible_combos = []
	#var hidden_combinations = Database.Levels[Globals.current_level].hidden_combinations
	# get all the valid combos and their chances
	#for combo in hidden_combinations:
		#if combo.check_match(p1, p2):
			#possible_combos.append(combo)
	# pick a random mutation from the list respecting their probabilities
	var remaining_chance = randf()
	for combo in possible_combos:
		remaining_chance -= combo.chance
		if remaining_chance <= 0:
			return _create_combo_child(combo)
	return null


static func _create_combo_child(combo: HiddenCombination) -> Item:
	if not combo.discovered:
		_discover_alleles_from_genes(combo.child.genes)
		Events.show_modal.emit({
			"heading": "Mutation Found",
			"message": "",
			"item": combo.child
		})
		Events.allele_discovered.emit()
	combo.discovered = true
	return combo.child.full_duplicate()


static func _discover_alleles_from_genes(genes: Dictionary) -> void:
	# iterates through all genes and if any of the alleles are hidden
	# it erases them from the hidden dictionary
	var hidden_alleles = Database.Levels[Globals.current_level].hidden_alleles
	for gene in genes:
		if hidden_alleles.has(gene):
			for allele in genes[gene]:
				hidden_alleles[gene].erase(allele)


class _ChildChancePair:
	# small private data class for readability
	var child: Item
	var chance: float
	func _init(_child: Item, _chance: float):
		self.child = _child
		self.chance = _chance


static func generate_children_with_percentages(p1: Item, p2: Item) -> Array[_ChildChancePair]:
	# generates all possible children for the 
	#var combo_children = _get_combo_children(p1, p2)
	#var remaining_chance = combo_children.reduce(func(accum, c: _ChildChancePair): return accum - c.chance, 1.0)
	var remaining_chance = 1.0
	var potential_genes = _generate_potential_genes(p1, p2)
	var children = _generate_children_from_genes(potential_genes, p1.species)
	var children_items: Array[_ChildChancePair]
	children_items.assign(_convert_children(children).map(
		func(child): 
			child.chance *= remaining_chance
			return child
	))
	#children_items.append_array(combo_children)
	return children_items

static func _get_combo_children(p1, p2) ->Array[_ChildChancePair]:
	var combo_children: Array[_ChildChancePair] = []
	for combo in Database.Levels[Globals.current_level].hidden_combinations:
		if combo.check_match(p1, p2):
			var child = combo.child.full_duplicate()
			combo_children.append(_ChildChancePair.new(child, combo.chance))
	return combo_children


static func _generate_potential_genes(p1: Item, p2:Item) -> Dictionary:
	# generate a list of all combinations for each gene 
	# e.g. parents: Xx Xx -> [XX, Xx, xx]
	var potential_genes = {}
	for gene in p1.genes:
		potential_genes[gene] = {}
		for i in [[0, 0], [0, 1], [1, 0], [1, 1]]:
			var new_gene_value = p1.genes[gene][i[0]] + p2.genes[gene][i[1]]
			new_gene_value = sort_gene(new_gene_value, p1.species.genome[gene].alleles)
			if potential_genes[gene].has(new_gene_value):
				potential_genes[gene][new_gene_value] += 0.25
			else:
				potential_genes[gene][new_gene_value] = 0.25
	return potential_genes


static func _generate_children_from_genes(potential_genes: Dictionary, species: Species) -> Array[Dictionary]:
	var children = [{"child": { "genes": {}, "species": species.name}, "chance": 1}]
	for gene in potential_genes:
		var next_children: Array[Dictionary] = []
		for child in children:
			for value in potential_genes[gene]:
				var temp = child.duplicate(true)
				temp["child"]["genes"][gene] = value
				temp["chance"] *= potential_genes[gene][value]
				next_children.append(temp)
		children = next_children
	return children


static func _convert_children(children: Array[Dictionary]) -> Array[_ChildChancePair]:
	# convert children from dict to Items
	var children_items: Array[_ChildChancePair] = []
	for child in children:
		children_items.append(
			_ChildChancePair.new(
				Item.new(child["child"]), 
				child["chance"]
			)
		)
	return children_items


static func generate_phenotype_percents(children: Array[_ChildChancePair]) -> Dictionary:
	# aggregates all phenotypes from the list of genotypical children
	# and produces their percentages. It skips hidden children as their phenotype
	# isn't known to the player
	var phenotypes = {}
	for child in children:
		if is_hidden(child["child"]):
			continue
		var properties = get_phenotype(child["child"].species, child["child"].genes)
		var phenotype = ""
		for property in properties:
			phenotype += str(properties[property])
		if not phenotype in phenotypes:
			phenotypes[phenotype] = {
				"item": child["child"],
				"chance": child["chance"]
			}
		else:
			phenotypes[phenotype]["chance"] += child["chance"]
	return phenotypes


static func is_hidden(child: Item) -> bool:
	# if any allele in the child is hidden return true
	if Globals.current_level == "Story":
		return false
	var hidden_alleles = Database.Levels[Globals.current_level].hidden_alleles
	for gene in child.genes:
		if hidden_alleles.has(gene):
			for allele in child.genes[gene]:
				if allele in hidden_alleles[gene]:
					return true
	return false


static func sort_gene(gene: String, dominance: Array[String]) -> String:
	# sorts the gene based on the dominance hierarchy array
	var arr = []
	for i in gene.length():
		arr.append(gene[i])
	arr.sort_custom(_get_sorter_by_array(dominance))
	return "".join(arr)


static func _get_sorter_by_array(arr: Array) -> Callable:
	# returns a comparison function that sorts based on position in an array
	var f = func (a, b):
		return arr.find(a) < arr.find(b)
	return f


static func genes_match(g1: Dictionary, g2: Dictionary) -> bool:
	# checks equivelance accounting for wildcards
	for gene in g1:
		if not g2.has(gene):
			return false
		if not alleles_match(g1[gene], g2[gene]):
			return false
	return true


static func phenotypes_match(phen1: Dictionary, phen2: Dictionary) -> bool:
	var p1_keys: Array = phen1.keys()
	var p2_keys: Array = phen2.keys()
	p1_keys.sort()
	p2_keys.sort()
	
	if p1_keys != p2_keys:
		return false
		
	for k in phen1.keys():
		if phen1[k] != phen2[k]:
			return false
	
	return true


static func item_satisfies_restrictions(item: Item, restrictions: ResearchContract.GoalRestrictions) -> bool:
	if not genes_match(item.genes, restrictions.genes):
		return false

	var item_phenotype = get_phenotype(item.species, item.genes)
	var restrictions_phenotype = get_phenotype(restrictions.species, restrictions.genes)
	restrictions_phenotype = _merge_phenotypes(restrictions_phenotype, restrictions.modules)

	return phenotypes_match(item_phenotype, restrictions_phenotype)
	

static func alleles_match(a1: String, a2: String) -> bool:
	for i in a1.length(): 
		if a1[i] == "*" or a2[i] == "*" or a1[i] == a2[i]:
			continue
		return false
	return true


static func get_raw_genotype(species: Species, genes: Dictionary) -> String:
	# concatenates all alleles together creating a unique string for the genotype
	var raw_genotype = ""
	for gene in species.genome:
		raw_genotype += genes[gene]
	return raw_genotype


static func get_heterozygous_count(genes: Dictionary) -> int:
	var count = 0
	for gene in genes.values():
		if gene[0] != gene[1]:
			count += 1
	return count


static func get_heterozygous_count_raw(raw_genotype: String) -> int:
	var count = 0
	for i in raw_genotype.length()/2:
		if raw_genotype[2*i] != raw_genotype[2*i+1]:
			count += 1
	return count
