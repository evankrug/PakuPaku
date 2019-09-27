using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HighScore : MonoBehaviour {


    public Text topscore;
    public static int temp;
    public static int temp2;

    public static string name_temp;

    public static string PlayerName1 = "Player 1";
    public static string PlayerName2 = "Player 2"; 
    public static string PlayerName3 = "Player 3";
    public static string PlayerName4 = "Player 4";
    public static string PlayerName5 = "Player 5";


    public static int highscore1;
    public static int highscore2;
    public static int highscore3;
    public static int highscore4;
    public static int highscore5;

	// Use this for initialization
	void Start () {

        highscore1 = PlayerPrefs.GetInt("High Score 1");
        highscore2 = PlayerPrefs.GetInt("High Score 2");
        highscore3 = PlayerPrefs.GetInt("High Score 3");
        highscore4 = PlayerPrefs.GetInt("High Score 4");
        highscore5 = PlayerPrefs.GetInt("High Score 5");

        PlayerName1 = PlayerPrefs.GetString("Player Name 1");
        PlayerName2 = PlayerPrefs.GetString("Player Name 2");
        PlayerName3 = PlayerPrefs.GetString("Player Name 3");
        PlayerName4 = PlayerPrefs.GetString("Player Name 4");
        PlayerName5 = PlayerPrefs.GetString("Player Name 5");




        if (WinCondition.temp_highscore > highscore1 && WinCondition.win == true)
        {
            PlayerPrefs.SetString("Player Name 1", name_temp);
            PlayerPrefs.SetString("Player Name 2", PlayerName1);
            PlayerPrefs.SetString("Player Name 3", PlayerName2);
            PlayerPrefs.SetString("Player Name 4", PlayerName3);
            PlayerPrefs.SetString("Player Name 5", PlayerName4);



            temp = PlayerPrefs.GetInt("High Score 1");
            PlayerPrefs.SetInt("High Score 1", WinCondition.temp_highscore);

            temp2 = PlayerPrefs.GetInt("High Score 2");
            PlayerPrefs.SetInt("High Score 2", temp);

            temp = PlayerPrefs.GetInt("High Score 3");
            PlayerPrefs.SetInt("High Score 3", temp2);

            temp2 = PlayerPrefs.GetInt("High Score 4");
            PlayerPrefs.SetInt("High Score 4", temp);

            temp = PlayerPrefs.GetInt("High Score 5");
            PlayerPrefs.SetInt("High Score 5", temp2);

        }
        else if (WinCondition.temp_highscore > highscore2 && WinCondition.win == true)
        {
            PlayerPrefs.SetString("Player Name 2", name_temp);
            PlayerPrefs.SetString("Player Name 3", PlayerName2);
            PlayerPrefs.SetString("Player Name 4", PlayerName3);
            PlayerPrefs.SetString("Player Name 5", PlayerName4);

            temp2 = PlayerPrefs.GetInt("High Score 2");
            PlayerPrefs.SetInt("High Score 2", WinCondition.temp_highscore);

            temp = PlayerPrefs.GetInt("High Score 3");
            PlayerPrefs.SetInt("High Score 3", temp2);

            temp2 = PlayerPrefs.GetInt("High Score 4");
            PlayerPrefs.SetInt("High Score 4", temp);

            temp = PlayerPrefs.GetInt("High Score 5");
            PlayerPrefs.SetInt("High Score 5", temp2);

        }
        else if (WinCondition.temp_highscore > highscore3 && WinCondition.win == true)
        {
            PlayerPrefs.SetString("Player Name 3", name_temp);
            PlayerPrefs.SetString("Player Name 4", PlayerName3);
            PlayerPrefs.SetString("Player Name 5", PlayerName4);

            temp = PlayerPrefs.GetInt("High Score 3");
            PlayerPrefs.SetInt("High Score 3", WinCondition.temp_highscore);

            temp2 = PlayerPrefs.GetInt("High Score 4");
            PlayerPrefs.SetInt("High Score 4", temp);

            temp = PlayerPrefs.GetInt("High Score 5");
            PlayerPrefs.SetInt("High Score 5", temp2);
        }
        else if (WinCondition.temp_highscore > highscore4 && WinCondition.win == true)
        {
            PlayerPrefs.SetString("Player Name 4", name_temp);
            PlayerPrefs.SetString("Player Name 5", PlayerName4);

            temp2 = PlayerPrefs.GetInt("High Score 4");
            PlayerPrefs.SetInt("High Score 4", WinCondition.temp_highscore);

            temp = PlayerPrefs.GetInt("High Score 5");
            PlayerPrefs.SetInt("High Score 5", temp2);
        }
        else if (WinCondition.temp_highscore > highscore5 && WinCondition.win == true)
        {
            PlayerPrefs.SetString("Player Name 5", name_temp);
            temp = PlayerPrefs.GetInt("High Score 5");
            PlayerPrefs.SetInt("High Score 5", WinCondition.temp_highscore);
        }

        highscore1 = PlayerPrefs.GetInt("High Score 1");
        highscore2 = PlayerPrefs.GetInt("High Score 2");
        highscore3 = PlayerPrefs.GetInt("High Score 3");
        highscore4 = PlayerPrefs.GetInt("High Score 4");
        highscore5 = PlayerPrefs.GetInt("High Score 5");

        PlayerName1 = PlayerPrefs.GetString("Player Name 1");
        PlayerName2 = PlayerPrefs.GetString("Player Name 2");
        PlayerName3 = PlayerPrefs.GetString("Player Name 3");
        PlayerName4 = PlayerPrefs.GetString("Player Name 4");
        PlayerName5 = PlayerPrefs.GetString("Player Name 5");

    }

    // Update is called once per frame
    void Update () {
        topscore.text = "HIGHSCORES\n\n" + PlayerName1 + ": " + highscore1 + "\n\n"
                           + PlayerName1 + ": " + highscore2 + "\n\n"
                           + PlayerName3 + ": " + highscore3 + "\n\n"
                           + PlayerName4 + ": " + highscore4 + "\n\n"
                           + PlayerName5 + ": " + highscore5 + "\n\n";
    }
}
