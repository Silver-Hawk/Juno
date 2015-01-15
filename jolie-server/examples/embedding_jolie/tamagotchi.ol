include "console.iol"

execution { sequential }

interface TamagotchiInterface {
RequestResponse:
	feed(undefined)(undefined),
	play(undefined)(undefined),
	sleep(undefined)(undefined)
}

inputPort TamagotchiInput {
Location: "local"
Interfaces: TamagotchiInterface
}

main
{
	[ feed( request )( "Feeling " + feeling ) {
		println@Console( "Got some food: " + request.food )();
		if ( request.food == "apple" ) {
			feeling = "good"
		} else {
			feeling = "bad"
		}
	} ]
	{ nullProcess }

	[ play()() { nullProcess } ]
	{ nullProcess }
	
	[ sleep()() { nullProcess } ]
	{ nullProcess }
}