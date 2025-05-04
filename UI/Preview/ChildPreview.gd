extends Container

@onready var ItemDisplay = %ItemDisplay
@onready var PercentLabel = %PercentLabel

func set_item(item):
	ItemDisplay.set_item(item)

func set_percent(percent):
	PercentLabel.text = "%.2f%%" % (percent*100)

func set_text(text):
	PercentLabel.text = text
