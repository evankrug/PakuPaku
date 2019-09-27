using System;
using System.Collections.Generic;
using System.Text;

namespace PakuPaku
{
    class GameController
    {
        private List<Ghost> ghostlist;
        private const int NUM_GHOSTS = 4;

        //values from PAS file lines 220-229
        private const int pointsPerLife = 10000;
        private const int startingLives = 3;
        private const int startingLevel = 0;

        private const int startingDots = 244;
        private const int fruitCounter1 = startingDots - 70;
        private const int fruitCounter2 = fruitCounter1 - 100;
        private const int elroy = 20;  //I believe this refers to the number of dots paku must eat before blinky speeds up. Source: https://pacman.fandom.com/wiki/Blinky
        private const int superElroy = 10;


        public GameController()
        {
            Console.WriteLine("Game controller has been created");
            ghostlist = new List<Ghost>();
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
            ghostlist.Add(new Ghost(Ghosts.stinky)); //red
            ghostlist.Add(new Ghost(Ghosts.kinky)); //blue
            ghostlist.Add(new Ghost(Ghosts.hinky)); //pink
            ghostlist.Add(new Ghost(Ghosts.blaine)); //orange

        }
    }
}
