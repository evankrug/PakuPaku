package Model;
import java.util.ArrayList;
//import org.json.simple.JSONArray;
//import org.json.simple.JSONObject;


public abstract class movingGameObject {

	public enum States{

	}
	private ArrayList<Integer> position;
	protected States state;
	protected Direction facingDirection;
	protected Location loc;
	protected int modX, modY;

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
	public Location getLocation() {
		return this.loc;
	}

	public Direction getFacingDirection() {
		return facingDirection;
	}
}