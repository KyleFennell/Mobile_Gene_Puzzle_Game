extends MarginContainer

@onready var ProgressBarTexture = %ProgressBarTexture
@onready var ProgressTimer = %ProgressTimer

@export var TIME = 2

# used for when the timer was loaded to correctly update the progress bar
var resume_offset = 0
signal timeout

func _ready():
	ProgressTimer.connect("timeout", on_timeout)

func _process(_delta: float):
	if not ProgressTimer.is_stopped():
		set_percent((1-(ProgressTimer.time_left/TIME))*(1-resume_offset)+resume_offset)

func set_percent(perc: float):
	ProgressBarTexture.texture.set_percent(perc)

func start():
	ProgressTimer.start(TIME)

func stop():
	set_percent(0)
	ProgressTimer.stop()

func resume_from(time: float, resume_offset: float):
	if time == 0:
		return
	self.resume_offset = resume_offset
	ProgressTimer.start(time)

func is_running() -> bool:
	return not ProgressTimer.is_stopped()

func time_left() -> float:
	return ProgressTimer.time_left

func on_timeout():
	resume_offset = 0
	ProgressTimer.wait_time = TIME
	timeout.emit()

func save_data() -> Dictionary:
	return {
		"time": ProgressTimer.time_left,
		"offset": 1-(ProgressTimer.time_left/TIME)
	}

func load_data(data: Dictionary):
	resume_from(data["time"], data["offset"])
