/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Controller;

import Model.Ghost;
import Model.Ghost.Ghosts;
import Model.Paku;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author kruge
 */
public class GameController {
    private List<Ghost> ghostlist;
    private final int NUM_GHOSTS = 4;

    //values from PAS file lines 220-229
    private final int pointsPerLife = 10000;
    private final int startingLives = 3;
    private final int startingLevel = 0;

    private final int startingDots = 244;
    private final int fruitCounter1 = startingDots - 70;
    private final int fruitCounter2 = fruitCounter1 - 100;
    private final int elroy = 20;  //I believe this refers to the number of dots paku must eat before blinky speeds up. Source: https://pacman.fandom.com/wiki/Blinky
    private final int superElroy = 10;

    public GameController() {
        System.out.println("Game controller has been created");
        ghostlist = new ArrayList<Ghost>();
    }

    //Responsible for setting up the game
    public void startGame() {
        Paku paku = new Paku();
        spawnGhosts();

    }

    //creates the four ghosts for gameplay
    public void spawnGhosts() {
        ghostlist.add(new Ghost(Ghosts.stinky)); //red
        ghostlist.add(new Ghost(Ghosts.kinky)); //blue
        ghostlist.add(new Ghost(Ghosts.hinky)); //pink
        ghostlist.add(new Ghost(Ghosts.blaine)); //orange

    }
}
    

