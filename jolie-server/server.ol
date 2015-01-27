include "console.iol"
include "myInterface.iol"

inputPort Input {
	Location: myLocation
	Protocol: soap
	Interfaces: MyInterface
}

outputPort Output {
    Location: targetLocation
    Protocol: soap
    Interfaces: MyInterface
}

constants
{
    myLocation = "",
    targetLocation = "",
    myName = ""
}

execution{ concurrent }

init {
	println@Console("[SERVER_START]\n")();
	Input.location = myLocation
}

main
{
	//Message operations
	[
		getMessage( void ) ( m ){
			synchronized( mid ){
				undef(m);
				m << global.messages[0];
				undef(global.messages[0])
			}
		}
	
	]{
		nullProcess
	}

	[
		getMessages( void ) ( m ){
			synchronized( mid ){
				undef( m );
				m.messages << global.messages;
				undef(global.messages)
			}
		}
	]{
		nullProcess
	}

	[
		putMessage( r ) ( m ){
			synchronized( mid ){
				if(r.id == "new") r.id = new;
				undef( m );
				m << r;
				undef(r);
				global.messages[#global.messages] << m
			}
		}
	] { 
		nullProcess
	}

		
	//Lobby operations
	[
		startLobby( void ) ( r ) {
			iplist[#iplist] = Input.location;
			lobbystarted = true;
			r.iplist << iplist
		}
	] {
		undef(r)
	}
	[
		joinLobby( m ) ( r ) {
			//check if we are on the right server
			if(m.target == input.location)
				if(lobbystarted)
				{
					iplist[#iplist] = m.sender;
					r.iplist << iplist
				}
				else
				{
					r = null
				}
			//otherwise forward to target server
			else
			{
				Output.location = m.target;
				joinLobby@Output( m ) ( r )
			}

		}
	] {
		undef(r)
	}
}