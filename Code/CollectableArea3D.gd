extends Area3D
class_name CollectableArea3D

enum COLLECTABLE_TYPE {
	DIAMOND
}
@export var collectableType : COLLECTABLE_TYPE

signal aboutToBeCollected
signal collected(what : COLLECTABLE_TYPE, howMuch : int)
