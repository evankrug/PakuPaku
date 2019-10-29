/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Model;
import java.util.List;
import java.util.ArrayList;

/**
 *
 * @author kruge
 */
public class Score 
{
    private int currentScore;


    public Score()
    {
        currentScore = 0;
    }

    public void addScore(int score)
    {
        this.currentScore += score;
    }

    public int getCurrentScore() {
        return currentScore;
    }


    /*  currently no use for this reset method, since a new score object is created every game --Evan
    public void reset()
    {
        if(currentScore > 0)
            archiveScore();
        currentScore = 0;
    }
    */




    /*
    public int getHighScore()
    {
        determineHighScore();
        return highScore;
    }
    */
}
