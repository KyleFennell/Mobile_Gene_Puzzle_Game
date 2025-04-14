# TODO: split this into a Node class and a Resource class 

extends Resource
class_name SpeciesModule

var name: String
var kind: String
var hidden: bool
var parent: SpeciesModule
var params: Dictionary
var initial_params: Dictionary
var node: Node

func _init(data: Dictionary, modules: Array):
	self.name = data.get("name")
	self.kind = data.get("kind")
	self.hidden = data.get("hidden", false)
	self.initial_params = data.get("params", {})
	if data.has("parent"):
		self.parent = modules.filter(func(m): return m.name == data.get("parent"))[0]
	
func create_on(root: Node):
	if parent != null:
		parent.node.add_child(node)
	else:
		root.add_child(node)
	if self.hidden and self.node: node.hide()
	process_attributes(self.initial_params)

func process_attributes(dict: Dictionary):
	pass

func is_equal(other: SpeciesModule) -> bool:
	for param in params:
		if other.params[param] != params[param]:
			return false
	return true
