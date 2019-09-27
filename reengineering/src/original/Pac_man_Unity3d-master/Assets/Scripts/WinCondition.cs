using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class WinCondition : MonoBehaviour {

    [SerializeField]
    Transform cubeObject;


    public static bool win = false;
    public static int temp_highscore;
    public static int lowestHighScore;

	// Use this for initialization
	void Start () {
        win = false;
	}
	
	// Update is called once per frame
	void Update () {
        if (cubeObject.childCount < 1)
        {
            lowestHighScore = PlayerPrefs.GetInt("High Score 5");

            print(lowestHighScore);

            temp_highscore = Pacman.score;
            Pacman.life = 3;
            Pacman.score = 0;
            win = true;

            if (temp_highscore > lowestHighScore)
            {
                SceneManager.LoadScene("Choose a name");
            }
            else
            {
                SceneManager.LoadScene("Win");
            }
            

        }
        else
        {
            win = false;
        }
    }
}
