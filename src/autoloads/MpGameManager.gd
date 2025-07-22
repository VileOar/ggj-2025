extends Node

const HOST_ID = 1
const MAX_PLAYERS = 2


## MULTIPLAYER VARIABLES
# -1 -> not definied
# 0 -> local
# 1 -> host multiplayer from godot
# 2 -> client multiplayer from godot
# 3 -> steam Api
var multiplayer_status : int = -1

# Keeps track of every player in multiplayer
var mp_players = {}
