extends CanvasLayer

@onready var enemiesDestroyedLabel: Label = $EnemiesDestroyedLabel
@onready var startGameLabel: Label = $StartGameLabel
@onready var startGameLayer: ColorRect = $StartGameLayer
@onready var endGameLabel: Label = $EndGameLabel
@onready var endGameLayer: ColorRect = $EndGameLayer

func _ready() -> void:
	startGameLabel.visible = true
	startGameLayer.visible = true
	enemiesDestroyedLabel.visible = false
	endGameLabel.visible = false
	endGameLayer.visible = false

func _on_enemy_spawner_enemy_destroyed(count: int) -> void:
	enemiesDestroyedLabel.text = "Enemies destroyed: " + str(count)


func _on_game_manager_start_game() -> void:
	_on_enemy_spawner_enemy_destroyed(0)
	startGameLabel.visible = false
	startGameLayer.visible = false
	enemiesDestroyedLabel.visible = true
	endGameLabel.visible = false
	endGameLayer.visible = false


func _on_game_manager_game_over() -> void:
	startGameLabel.visible = false
	startGameLayer.visible = false
	enemiesDestroyedLabel.visible = true
	endGameLabel.visible = true
	endGameLayer.visible = true
