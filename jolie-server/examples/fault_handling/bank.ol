include "bank.iol"
include "console.iol"

execution { sequential }

inputPort MyInput {
Location: Location_Bank
Protocol: sodep
Interfaces: BankInterface
}

init
{
	global.amount = int( args[0] )
}

main
{
	[ change( money )() {
		global.amount += money;
		println@Console(
			"Applied change " + money
			+ ". New amount: "
			+ global.amount
		)();
		if( global.amount > 120 ) {
			throw( MyFault )
		}
	} ] { nullProcess }
}