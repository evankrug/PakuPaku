package asset;

public enum MapMapping {
    zero("wall"),
    one("dot"), //red
    two("empty"), //pink
    three("superdot"), //blue
    four("teleport");  //yellow

    private String name;

    MapMapping(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public String getNameInt(int number) {
        switch(number){
            case 0: return zero.getName();
            case 1: return one.getName();
            case 2: return two.getName();
            case 3: return three.getName();
            case 4: return four.getName();
        }
        return null;
    }

}
