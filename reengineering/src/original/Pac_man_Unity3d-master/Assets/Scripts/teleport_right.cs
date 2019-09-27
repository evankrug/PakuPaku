using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class teleport_right : MonoBehaviour
{

    [SerializeField]
    Transform Portal;

    [SerializeField]
    Transform pac_man;

    private float dist;

    // Use this for initialization
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        dist = Vector3.Distance(Portal.position, pac_man.position);

        if (dist < 0.5)
        {
            pac_man.position = new Vector3(-14,  0.5f, 1);
        }
    }
}
