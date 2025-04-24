extends MarginContainer

@export var dialogue_json: JSON
var state = {}
var skip_next_textanimation = false
var speed = 0.02
var percent_visible = 0.0
var current_text = ""
var text_animation_finished = false
var eod_reached = false

signal dialogue_event

func _ready():
	($EzDialogue as EzDialogue).start_dialogue(dialogue_json, state, "Tutorial_start")
	%ContinueButton.button_up.connect(_on_continue_button_pressed)

func _process(delta: float) -> void:
	if text_animation_finished:
		return
	if percent_visible < 1:
		print(percent_visible, " ", %TextBox.visible_characters, " ", %TextBox.get_total_character_count())
		percent_visible += 1.0/%TextBox.get_total_character_count()/speed*delta
		%TextBox.visible_characters = %TextBox.get_total_character_count() * percent_visible
	else:
		text_animation_finished = true
		_on_text_animation_finished()

func _on_ez_dialogue_dialogue_generated(response: DialogueResponse) -> void:
	%ContinueButton.hide()
	eod_reached = response.eod_reached

	if skip_next_textanimation:
		percent_visible = 1
		skip_next_textanimation = false
		_on_text_animation_finished()
	else:
		percent_visible = 0
		text_animation_finished = false
	
	%TextBox.text = response.text
	print(%TextBox.text)
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
