/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Model;/*
import Model.MovingGameObject;
import org.json.simple.JSONObject;
import Controller.Controls;*/

/**
 *
 * @author kruge
 */
public class Paku extends MovingGameObject{

    private static Paku paku = new Paku();  //to make this class a Singleton
    private int remainingLife;
    private final int STARTINGLIFES = 3;
    private Location loc;
    private final int STARTING_X = 14;  //starting x and y coordinates of Paku; subject to change
    private final int STARTING_Y = 24;

    private Paku()
    {
        System.out.println("Paku has been constructed");
        remainingLife = STARTINGLIFES;
        loc = new Location(STARTING_X, STARTING_Y);
    }


    /*
    returns the single Paku instance
     */
    public static Paku getInstance()
    {
        return paku;
    }


    //JSONObject jo = new JSONObject();
    @Override
    public void move()
    {
        //jo.put(dir.toString());

    }


    public void substractLife(){
        remainingLife--;
    }

    public void addLife(){
        remainingLife++;
    }

    public boolean isGameOver(){
        return remainingLife > 0;
    }

    public int getRemainingLife()
    {
        return remainingLife;
    }

    @Override
    public Location getLoc() {
        return loc;
    }


    public void setLoc(Location loc) {
        this.loc = loc;
    }
    public void setDir(Direction dir)
    {
        this.facingDirection = dir;
    }
    public void reset()
    {
        loc.setyLoc(STARTING_Y);
        loc.setxLoc(STARTING_X);
    }

}
