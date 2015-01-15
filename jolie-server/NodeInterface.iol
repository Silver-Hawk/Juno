type JoinReq:void {
}

type JoinedRes:void {
	.map:undefined
	.region:undefined
}

interface NodeInterface {
RequestResponse: 
	join(JoinReq)(JoinedRes)
}
