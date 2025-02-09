extends TileMapLayer

@onready var Select_Square = %SelectSquare

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var highlighted_coords = Vector2i(get_global_mouse_position()) - (Vector2i(get_global_mouse_position()) % self.tile_set.tile_size) + (self.tile_set.tile_size / 2)
	Select_Square.position = highlighted_coords
	Select_Square.show()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		
