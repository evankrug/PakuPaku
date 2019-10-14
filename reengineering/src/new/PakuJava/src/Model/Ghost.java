/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Model;
import Model.movingGameObject;
/**
 *
 * @author kruge
 */



public class Ghost extends movingGameObject
{
    public enum Ghosts{
        stinky("stinky"), //red
        kinky("kinky"), //pink
        hinky("hinky"), //blue
        blaine("blaine");  //yellow

        private String name;

        Ghosts(String name) {
            this.name = name;
        }

        public String getName() {
            return name;
        }
    }
    
    public Ghost(Ghosts ghostname){
            System.out.println(ghostname.ToString() + " has spawned. Beware!");
    
    }
}
