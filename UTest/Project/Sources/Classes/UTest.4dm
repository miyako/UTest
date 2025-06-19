Class constructor
	This:C1470.UTest_result:=[]
	This:C1470.CLI:=cs:C1710.CLI.new()
	
Function build_HL($list : Integer)
	$imgPath:=Folder:C1567("/RESOURCES/Images").platformPath
	READ PICTURE FILE:C678($imgPath+"fail.svg"; $failPict)
	READ PICTURE FILE:C678($imgPath+"success.svg"; $successPict)
	
	$classes:=Form:C1466.UTest.UTest_result.distinct("class")
	
	$index:=0
	For each ($class; $classes)
		$tests:=Form:C1466.UTest.UTest_result.query("class == :1"; $class)
		$sublist:=New list:C375
		For each ($test; $tests)
			APPEND TO LIST:C376($sublist; $test.function+" --> "+$test.description; 0)
			SET LIST ITEM PARAMETER:C986($sublist; 0; "UUID"; $test.UUID)
			If ($test.success)
				SET LIST ITEM ICON:C950($sublist; 0; $successPict)
			Else 
				SET LIST ITEM ICON:C950($sublist; 0; $failPict)
			End if 
			$index+=1
		End for each 
		APPEND TO LIST:C376($list; $class; 0; $sublist; True:C214)
	End for each 
	
Function createMock($formula; $resultToRestur)
	return New object:C1471($formula; Formula:C1597($resultToRestur))
	
Function describe($description : Text) : cs:C1710.UTest
	This:C1470.description:=$description
	return This:C1470
	
Function expect($receivedValue : Variant) : cs:C1710.UTest
	This:C1470.receivedValue:=$receivedValue
	return This:C1470
	
