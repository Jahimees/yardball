extends Node

signal goal

signal teams_changed

signal reset_players_positions

signal move_player_to(peer_id, position: Vector2)
signal reset_ball

signal block_players(is_blocked: bool)

signal game_end

signal change_game_ui_visible(peer_id)
signal update_hud_values(smash_cd: float, stamina: float)
