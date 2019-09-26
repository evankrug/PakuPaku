using System;
using System.Collections.Generic;
using System.Text;

namespace PakuPaku
{
    class GameController
    {
        private List<Ghost> ghosts;
        private const int NUM_GHOSTS = 4;
        public GameController()
        {
            Console.WriteLine("Game controller has been created");
            ghosts = new List<Ghost>();
        }

        //Responsible for setting up the game
        public void startGame()
        {
            PakuPaku paku = new PakuPaku();
            spawnGhosts();

        }

        //creates the four ghosts for gameplay
        public void spawnGhosts()
        {
            ghosts.Add(new Ghost("Stinky"));
            ghosts.Add(new Ghost("Kinky"));
            ghosts.Add(new Ghost("Hinky"));
            ghosts.Add(new Ghost("Blaine"));
        }
    }
}
