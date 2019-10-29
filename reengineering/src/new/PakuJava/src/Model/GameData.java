package Model;

import org.json.JSONException;
import org.json.JSONObject;


/**
 * This class holds all data to be sent to UI at any given time
 */

public class GameData
{

    private static GameData data = new GameData();  //to make this class a Singleton
    private GameStatus gameStatus;
    private Location pakuLoc; //x, y location of the paku

    // The ghost locations
    private Location blaineLoc;
    private Location stinkyLoc;
    private Location hinkyLoc;
    private Location kinkyLoc;

    private Score score;

    JSONObject object;

    private GameData()
    {
        object = new JSONObject();

    }

    public void createObject()
    {
        try {
            String gameStatusToSend = GameStatus.getStatusUI(this.gameStatus);
            object.put("game_state", gameStatusToSend);
        }

        catch (JSONException ex)
        {

        }

    }

    public JSONObject getData()
    {

        return object;
    }

    public static GameData getInstance()
    {
        return data;
    }

    public void setGameStatus(GameStatus gameStatus) {
        this.gameStatus = gameStatus;
    }

    public void setPakuLoc(Location pakuLoc) {
        this.pakuLoc = pakuLoc;
    }

    public void setHinkyLocation(Location loc)
    {
        this.hinkyLoc = loc;
    }

    public void setStinkyLocation(Location loc)
    {
        this.stinkyLoc = loc;
    }

    public void setKinkyLocation(Location loc)
    {
        this.kinkyLoc = loc;
    }

    public void setBlaineLocation(Location loc)
    {
        this.blaineLoc = loc;
    }

    public GameStatus getGameStatus() {
        return gameStatus;
    }

    public Location getPakuLoc() {
        return pakuLoc;
    }

    public Location getBlaineLoc() {
        return blaineLoc;
    }

    public Location getStinkyLoc() {
        return stinkyLoc;
    }

    public Location getHinkyLoc() {
        return hinkyLoc;
    }

    public Location getKinkyLoc() {
        return kinkyLoc;
    }

    public Score getScore() {
        return score;
    }

    public void setScore(Score score) {
        this.score = score;
    }
}
