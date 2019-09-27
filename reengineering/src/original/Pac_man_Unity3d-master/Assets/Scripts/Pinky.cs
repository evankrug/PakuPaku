using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Pinky : MonoBehaviour {


    [SerializeField]
    Transform pac_man;

    [SerializeField]
    Transform blinky;

    [SerializeField]
    Transform pinky;


    public float moveSpeed;
    private float input1;
    private float input2;
    private float dist;
    private float dist_t;
    private float dist_pb_x;
    private float dist_pb_z;

    public static bool pinky_running = false;
    public static Vector3 pinky_startpos;

    private Vector3 target;
    private bool reached = false;
    private int select;
    private bool chase = false;

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


    //    private bool reached;

    // Use this for initialization
    void Start () {
        pinky_startpos = pinky.position;
        StartCoroutine(Countdown());
        Renderer rend = GetComponent<Renderer>();
        rend.material.color = Color.magenta;

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
        NavMeshAgent agent = GetComponent<NavMeshAgent>();
        if (pinky_running == true)
        {
            if (Powerup.powerup == false)
            {
                Renderer rend = GetComponent<Renderer>();
                rend.material.color = Color.magenta;
                if (chase == true)
                    pinky_chase();
                else
                    pinky_stagger();

                dist = Vector3.Distance(pinky.position, target);
                if (dist < 0.5)
                    reached = true;
                else
                    reached = false;
            }
            else
            {
                agent.speed = 2;
                agent.destination = new Vector3(-1*pac_man.position.x, 0.5f, pac_man.position.z);
                pinky.eulerAngles = new Vector3(0, 0, 0);
                Renderer rend = GetComponent<Renderer>();
                rend.material.color = Color.white;

                dist = Vector3.Distance(pac_man.position, pinky.position);
                if (dist < 0.5)
                {
                    AudioSource source = GetComponent<AudioSource>();
                    source.Play();
                    pinky.position = pinky_startpos;
                    agent.Warp(pinky_startpos);
                    Pacman.score += 200;
                }
            }
        }
        else if (pinky_running == false)
        {
            //NavMeshAgent agent = GetComponent<NavMeshAgent>();
            agent.Warp(pinky_startpos);
            agent.destination = pinky.position;
        }
    }

    IEnumerator Countdown()
    {
        yield return new WaitForSeconds(3f);
        pinky_running = true;
    }

    void pinky_chase()
    {
        NavMeshAgent agent = GetComponent<NavMeshAgent>();
        agent.speed = 5;
        agent.destination = pac_man.position;
        pinky.eulerAngles = new Vector3(0, 0, 0);
    }

    void pinky_stagger()
    {
        NavMeshAgent agent = GetComponent<NavMeshAgent>();
        agent.speed = 5;
        agent.destination = target;
        pinky.eulerAngles = new Vector3(0, 0, 0);
    }

    IEnumerator changeSelect()
    {
        if (chase == false) {
            yield return new WaitForSeconds(7f);
            chase = true;
        }
        else {
            yield return new WaitForSeconds(7f);
            chase = false;
        } 
    }


}
