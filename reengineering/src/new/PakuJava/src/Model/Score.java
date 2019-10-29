/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Model;
import java.util.List;

/**
 *
 * @author kruge
 */
public class Score 
{
    private int score;
    private int highScore;

    private List<Integer> scorelist;

    public Score()
    {
        score = 0;
        highScore = 0;
    }

    public void addScore(int score)
    {
        this.score += score;
    }

    public int getScore() {
        return score;
    }
    public void reset(){score = 0;}


    /**
     * Adds score to the list of scores (used to keep track of high scores)
     */
    public void archiveScore()
    {
        scoreList.add(score);
    }


    public int getHighScore()
    {

    }
}
