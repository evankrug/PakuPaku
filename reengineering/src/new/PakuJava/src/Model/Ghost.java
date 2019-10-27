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
 * @author kruge
 */


public abstract class Ghost extends movingGameObject {

    protected final int FAR_RIGHT = 26;
    private final int JAIL_BOTTOM = 17;
    private final int JAIL_TOP = 12;
    private final int JAIL_LEFT = 10;
    private final int JAIL_RIGHT = 17;
    private final int JAIL_DOOR = 13;
    private final int WARP_LEVEL = 14;
    private final int EATEN_Y = 10;
    private final int EATEN_X = 13;
    protected boolean jailSkip;
    protected boolean allowTurn = false;
    protected boolean alternate = false;
    protected int changeX, changeY;
    protected int absoluteX, absoluteY;
    protected Random random;
    protected int testAmount;
    protected int exitCounter;
    protected int howFar;
    protected int fleeTotal;
    protected int[][] map;
    GhostState state;

    public Ghost() {
        random = new Random();
    }

    @Override
    public void move(Direction dir) {

    }

    protected boolean inJail() {
        if (loc.getxLoc() >= JAIL_LEFT && loc.getxLoc() <= JAIL_RIGHT) {
            if (loc.getyLoc() <= JAIL_BOTTOM && loc.getyLoc() >= JAIL_TOP)
                return true;
            else
                return false;
        } else
            return false;
    }

    protected void jailMove() {
        if (state.equals(GhostState.eaten) && loc.getyLoc() < JAIL_TOP) {
            loc.setyLoc(loc.getyLoc() + 1);
            if (loc.getyLoc() == JAIL_BOTTOM)
                state = GhostState.scatter;

        } else {
            if (exitCounter < 0) {
                if (loc.getyLoc() == JAIL_TOP) {
                    facingDirection = Direction.down;
                } else if (loc.getyLoc() == JAIL_BOTTOM) {
                    facingDirection = Direction.up;
                }
            } else {

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

    protected void checkWarp() {
        if (facingDirection.equals(Direction.right)) {
            if (loc.getxLoc() == FAR_RIGHT && loc.getyLoc() == WARP_LEVEL) {
                loc.setxLoc(1);
            }
        } else if (facingDirection.equals(Direction.left)) {
            if (loc.getxLoc() == 1 && loc.getyLoc() == WARP_LEVEL) {
                loc.setxLoc(FAR_RIGHT);
            }
        }
    }

    protected void scatterMove(int scatterX, int scatterY) {
        changeX = scatterX - loc.getxLoc();
        changeY = scatterY - loc.getyLoc();
    }

    protected void fleeMove() {
        changeX = loc.getxLoc() - Paku.getInstance().getLocation().getxLoc();
        changeY = loc.getyLoc() - Paku.getInstance().getLocation().getyLoc();
    }

    protected void eatenMove() {
        if (loc.getyLoc() == JAIL_DOOR) {
            if (loc.getyLoc() >= (JAIL_BOTTOM + 4) && loc.getyLoc() > JAIL_BOTTOM) {
                facingDirection = Direction.down;
                jailSkip = true;
            }
        } else {
            changeX = EATEN_X - loc.getxLoc();
            changeY = EATEN_Y - loc.getyLoc();
        }
    }

    protected void calculateMove() {
        int randomInt = random.nextInt(10);
        if (!jailSkip) {

            absoluteX = Math.abs(changeX);
            absoluteY = Math.abs(changeY);
            if (facingDirection.equals(Direction.up) || facingDirection.equals(Direction.left)) {
                testAmount = -1;
            } else {
                testAmount = 1;
            }
            if (facingDirection.equals(Direction.up) || facingDirection.equals(Direction.down)) {
                if (randomInt > 1) {
                    if (loc.getxLoc() == 9) {
                        allowTurn = true;
                    } else if (loc.getxLoc() == 18)
                        if (loc.getyLoc() > 9 && loc.getyLoc() < 19)
                            allowTurn = true;
                        else
                            allowTurn = false;
                    else
                        allowTurn = false;

                } else
                    allowTurn = false;


                if (absoluteX > absoluteY || changeY > 0) {
                    turnUpDown();
                } else if (map[loc.getxLoc()][loc.getyLoc() + testAmount] == 0 || allowTurn) {
                    turnUpDown();
                } else if (randomInt > 8) {
                    turnUpDown();
                } else {
                    moveUpDown();
                }


            } else if (facingDirection.equals(Direction.left) || facingDirection.equals(Direction.right)) {

                if (randomInt > 1) {
                    if (loc.getxLoc() > 9 && loc.getxLoc() < 18)
                        if (loc.getyLoc() > 10 || loc.getyLoc() < 22)
                            allowTurn = true;
                        else
                            allowTurn = false;
                    else
                        allowTurn = false;

                } else
                    allowTurn = false;
                if (absoluteX > absoluteY || changeY > 0) {
                    turnLeftRight();
                }
                else 
                {
                    moveLeftRight();
                }


            }


            // left/right check
            // jailskip check

            if (!state.equals(GhostState.flee)) {
                if (!(loc.getyLoc() == 13))
                    if (!(loc.getxLoc() < 6 || loc.getxLoc() > 20))
                        if (!alternate) {
                            if (facingDirection.equals(Direction.up)) {
                                if ()
                                    loc.setyLoc(loc.getyLoc() - howFar);
                                else
                                    loc.setyLoc(loc.getyLoc() - 1);
                            } else if (facingDirection.equals(Direction.right)) {
                                if ()
                                    loc.setxLoc(loc.getxLoc() + howFar);
                                else
                                    loc.setxLoc(loc.getxLoc() + 1);
                            } else if (facingDirection.equals(Direction.down)) {
                                if ()
                                    loc.setyLoc(loc.getyLoc() + howFar);
                                else
                                    loc.setyLoc(loc.getyLoc() + 1);
                            } else if (facingDirection.equals(Direction.left)) {
                                if ()
                                    loc.setxLoc(loc.getxLoc() - howFar);
                                else
                                    loc.setxLoc(loc.getxLoc() - 1);
                            }
                        }
            }

        }
    }

    private void moveLeftRight() {

    }

    private void moveUpDown() {
    }

    private void turnUpDown() {
        if(map[])
    }

    private void turnLeftRight() {

    }

    public void setState(GhostState state) {
        this.state = state;
    }


    /*
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
        }git add 
    }
    */
}
