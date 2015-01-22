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


main
{
	println@Console("[SERVER_START]\n")();
	Input.location = myLocation;

	while (true) {
		//Message operations
		[
			getMessage( void ) ( messages[0] ){
				nullProcess
			}
		]{
			undef(messages[0])
		}

		[
			getMessages( void ) ( m ){
				m.messages << messages
			}
		]{
			undef( m );
			undef(messages)
		}

		[
			putMessage( m ) ( m ){
				if(m.id == "new") m.id = new;
				messages[#messages] << m
			}
		] { 
			undef( m ) 
		}

		[
			sendMessage( m ) ( m ){
				Output.location = m.target;
				putMessage@Output( m ) ( m )
			}
		] {
			undef(m)
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
}