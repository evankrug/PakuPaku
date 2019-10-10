package Model;
import java.util.ArrayList;

/**
 *
 * @author kruge
 */
public class Dot {
	
	private boolean eaten;
	private ArrayList<Integer> position;
	
	public Dot(int x, int y){
		eaten = false;
		position = new ArrayList<Integer>();
		position.add(x);
		position.add(y);
	}
	
	public void gotEaten(){
		eaten = true;
	}
    
}
