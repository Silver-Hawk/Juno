include "console.iol"
include "myInterface.iol"

constants
{
    myLocation = "",
    myName = ""
}

inputPort Input {
	Location: myLocation
	Protocol: soap
	Interfaces: MyInterface
}

main
{
	println@Console("[SERVER_START]\n")();

	message.m = "[SERVER_START]";
	message.sender = myName;
	message.id = new;

	//println@Console(myLocation)();

	messages[#messages] << message;

	while (true) {
	[ 
		sendNumber( x ) ( y ){
			y.number = x.number + 6
		}
	] { nullProcess }
	[
		getMessage( void ) ( m ){
			m << message[0]
		}
	]{ nullProcess }	 
	}
}