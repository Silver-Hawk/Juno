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
	scope( s ) {
		install(
			NotEnoughMoney
			=>
			println@Console( "No harm done" )()
		);
		money = int( args[0] );
		{
			withdraw@Bank1( money )()
			|
			deposit@Bank2( money )()
				[
				NotEnoughMoney
				=>
				install(
					NotEnoughMoney
					=>
					println@Console( "Call the Insurance Company (911)" )()
				);
				withdraw@Bank2( money )()
				]
		}
	}
}