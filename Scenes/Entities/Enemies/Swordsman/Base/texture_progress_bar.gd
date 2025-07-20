extends TextureProgressBar

@export var health_component : HealthComponent

func _ready() -> void:
	self.max_value = health_component.max_health
	self.value = self.max_value
	
func _process(delta: float) -> void:
	self.value = health_component.current_health
