extends CanvasLayer

func _ready() -> void:
	NG.on_signed_in.connect(_onSignedIn)
	NG.on_signed_out.connect(_onSignedOff)
	NG.on_signin_cancelled.connect(_onSignInCanceled)
	NG.on_signin_started.connect(_onSignInStarted)
	
	if NG.signed_in:
		$Label3.text = "[color=green]Successfully logged in."
		$Log.text = "Click here to log-off\nto your account."
		if Global.os == "Web":
			$Log.disabled = true
		else:
			$Log.disabled = false
	else:
		$Log.text = "Click here to log-on\nto your account."
		$Label3.text = "Waiting for user input..."
			
func _onSignedIn():
	if Global.os == "Web":
		$Log.disabled = true
	else:
		$Log.disabled = false
	$Close.disabled = false
	$Log.text = "Click here to log-off\nto your account."
	$Label3.text = "[color=green]Successfully logged in."
		
func _onSignedOff():
	$Log.disabled = false
	$Close.disabled = false
	$Log.text = "Click here to log-on\nto your account."
	$Label3.text = "[color=red]Successfully logged off."
	
func _onSignInCanceled():
	$Log.disabled = false
	$Close.disabled = false
	$Label3.text = "User canceled sign-in."
	
func _onSignInStarted():
	$Label3.text = "Signing-in..."

func _on_close_pressed() -> void:
	self.visible = false

func _on_log_pressed() -> void:
	if !NG.signed_in:
		NG.sign_in()
	else:
		NG.sign_out()
	$Log.disabled = true
	$Close.disabled = true
