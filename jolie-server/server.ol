include "console.iol"
include "myInterface.iol"

inputPort Input {
	Location: myLocation
	Protocol: soap
	Interfaces: MyInterface
}

constants
{
    myLocation = "",
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
}