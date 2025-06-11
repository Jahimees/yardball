extends Node

signal left_goal
signal right_goal
signal reset #РЕАЛИЗОВАТЬ CALLBACK, А ТАКЖЕ ПРИСОЕДИНИИТЬ К ИГРОКАМ ДЛЯ УТСНОВКИ В СТАРТОВОЕ ПОЛОЖЕНИЕ

signal teams_changed

signal reset_players_positions

signal move_player_to(peer_id, position: Vector2)
signal reset_ball
