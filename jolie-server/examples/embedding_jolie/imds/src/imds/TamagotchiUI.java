/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package imds;

import javax.swing.JOptionPane;
import jolie.runtime.JavaService;
import jolie.runtime.Value;
import jolie.runtime.embedding.RequestResponse;

/**
 *
 * @author fmontesi
 */
public class TamagotchiUI extends JavaService
{
	private final Tamagotchi tamagotchi;
	
	public TamagotchiUI()
	{
		super();
		tamagotchi = new Tamagotchi();
	}
	
	@RequestResponse
	public String feed( Value request )
	{
		tamagotchi.feed( request.getFirstChild( "food" ).strValue() );
		String feeling = tamagotchi.feeling();
		JOptionPane.showMessageDialog( null, "Your tamagotchi feels " + feeling );
		return feeling;
	}
	
	@RequestResponse
	public Value play( Value game )
	{
		return Value.create();
	}
	
	@RequestResponse
	public Value sleep( Value time )
	{
		return Value.create();
	}
}
