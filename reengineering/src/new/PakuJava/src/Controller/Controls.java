package Controller;

import Model.Direction;

public enum Controls {
    arrow_up("arrow_up"),
    arrow_down("arrow_down"),
    arrow_left("arrow_left"),
    arrow_right("arrow_right"),
    W("W"),
    A("A"),
    S("S"),
    D("D"),
    escape("escape"),
    O("O"),
    enter("enter"),
    none("none");

    private String name;

    Controls(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public Controls getControl(String input) {
        switch(input){
            case "arrow_up": return arrow_up;
            case "arrow_down": return arrow_down;
            case "arrow_left": return arrow_left;
            case "arrow_right": return arrow_right;
            case "W": return W;
            case "A": return A;
            case "S": return S;
            case "D": return D;
            case "escape": return escape;
            case "O": return O;
            case "enter": return enter;
            case "none": return none;
        }
        return null;
    }



}
