type OpenRoomRequest:void {
	.username:string
	.roomName:string
}

type PublishRequest:void {
	.message:string
	.username:string
	.roomName:string
}

type GetHistory:void {
	.roomName:string
}

interface ChatInterface {
RequestResponse:
	openRoom(OpenRoomRequest)(void),
	publish(PublishRequest)(void),
	getHistory(GetHistory)(string)
}