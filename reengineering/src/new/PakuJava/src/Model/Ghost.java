/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Model;/*
import Model.movingGameObject;
import org.json.simple.JSONObject;
import Controller.Controls;*/

import java.util.Random;

/**
 *
 * @author kruge
 */



public abstract class Ghost extends movingGameObject {

    private final int JAIL_BOTTOM = 17;
    private final int JAIL_TOP = 12;
    private final int JAIL_LEFT = 10;
    private final int JAIL_RIGHT = 17;
    private final int WARP_LEVEL = 14;
    protected final int FAR_RIGHT = 26;
    GhostState state;
    protected boolean jailSkip;
    protected int dx, dy;
    protected int changeX, changeY;
    protected int absoluteX, absoluteY;
    protected Random random;
    protected int testAmount;
    protected int exitCounter;
    public enum Ghosts {
        stinky("stinky"), //red
        kinky("kinky"), //pink
        hinky("hinky"), //blue
        blaine("blaine");  //yellow

        private String name;


        Ghosts(String name) {
            this.name = name;
        }

        public String getName() {
            return name;
        }
    }

    public Ghost() {
        random = new Random();

    }

    @Override
    public void move(Direction dir) {

    }

    protected boolean inJail()
    {
        if(loc.getxLoc() >= JAIL_LEFT && loc.getxLoc() <= JAIL_RIGHT)
        {
            if(loc.getyLoc() <= JAIL_BOTTOM && loc.getyLoc() >= JAIL_TOP)
                return true;
            else
                return false;
        }
        else
            return false;
    }
    protected void jailMove()
    {
        if(state.equals(GhostState.eaten) && loc.getyLoc() < JAIL_TOP)
        {
            loc.setyLoc(loc.getyLoc() + 1);
            if(loc.getyLoc() == JAIL_BOTTOM)
                state = GhostState.scatter;

        }
        else
        {
            if(exitCounter < 0)
            {
                if(loc.getyLoc() == JAIL_TOP)
                {
                    facingDirection = Direction.down;
                }
                else if(loc.getyLoc() == JAIL_BOTTOM)
                {
                    facingDirection = Direction.up;
                }
            }
            else
            {

            }
            switch (facingDirection) {
                case up:
                    loc.setyLoc(loc.getyLoc() + 1);
                    break;
                case down:
                    loc.setyLoc(loc.getyLoc() - 1);
                    break;
                case left:
                    loc.setxLoc(loc.getxLoc() - 1);
                    break;
                case right:
                    loc.setxLoc(loc.getxLoc() + 1);
                    break;
            }
        }
    }
    protected void checkWarp()
    {
        if(facingDirection.equals(Direction.right))
        {
            if(loc.getxLoc() == FAR_RIGHT && loc.getyLoc() == WARP_LEVEL)
            {
                loc.setxLoc(1);
            }
        }
        else if(facingDirection.equals(Direction.left))
        {
            if(loc.getxLoc() == 1 && loc.getyLoc() == WARP_LEVEL)
            {
                loc.setxLoc(FAR_RIGHT);
            }
        }
    }

    protected void scatterMove(int scatterX, int scatterY)
    {
        changeX = scatterX - loc.getxLoc();
        changeY = scatterY - loc.getyLoc();
    }

    protected void fleeMove()
    {
        changeX = loc.getxLoc() - Paku.getInstance().getLocation().getxLoc();
        changeY = loc.getyLoc() - Paku.getInstance().getLocation().getyLoc();
    }

    protected void eatenMove()
    {

    }
    protected void calculateMove()
    {
        int randomInt = random.nextInt(10);
        if(!jailSkip)
        {

            absoluteX = Math.abs(changeX);
            absoluteY = Math.abs(changeY);
            if(facingDirection.equals(Direction.up) || facingDirection.equals(Direction.left))
            {
                testAmount = -1;
            }
            else
            {
                testAmount = 1;
            }
            if(facingDirection.equals(Direction.up) || facingDirection.equals(Direction.down))
            {
                if(modY == 0)
                {
                    if((randomInt > 1 && )
                }
                if()
            }
        }
    }


    public void setState(GhostState state)
    {
        this.state = state;
    }
}
