package Model;

public class SuperDot extends Dot{
    private final int POINTS = 50;
    public SuperDot(int x, int y) {
        super(x, y);
    }

    @Override
    public void gotEaten(Score score) {
        if (!eaten) {
            score.addScore(POINTS);
            eaten = true;
        }
    }
}
