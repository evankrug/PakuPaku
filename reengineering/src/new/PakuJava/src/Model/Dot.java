package Model;
import java.util.ArrayList;

/**
 *
 * @author kruge
 */
public class Dot {
	private final int POINTS = 10;
	protected boolean eaten;
	private ArrayList<Integer> position;
	
	public Dot(int x, int y){
		eaten = false;
		position = new ArrayList<Integer>();
		position.add(x);
		position.add(y);
	}
	
	public void gotEaten(Score score){
		score.addScore(POINTS);
		eaten = true;
	}
    
}
