using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Inky : MonoBehaviour {

    [SerializeField]
    Transform pac_man;

    [SerializeField]
    Transform inky;


    public static bool inky_running = false;
    private int choice;
    private float dist;
    private float input1;
    private float input2;
    private float x;
    private float z;
    public static Vector3 inky_startpos;

    public bool newChoice = true;

    private Vector3 target;
    private bool reached = false;
    private int select;
    private bool chase;

    private Vector3 target1 = new Vector3(-13.25f, 0.5f, 13.25f);
    private Vector3 target2 = new Vector3(13.25f, 0.5f, 13.25f);
    private Vector3 target3 = new Vector3(-13.25f, 0.5f, -13.25f);
    private Vector3 target4 = new Vector3(13.25f, 0.5f, -13.25f);
    private Vector3 target5 = new Vector3(-7.75f, 0.5f, 0.5f);
    private Vector3 target6 = new Vector3(7.75f, 0.5f, 0.5f);
    private Vector3 target7 = new Vector3(0f, 0.5f, -14f);
    private Vector3 target8 = new Vector3(0f, 0.5f, 9.5f);
    private Vector3 target9 = new Vector3(0f, 0.5f, -2f);
    private Vector3 target0 = new Vector3(0f, 0.5f, 4f);
    private Vector3 target01 = new Vector3(-13.5f, 0.5f, 3.25f);
    private Vector3 target02 = new Vector3(13.5f, 0.5f, 3.25f);

    // Use this for initialization
    void Start () {
        inky_startpos = inky.position;
        Renderer rend = GetComponent<Renderer>();
        rend.material.color = Color.blue;
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
	void Update () {

        StartCoroutine(changeSelect());

      

        if (reached == true)
        {
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

        if (inky_running == true)
        {
            if (Powerup.powerup == false)
            {
                Renderer rend = GetComponent<Renderer>();
                rend.material.color = Color.blue;
                if (chase == true)
                    inky_chase();
                else
                    inky_stagger();

                dist = Vector3.Distance(inky.position, target);
                if (dist < 0.5)
                    reached = true;
                else
                    reached = false;
            }
            else
            {
                Renderer rend = GetComponent<Renderer>();
                rend.material.color = Color.white;
                NavMeshAgent agent = GetComponent<NavMeshAgent>();
                agent.speed = 2;
                agent.destination = new Vector3(-1 * pac_man.position.x, 0.5f, -1 * pac_man.position.z);
                inky.eulerAngles = new Vector3(0, 0, 0);
                dist = Vector3.Distance(pac_man.position, inky.position);
                if (dist < 0.5)
                {
                    AudioSource source = GetComponent<AudioSource>();
                    source.Play();
                    inky.position = inky_startpos;
                    agent.Warp(inky_startpos);
                    Pacman.score += 200;
                }
            }
        }
        else if (inky_running == false)
        {
            NavMeshAgent agent = GetComponent<NavMeshAgent>();
            agent.Warp(inky_startpos);
            agent.destination = inky.position;
        }
    }

    IEnumerator Countdown()
    {
        yield return new WaitForSeconds(3f);
        inky_running = true;
    }

    void inky_chase()
    {
        NavMeshAgent agent = GetComponent<NavMeshAgent>();
        agent.speed = 5;
        agent.destination = pac_man.position;
        inky.eulerAngles = new Vector3(0, 0, 0);
    }

    void inky_stagger()
    {
        NavMeshAgent agent = GetComponent<NavMeshAgent>();
        agent.speed = 5;
        agent.destination = target;
        inky.eulerAngles = new Vector3(0, 0, 0);

    }

    IEnumerator changeSelect()
    {
        if (chase == false)
        {
            yield return new WaitForSeconds(5f);
            chase = true;
        }
        else
        {
            yield return new WaitForSeconds(5f);
            chase = false;
        }
    }
}
