package Model;

import java.util.ArrayList;

public class movingGameObject {
	
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

	
    
}