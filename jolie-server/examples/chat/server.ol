include "chat.iol"
include "console.iol"

execution { concurrent }

inputPort ChatInput {
Location: "socket://localhost:8000/"
Protocol: sodep
Interfaces: ChatInterface
}

cset {
roomName:
	OpenRoomRequest.roomName
	PublishRequest.roomName
	GetHistory.roomName
}

main
{
	openRoom( openReq )( openResp ) {
		csets.roomName = openReq.roomName;
		println@Console(
			"Created room "
			+ openReq.roomName
			+ " by " + openReq.username
		)()
	};
	while( true ) {
		[ publish( pubReq )() {
			m = "[" + pubReq.roomName + "] "
				+ pubReq.username + ": "
				+ pubReq.message;
			println@Console( m )();
			history += m + "\n"
		} ] { nullProcess }

		[ getHistory()( history ) {
			nullProcess
		} ] { nullProcess }
	}
}