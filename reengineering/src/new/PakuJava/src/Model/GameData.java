package Model;


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


    private GameData()
    {

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



}
