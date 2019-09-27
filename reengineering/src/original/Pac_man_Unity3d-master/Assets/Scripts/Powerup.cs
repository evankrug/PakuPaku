using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.UI;

public class Powerup : MonoBehaviour {

    [SerializeField]
    Transform pac_man;

    [SerializeField]
    Transform power_up;



    public static bool powerup = false;
    private float dist;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
            dist = Vector3.Distance(power_up.position, pac_man.position);
        // power_up.Rotate(Vector3.right * Time.deltaTime * 50);
        

        if (dist < 1)
            {
            
            Power();

                //powerup = false;
                // StopAllCoroutines();


            }
    }

    void Power()
    {
        if (power_up.childCount>0)
        {
            AudioSource source = GetComponent<AudioSource>();
            source.Play();
            Destroy(power_up.Find("Powerup").gameObject);
            Pacman.score += 75;
            StartCoroutine(Countdown());
        }
        
        
    }

    IEnumerator Countdown()
    {
        //Create a Countdown wait timer
        //Call End game if failed
        powerup = true;

        yield return new WaitForSeconds(7f);

        powerup = false;

        
    }

}
