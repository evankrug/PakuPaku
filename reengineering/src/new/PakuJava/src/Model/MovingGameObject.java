package Model;
import java.util.ArrayList;
//import org.json.simple.JSONArray;
//import org.json.simple.JSONObject;


public abstract class MovingGameObject {

	public enum States{

	}
	private ArrayList<Integer> position;
	protected States state;
	protected Direction facingDirection;
	protected Location loc;
	protected int modX, modY;

	public MovingGameObject(int x, int y, States state, Direction dir){
		position = new ArrayList<>();
		position.add(x);
		position.add(y);
		this.state = state;
		this.facingDirection = dir;
	}

	public MovingGameObject(){

	}

	public abstract void move();

	public Direction getFacingDirection() {
		return facingDirection;
	}
	public Location getLoc() {
		return loc;
	}

}