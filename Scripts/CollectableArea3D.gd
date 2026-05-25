extends Area3D
class_name CollectableArea3D

enum COLLECTABLE_TYPE {
	STEEDIUM
}
@export var collectableType : COLLECTABLE_TYPE

signal aboutToBeCollected
signal collected(what : COLLECTABLE_TYPE, howMuch : int)
