extends MarginContainer

@export var dialogue_json: JSON
var state = {}
var skip_next_textanimation = false
var speed = 40
var visible_characters = 0.0
var current_text = ""
var text_animation_finished = false
var eod_reached = false

signal dialogue_event

func _ready():
	($EzDialogue as EzDialogue).start_dialogue(dialogue_json, state, "Tutorial_start")
	%ContinueButton.button_up.connect(_on_continue_button_pressed)
	gui_input.connect(_on_gui_input)


func _process(delta: float) -> void:
	if text_animation_finished:
		return
	if visible_characters < %TextBox.get_total_character_count():
		visible_characters += clamp(speed*delta, 0, %TextBox.get_total_character_count())
		%TextBox.visible_characters = visible_characters
	else:
		text_animation_finished = true
		_on_text_animation_finished()

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_NONE and event.is_pressed():
		finish_text_animation()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		finish_text_animation()

func _on_ez_dialogue_dialogue_generated(response: DialogueResponse) -> void:
	%ContinueButton.hide()
	eod_reached = response.eod_reached

	if skip_next_textanimation:
		finish_text_animation()
	else:
		visible_characters = 0
		text_animation_finished = false
	
	%TextBox.visible_characters = visible_characters
	%TextBox.text = response.text
	%ContinueButton.text = "continue" if response.choices == [] else response.choices[0]

func _on_ez_dialogue_custom_signal_received(value: Variant) -> void:
	var params = (value as String).split(",")
	match params[0]:
		"skip_text_animation":
			skip_next_textanimation = true
		"show_flower":
			match params[1]:
				"red_tulip":
					dialogue_event.emit("show_red_tulip")
				"yellow_tulip":
					dialogue_event.emit("show_yellow_tulip")

func finish_text_animation():
	visible_characters = %TextBox.get_total_character_count()
	%TextBox.visible_characters = visible_characters
	skip_next_textanimation = false
	_on_text_animation_finished()

func process_event_completion(value: String):
	var params = value.split(",")
	match params[0]:
		"hover_flower":
			match params[1]:
				"red_tulip":
					_on_red_tulip_hover()
				"yellow_tulip":
					_on_yelow_tulip_hover()

func _on_text_animation_finished():
	print("text animation finished")
	if not eod_reached:
		%ContinueButton.show()

func _on_red_tulip_hover():
	print("red tulip hover complete")
	($EzDialogue as EzDialogue).start_dialogue(dialogue_json, state, "red_tulip_hover")

func _on_yelow_tulip_hover():
	print("yellow tulip hover complete")
	($EzDialogue as EzDialogue).start_dialogue(dialogue_json, state, "yellow_tulip_hover")

func _on_continue_button_pressed():
	$EzDialogue.next()
