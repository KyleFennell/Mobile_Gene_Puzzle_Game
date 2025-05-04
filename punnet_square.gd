extends VBoxContainer

func _ready() -> void:
	%MonoToggle.pressed.connect(_on_mono_toggle_toggled)

func _on_mono_toggle_toggled():
	if %MonoToggle.button_pressed:
		%MonoGene.hide()
		%DiHybrid.show()
	else:
		%MonoGene.show()
		%DiHybrid.hide()
