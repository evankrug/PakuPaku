package Model;
import java.util.ArrayList;
//import org.json.simple.JSONArray;
//import org.json.simple.JSONObject;


public abstract class MovingGameObject {

	public enum States{

	}
	
	public enum FacingDirection{
		up, 
		down, 
		left, 
		right
	}


	private ArrayList<Integer> position;
	private States state;
	private States FacingDirection;

	public MovingGameObject(int x, int y, States state, FacingDirection dir){
		position = new ArrayList<Integer>();
		position.add(x);
		position.add(y);
		this.state = state;
		this.FacingDirection = FacingDirection;
	}

	public MovingGameObject(){

	}

	public abstract void move(Direction dir);
	public abstract int getPosition();


	
    
}