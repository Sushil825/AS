extends TextureProgressBar

@export var health_component : HealthComponent

func _ready() -> void:
	self.max_value = health_component.max_health
	self.value = self.max_value
	
	health_component.health_changed.connect(
		func(current_health: int, max_health: int):
			self.value = current_health
	)
