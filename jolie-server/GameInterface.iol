type JoinGameReq:void {
	.list:undefined
}

type JoinGameRes:void {
	.list[1, *]:any 
} 

interface GameInterface {
RequestResponse: 
	join(JoinGameReq)(JoinGameRes)
}
