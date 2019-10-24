package Model;


import java.util.Random;

public class Stinky extends Ghost
{

    private final int STARTING_X = 14;  //starting x and y coordinates of Paku; subject to change
    private final int STARTING_Y = 11;
    private final int SCATTER_X = FAR_RIGHT;
    private final int SCATTER_Y = 1;
    public Stinky()
    {

        loc = new Location(STARTING_X, STARTING_Y);
    }

    @ Override
    public void move(Direction dir)   {
        Location paku = Paku.getInstance().getLocation();

        alternate = !alternate;
        modX = loc.getxLoc() % 3;
        modY = (loc.getyLoc() + 1) % 3;
        if(inJail())
        {
            jailMove();
        }
        else {
            checkWarp();
                jailSkip = false;
                howFar = 1;
            int randomInt = random.nextInt(10);
            if (state.equals(GhostState.scatter)) {
                scatterMove(SCATTER_X, SCATTER_Y);
            } else if (state.equals(GhostState.chase)) {
                changeX = paku.getxLoc() - loc.getxLoc();
                changeY = paku.getyLoc() - loc.getyLoc();
            } else if (state.equals(GhostState.flee)) {
                fleeMove();
            } else if (state.equals(GhostState.eaten)) {
                eatenMove();
            }
            this.calculateMove();
        }
    }
}

