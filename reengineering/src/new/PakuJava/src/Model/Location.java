package Model;

public class Location
{

    private int xLoc, yLoc;



    public Location(int xLoc, int yLoc)
    {
        this.xLoc = xLoc;
        this.yLoc = yLoc;
    }

    public int getxLoc() {
        return xLoc;
    }

    public int getyLoc() {
        return yLoc;
    }

    public void setxLoc(int x)
    {
        xLoc = x;
    }
    public void setyLoc(int y)
    {
        yLoc = y;
    }


}
