/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Model;
import Model.movingGameObject;
import org.json.simple.JSONObject;

/**
 *
 * @author kruge
 */
public class Paku extends movingGameObject{

    private static Paku paku = new Paku();
    private Paku()
    {
        System.out.println("Paku has been constructed");
    }

    public static Paku getInstance()
    {
        return paku;
    }


    JSONObject jo = new JSONObject();

    public void move(Direction dir)
    {
        jo.put(dir.toString());

    }


}
