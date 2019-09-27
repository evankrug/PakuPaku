using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Pacman : MonoBehaviour {

    [SerializeField]
    Transform pac_man;

    [SerializeField]
    Transform blinky;

    [SerializeField]
    Transform pinky;

    [SerializeField]
    Transform inky;

    [SerializeField]
    Transform clyde;


    


    public float moveSpeed;
    private float input1;
    private float input2;
   // private float t = Time.deltaTime;
    bool shouldmove = true;
    public static int score;

    public static float life = 3;
    private float dist_b;
    private float dist_p;
    private float dist_i;
    private float dist_c;
    private Vector3 pac_startpos;

	// Use this for initialization
	void Start () {
        pac_startpos = pac_man.position;
	}
	
	// Update is called once per frame
	void Update () {

        TextMesh score_display = GameObject.Find("Score").GetComponent<TextMesh>();
        score_display.text = "Score\n" + score;

        TextMesh lives_display = GameObject.Find("Lives").GetComponent<TextMesh>();
        lives_display.text = "Lives\n" + life;

        input1 = Input.GetAxis("Horizontal");
        input2 = Input.GetAxis("Vertical");
        // pac_man.Translate(0, 0, input2 * t * moveSpeed);



        if (input1 != 0 || input2 != 0)
        {
      //        Vector3 movement = new Vector3(input1, 0.0f, input2);
            pac_man.Translate(input1 * Time.deltaTime * moveSpeed, 0 , 0);
            pac_man.Translate(0, 0, input2 * Time.deltaTime * moveSpeed);
            pac_man.eulerAngles = new Vector3(0, 0, 0);


            //if(input1 == 1 || input1 == -1)
            pac_man.GetChild(0).eulerAngles = new Vector3(0, input1 * 90, 0);

            if (input2 == 1)
                pac_man.GetChild(0).eulerAngles = new Vector3(0, 0, 0);
            if(input2 == -1)
                pac_man.GetChild(0).eulerAngles = new Vector3(0, 180, 0);


        }
                

            
         //   pac_man.rotation = Quaternion.Slerp(pac_man.rotation, Quaternion.LookRotation(movement), Time.deltaTime * 500000);


        if (Powerup.powerup == false)
        {
            dist_b = Vector3.Distance(pac_man.position, blinky.position);
            dist_p = Vector3.Distance(pac_man.position, pinky.position);
            dist_i = Vector3.Distance(pac_man.position, inky.position);
            dist_c = Vector3.Distance(pac_man.position, clyde.position);

            AudioSource[] source = GetComponents<AudioSource>();

            if (dist_b < 0.5 || dist_p < 0.5 || dist_i < 0.5 || dist_c < 0.5)
            {
                if (dist_b < 0.5)
                {                            
                    source[0].Play();
                }else if (dist_p < 0.5)
                {                    
                    source[1].Play();
                }
                else if(dist_i < 0.5)
                {
                    source[2].Play();
                }
                else if(dist_c < 0.5)
                {
                    source[3].Play();
                }

                if (life == 1)
                {
                    SceneManager.LoadScene("GameOver");
                    life = 3;
                    score = 0;
                    WinCondition.win = false;
                }
                else
                {
                    life = life - 1;
                    WinCondition.win = false;
                    Blinky.blinky_running = false;
                    Pinky.pinky_running = false;
                    Inky.inky_running = false;
                    Clyde.clyde_running = false;
                    blinky.position = Blinky.blinky_startpos;
                    pinky.position = Pinky.pinky_startpos;
                    inky.position = Inky.inky_startpos;
                    clyde.position = Clyde.clyde_startpos;
                    pac_man.position = pac_startpos;
                    StartCoroutine(countdown());

                }
            }
        }

    }

    IEnumerator countdown()
    {
        yield return new WaitForSeconds(1f);
        Blinky.blinky_running = true;

        yield return new WaitForSeconds(1f);
        Pinky.pinky_running = true;

        yield return new WaitForSeconds(4f);
        Inky.inky_running = true;

        yield return new WaitForSeconds(2f);
        Clyde.clyde_running = true;

    }

   /* private void OnTriggerEnter(Collider other)
    {
        pac_man.Translate(new Vector3(0, 0, 0));
        shouldmove = false;
    }*/
}
