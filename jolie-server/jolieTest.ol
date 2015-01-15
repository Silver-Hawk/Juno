include "console.iol"
include "NodeInterface.iol"
include "json_utils.iol"

//dht definitions
include "dht_defs.iol"
execution{ single }

constants
{
    myLocation = "",
    targetJoin = ""
}

inputPort MyInput {
    Location: myLocation
    Protocol: sodep
    Interfaces: NodeInterface
}

outputPort NeighborgOutput {
    Location: targetJoin
    Protocol: sodep
    Interfaces: NodeInterface
}

type obj : string {
    .x:int
    .y:int
    .elem:string
}

main
{
	//SelfInput.Location = "localhost";
    //SelfInput.Protocol = "sodep";
    MyLocation = args[2];
    println@Console(MyInput.protocol)();

    println@Console( "args size is " + #args)();
	for ( i = 0, i < #args , i++  ) {
    		println@Console( args[i] )()
	};


    println@Console("Operation = " + args[0])();
    //commands
    if (args[0] == "init") {
        map.xsize = int (args[1]);
        map.ysize = int (args[2]);
        println@Console("map.xsize = " + map.xsize)();
        println@Console("map.ysize = " + map.ysize)();

        //Content should be a json array mapping (x,y) values        
        with(elem1){ 
            .x=10; 
            .y=10;
            .elem[0].var1="test";
            .elem[0].var2="test2"
        };
        with(elem2){ 
            .x=39; 
            .y=25;
            .elem="test"
        };
        println@Console(elem1.x)();
        my.region.content[#my.region.content] << elem1;
        my.region.content[#my.region.content] << elem2;
        //jsonTest = "test";
        getJsonString@JsonUtils(my.region)(jsonTest);
        println@Console(jsonTest)();

        with(my.region) {
            .xstart = 0;
            .xend = map.xsize;
            .xsize = .xend - .xstart;
            .ystart = 0;
            .yend = map.ysize;
            .ysize = .yend - .ystart;
            .test = "test"
            
        };
        getJsonString@JsonUtils(my.region)(debug);
        println@Console("New region is: " + debug)();
        //my.region.content = map.content

        //neighbors = null;        

        println@Console( neighbors )()
    }
    else if (args[0] == "join") {
        join@NeighborgOutput () (joinRes);
        my.region << joinRes.region;
        map << joinRes.map;
        
        getJsonString@JsonUtils(my.region)(debug);
        println@Console("My region is: " + debug)();
        println@Console (joinRes.map.xsize) ()
    };

    while (true) {
        [ join( )( joinRes ) {
            /*
                split_reqion_procedure
                creates 2 new regions with their own contents
                * split1
                * split2
            */
            split_reqion_procedure;
            
            my.region << split1;
            
            //return variable joinRes
            undef(joinRes);
            joinRes.map << map;
            joinRes.region << split2;

            debug << split1;
            printArray;
            debug << split2;
            printArray
            
        }] { nullProcess }
    }

}