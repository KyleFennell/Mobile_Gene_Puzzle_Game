extends Item
class_name GoalItem

const DEFAULT_TARGET_QUANITTY = 5
var properties: Dictionary = {}
var target_quantity: int
var _item: Item

func _init(dict: Dictionary):
	_item = super._init(dict)
	properties = dict.get("properties", {})
	target_quantity = int(dict.get("quantity", DEFAULT_TARGET_QUANITTY))

func get_item() -> Item:
	return _item

func equals(other: Item, identification_relevant: bool=false) -> bool:
	if not other is Item:
		return false
	if identification_relevant and identified != other.identified:
		return false
	if self.genes:
		return GeneHelpers.genes_match(other.genes, self.genes)
	if self.properties:
		return GeneHelpers.get_phenotype(other.genes) == self.properties
	return false