Function resultText()->$resultText : Text
	$testsFailed:=This:C1470.UTest_result.query("success == :1"; False:C215)
	
	If ($testsFailed.length>0)
		$resultText:="Unit tests failed"
		This:C1470.CLI.print("Unit tests "; "bold").print("failed"; "196;bold").LF()
	Else 
		$resultText:="Unit tests passed"
		This:C1470.CLI.print("Unit tests "; "bold").print("passed"; "82;bold").LF()
	End if 
	$resultText+="\r"
	
	$message:="Tests: "+String:C10(This:C1470.UTest_result.length)
	This:C1470.CLI.print($message; "244").LF()
	$resultText+=$message
	$resultText+="\r"
	
	$message:=String:C10($testsFailed.length)+" failed"
	This:C1470.CLI.print($message; "244").LF()
	$resultText+=$message
	$resultText+="\r"
	
	$message:=String:C10(This:C1470.UTest_result.length-$testsFailed.length)+" passed"
	This:C1470.CLI.print($message; "244").LF()
	$resultText+=$message
	$resultText+="\r"
	
	$message:="Time: "+String:C10(This:C1470.time)+" ms"
	This:C1470.CLI.print($message; "244").LF()
	$resultText+=$message
	$resultText+="\r"
	$resultText+="\r"
	
	$hr:="------------------------------"
	This:C1470.CLI.print($hr; "244").LF()
	$resultText+=$hr
	$resultText+="\r"
	
	$messages:=$testsFailed.extract("message")
	
	If ($messages.length#0)
		$last:=$messages.length-1
		For ($i; 0; $last)
			This:C1470.CLI.print($messages[$i]; "244")
			If ($i#$last)
				This:C1470.CLI.print($hr; "244").LF()
			End if 
		End for 
		$resultText+=$messages.join($hr+"\r")
	End if 
	
Function _setup($instance : Object)
	
	If ($instance.sut#Null:C1517)
		var $class : 4D:C1709.Class
		$class:=OB Class:C1730($instance.sut)
		If (OB Instance of:C1731($class; 4D:C1709.Class))
			$instance.testMethods:=[]
			$__prototype:=$class.__prototype
			var $property : Text
			For each ($property; $__prototype)
				If (OB Instance of:C1731($__prototype[$property]; 4D:C1709.Function))
					$instance.testMethods.push($property)
				End if 
			End for each 
			$instance.UTest:=cs:C1710.UTest.new()
		End if 
	End if 
	
Function run($testClasses : Collection) : cs:C1710.UTest
	
	$start:=Milliseconds:C459
	
	If ($testClasses#Null:C1517)
		
		var $testClass; $instance : Object
		var $class : 4D:C1709.Class
		For each ($testClass; $testClasses)
			$class:=$testClass.value
			Case of 
				: ($class.superclass.name="DataClass")
				: ($class.superclass.name="EntitySelection")
				: ($class.superclass.name="Entity")
				: ($class.superclass.name="DataStoreImplementation")
				Else 
					$instance:=$class.new()
					This:C1470._setup($instance)
					If ($instance.testMethods#Null:C1517)
						For each ($testMethod; $instance.testMethods)
							$instance[$testMethod]()
						End for each 
						This:C1470.UTest_result:=This:C1470.UTest_result.concat($instance.UTest.UTest_result)
					End if 
			End case 
		End for each 
	End if 
	
	This:C1470.time:=Milliseconds:C459-$start
	
	return This:C1470
	
Function show()
	$form:={UTest: This:C1470}
	$ref:=Open form window:C675("UTest")
	DIALOG:C40("UTest"; $form)
	CLOSE WINDOW:C154($ref)
	
Function toBe($expectedValue : Variant) : cs:C1710.UTest
	var errorMessage : Text
	errorMessage:=""
	If (True:C214)
		
		ON ERR CALL:C155(Formula:C1597(onError).source; ek local:K92:1)
		ASSERT:C1129($expectedValue=This:C1470.receivedValue)
		ON ERR CALL:C155("")
		
		This:C1470.UTest_result.push(This:C1470._build_result(errorMessage="" ? True:C214 : False:C215; Get call chain:C1662; This:C1470.description; $expectedValue; This:C1470.receivedValue; errorMessage))
		This:C1470._clearTmp()
		return This:C1470
		
	Else 
		If (Value type:C1509(This:C1470.receivedValue)=Value type:C1509($expectedValue)) && (This:C1470.receivedValue=$expectedValue)
			This:C1470.UTest_result.push(This:C1470._build_result(True:C214; Get call chain:C1662; This:C1470.description))
			This:C1470._clearTmp()
			return This:C1470
		End if 
		$message:=Choose:C955(Value type:C1509(This:C1470.receivedValue)#Value type:C1509($expectedValue); "Value types are different"; "Values are not equals")
		This:C1470.UTest_result.push(This:C1470._build_result(False:C215; Get call chain:C1662; This:C1470.description; $expectedValue; This:C1470.receivedValue; $message))
		This:C1470._clearTmp()
		return This:C1470
	End if 
	
	//MARK:-
	
Function _build_result($testResult : Boolean; $callChain : Collection; $description : Text; $expected : Variant; $received : Variant; $msg : Text)->$result : Object
	$objTest:=Position:C15("."; $callChain[1].name; *)>0 ? \
		{class: Split string:C1554($callChain[1].name; ".")[0]; function: Split string:C1554($callChain[1].name; ".")[1]} : \
		{class: Null:C1517; function: $callChain[1].name}
	
	$result:={}
	$result.UUID:=Generate UUID:C1066
	$result.success:=$testResult
	$result.testMethod:=$callChain[1].name
	$result.class:=$objTest.class
	$result.function:=$objTest.function
	$result.description:=$description
	$result.line:=$callChain[1].line
	
	$result.message:="--> "+$description+"\r"
	$result.message+="Function: "+$callChain[1].name+" - Line: "+String:C10($callChain[1].line)+"\r"+\
		"Expected: "+String:C10($expected)+"\r"+\
		"Recevied: "+String:C10($received)+"\r"+\
		$msg+"\r"
	
	This:C1470.CLI.print($result.class; "39").print("."; "bold").print($result.function; "100").LF()
	This:C1470.CLI.print($result.description; "244").LF()
	This:C1470.CLI.print("expected: "; "244").print(String:C10($expected); "244").LF()
	This:C1470.CLI.print("recevied: "; "244").print(String:C10($received); "244").LF()
	
	If ($testResult)
		This:C1470.CLI.print("success"; "82;bold").LF()
	Else 
		This:C1470.CLI.print("failure"; "196;bold").LF()
	End if 
	
Function _clearTmp()
	This:C1470.receivedValue:=Null:C1517
	This:C1470.description:=""