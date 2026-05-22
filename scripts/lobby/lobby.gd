extends Node3D

@onready var terminal_ui = $TerminalUI
@onready var code_input = $TerminalUI/Control/Panel/VBoxContainer/LineEdit

func _ready():
	# Garante que a UI comece escondida
	terminal_ui.hide()

# Sinal conectado do Area3D (Quando o player entra na zona)
func _on_zona_terminal_body_entered(body: Node3D) -> void:
	if body.name == "Player3D": # Verifica se quem pisou foi o jogador
		terminal_ui.show()
		# Libera o mouse para o jogador conseguir clicar nos botões da UI
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Sinal conectado do Area3D (Quando o player sai da zona)
func _on_zona_terminal_body_exited(body: Node3D) -> void:
	if body.name == "Player3D":
		terminal_ui.hide()
		# Prende o mouse de volta no jogo para ele poder olhar em volta
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		# Opcional: Limpa o campo de texto se ele sair do terminal
		code_input.text = ""
