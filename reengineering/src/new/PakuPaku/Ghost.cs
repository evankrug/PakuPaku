using System;
using System.Collections.Generic;
using System.Text;


namespace PakuPaku
{
    public enum Ghosts
    {
        stinky, //red
        kinky, //pink
        hinky, //blue
        blaine  //yellow

}
    class Ghost
    {
        public Ghost(Ghosts ghostname)
        {
            Console.WriteLine(ghostname.ToString() + " has spawned. Beware!");
        }

        

       
    }
}
