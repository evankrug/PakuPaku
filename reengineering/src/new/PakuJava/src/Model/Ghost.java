/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Model;

/**
 *
 * @author kruge
 */



public class Ghost 
{
    public enum Ghosts{
        stinky, //red
        kinky, //pink
        hinky, //blue
        blaine;  //yellow

        private String ToString() 
        {
            switch (this) {
		case stinky:
			return "stinky";
		case kinky:
			return "kinky";
		case hinky:
			return "hinky";
		case blaine:
			return "blaine";
		default:
			return "invalid ghost";
		}
        }
    }
    
    public Ghost(Ghosts ghostname){
            System.out.println(ghostname.ToString() + " has spawned. Beware!");
    
    }
}
