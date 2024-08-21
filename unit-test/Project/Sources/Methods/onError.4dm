//%attributes = {"invisible":true,"preemptive":"capable"}
var errorMessage : Text

var $errors : Collection
$errors:=Last errors:C1799

errorMessage:=$errors.extract("message").join(". ")
