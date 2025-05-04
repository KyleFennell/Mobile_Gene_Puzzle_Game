extends MarginContainer

var ItemDisplay = load("res://UI/Preview/ChildPreview.tscn")

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
