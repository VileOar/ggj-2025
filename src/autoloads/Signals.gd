extends Node
## This autoload is responsible for storing all global signals.
## It should have no functionality whatsoever.
## It just declares the signals that should be accessible by anyone.

## Simply declare signal and add warning ignore.
@warning_ignore("unused_signal")
signal crab_lose(player_index)
