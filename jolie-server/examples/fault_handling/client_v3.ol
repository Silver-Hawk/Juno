include "bank.iol"

include "console.iol"

outputPort Bank1 {
Location: "socket://localhost:8000/"
Protocol: sodep
Interfaces: BankInterface
}

outputPort Bank2 {
Location: "socket://localhost:8001/"
Protocol: sodep
Interfaces: BankInterface
}

main
{
	money = int( args[0] );
	{
		scope( s1 ) {
			withdraw@Bank1( money )()
			[
				this
				=>
				println@Console( "Hey1" )()
			]
		}
		|
		scope( s2 ) {
			deposit@Bank2( money )()
			[
				this
				=>
				println@Console( "Hey2" )();
				cH
			]
		}
	}
}
