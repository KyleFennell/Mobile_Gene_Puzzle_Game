extends MarginContainer

@onready var ProgressBarTexture = %ProgressBarTexture
@onready var ProgressTimer = %ProgressTimer

@export var TIME = 2

signal timeout

func _ready():
	ProgressTimer.connect("timeout", func(): timeout.emit())

func _process(_delta: float):
	if not ProgressTimer.is_stopped():
		set_percent(1-(ProgressTimer.time_left/TIME))

func set_percent(perc: float):
	ProgressBarTexture.texture.set_percent(perc)

func start():
	ProgressTimer.start(TIME)

func stop():
	ProgressTimer.stop()

func is_running():
	return not ProgressTimer.is_stopped()
