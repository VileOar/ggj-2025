class_name UtilsNetwork
extends Node

static func is_port_available_in_machine_ip(port: int) -> bool:
	var sock := PacketPeerUDP.new()
	var err := sock.bind(port)
	if err == OK:
		sock.close()
		return true
	return false
