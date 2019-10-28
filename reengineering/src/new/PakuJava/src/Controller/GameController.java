package Controller;

import Model.Ghost;
import Model.Paku;
import Model.GameStatus;
import Model.*;
import java.util.ArrayList;
import java.util.List;
import java.lang.Math;
import java.util.Arrays;

import java.io.IOException;

import com.opencsv.CSVReader;

import java.io.Reader;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.json.JSONException;
import org.json.JSONObject;


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
    private Score score;
    private final double ghostSpeed = 10;
    private final double ghostSpeedToThePower = 0.6;
    private Paku paku;

    private int frame;  //the number of the current frame
    private Direction inputDirection = Direction.stay;


    private JSONObject jo = new JSONObject();

    private ArrayList<ArrayList> map;
    private ArrayList<Integer> eachrow;
    private final String SAMPLE_CSV_FILE_PATH = "src/asset/map.csv";

    private int extraLives;

    public GameController() {
        System.out.println("Game controller has been created");
        ghostlist = new ArrayList<>();
        gamelevel = 0;
        map = new ArrayList<ArrayList>();
        LoadMap();
        startGame();
    }

    private void LoadMap() {
        // For showing the dicionary. do not remove.
        /*File file = new File(".");
        for(String fileNames : file.list()) System.out.println(fileNames);*/
        try (
                Reader reader = Files.newBufferedReader(Paths.get(SAMPLE_CSV_FILE_PATH));
                CSVReader csvReader = new CSVReader(reader);
        ) {
            // Reading Records One by One in a String array
            String[] nextRecord;
            while ((nextRecord = csvReader.readNext()) != null) {

                eachrow = new ArrayList<Integer>();

                for(String number: nextRecord){
                    System.out.println(number);

                    number = number.replaceAll("\\uFEFF", "");
                    int temp = Integer.parseInt(number);
                    eachrow.add(temp);
                }
                map.add(eachrow);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    //Responsible for setting up the game
    public void startGame() {
        paku = Paku.getInstance();
        spawnGhosts();
        score = new Score();
        gameStatus = GameStatus.mainMenu;
        while (!gameStatus.equals(GameStatus.closing))
        {
            while (gameStatus.equals(GameStatus.mainMenu))
            {

            }
            resetGame();
            while(gameStatus.equals(GameStatus.play))
            {
                if(gameStatus.equals(GameStatus.nextLevel))
                    nextLevel();
                else if(gameStatus.equals(GameStatus.pakuDiedButStillHasLifeLeft))
                    respawn();
            }
            while(gameStatus.equals(GameStatus.highScore))
            {

            }
            score.reset();
            gameStatus = GameStatus.mainMenu;
        }
    }



    public int increaseGhostSpeed(int ghostSpeed) {
        return (int) Math.pow(gamelevel, ghostSpeedToThePower);
    }

    //creates the four ghosts for gameplay
    public void spawnGhosts() {
        ghostlist.add(new Blaine()); //orange
        ghostlist.add(new Kinky()); //blue
        Stinky stinky = new Stinky();
        ghostlist.add(stinky); //red
        ghostlist.add(new Hinky(stinky)); //pink, Hinky needs Stinky's info to move. please do not modify

    }

    public void respawn()
    {
        paku.resetLocation();
        for(Ghost ghost : ghostlist){
            ghost.reset();
        }
        ghostlist.get(0).resetMultiplier();
    }
    public void resetGame()
    {
        paku.resetPaku();
        for(Ghost ghost : ghostlist){
            ghost.reset();
        }
        ghostlist.get(0).resetMultiplier();
        gamelevel = 1;
        extraLives = 1;
    }

    private void nextLevel() {
        paku.resetLocation();
        for(Ghost ghost : ghostlist){
            ghost.reset();
        }
        ghostlist.get(0).resetMultiplier();
        gamelevel = gamelevel++;
    }
    //Called every frame(or whenever timer ticks)
    public void update(){
        Controls input = receivedUserInput();
        if(input != Controls.escape && input != Controls.O && input != Controls.enter)
        {
            pakuUpdate((input.castToDir(input)));
        }
    }


    //talks to frontend, return input enum
    private Controls receivedUserInput() {

        return null;//Controls.getControl(uiInput(keyBoardInput));
    }



    /*
    This method receives the data from the UI in the form of a JSON object
     */
    public void uiInput(JSONObject keyBoardInput) throws JSONException {
        //frame = input.frame;
        //String input = (String) keyBoardInput.get("input")[0];

    }

    private void pakuUpdate(Direction input){
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
        
        pakuEatsDots(paku.getLoc());
        if(score.getScore() > (pointsPerLife * extraLives))
        {
            extraLives = 2;
            paku.addLife();
        }
    }

    private void pakuEatsDots(Location location)
    {
        map.get(location.getxLoc()).get(location.getyLoc());

    }

    private void collideWithGhostProtocol() {
        boolean death = false;
        for(Ghost ghost : ghostlist){

            if(!ghost.getState().equals(GhostState.flee) || !ghost.getState().equals(GhostState.eaten))
            {
                paku.substractLife();
                death = true;
            }
            if(ghost.getState().equals(GhostState.flee))
            {
                ghost.addScore(score);
            }
        }
        if(paku.isGameOver()){
            gameStatus = GameStatus.GameOver;
        }
        else if(death)
        {
            gameStatus = GameStatus.pakuDiedButStillHasLifeLeft;
        }

    }

    /**
     * Calls each ghost's move method, which updates the ghost's position
     */
    private void ghostsMove() {
        boolean fleeing = false;
        for (Ghost ghost: ghostlist) {
            ghost.move();
            if(ghost.getState().equals(GhostState.flee) || ghost.getState().equals(GhostState.eaten))
                fleeing = true;
        }
        if(!fleeing)
            ghostlist.get(0).resetMultiplier();
    }
    /**
     * checks whether paku collided with ghost
     * @return
     */
    private boolean collideWithGhost() {
        for(Ghost ghost : ghostlist){
           if(!ghost.getState().equals(GhostState.eaten))
           {
                if(paku.getLoc().getxLoc() == ghost.getLoc().getxLoc())
                    if(paku.getLoc().getyLoc() == ghost.getLoc().getyLoc())
                        return true;
           }
        }
        return false;
    }

    /**
     * Calls paku's move method, which updates the paku's position
     */
    private void pakuMove(Direction input)
    {
        if(!input.equals(Direction.stay))
            if(!inputDirection.equals(input) || !inputDirection.equals(Direction.stay)) {
                paku.setDir(input);
                inputDirection = input;
            }
        paku.move();

    }
    private void spawnFruit()
    {
        Fruit fruit;
        // Todo: level check and then fruit spawn based on enum.
    }
}
    

