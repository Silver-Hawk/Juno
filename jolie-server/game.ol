//jolie standard libs
include "console.iol"
include "json_utils.iol"

//game server libs
include "GameInterface.iol"

execution{ single }

constants
{
    myLocation = "",
    joinLocation = ""
}

inputPort Input {
    Location: myLocation
    Protocol: sodep
    Interfaces: GameInterface
}

outputPort Output {
    Location: joinLocation
    Protocol: sodep
    Interfaces: GameInterface
}

main
{
    //add self to ip.list
    ip.list[#ip.list] = myLocation;
    
    println@Console(#ip.list)();
    //commands
    if (args[0] == "start") {
        getJsonString@JsonUtils(ip)(jsonTest);
        println@Console(jsonTest)()
    }
    else if (args[0] == "join") {
        //send own ip
        joinReq.list << ip.list;

        getJsonString@JsonUtils(joinReq)(jsonTest);
        println@Console(jsonTest)();
        join@Output (joinReq) (joinRes);

        ip.list << joinRes.list;
        
        getJsonString@JsonUtils(ip)(debug);
        println@Console("Ips: " + debug)()
    };

    while (true) {
        [ join( joinReq )( joinRes ) {
            /*
                split_reqion_procedure
                creates 2 new regions with their own contents
                * split1
                * split2
            */
            
            //return variable joinRes
            joinRes << ip;
            joinRes.list[#joinRes.list] = joinReq.list[0];
            getJsonString@JsonUtils(joinRes)(debug);
            println@Console(debug)()

        }] { nullProcess }
    }

}