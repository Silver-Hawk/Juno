include "console.iol"
include "myInterface.iol"

execution{ single }

inputPort Input {
	Location: myLocation
	Protocol: soap
	Interfaces: MyInterface
}

constants
{
    myLocation = "",
    myName = ""
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
			m << messages
		}
	]{
		undef(m);
		undef(messages[0])
	}

	[
		getMessages( void ) ( m ){
			undef(m);
			m.messages << messages
		}
	]{
		undef( m )
	}

	[
		putMessage( m ) ( m ){
			if(m.id == "new") m.id = new;
			messages[#messages] << m
		}
	] { nullProcess }

	}
}