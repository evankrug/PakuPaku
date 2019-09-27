using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Blinky : MonoBehaviour {

    [SerializeField]
    Transform pac_man;

    [SerializeField]
    Transform blinky;

    private float dist;
    public static bool blinky_running = true;
    public static Vector3 blinky_startpos;
    


    void Start () {
        blinky_startpos = blinky.position;
        StartCoroutine(Countdown());
        Renderer rend = GetComponent<Renderer>();
        rend.material.color = Color.red;
    }
	
	// Update is called once per frame
	void Update () {

        if (blinky_running == true)
        {
            NavMeshAgent agent = GetComponent<NavMeshAgent>();

            if (Powerup.powerup == false)
            {
                Renderer rend = GetComponent<Renderer>();
                rend.material.color = Color.red;
                agent.speed = 5;
                //agent.acceleration = 10000;
                agent.destination = pac_man.position;
                blinky.eulerAngles = new Vector3(0, 0, 0);
            }
            else if (Powerup.powerup == true)
            {
                agent.speed = 2;
                agent.destination = new Vector3(pac_man.position.x, 0.5f, -1 * pac_man.position.z);
                blinky.eulerAngles = new Vector3(0, 0, 0);

                Renderer rend = GetComponent<Renderer>();
                rend.material.color = Color.white;

                dist = Vector3.Distance(pac_man.position, blinky.position);
                if (dist < 0.5)
                {
                    AudioSource source = GetComponent<AudioSource>();
                    source.Play();
                    blinky.position = blinky_startpos;
                    agent.Warp(blinky_startpos);
                    Pacman.score += 200;
                }
            }
        }else if(blinky_running == false)
        {
            NavMeshAgent agent = GetComponent<NavMeshAgent>();
            agent.Warp(blinky_startpos);
            agent.destination = blinky.position;
        }
    }

//    void powerup()
//    {

//    }
    IEnumerator Countdown()
    {
        yield return new WaitForSeconds(1f);
    }

}
