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


/*	Output.location = "socket://localhost:8090";

	tm.n.m = "test";
	putMessage@Output( tm ) ( tm2 );
*/

	while (true) {
		[ 
			sendNumber( x ) ( y ){
				y.number = x.number + 6
			}
		] { nullProcess }

		[
			getSyntax( void ) ( y ){
				y.test.hey = "some string";
				y.test.num = 1337;
				y.hest.n1.n2.n3 = 4;
				y[0] = 1;
				y[1] = 2;
				y[2] = 3
			}
		] {
			nullProcess
		}

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

	}
}