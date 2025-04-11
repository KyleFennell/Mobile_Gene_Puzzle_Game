extends Node

# usage: req_slot.connect("gui_input", Helpers.element_clicked_event.bind(req_slot, auto_fill_goal))
func element_clicked_event(event: InputEvent, payload, sig: Signal):
	print(payload, sig.get_name())
	#if not slot.has_item():
		#return
	if Settings.CLICK_CONTROLS:
		if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_NONE and not event.pressed:
			sig.emit(payload)

func clicked_event(event: InputEvent, element, sig: Signal):
	if Settings.CLICK_CONTROLS:
		if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_NONE and not event.pressed:
			sig.emit()

func deep_dictionary_equal(d1: Dictionary, d2: Dictionary):
	if not (d1.has_all(d2.keys) and d2.has_all(d1.keys)):
		return false
	
	for key in d1.keys():
	
		# if types not even equivelant 
		if not typeof(d1[key]) == typeof(d2[key]):
			return false
	
		# if both are dictionaries
		if d1[key] is Dictionary and d2[key] is Dictionary \
		and not deep_dictionary_equal(d1[key], d2[key]):
			return false
	
		# if both are arrays
		if d1[key] is Array and d2[key] is Array \
		and d1[key].hash() != d2[key].hash():
			return false
	
		# neither dictionary or array
		if d1[key] != d2[key]:
			return false
	
	return true
