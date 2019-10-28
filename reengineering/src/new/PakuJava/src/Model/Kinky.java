package Model;


public class Kinky extends Ghost
{

    private Location loc;
    private final int STARTING_X = 14;  //starting x and y coordinates of Paku; subject to change
    private final int STARTING_Y = 11;
    private final int SCATTER_X = 1;
    private final int SCATTER_Y = 1;
    public Kinky()
    {

        loc = new Location(STARTING_X, STARTING_Y);
    }
    @Override
    public void resetLocation() {
        loc.setxLoc(STARTING_X);
        loc.setyLoc(STARTING_Y);
    }
    @ Override
        public void move() {
            Location paku = Paku.getInstance().getLoc();
            modX = loc.getxLoc() % 3;
            modY = (loc.getyLoc() + 1) % 3;
            if (inJail()) {
                jailMove();
            } else {
                if (state.equals(GhostState.scatter)) {
                    scatterMove(SCATTER_X, SCATTER_Y);
                } else if (state.equals(GhostState.chase)) {

                } else if (state.equals(GhostState.flee)) {
                    fleeMove();
                } else if (state.equals(GhostState.eaten)) {
                    eatenMove();
                }
                calculateMove();
            }
        }
    }