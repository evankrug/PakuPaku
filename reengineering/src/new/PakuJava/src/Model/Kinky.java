package Model;


public class Kinky extends Ghost
{

    private Location loc;
    private final int STARTING_X = 14;  //starting x and y coordinates of Paku; subject to change
    private final int STARTING_Y = 11;
    public Kinky()
    {

        loc = new Location(STARTING_X, STARTING_Y);
    }

    @ Override
    public void move(Direction dir)   {

    }
}