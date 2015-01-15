define split_reqion_procedure {
	undef(split1);
	undef(split2);
	split1 << my.region;
	split2 << my.region;
	
	if (my.region.xsize >= my.region.ysize) {
		xsplit = my.region.xsize / 2;
		ysplit = my.region.ysize;
		split1.xend -= xsplit;
		split2.xstart += xsplit;
		split1.xsize = split2.xsize = split1.xend - split1.xstart;
		println@Console("splitting on x:" + xsplit)()
	} 
	else
	{
		xsplit = my.region.xsize ;
		ysplit = my.region.ysize / 2;
		split1.yend -= ysplit;
		split2.ystart += ysplit;
		split1.ysize = split2.ysize = split1.yend - split1.ystart;
		println@Console("splitting on y:" + ysplit)()	
	};

	undef(split1.content);
	undef(split2.content);
	
	//split elements in region
	for(i=0,i<#my.region.content,i++){
		element << my.region.content[i];
		println@Console("xsplit:" + xsplit)();
		println@Console("element.x:" + element.x)();
		if (element.x < xsplit)
			println@Console("element.x < xsplit")();
		if (element.y < ysplit)
			println@Console("element.y < ysplit")();


		if (element.x < xsplit+split1.xstart && elemment.y < ysplit+split1.ystart){
			println@Console("adding to split1")();
			split1.content[#split1.content] << element
		}
		else
		{
			println@Console("adding to split2")();
			split2.content[#split2.content] << element
		}
	};
	undef(my.region)
}

define printArray {
	getJsonString@JsonUtils(debug)(debug2);
	println@Console("[DEBUG]" + debug_msg + debug2)();
	undef(debug);
	undef(debug_msg)
}