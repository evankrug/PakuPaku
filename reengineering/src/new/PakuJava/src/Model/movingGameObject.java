package Model;
import java.util.ArrayList;
//import org.json.simple.JSONArray;
//import org.json.simple.JSONObject;


public abstract class movingGameObject {

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

	public movingGameObject(int x, int y, States state, FacingDirection dir){
		position = new ArrayList<Integer>();
		position.add(x);
		position.add(y);
		this.state = state;
		this.FacingDirection = FacingDirection;
	}

	public movingGameObject(){

	}

	public abstract void move(Direction dir);
	public abstract int getPosition();


	
    
}