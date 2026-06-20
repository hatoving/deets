class_name CollectableArea3D
extends Area3D

signal aboutToBeCollected
signal collected(what: COLLECTABLE_TYPE, howMuch: int)

enum COLLECTABLE_TYPE {
	STEEDIUM,
}

@export var collectableType: COLLECTABLE_TYPE
