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
//procedure menuLoop;
//var
//    ch:char;
//	b,color:byte;
//	t,n,
//	counter,
//	borderCounter,
//	mt32Counter:word;
//begin
//    ch:=#255;
//	score:=0;
//	counter:=0;
//	borderCounter:=0;
//	mt32Counter:=0;
//	color:=c_green;
//	soundOn:=true;
//	drawMenu;
//	userClockCounter:=0;
//	repeat
//		if userTimerExpired(timerInterval) then begin


//            counter:=(counter+1) and $1F;

//			case (counter and $0F) of
//				$00:begin
//                    n:=32;
//					if (counter=$00) then t:=0 else t:=1;
//					repeat
//                        buffer_copySourceDest8x8(90, n);
//buffer_tile5(90, n, t);
//buffer_show8x6(89, n);
//inc(n,7);
//inc(t,8);
//until t>=32;
//				end;
//				$01,$09:begin
//					for n:=0 to 3 do begin
//                        borderCounter:=(bordercounter+1) and $03;
//						b:=borderColors[borderCounter];
//						t:=n+30;
//						repeat
//                            tg_putpixel(t+57,   29, b);
//tg_putpixel(187-t,   60, b);
//tg_putpixel(   87, 89-t, b);
//tg_putpixel(  157, t, b);
//inc(t,4);
//until t>60;
//						inc(t,57);
//repeat
//    tg_putpixel(t,   29, b);
//tg_putpixel(244-t,   60, b);
//inc(t,4);
//until t>157;
//					end;
//					inc(bordercounter);
//end;
//				$04,$0C:begin
//                    pelletBlinkCounter:=(pelletBlinkCounter+1) mod 6;
//					curPellet:=@pelletData;
//					case pelletBlinkCounter of
//						0:begin
//                            repeat

//                                with curPellet^ do tg_bar(x, y, x+2, y+2,0);
//inc(curPellet);
//until longint(curPellet)>longint(@pelletData[3]);
//tg_bar(101,80,103,82, c_black);
//end;
//						3:begin
//                            tileSource:=mapTiles.dataStart;
//							repeat
//                                with curPellet^ do tg_Tile3(x, y,$21);
//inc(curPellet);
//until longint(curPellet)>longint(@pelletData[3]);
//tg_tile3(101,80,$21);
//tileSource:=spriteTiles.dataStart;
//						end;
//					end;
//				end;
//				$08:begin

//                    fonts^.outtext(98,15,'ENTER', color);
//color:=color xor $08;
//					fonts^.outtext(103,21,'ESC', color);
//end;
//			end;

//			if (soundSource=sound_MT32) and(counter=$1E) then begin
//				if (mt32Counter and $01)>0 then begin

//                    mt32_Display('***  PAKU  PAKU  ***');
//end else mt32_Display('     PAKU  PAKU     ');
//inc(mt32Counter);
//end;

//		end; {timerinterval}

//		if keypressed then begin
//            ch:=readkey;
//			if ch=#13 then begin
//				gameloop;
//				drawMenu;
//			end else checkGlobalKeys(ch,true);
//end else if (
//    joyEnabled and

//            (joystickButton(0) or joystickButton(1))
//		) then begin

//            gameloop;
//			drawMenu;
//		end;
//	until ch =#27;
//	silence;
//flushKeyBuffer;
//end;