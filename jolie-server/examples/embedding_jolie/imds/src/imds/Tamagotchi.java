/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package imds;

/**
 *
 * @author fmontesi
 */
public class Tamagotchi
{
	private String feeling = "good";
	
	public Tamagotchi()
	{}
	
	public void feed( String food )
	{
		if ( food.equals("apple") ) {
			feeling = "good";
		} else {
			feeling = "bad";
		}
	}
	
	public String feeling()
	{
		return feeling;
	}
}
