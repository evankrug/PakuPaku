package Controller;

import Model.Ghost;
import Model.Ghost.Ghosts;
import Model.Paku;
import java.util.ArrayList;
import java.util.List;
import java.lang.Math;


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
    private final int elroy = 20;  //I believe this refers to the number of dots paku must eat before blinky speeds up. Source: https://paku.fandom.com/wiki/Blinky
    private final int superElroy = 10;
    private final int dotPoint = 10;

    private int gamelevel;
    private GameStatus gameStatus;

    private final double ghostSpeed = 10;
    private final double ghostSpeedToThePower = 0.6;
    private Paku paku;

    public GameController() {
        System.out.println("Game controller has been created");
        ghostlist = new ArrayList<>();
        gamelevel = 0;
    }

    //Responsible for setting up the game
    public void startGame() {
        paku = Paku.getInstance();
        spawnGhosts();
        gameStatus = GameStatus.staring;
    }

    public int increaseGhostSpeed(int ghostSpeed) {
        return (int) Math.pow(gamelevel, ghostSpeedToThePower);
    }

    //creates the four ghosts for gameplay
    public void spawnGhosts() {
        ghostlist.add(new Ghost(Ghosts.stinky)); //red
        ghostlist.add(new Ghost(Ghosts.kinky)); //blue
        ghostlist.add(new Ghost(Ghosts.hinky)); //pink
        ghostlist.add(new Ghost(Ghosts.blaine)); //orange

    }


    //Called every frame(or whenever timer ticks)
    public void update(){
        Controls input = receivedUserInput();
        pakuUpdate(input);
    }

    //talks to frontend, return input enum
    private Controls receivedUserInput() {
        return null;
    }

    private void pakuUpdate(Controls input){
        pakuMove(input);
        if(collideWithGhost())
        {
            collideWithGhostProtocol();
            if(gameStatus == GameStatus.GameOver)
                return;
        }
        else{
            ghostsMove();
        }
        if(collideWithGhost())
        {
            collideWithGhostProtocol();
            if(gameStatus == GameStatus.GameOver)
                return;
        }
        
        pakuEatsDots();
    }

    private void pakuEatsDots() {
    }

    private void collideWithGhostProtocol() {
        if(!checkPakuAlive()){
            gameStatus = GameStatus.GameOver;
            return;
        }
    }

    private boolean checkPakuAlive() {

    }

    private void ghostsMove() {
        for (Ghost ghost: ghostlist) {
            ghost.move();
        }
    }

    private boolean collideWithGhost() {
        for(Ghost ghost : ghostlist){
            if((ghost.getPositionX() == paku.getPositionX()){
                return true;
            }
        }

        return false;
    }

    private void pakuMove(Controls input){

    }
}
    

