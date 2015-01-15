include "console.iol"
include "runtime.iol"

execution { sequential }

interface TamagotchiInterface {
RequestResponse:
	feed(undefined)(undefined),
	play(undefined)(undefined),
	sleep(undefined)(undefined)
}

outputPort UI {
Interfaces: TamagotchiInterface
}

interface ShutdownInterface {
OneWay:
	shutdown(void)
}

inputPort TamagotchiInput {
Location: "socket://localhost:8000/"
Protocol: http
Interfaces: ShutdownInterface
Aggregates: UI
}

init
{
	x.type = args[0];
	x.filepath = args[1];
	loadEmbeddedService@Runtime( x )( UI.location )
}

main
{
	shutdown()
}