extends Container

@export var PREDICTION_TIME = 5

@onready var Parent1 = %Parent1
@onready var Parent2 = %Parent2
@onready var Children = %Children
@onready var Progress = %ProgressBar
@onready var ChildPreview = preload("res://UI/Preview/ChildPreview.tscn")

func _ready() -> void:
	Parent1.slot_contence_changed.connect(on_parent_changed)
	Parent2.slot_contence_changed.connect(on_parent_changed)
	Progress.timeout.connect(on_progress_timeout)
	Progress.TIME = PREDICTION_TIME

func reset():
	Parent1.set_item(null)
	Parent2.set_item(null)
	reset_children()
	stop_predicting()

func reset_children():
	for child in Children.get_children():
		child.queue_free()

func start_predicting():
	Progress.start()

func stop_predicting():
	Progress.stop()

func on_parent_changed():
	reset_children()
	if Parent1.has_item() && Parent2.has_item():
		stop_predicting()
		start_predicting()
	else:
		stop_predicting()

func on_progress_timeout():
	var child_percentages = GeneHelpers.generate_children_with_percentages(Parent1.item, Parent2.item)
	var phenotype_percentages = GeneHelpers.generate_phenotype_percents(child_percentages)
	for child in phenotype_percentages:
		var child_preview = ChildPreview.instantiate()
		Children.add_child(child_preview)
		child_preview.set_item(child.child)
		child_preview.set_percent(child.chance)
