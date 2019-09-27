using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LevelManager : MonoBehaviour {

	public void LoadLevel(string name){
		Debug.Log("Level load requested: "+name);
		SceneManager.LoadScene(name);
	}

    public void changeName_Craige(string name) {
        HighScore.name_temp = "CRAIGE";
        SceneManager.LoadScene(name);
    }

    public void changeName_tanay(string name)
    {
        HighScore.name_temp = "TANAY";
        SceneManager.LoadScene(name);
    }

    public void changeName_Leighann(string name)
    {
        HighScore.name_temp = "LEIGHANN";
        SceneManager.LoadScene(name);
    }

    public void changeName_bash(string name)
    {
        HighScore.name_temp = "BASH";
        SceneManager.LoadScene(name);
    }

    public void changeName_April(string name)
    {
        HighScore.name_temp = "APRIL";
        SceneManager.LoadScene(name);
    }

    public void changeName_haley(string name)
    {
        HighScore.name_temp = "HALEY";
        SceneManager.LoadScene(name);
    }

    public void changeName_Jaymes(string name)
    {
        HighScore.name_temp = "JAYMES";
        SceneManager.LoadScene(name);
    }

    public void changeName_Cheletta(string name)
    {
        HighScore.name_temp = "CHELETTA";
        SceneManager.LoadScene(name);
    }
}