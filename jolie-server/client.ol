include "console.iol"
include "myInterface.iol"

outputPort B {
Location: "socket://localhost:8090"
Protocol: soap
Interfaces: MyInterface
}

main
{

	test.x = "lål den returnerer";
	test.y = 2;
	test.z = 3;
	test.o.o.x = 3;
	println@Console("test")();
	sendNumber@B( test ) ( result );
	println@Console( result.x ) ()
}
