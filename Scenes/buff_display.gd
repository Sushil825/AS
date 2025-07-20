extends Panel

@onready var image : TextureRect = $TextureRect
@onready var timeText : Label = $Label

func _ready() -> void:
	self.visible = false

func _process(delta: float) -> void:
	if timeText.text == "0":
		self.visible = false

func setTexture(buffImage: CompressedTexture2D) -> void:
	image.texture = buffImage

func setText(time: float) -> void:
	timeText.text = str(int(time))

func ToggleVisibility(seen : bool) -> void:
	self.visible = seen
