using System;
using System.Collections.Generic;
using System.Text;

namespace PakuPaku
{
    class Ghost
    {
        private String name;
        public Ghost(String name)
        {
            this.name = name;
            Console.WriteLine(name + " has spawned. Beware!");
        }
    }
}
