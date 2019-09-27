using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Clyde : MonoBehaviour
{

    [SerializeField]
    Transform pac_man;

    [SerializeField]
    Transform clyde;

    private float x;
    private float z;
    private float x2;
    private float z2;
    private float dist;
    private float dist2;
    public static bool clyde_running = false;
    public static Vector3 clyde_startpos;


    private Vector3 target;
    private bool reached = false;
    private int select;

    private Vector3 target1 = new Vector3(-13.25f, 0.5f, 13.25f);
    private Vector3 target2 = new Vector3(13.25f, 0.5f, 13.25f);
    private Vector3 target3 = new Vector3(-13.25f, 0.5f, -13.25f);
    private Vector3 target4 = new Vector3(13.25f, 0.5f, -13.25f);
    private Vector3 target5 = new Vector3(-7.75f, 0.5f, 0.5f);
    private Vector3 target6 = new Vector3(7.75f, 0.5f, 0.5f);
    private Vector3 target7 = new Vector3( 0f, 0.5f, -14f);
    private Vector3 target8 = new Vector3(0f, 0.5f, 9.5f);
    private Vector3 target9 = new Vector3(0f, 0.5f, -2f);
    private Vector3 target0 = new Vector3(0f, 0.5f, 4f);
    private Vector3 target01 = new Vector3(-13.5f, 0.5f, 3.25f);
    private Vector3 target02 = new Vector3(13.5f, 0.5f, 3.25f);





    void Start()
    {
        //       NavMeshAgent agent = GetComponent<NavMeshAgent>();
        Renderer rend = GetComponent<Renderer>();
        rend.material.color = Color.green;

        clyde_startpos = clyde.position;

        StartCoroutine(Countdown());

        select = Random.Range(1, 13);

        switch (select)
        {
            case 1:
                target = target1;
                break;
            case 2:
                target = target2;
                break;
            case 3:
                target = target3;
                break;
            case 4:
                target = target4;
                break;
            case 5:
                target = target5;
                break;
            case 6:
                target = target6;
                break;
            case 7:
                target = target7;
                break;
            case 8:
                target = target8;
                break;
            case 9:
                target = target9;
                break;
            case 10:
                target = target0;
                break;
            case 11:
                target = target01;
                break;
            case 12:
                target = target02;
                break;
            default:
                target = target1;
                break;
        }
    }

    // Update is called once per frame
    void Update()
    {

      

       
        NavMeshAgent agent = GetComponent<NavMeshAgent>();
        agent.speed = 5;



        //     blocked = NavMesh.Raycast(clyde.position, new Vector3(x2, 0.5f, z2), out hit, NavMesh.AllAreas);
        if (reached == true) {
            select = Random.Range(1, 13);

            switch (select)
            {
                case 1:
                    target = target1;
                    break;
                case 2:
                    target = target2;
                    break;
                case 3:
                    target = target3;
                    break;
                case 4:
                    target = target4;
                    break;
                case 5:
                    target = target5;
                    break;
                case 6:
                    target = target6;
                    break;
                case 7:
                    target = target7;
                    break;
                case 8:
                    target = target8;
                    break;
                case 9:
                    target = target9;
                    break;
                case 10:
                    target = target0;
                    break;
                default:
                    target = target1;
                    break;
            }

        }

        if (clyde_running == true)
        {
            if (Powerup.powerup == false)
            {
                Renderer rend = GetComponent<Renderer>();
                rend.material.color = Color.green;
                //               
                dist2 = Vector3.Distance(pac_man.position, clyde.position);

                if (dist2 > 3)
                {
                    //agent.speed = 5;
                    agent.destination = target;
                    clyde.eulerAngles = new Vector3(0, 0, 0);

                    dist = Vector3.Distance(clyde.position, target);
                    if (dist < 0.5)
                        reached = true;
                    else
                        reached = false;
                }
                else
                {
                    agent.speed = 5;
                    agent.destination = pac_man.position;
                }
                
            }
            else
            {
                
                agent.speed = 2;
                agent.destination = -1 * pac_man.position;
                clyde.eulerAngles = new Vector3(0, 0, 0);

                Renderer rend = GetComponent<Renderer>();
                rend.material.color = Color.white;

                dist = Vector3.Distance(pac_man.position, clyde.position);
                if (dist < 0.5)
                {
                    AudioSource source = GetComponent<AudioSource>();
                    source.Play();
                    clyde.position = clyde_startpos;
                    agent.Warp(clyde_startpos);
                    Pacman.score += 200;
                }
            }
        }
        else if (clyde_running == false)
        {
            agent.Warp(clyde_startpos);
            agent.destination = clyde_startpos;
        }

    }


    IEnumerator Countdown()
    {
        yield return new WaitForSeconds(5f);
        clyde_running = true;
    }

}
