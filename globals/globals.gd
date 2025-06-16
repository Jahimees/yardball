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
