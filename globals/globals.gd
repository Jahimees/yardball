extends Node

var win_goals: int = 0
var game_time: int = 0

var left_goals: int = 0
var right_goals: int = 0

var left_team_lobby := {}
var right_team_lobby := {}
var players_lobby := {}

var players := {}
var left_team := {}
var right_team := {}

enum GoalSideEnum {
	LEFT_GOAL = 0, 
	RIGHT_GOAL = 1
}

const DEFAULT_DELAY := 0.3

#PLAYER
const DEFAULT_PLAYER_SPEED := 200.0
const DEFAULT_PLAYER_STAMINA := 100.0
const SPRINT_PLAYER_SPEED := 300.0

const SMASH_RATIO := 6
const PUSH_RATIO := 2

const REDUCE_STAMINA_RATIO := 5
const RESTORE_STAMINA_RATIO := 10

#BALL
const SYNC_UPDATE_INTERVAL := 0.00000000000000000001

const GAME_FIELD_CENTER_POS := Vector2(576, 322)
