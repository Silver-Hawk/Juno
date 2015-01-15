include "chat.iol"
include "console.iol"

outputPort Chat {
Location: "socket://localhost:8000/"
Protocol: sodep
Interfaces: ChatInterface
}

main
{
	if ( args[0] == "open" ) {
		openReq.username = args[1];
		openReq.roomName = args[2];
		openRoom@Chat( openReq )()
	} else if ( args[0] == "pub" ) {
		pubReq.username = args[1];
		pubReq.roomName = args[2];
		pubReq.message = args[3];
		publish@Chat( pubReq )()
	} else if ( args[0] == "hist" ) {
		req.roomName = args[1];
		getHistory@Chat( req )( history );
		println@Console( history )()
	}
}
