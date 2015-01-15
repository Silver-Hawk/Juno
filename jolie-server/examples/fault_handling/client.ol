include "bank.iol"
include "time.iol"

include "console.iol"

outputPort Bank {
Location: "socket://localhost:8000/"
Protocol: sodep
Interfaces: BankInterface
}

main
{
	scope( s ) {
		install(
			this MyFault
			=>
			println@Console( "Handling fault.." )()
		);
		money = int( args[0] );

		i = 0;
		banks[i++] = "socket://localhost:8000/";
		banks[i++] = "socket://localhost:8001/";
		banks[i++] = "socket://localhost:8002/";

		for( i = 0, i < #banks, i++ ) {
			contacted[i] = false
		};

		for( i = 0, i < #banks, i++ ) {
			Bank.location = banks[i];
			sleep@Time( 50 )();
			change@Bank( money )()
			[
				this MyFault
				=>
				cH;
				scope( s ) {
					install( IOException => nullProcess );
					Bank.location = banks[^i];
					change@Bank( 0 - money )();
					println@Console( "Updated " + Bank.location )()
				}
			]
		}
	}
	|
	{
		sleep@Time( int( args[1] ) )();
		throw( RandomFault )
	}
}
