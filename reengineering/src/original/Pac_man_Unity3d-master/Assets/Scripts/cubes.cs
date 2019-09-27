using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;



public class cubes : MonoBehaviour {

    [SerializeField]
    Transform pac_man;

    [SerializeField]
    Transform cube;

    
    

    private float dist;
    

    // Use this for initialization
    void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
        dist = Vector3.Distance(cube.position, pac_man.position);
        cube.Rotate(Vector3.right * Time.deltaTime * 50);
        AudioSource aud = GetComponent<AudioSource>();


        if (dist < 0.5)
        {
            
            aud.Play();
            StartCoroutine(destroy());
            cube.Translate(0, 50, 0);
            
        }

    }

    IEnumerator destroy()
    {
        yield return new WaitForSeconds(1f);
        Destroy(cube.gameObject);
        Pacman.score += 25;
    }

}
