package Model;
import java.util.ArrayList;
//import org.json.simple.JSONArray;
//import org.json.simple.JSONObject;


public abstract class movingGameObject {

	public enum States{

	}
	private ArrayList<Integer> position;
	private States state;
	private Direction facingDirection;

	public movingGameObject(int x, int y, States state, Direction dir){
		position = new ArrayList<>();
		position.add(x);
		position.add(y);
		this.state = state;
		this.facingDirection = dir;
	}

	public movingGameObject(){

	}

	public abstract void move(Direction dir);
	public abstract int getPosition();


	
    
}