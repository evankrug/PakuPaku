package Model;
import java.util.ArrayList;
import java.io.BufferedReader;
import java.io.FileReader;

public class paths
{
    private int mapWidth = 26;//Map size is the size within the boundary.
    private int mapHeight = 29;
    private String pathToCsv = "../asset/maps.csv";
    BufferedReader csvReader;

    public paths(){
        try {
            csvReader = new BufferedReader(new FileReader(pathToCsv));
        }
        catch(Exception e) {
            System.out.println(e.toString());
        }
    }
}
