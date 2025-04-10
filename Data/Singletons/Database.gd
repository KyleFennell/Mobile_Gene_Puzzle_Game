extends Node

var Levels = {}
var Genes = {}
var Interactions = {}
var Contracts = {}
var ResearchContracts = {}
var Speciess = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	load_folder_data("Species", Species, "Speciess")
	#load_file_data("Genes", Gene, "Genes")
	#load_file_data("Interactions", Interaction, "Interactions")
	#load_file_data("Levels", Level, "Levels")
	load_file_data("Contracts", Contract, "Contracts")
	load_file_data("Tulip_Unlocks", ResearchContract, "ResearchContracts")
	
func load_file_data(data_name, resource_type, member):
	var my_csharp_script = preload("res://Data/Singletons/YmlToJson.cs")
	var my_csharp_node = my_csharp_script.new()
	var resources = JSON.parse_string(my_csharp_node.Convert("res://Data/DataFiles/"+data_name+".yml"))
	for res in resources:
		var new_resource = resource_type.new(res)
		self[member][res["name"]] = new_resource

func load_folder_data(folder_name: String, resource_type: Resource, member: String):
	var my_csharp_script = preload("res://Data/Singletons/YmlToJson.cs")
	var my_csharp_node = my_csharp_script.new()
	var dir = DirAccess.open("res://Data/DataFiles/Species")
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var res = JSON.parse_string(my_csharp_node.Convert("res://Data/DataFiles/"+folder_name+"/"+file_name))
		if res:
			res = resource_type.new(res)
			self[member][res.name] = res
		else:
			print("Error: failed to load species "+file_name)
		file_name = dir.get_next()
