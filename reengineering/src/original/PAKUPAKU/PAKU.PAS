{$M 3072,26624,26624}
{
	3k stack + 26k heap + 36k .exe
	== 65k memory footprint
	Trying to stay under 72k!
}

program paku;

{
	PAKU PAKU, A TXTGRAPH Game
	Jason M. Knight, 2011
	Revision 1.6

	New in this release:

		Added MT32/GM/Midi support
		-- *NOTE* requires midi device to be able to have
		   24 step pitch bend range or allow setting via RPN

		   Which "Microsoft GS Wavetable" does not...

		Better EGA and VGA support
		-- VGA now uses BIOS scanline set, works properly on pretty much everything!
		-- EGA sets misc register properly

		"infinite fruit" bugfix
		-- added counter of how many have been shown

		Fixed AI bug where random turn was ignored
		Fixed AI bug where random don't turn was always taken
		Fixed AI bug where death during final 'chase' resumed as 'always scatter'
		-- increased difficulty

		Fixed 'final chase' behavior update being called every timer tick
		-- got rid of late game 'slowdowns' on slower systems

		Improved sound on/off handling
		-- can now turn sound off mid-theme and during longer sfx

		Better dividing of tasks between audio timer ticks
		-- should lower CPU speed requirements even further

		removed many FOR, WHILE and REPEAT for recursive object calls
		-- speedup, lower memory use and simpler logic flow

		Rewrote many library functions in ASM
		-- speedup, smaller exe size

		Stopped passing sprite pointer on every call, now handled by
		global pointer "tileSource"
		-- speedup, lower stack use

		New Joystick Handler
		-- faster, reads both axis at same time

		Replaced write/writeln with custom handler
		-- reduced total code size 5%, who knew WRITE was inefficient?

		Smaller/simpler graphics 'outtext' routines
		-- removed all the custom number outputs
		-- allows wider use of background erase or transparent

		Rewrote 'circling' pixels on menu page
		-- faster, lower memory use, prevents really slow
		   8088's from bogging down

		Renamed many procedures and variables
		-- code cleanup, make it easier to find things

		Renamed all data files to .DAT (no more .FNT or .TDT)
		-- just makes copying just the needed stuff easier

		Moved music config info into external .DAT files
		-- Lowers heap/stack/code size, makes customization easier

				PAT_MT32.DAT, PAT_GM.DAT, PAT_CUST.DAT
				Patch files for MT32, General Midi or Custom (see custMidi.txt)

				PAT_ADLB.DAT
				Instrument Data for Adlib

		Distribution built with stack checking off
		-- reduced exe size, faster execution. My stack is fine, don't need
		   the program second guessing me.

	deathshadow60@hotmail.com
	http://www.deathshadow.com

}

{
	add "DEFINE profile" for checking timeslices
}

uses
	jfunc,
	timer,
	sound,
	txtGraph,
	joystick;

const
	revision='1.6';
	buildDate='9 November, 2011';
	makerString:string[15]='PALADIN_SYSTEMS';
	titleString=
		CRLF+'PAKU PAKU By Jason M. Knight, Paladin Systems North. '+
		CRLF+'Version '+revision+' - '+buildDate+
		CRLF+CRLF;

type
	initials=string[3];

	pPlayerScore=^tPlayerScore;
	tPlayerScore=record
		points:longint;
		name:initials;
		system:boolean;
	end;

	tScoreList=object
		data:array[0..4] of tPlayerScore;
		lastScore:longint;
		f:file;
		constructor init;
		procedure update;
		destructor term;
	end;

	gameSprite=object
		tile:integer;
		cSprite:pSprite;
		constructor init(sx,sy,sTile:integer);
	end;

	tBonus=object(gameSprite)
		showCounter:integer;
		direction:byte;
		constructor init;
		procedure reset;
		procedure activate;
		procedure update;
	end;

	tPlayer=object(gameSprite)
		direction,
		inputDirection:byte;
		waka,wakaDir:integer;
		lastInputDirX:boolean;
		constructor init;
		procedure reset;
		procedure update;
	end;

	pGhost=^tGhost;
	tGhost=object(gameSprite)
		direction,inputDirection,
		tileOffset,activeTileOffset,
		logic,
		mode,
		frame,
		fleeCounter,
		exitCounter,
		homeX,homeY:integer;
		alternate,inJail:boolean;
		next:pGhost;
		constructor init(sLogic:integer);
		procedure reset;
		procedure update;
		destructor term;
	end;

	tGhostData=record
		nickname:string[6];
		behavior:string[7];
		color:byte;
		cx,cy,d,hx,hy:byte;
	end;

	tLevelData=record
		symbol:byte;
		points:word;
		rate:byte;
		frightTime,
		flashes:word;
	end;

	tBehavior=record
		behavior:byte;
		time:word;
	end;
	tBehaviorList=array[0..7] of tBehavior;

	pPelletData=^tPelletData;
	tPelletData=record
		x,y,
		tileX,
		tileY:byte;
	end;

	pTextLine=^tTextLine;
	tTextLine=record
		x,y:byte;
		center:boolean;
		data:string[14];
	end;

	pTextLineLong=^tTextLineLong;   
	tTextLineLong=record
		x,y:byte;
		center:boolean;
		data:string[24];
	end;

const
	readyString='READY!';

	{ difficulty settings }
	pointsPerLife=10000;
	startingLives=3;
	startingLevel=0;

	{game settings}
	startingDots=244;
	fruitCounter1=startingDots-70;
	fruitCounter2=fruitCounter1-100;
	elroy=20;
	superElroy=10;

	move_up 	 = 0;
	move_right = 1;
	move_down  = 2;
	move_left  = 3;
	move_none  = $80;

	mode_scatter = 0;
	mode_chase	 = 1;
	mode_flee 	 = 2;
	mode_eaten	 = 3;

	jail_left 	= 33;
	jail_right	= 52;
	jail_top		= 38;
	jail_bottom = 44;

	stinky=0;
	kinky=1;
	hinky=2;
	blaine=3;

	fieldOffsetX=1;
	fieldWidth=28;
	fieldEndX=fieldWidth*3+fieldOffsetX;

	ghostData:array[0..3] of tGhostData=( 
		(nickname:'STINKY'; behavior:'HOUND'; 	color:4; cX:40; cY:32; d:move_left; hX:78; hY:1),
		(nickname:'KINKY';	behavior:'HUNTER';	color:5; cX:41; cY:39; d:move_up; 	hX:1;  hY:1),
		(nickname:'HINKY';	behavior:'SCHIZO';	color:3; cX:34; cY:39; d:move_down; hX:78; hY:85),
		(nickname:'BLAINE'; behavior:'ELUSIVE'; color:6; cX:47; cY:39; d:move_up; 	hX:1;  hY:85)
	);

	levelData:array[1..21] of tLevelData=( 
		(symbol:$38; points:100;	rate:6; frightTime:1320; flashes:600),
		(symbol:$39; points:300;	rate:5; frightTime:1200; flashes:600),
		(symbol:$3A; points:500;	rate:5; frightTime:1080; flashes:600),
		(symbol:$3A; points:500;	rate:5; frightTime:960;  flashes:600),

		(symbol:$3B; points:700;	rate:4; frightTime:840;  flashes:600),
		(symbol:$3B; points:700;	rate:4; frightTime:1320; flashes:600),
		(symbol:$3C; points:1000; rate:4; frightTime:840;  flashes:600),
		(symbol:$3C; points:1000; rate:4; frightTime:840;  flashes:600),

		(symbol:$3D; points:2000; rate:4; frightTime:480;  flashes:360),
		(symbol:$3D; points:2000; rate:4; frightTime:1200; flashes:600),
		(symbol:$3E; points:3000; rate:4; frightTime:840;  flashes:600),
		(symbol:$3E; points:3000; rate:4; frightTime:480;  flashes:360),

		(symbol:$3F; points:5000; rate:4; frightTime:480; flashes:360),
		(symbol:$3F; points:5000; rate:4; frightTime:960; flashes:600),
		(symbol:$3F; points:5000; rate:4; frightTime:480; flashes:360),
		(symbol:$3F; points:5000; rate:4; frightTime:480; flashes:360),

		(symbol:$3F; points:5000; rate:4; frightTime:0; 	flashes:0),
		(symbol:$3F; points:5000; rate:4; frightTime:480; flashes:360),
		(symbol:$3F; points:5000; rate:4; frightTime:0; 	flashes:0),
		(symbol:$3F; points:5000; rate:4; frightTime:0; 	flashes:0),

		(symbol:$3F; points:5000; rate:5; frightTime:0; 	flashes:0)
	);

	behaviorLevel1:tBehaviorList=(
		(behavior:mode_scatter; time:420),
		(behavior:mode_chase; time:1200),
		(behavior:mode_scatter; time:420),
		(behavior:mode_chase; time:1200),
		(behavior:mode_scatter; time:300),
		(behavior:mode_chase; time:1200),
		(behavior:mode_scatter; time:300),
		(behavior:mode_chase; time:1)
	);
	behaviorLevel2_4:tBehaviorList=(
		(behavior:mode_scatter; time:420),
		(behavior:mode_chase; time:1200),
		(behavior:mode_scatter; time:420),
		(behavior:mode_chase; time:1200),
		(behavior:mode_scatter; time:300),
		(behavior:mode_chase; time:65535),
		(behavior:mode_scatter; time:1),
		(behavior:mode_chase; time:1)
	);
	behaviorLevel5Plus:tBehaviorList=(
		(behavior:mode_scatter; time:300),
		(behavior:mode_chase; time:1200),
		(behavior:mode_scatter; time:300),
		(behavior:mode_chase; time:1200),
		(behavior:mode_scatter; time:300),
		(behavior:mode_chase; time:65535),
		(behavior:mode_scatter; time:1),
		(behavior:mode_chase; time:1)
	);

	pelletData:array[0..3] of tPelletData=(
		(x:4;  y:9;  tileX:1;  tileY:3),
		(x:79; y:9;  tileX:26; tileY:3),
		(x:79; y:69; tileX:26; tileY:23),
		(x:4;  y:69; tileX:1;  tileY:23)
	);

	borderColors:array[0..3] of byte=(c_white,c_ltRed,c_red,c_black);

	menuTextStart=0;
	menuTextCount=4;

	highLastTextStart=menuTextCount+menuTextStart;
	highLastTextCount=3;

	scoreTextStart=highLastTextStart+highLastTextCount;
	scoreTextCount=5;

	lastText=scoreTextStart+scoreTextCount-1;

	textList:array[menuTextStart..lastText] of tTextLine=(
		(x:107; y:73; center:false; data:'10 POINTS'),
		(x:107; y:79; center:false; data:'50 POINTS'),
		(x:98;	y:15; center:false; data:'ENTER TO PLAY'),
		(x:103; y:21; center:false; data:'ESC TO EXIT'),

		(x:23;  y:18; center:false; data:'HIGH'),
		(x:40;  y:18; center:false; data:'SCORES'),
		(x:43;  y:57; center:true;  data:'LAST SCORE'),

		(x:43; y:18; center:true; data:'\EEXCELLENT!'),
		(x:43; y:27; center:true; data:'\BYOU HAVE THE'),
		(x:43; y:33; center:true; data:'\BHIGH SCORE!'),
		(x:43; y:42; center:true; data:'\FENTER YOUR'),
		(x:43; y:48; center:true; data:'\FINITIALS')
	);

	calibrateTextList:array[0..5] of tTextLineLong=(
		(x:0; y:22; center:true; data:'\EJOYSTICK CALIBRATION'),
		(x:0; y:39; center:true; data:'CENTER STICK AND PRESS'),
		(x:0; y:45; center:true; data:'\FBUTTON\7 OR \FSPACEBAR'),
		(x:0; y:51; center:true; data:'TO CALIBRATE'),
		(x:0; y:60; center:true; data:'OR \FESC\7 TO CANCEL AND'),
		(x:0; y:66; center:true; data:'DISABLE JOYSTICK')
	);

var
	score,
	highScore:longint;
	scoreList:tScoreList;

	lives,
	level,truncLevel,
	dots,
	ghostMode,
	nextGhost,
	behaviorStep,
	behaviorCounter,
	globalDotCounter,
	globalJailCounter,
	globalFleeCounter,
	pelletBlinkCounter,
	gainLifeCounter,
	fleeTotal,
	siren,chompSound,
	frameSpeed,
	timerInterval:word;

	joyEnabled:boolean;
	joyX,joyY:integer;
	joyPosition:longint absolute joyX;
	joyCenterX,joyCenterY,
	joyDeadX,joyDeadY,
	joyDirection:integer;
	joyScaleY:real;

	soundOn,
	globalJailCounterEnable:boolean;

	map,
	mapTiles,
	spriteTiles:tDynamicData;

	theme:tMusic;
	midiSiren:word;

	fonts:pFontSet;

	tileMap:array[0..30,0..fieldWidth-1] of byte;

	player:tPlayer;
	bonus:tBonus;
	pStinky,pHinky,pBlaine:pGhost;

	curPellet:pPelletData;

{$IFDEF PROFILE}
	profileCount:word;
	profile:array[0..9] of longint;
{$ENDIF}

const
	pTileMap:pointer=@tileMap;

procedure wait(ticks:word);
begin
	userClockCounter:=0;
	repeat
		if userTimerExpired(timerInterval) then dec(ticks);
	until ticks<=0;
end;

procedure drawdrawScoreBox;
begin
	tg_rectangle(16,14,69,72,c_ltBlue);
	tg_bar(17,15,68,71,c_blue);
	tg_putpixel(16,14,c_black);
	tg_putpixel(16,72,c_black);
	tg_putpixel(69,14,c_black);
	tg_putpixel(69,72,c_black);
end;

procedure drawTextArray(first,count:word);
var
	current,last:pTextLine;
begin
	current:=@textList[first];
	last:=@textList[first+count];
	repeat
		with current^ do if center then begin
			fonts^.outTextCentered(x,y,data,c_ltGrey);
		end else fonts^.outText(x,y,data,c_ltGrey);
		inc(current);
	until current=last;
end;

procedure drawScoreBox;
var
	t,n,b:byte;
begin
	drawdrawScoreBox;
	n:=25;
	for t:=0 to 4 do with scoreList.data[t] do begin
		if system then b:=c_ltBlue else if t=0 then b:=c_white else b:=c_ltGrey;
		fonts^.outText(19,n,longToSt8(points),b);
		if (b=15) then dec(b);
		fonts^.outTextCentered(60,n,name,b);
		inc(n,6);
	end;
	fonts^.outTextCentered(43,64,longToSt8(scoreList.lastScore),c_cyan);
	drawTextArray(highLastTextStart,highLastTextCount);
end;

procedure drawAudioStatus;
begin
	tg_bar(107,94,142,98,0);
	fonts^.outText(107,94,'S\FO\7UND',c_ltGrey);
	if soundOn then begin
		fonts^.outtext(129,94,'ON',c_ltGreen);
	end else fonts^.outtext(129,94,'OFF',c_red);
end;

procedure drawLives;
var
	x,xEnd:integer;
begin
	x:=2;
	xEnd:=lives*6-4;
	while (x<xEnd) do begin
		tg_tile5(x,94,$4C);
		inc(x,6);
	end;
	tg_bar(x,94,26,99,0);
end;

{ map is stored RLE, so we need to decode that }
procedure drawPlayfield;
var
	px,py:word;
	mapOffset:pByte;
	c:byte;

begin
	px:=fieldOffsetX;
	py:=0;
	mapOffset:=map.dataStart;
	tileSource:=mapTiles.dataStart;
	buffer_sourceClear;
	buffer_sourceRender;
	repeat
		if (mapOffset^ and $80)=0 then c:=1 else begin
			{
				bit 7 set, bottom bits holds how many times
				to repeat next byte. Store the repeat and move
				the pointer ahead one.
			}
			c:=mapOffset^ and $7F;
			inc(mapOffset);
		end;
		repeat
			buffer_tile3(px,py,mapOffset^);
			inc(px,3);
			if (px>=fieldEndX) then begin
				px:=fieldOffsetX;
				inc(py,3);
			end;
			dec(c);
		until c=0;
		inc(mapOffset);
	until mapOffset=map.dataEnd;
	tileSource:=spriteTiles.dataStart;
	buffer_sourceBackground;
	buffer_copySource2Dest;
	buffer_copyDest2Screen;
end;

procedure drawMenu;
var
	t,n,v:word;
begin
	level:=0;
	lives:=startingLives;
	userClockCounter:=0;
	tg_clear(0);
	drawPlayField;
	drawLives;
	n:=91;
	v:=32;
	for t:=0 to 7 do begin
		tg_tile5(37+t*6,94,t+$38);
		if t<6 then begin
			tg_tile5(n,3,$60+t);
			tg_tile5(n,8,$66+t);
			inc(n,36);
			tg_tile5(n,3,$60+t);
			tg_tile5(n,8,$66+t);
			dec(n,31);
			if t<4 then with ghostData[t] do begin
				fonts^.outText( 98,v,nickname,color or 8);
				fonts^.outText(127,v,behavior,color);
				inc(v,7);
			end;
		end;
	end;
	drawTextArray(menuTextStart,menuTextCount);
	tg_tile5(120,7,$50);
	tileSource:=mapTiles.dataStart;
	tg_tile3(101,74,$20);
	tileSource:=spriteTiles.dataStart;
	drawAudioStatus;
	drawScoreBox;
end;

procedure eraseReady;
var
	x:word;
begin
	x:=32;
	repeat
		buffer_show8x6(x,50);
		inc(x,6);
	until x>50;
end;

constructor tScoreList.init;
var
	t:word;
	n:longint;
begin
	assign(f,'SCORES.DAT');
	{$I-}
	reset(f,1);
	{$I+}
	if IOResult=0 then begin
		blockread(f,data,sizeof(data));
		blockread(f,lastScore,4);
		close(f);
	end else begin
		n:=80000;
		for t:=0 to 4 do with data[t] do begin
			name:=copy(makerString,t*3+1,3);
			points:=n;
			n:=n shr 1;
			system:=true;
		end;
		lastScore:=0;
	end;
	highScore:=data[0].points;
end;

function getScoreName:initials;
var
	t:byte;
	ch:char;
	tst:st10;
begin
	tst:='';
	ch:=' ';
	t:=0;
	userClockCounter:=0;
	flushKeyBuffer;
	repeat
		if userTimerExpired(timerInterval) then begin
			case (t and $1F) of
				$00:fonts^.outtextCentered(43,59,tst+'\9_',c_white);
				$10:fonts^.outtextCentered(43,59,tst+'_',c_white);
			end;
			inc(t);
		end;
		if keypressed then begin
			ch:=readkey;
			case ch of
				'a'..'z',
				'A'..'Z',
				'0'..'9',
				#32:begin
					tst:=tst+upcase(ch);
					tg_waitRetrace;
					tg_bar(30,59,56,65,c_blue);
					fonts^.outtextCentered(43,59,tst+'_',c_white);
					wait(30);
				end;
				#13:ch:=#27;
			end;
		end;
	until (ch=#27) or (length(tst)=3);
	tg_bar(30,59,56,65,c_blue);
	fonts^.outtextCentered(43,59,tst,c_white);
	wait(120);
	flushKeyBuffer;
	getScoreName:=tst;
end;

procedure tScoreList.update;
var
	t,n:word;
begin
	lastScore:=score;
	t:=0;
	while (t<5) do with data[t] do begin
		if lastScore>points then begin
			n:=4;
			while (n>t) do begin
				move(data[n-1],data[n],sizeof(tPlayerScore));
				dec(n);
			end;
			points:=lastScore;
			system:=false;
			drawdrawScoreBox;
			drawTextArray(scoreTextStart,scoreTextCount);
			name:=getScoreName;
			break;
		end;
		inc(t);
	end;
	highScore:=data[0].points;
end;

destructor tScoreList.term;
begin
	rewrite(f,1);
	blockwrite(f,data,sizeof(data));
	blockwrite(f,lastScore,4);
	close(f);
end;

procedure whitePlayField; assembler;
asm
	les  di,renderBuffer
	mov  cx,7520
	inc  di
	mov  dx,$0301
	mov  bx,$3010
@loop:
	mov  al,es:[di]
	mov  ah,al
	and  ah,dh
	cmp  ah,dl
	jne  @compare2
	or	 al,$07
@compare2:
	mov  ah,al
	and  ah,bh
	cmp  ah,bl
	jne  @writeIt
	or	 al,$70
@writeIt:
	stosb
	loop @loop
end;

procedure showDestPlayField; assembler;
asm
	mov  ax,$B800
	mov  es,ax
	mov  di,1
	push ds
	lds  si,destBuffer
	mov  cx,93
	mov  bl,43
@loopRow:
	mov  bh,cl
	mov  cl,bl
@loopPixel:
	movsb
	inc  di
	loop @loopPixel
	add  di,74
	add  si,37
	mov  cl,bh
	loop @loopRow
	pop  ds
end;

procedure joyUpdate;
var
	ajx,ajy:integer;
begin
	if joyEnabled then begin
		joyPosition:=joystick1Axis;
		joyX:=joyX-joyCenterX;
		joyY:=joyY-joyCenterY;
		joyDirection:=move_none;
		ajx:=abs(joyX);
		ajy:=abs(joyY);
		if ajx>ajy then begin
			if ajx>joyDeadX then begin
				if joyX>0 then begin
					player.inputDirection:=move_right;
				end else	begin
					player.inputDirection:=move_left;
				end;
				if ((ajy*16) div ajx)>14 then begin
					if joyY>0 then begin
						joyDirection:=move_down;
					end else begin
						joyDirection:=move_up;
					end;
				end;
			end;
		end else begin
			if ajy>joyDeadY then begin
				if joyY>0 then begin
					player.inputDirection:=move_down;
				end else begin
					player.inputDirection:=move_up;
				end;
				if ((ajx*16) div ajy)>14 then begin
					if joyX>0 then begin
						joyDirection:=move_right;
					end else	begin
						joyDirection:=move_left;
					end;
				end;
			end;
		end;
	end;
end;

function joyCalibrate(displayX:byte):boolean;
var
	ch:char;
	stx,sty:string[8];
	current:pTextLineLong;
begin
	joyPosition:=joystick1Axis;
	if (joyX<stickFailPoint) then begin
		ch:='~';
		current:=@calibrateTextList[0];
		repeat
			with current^ do if center then begin
				fonts^.outTextCentered(x+displayX,y,data,c_ltGrey);
			end else fonts^.outText(x+displayX,y,data,c_ltGrey);
			inc(current);
		until longint(current)>longint(@calibrateTextList[5]);
		fonts^.setBackground(c_blue);
		repeat
			joyPosition:=joystick1Axis;
			str(joyX,stx);
			str(joyY,sty);
			fonts^.outTextCentered(displayX-17,30,'  '+stx+'  ',c_ltCyan);
			fonts^.outTextCentered(displayX+17,30,'  '+sty+'  ',c_ltCyan);
			{
				now wait a couple frames so we're sure both values show
				on screen
			}
			if keypressed then ch:=readkey;
			if (
				(ch=#32) or
				joystickButton(0) or
				joystickButton(1)
			) then begin
				joystickDebounce;
				joyCenterX:=joyX;
				joyCenterY:=joyY;
				joyScaleY:=joyCenterX/joyCenterY;
				joyDeadX:=joyCenterX div 4;
				joyDeadY:=trunc(joyCenterY*joyScaleY/4);
				ch:=#32;
				joyCalibrate:=true;
			end else if (ch=#27) then joyCalibrate:=false;
		until (ch=#27) or (ch=#32);
		fonts^.setBackground(c_transparent);
	end else begin
		joyCalibrate:=false;
	end;
	joyDirection:=move_none;
end;

procedure joyInit;
begin
	if paramExists('/joy') then begin
		tg_clear(1);
		joyEnabled:=joyCalibrate(79);
	end else joyEnabled:=false;
	joyDirection:=move_none;
end;

procedure silence;
begin
	killVoices;
	midiSiren:=0;
end;
/* Current end on class Diagram */
procedure checkGlobalKeys(ch:char; fromMenu:boolean);
begin
	case ch of
		'o','O':begin
			if soundOn then silence;
			soundOn:=not(soundOn);
			drawAudioStatus;
		end;
		'j','J':if joyEnabled then begin
			if soundOn then silence;
			tg_bar(0,0,84,92,c_blue);
			joyCalibrate(43);
			if (fromMenu) then drawMenu else begin
				showDestPlayfield;
				buffer_writeSpritesToBackBuffer;
				buffer_copySpritesToScreen;
				buffer_eraseSpritesFromBuffer;
			end;
			userClockCounter:=0;
		end;
	end;
end;

function gameKeyCheck:char;
var
	ch:char;
begin
	if keypressed then begin
		ch:=readkey;
		gameKeyCheck:=ch;
		case ch of
			#0:begin
				ch:=readkey;
				case ch of
					#$48:player.inputDirection:=move_up;
					#$4D:player.inputDirection:=move_right;
					#$50:player.inputDirection:=move_down;
					#$4B:player.inputDirection:=move_left;
				end;
			end;
			'w','W','8':player.inputDirection:=move_up;
			'd','D','6':player.inputDirection:=move_right;
			's','S','2':player.inputDirection:=move_down;
			'a','A','4':player.inputDirection:=move_left;
{$IFDEF PROFILE}
		  'p':dots:=0;
		  'k':scorePoints(1000);
{$ENDIF}
			#27:lives:=0;
			else checkGlobalKeys(ch,false);
		end;
	end else gameKeyCheck:=#0;
end;

procedure playEatGhost;
var
	count:word;
begin
	if (soundOn) then begin
		silence;
		userClockCounter:=0;
		if soundIsMidi then begin
			count:=0;
			MPU401_OutBB(MIDI_NoteOn,5,69,127);
			repeat
				if userTimerExpired(timerInterval) then begin
					MPU401_pitchBend(5,count);
					inc(count,260);
				end;
				gameKeycheck;
				if not(soundOn) then count:=$FFFF;
			until count>16383;
			MPU401_OutBB(MIDI_NoteOff,5,69,127);
		end else begin
			count:=110;
			repeat
				if userTimerExpired(timerInterval) then begin
					outFreq(0,count,$0F,0);
					inc(count,25);
				end;
				gameKeyCheck;
				if not(soundOn) then count:=$FFFF;
			until count>=1760;
		end;
	end else wait(90);
end;

procedure playTheme;
var
	ch:char;
label
	done;
begin
	wait(20);
	userClockCounter:=0;
	repeat
		ch:=gameKeyCheck;
		if not(soundOn) then goto done;
		if userTimerExpired(timerInterval) and not(theme.step) then ch:=#32;
	until (ch=#27) or (ch=#32) or (ch=#13);
done:
	theme.rewind;
end;

procedure scorePoints(points:longint);
var
	oldScore:longint;
begin
	oldScore:=score mod pointsPerLife;
	inc(score,points);
	fonts^.setBackground(c_black);
	fonts^.outText(108,36,longToSt8(score),c_cyan);
	if (score>highScore) then begin
		highScore:=score;
		fonts^.outText(108,18,longToSt8(highScore),c_cyan);
	end;
	fonts^.setBackground(c_transparent);
	if oldScore>(score mod pointsPerLife) then begin
		if (lives<5) then begin
			inc(lives);
			gainLifeCounter:=90;
		end;
		drawLives;
	end;
end;

constructor tBonus.init;
begin
	showCounter:=0;
	direction:=move_right;
	cSprite:=buffer_addSprite(150,90,$5F,5);
	with cSprite^ do begin
		currentX:=154;
		currentY:=0;
		currentTile:=$5F;
		showCounter:=0;
	end;
end;

procedure tBonus.reset;
begin
	with cSprite^ do begin
		buffer_copySourceDest8x8(currentX,currentY);
		bufferShow(currentX,currentY);
		currentX:=154;
		currentY:=0;
		oldX:=currentX;
		oldY:=currentY;
		currentTile:=$5F;
		showCounter:=0;
	end;
end;

procedure tBonus.activate;
begin
	with (cSprite^) do begin
		cSprite^.currentTile:=levelData[truncLevel].symbol;
		currentX:=40;
		currentY:=50;
	end;
	showCounter:=(1080+random(120)) div frameSpeed;
end;

procedure tBonus.update;
begin
	if (showCounter>0) then begin
		dec(showCounter);
	end else if not(cSprite^.currentTile=$5F) then reset;
end;

constructor gameSprite.init(sx,sy,sTile:integer);
begin
	tile:=sTile;
	cSprite:=buffer_addSprite(sx,sy,tile,5);
end;

constructor tPlayer.init;
begin
	gameSprite.init(40,68,$42);
	reset;
end;

procedure tPlayer.reset;
begin
	with cSprite^ do begin
		currentX:=40;
		currentY:=68;
		currentTile:=$4C;
		oldX:=currentX;
		oldY:=currentY;
	end;
	direction:=move_left;
	inputdirection:=move_left;
	joyDirection:=move_none;
	waka:=0;
end;

procedure tPlayer.update;
var
	mx,my,
	tx,ty,
	dCount,oldDirection:integer;
	curGhost:pGhost;

	procedure eatDot;
	var
		t:word;
		curGhost:pGhost;
	begin
		tileMap[ty,tx]:=$28;
		if (soundSource=sound_pcSpeaker) then begin
			chompSound:=6;
		end else chompSound:=8;
		scorePoints(10);
		buffer_nullTile4x3(tx*3+1,ty*3);
		dec(dots);
		case dots of
			fruitCounter1,fruitCounter2:bonus.activate;
		end;
		globalDotCounter:=0;
		if globalJailCounterEnable then begin
			inc(globalJailCounter);
			if globalJailCounter>7 then begin
				pHinky^.exitCounter:=0;
				if globalJailCounter>14 then begin
					pBlaine^.exitCounter:=0;
				end;
			end;
		end else begin
			curGhost:=pStinky;
			repeat
				with curGhost^ do begin
					if inJail and (exitCounter>0) then begin
						dec(exitCounter);
						break;
					end;
				end;
				curGhost:=curGhost^.next;
			until curGhost=nil;
		end;
	end;

begin
	with (cSprite^) do begin

		dCount:=1;
		oldDirection:=direction;

		mx:=currentX mod 3;
		my:=(currentY+1) mod 3;

		tx:=(currentX+1) div 3;
		ty:=(currentY+1) div 3;

		if (
			(direction=move_left) and
			(currentX=0) and
			(currentY=41)
		) then begin
			tg_bar(0,41,4,45,c_black);
			currentX:=81;
			oldX:=currentX;
		end else if (
			(direction=move_right) and
			(currentX=81) and
			(currentY=41)
		) then begin
			tg_bar(81,41,85,45,c_black);
			currentX:=0;
			oldX:=currentX;
		end;

		case tileMap[ty,tx] of
			$20:eatDot;
			$21:begin
				eatDot;
				globalFleeCounter:=levelData[truncLevel].frightTime;
				nextGhost:=200;
				curGhost:=pStinky;
				repeat
					with curGhost^ do begin
						if (
							not(inJail) and
							not(mode=mode_eaten)
						) then begin
							mode:=mode_flee;
							direction:=(direction+2) and $03;
							fleeCounter:=globalFleeCounter;
						end;
					end;
					curGhost:=curGhost^.next;
				until curGhost=nil;
			end;
		end;

		case direction of
			move_up,move_down:begin
				case inputDirection of
					move_up,move_down:direction:=inputDirection;
					else if (my=0) then begin
						case inputDirection of
							move_right:if tileMap[ty,tx+1]>0 then direction:=inputDirection;
							move_left:if tileMap[ty,tx-1]>0 then direction:=inputDirection;
						end;
					end;
				end;
			end;
			move_left,move_right:begin
				case inputDirection of
					move_left,move_right:direction:=inputDirection;
					else if (mx=0) then begin
						case inputDirection of
							move_up:if tileMap[ty-1,tx]>0 then direction:=inputDirection;
							move_down:if tileMap[ty+1,tx]>0 then direction:=inputDirection;
						end;
					end;
				end;
			end;
		end;

		if (
			not(joyDirection=move_none) and
			(direction=oldDirection)
		) then case joyDirection of
			move_up:if (mx=0) and (tileMap[ty-1,tx]>0) then direction:=joyDirection;
			move_down:if (mx=0) and (tileMap[ty+1,tx]>0) then direction:=joyDirection;
			move_right:if (my=0) and (tileMap[ty,tx+1]>0) then direction:=joyDirection;
			move_left:if (my=0) and (tileMap[ty,tx-1]>0) then direction:=joyDirection;
		end;

		if (
			not(direction=oldDirection) and
			not(direction=(oldDirection+2) and $03)
		) then begin
			inc(dCount);
		end;
		case direction of
			move_up:if my=0 then begin
				if tileMap[ty-1,tx]>0 then dec(currentY,dCount) else waka:=4;
			end else dec(currentY);
			move_right:if mx=0 then begin
				if tileMap[ty,tx+1]>0 then inc(currentX,dCount) else waka:=4;
			end else inc(currentX);
			move_down:if my=0 then begin
				if tileMap[ty+1,tx]>0 then inc(currentY,dCount) else waka:=4;
			end else inc(currentY);
			move_left:if mx=0 then begin
				if tileMap[ty,tx-1]>0 then dec(currentX,dCount) else waka:=4;
			end else dec(currentX);
		end;

		currentTile:=$40+direction*4+waka div 2;
	end;

	waka:=(waka+1) and $07;

end;

constructor tGhost.init(sLogic:integer);
begin
	logic:=sLogic;
	cSprite:=buffer_addSprite(0,0,0,5);
	case logic of
		hinky:pHinky:=@self;
		blaine:pBlaine:=@self;
	end;
	if (logic<3) then new(next,init(logic+1)) else next:=nil;
end;

procedure tGhost.reset;
begin
	tileOffset:=logic*8;
	activeTileOffset:=tileOffset;
	frame:=0;
	alternate:=false;
	with cSprite^ do with ghostData[logic] do begin
		direction:=d;
		homeX:=hx;
		homeY:=hy;
		currentX:=cx;
		currentY:=cy;
		oldX:=currentX;
		oldY:=currentY;
		mode:=mode_scatter;
		currentTile:=activeTileOffset+(frame div 4)+direction*2;
		exitCounter:=0;
		case logic of
			2:if level=1 then inc(exitCounter,30);
			3:if level=1 then inc(exitCounter,60) else inc(exitCounter,50);
		end;
	end;
	inputDirection:=direction;
	if not(next=nil) then next^.reset;
end;

procedure tGhost.update;
var
	dx,dy,
	adx,ady,
	sdx,sdy,
	mx,my,
	tx,ty,
	testAmt,
	r10,
	howFar:integer;
	allowTurn,jailSkip:boolean;
begin
	r10:=random(10);
	alternate:=not(alternate);

	with (cSprite^) do begin

		mx:=currentX mod 3;
		my:=(currentY+1) mod 3;

		tx:=(currentX+1) div 3;
		ty:=(currentY+1) div 3;

		inJail:=(
			(currentX>=jail_left) and
			(currentX<=jail_right) and
			(currentY>=jail_top) and
			(currentY<=jail_bottom)
		);

		if (inJail) then begin

			if (mode=mode_eaten) and (currentY<jail_bottom) then begin
				inc(currentY);
				if (currentY=jail_bottom) then begin
					mode:=mode_scatter;
				end;
			end else begin

				if exitCounter>0 then case currentY of
					jail_top:begin
						direction:=move_down;
						inc(currentX);
					end;
					jail_bottom:begin
						direction:=move_up;
						dec(currentX);
					end;
				end else begin
					case currentX of
						jail_left..39:direction:=move_right;
						41..jail_right:direction:=move_left;
						40:direction:=move_up;
					end;
				end;

				case direction of
					move_up:dec(currentY);
					move_right:inc(currentX);
					move_down:inc(currentY);
					move_left:dec(currentX);
				end;
			end;

		end else begin

			if (
				(direction=move_left) and
				(currentX=0) and
				(currentY=41)
			) then begin
				tg_bar(0,41,4,45,c_black);
				currentX:=81;
				oldX:=currentX;
			end else if (
				(direction=move_right) and
				(currentX=81) and
				(currentY=41)
			) then begin
				tg_bar(81,41,85,45,c_black);
				currentX:=0;
				oldX:=currentX;
			end;

			howFar:=1;
			jailSkip:=false;

			case mode of
				mode_scatter:begin
					dx:=homeX-currentX;
					dy:=homeY-currentY;
				end;
				mode_chase:begin
					case logic of
						stinky:begin
							dx:=player.cSprite^.currentX-currentX;
							dy:=player.cSprite^.currentY-currentY;
						end;
						kinky:begin
							case player.direction of
								move_up:begin
									dx:=player.cSprite^.currentX-12;
									dy:=player.cSprite^.currentY-12;
								end;
								move_down:begin
									dx:=player.cSprite^.currentX;
									dy:=player.cSprite^.currentY+12;
								end;
								move_left:begin
									dx:=player.cSprite^.currentX-12;
									dy:=player.cSprite^.currentY;
								end;
								move_right:begin
									dx:=player.cSprite^.currentX+12;
									dy:=player.cSprite^.currentY;
								end;
							end;
							dx:=dx-currentX;
							dy:=dy-currentY;
						end;
						hinky:begin
							case player.direction of
								move_up:begin
									dx:=player.cSprite^.currentX-6;
									dy:=player.cSprite^.currentY-6;
								end;
								move_down:begin
									dx:=player.cSprite^.currentX;
									dy:=player.cSprite^.currentY+6;
								end;
								move_left:begin
									dx:=player.cSprite^.currentX-6;
									dy:=player.cSprite^.currentY;
								end;
								move_right:begin
									dx:=player.cSprite^.currentX+6;
									dy:=player.cSprite^.currentY;
								end;
							end;
							dx:=((dx+pStinky^.cSprite^.currentX) div 2)-currentX;
							dy:=((dy+pStinky^.cSprite^.currentY) div 2)-currentY;
						end;
						blaine:begin
							dx:=player.cSprite^.currentX-currentX;
							dy:=player.cSprite^.currentY-currentY;
							testAmt:=round(sqrt(dx*dx+dy*dy));
							if (testAmt<7) then begin
								dx:=homeX-currentX;
								dy:=homeY-currentY;
							end;
						end;
					end;
				end;
				mode_flee:begin
					dx:=currentX-player.cSprite^.currentX;
					dy:=currentY-player.cSprite^.currentY;
					dec(fleeCounter,frameSpeed);
					if (fleeCounter<=0) then mode:=ghostMode;
				end;
				mode_eaten:begin
					if (
						((currentX=40) or (currentX=41)) and
						(currentY>=31) and
						(currentY<jail_bottom)
					) then begin
						direction:=move_down;
						jailSkip:=true;
					end else begin
						dx:=40-currentX;
						dy:=32-currentY;
						inc(howFar);
					end;
				end;
			end;

			if not(jailSkip) then begin

				adx:=abs(dx);
				ady:=abs(dy);

				case direction of
					move_up,move_left:testAmt:=-1;
					else testAmt:=1;
				end;

				case direction of

					move_up,move_down:if (my=0) then begin
						allowTurn:=(
							(r10>1) and
							((currentX=27) or (currentX=54)) and
							(currentY>26) and
							(currentY<56)
						);
						if (
							(adx>ady) or
							(tileMap[ty+testAmt,tx]=0) or
							(dy>0) or
							allowTurn
							or (r10>8)
						) then begin
							if dx>0 then begin
								if tileMap[ty,tx+1]>0 then begin
									direction:=move_right;
								end else if (
									(tileMap[ty,tx-1]>0) and
									((tileMap[ty+testAmt,tx]=0) or (allowTurn and (currentX=54)))
								) then begin
									direction:=move_left;
								end;
							end else begin
								if tileMap[ty,tx-1]>0 then begin
									direction:=move_left;
								end else if (
									(tileMap[ty,tx+1]>0) and
									((tileMap[ty+testAmt,tx]=0) or (allowTurn and (currentX=27)))
								) then begin
									direction:=move_right;
								end;
							end;
						end;
					end;

					move_left,move_right:if (mx=0) then begin
						allowTurn:=not(
							(r10>1) and
							((currentX>27) and (currentX<54)) and
							((currentY=32) or (currentY=68))
						);
						if (
							(ady>adx) or
							(tileMap[ty,tx+testAmt]=0) or
							(dx>0) or
							(r10>8)
						) then begin
							if dy>0 then begin
								if tileMap[ty+1,tx]>0 then begin
									direction:=move_down;
								end else if (
									(tileMap[ty-1,tx]>0) and
									(tileMap[ty,tx+testAmt]=0) and
									allowTurn
								) then begin
									direction:=move_up;
								end;
							end else begin
								if (tileMap[ty-1,tx]>0) and allowTurn then begin
									direction:=move_up;
								end else if (tileMap[ty+1,tx]>0) and (tileMap[ty,tx+testAmt]=0) then begin
									direction:=move_down;
								end;
							end;
						end;
					end; { left/right }

				end; {case }

			end; { not jailskip }

			if not(
				(
					(mode=mode_flee) or (
						(currentY=41) and (
							(currentX<18) or (currentX>62)
						)
					)
				) and alternate
			)
			 then case direction of
				move_up:if my=0 then begin
					if tileMap[ty-1,tx]>0 then dec(currentY,howfar);
				end else dec(currentY);
				move_right:if mx=0 then begin
					if tileMap[ty,tx+1]>0 then inc(currentX,howfar);
				end else inc(currentX);
				move_down:if my=0 then begin
					if (tileMap[ty+1,tx]>0) or jailSkip then inc(currentY,howfar);
				end else inc(currentY);
				move_left:if mx=0 then begin
					if tileMap[ty,tx-1]>0 then dec(currentX,howfar);
				end else dec(currentX);
			end;

		end;

		currentTile:=(frame div 4)+direction*2;
		case mode of
			mode_eaten:inc(currentTile,$30);
			mode_flee:begin
				inc(currentTile,$20);
				if fleeCounter<levelData[truncLevel].flashes then begin
					inc(currentTile,(not(fleeCounter) and $40) shr 3);
				end;
				inc(fleeTotal);
			end;
			else inc(currentTile,activeTileOffset);
		end;
	end;
	frame:=(frame+1) and $07;
	if not(next=nil) then next^.update;
end;

destructor tGhost.term;
begin
	if not(next=nil) then dispose(next,term);
end;

procedure decodeTileMap; assembler;
asm
	push ds
	les  dx,map.dataEnd
	les  di,pTileMap
	lds  si,map.dataStart
	mov  ah,$28
	mov  bx,$2021
	xor  ch,ch
@loop1:
	lodsb
	mov  cl,1
	test al,$80
	jz   @test
	mov  cl,al
	and  cl,$7F
	lodsb
@test:
	cmp  al,ah
	je   @render
	cmp  al,bl
	je   @render
	cmp  al,bh
	je   @render
	mov  al,0
@render:
	rep  stosb
	cmp  si,dx
	jb   @loop1
	pop ds
end;

procedure loadData;
begin
	sWrite('Loading Data'+CRLF);
	map.init('MAP');
	mapTiles.init('MAPTILES');
	spriteTiles.init('SPRITES');
	tileSource:=spriteTiles.dataStart;
	new(fonts,init('FONTS'));
	scoreList.init;
	decodeTileMap;
	sWrite('Initializing Sprites System'+CRLF);
	new(pStinky,init(0));
	pStinky^.reset;
	player.init;
	bonus.init;
	curPellet:=@pelletData[0];
	repeat
		with curPellet^ do updateList.add(x,y);
		inc(curPellet);
	until longint(curPellet)>longint(@pelletData[3]);
	swrite(CRLF+'Starting Timer');
	startTimer;
	timerInterval:=getUserClockInterval(120);
	sWrite(
		' - Complete'+
		CRLF+'Starting Sound'
	);
	theme.init('THEME');
	startSound;
	if (soundSource=sound_adlib) then begin
		adlibSetVoice(0,pAdlibInstrument(patchKit.dataStart));
		adlibSetVoice(1,pAdlibInstrument(patchKit.dataStart));
		adlibSetVoice(2,pAdlibInstrument(patchKit.dataStart));
	end;
	if (soundIsMidi) then begin
		MPU401_OutB(MIDI_ProgramChange,4,pPatch(patchKit.dataStart)^[patch_FX1]);
		MPU401_OutB(MIDI_ProgramChange,5,pPatch(patchKit.dataStart)^[patch_FX2]);
		MPU401_OutB(MIDI_ProgramChange,6,pPatch(patchKit.dataStart)^[patch_FX3]);
	end;
	sWrite(
		' - Complete'+
		CRLF+'Dos Free:'+strInt(dosAvail,0)+
		CRLF+'Heap Free:'+strInt(memAvail,0)+
		CRLF+'Stack Free:'+strInt(stackAvail,0)+
		CRLF+
		CRLF+continueString
	);
	if paramExists('/debug') then	waitkey;
end;

procedure cleanup;
begin
	dispose(pStinky,term);
	scoreList.term;
	sWrite('Halted: Graphics');
	killSound;
	sWrite(' Sound');
	killTimer;
	sWrite(' Timer - Releasing Memory');
	theme.term;
	dispose(fonts);
	spriteTiles.term;
	mapTiles.term;
	map.term;
	sWrite(' - Complete'+CRLF);
end;

procedure resetSprites;
begin
	pStinky^.reset;
	player.reset;
	bonus.reset;
end;

procedure setupPlayfield;
var
	t,n,x:word;
	b:byte;
begin
	resetSprites;
	decodeTileMap;
	drawPlayField;
	fonts^.outtext(104,12,'HIGH SCORE',c_ltGrey);
	fonts^.outtext(104,30,'YOUR SCORE',c_ltGrey);
	fonts^.setBackground(c_black);
	fonts^.outText(108,36,longToSt8(score),c_cyan);
	fonts^.outText(108,18,longToSt8(highScore),c_cyan);
	fonts^.setBackground(c_transparent);
	x:=78;
	t:=level;
	if (t>9) then n:=t-9 else n:=0;
	while (t>n) do begin
		if (t>21) then begin
			b:=levelData[21].symbol;
		end else b:=levelData[t].symbol;
		tg_tile5(x,94,b);
		dec(x,6);
		dec(t);
	end;
	drawLives;
	drawAudioStatus;
	buffer_writeSpritesToBackBuffer;
	buffer_copySpritesToScreen;
	buffer_eraseSpritesFromBuffer;
end;

procedure behaviorUpdate;
var
	curGhost:pGhost;
begin
	case level of
		1:begin
			behaviorCounter:=behaviorLevel1[behaviorStep].time;
			ghostMode:=behaviorLevel1[behaviorStep].behavior;
		end;
		2..4:begin
			behaviorCounter:=behaviorLevel2_4[behaviorStep].time;
			ghostMode:=behaviorLevel2_4[behaviorStep].behavior;
		end;
		else begin
			behaviorCounter:=behaviorLevel5Plus[behaviorStep].time;
			ghostMode:=behaviorLevel5Plus[behaviorStep].behavior;
		end;
	end;

	curGhost:=pStinky;
	repeat
		with curGhost^ do begin
			if (
				not(inJail) and
				not(mode=mode_flee) and
				not(mode=mode_eaten)
			) then mode:=ghostMode;
			curGhost:=next;
		end;
	until curGhost=nil;
	if (behaviorStep<7) then inc(behaviorStep);
end;

procedure eatGhostScore(x,y,points:integer);
var
	x1,x2:integer;
	st:st8;
begin
	scorePoints(points);
	x1:=x-2;
	x2:=x+12;
	if (points>999) then dec(x1,2);
	str(points,st);
	fonts^.setBackground(c_black);
	fonts^.outText(x1,y,st,c_ltCyan);
	fonts^.setBackground(c_transparent);
	playEatGhost;
	repeat
		buffer_show8x6(x1,y);
		inc(x1,6);
	until x1>x2;
end;

procedure testCollisions;
var
	dx,dy,sx,sy,ex,ey:integer;
	t,n:word;
	current:pGhost;
begin

	with bonus.cSprite^ do begin
		sx:=currentX-2;
		ex:=currentX+2;
		sy:=currentY-2;
		ey:=currentY+2;
	end;

	with player.cSprite^ do begin
		if (
			(bonus.showCounter>0) and
			(currentX>sx) and
			(currentX<ex) and
			(currentY>sy) and
			(currentY<ey)
		) then begin
			bonus.reset;
			eatGhostScore(currentX,currentY,levelData[truncLevel].points);
		end;
	end;

	current:=pStinky;
	repeat
		with current^ do begin
			dx:=abs(cSprite^.currentX-player.cSprite^.currentX);
			if (dx<2) then begin
				dy:=abs(cSprite^.currentY-player.cSprite^.currentY);
				if (dy<2) then begin
					case mode of
						mode_flee:with cSprite^ do begin
							eatGhostScore(currentX,currentY,nextGhost);
							nextGhost:=nextGhost*2;
							mode:=mode_eaten;
						end;
						mode_chase,mode_scatter:begin
							if soundOn then silence;
							buffer_hideSprites;
							n:=0;
							repeat
								if userTimerExpired(timerInterval) then begin
									if soundOn then begin
										if soundIsMidi then begin
											case n of
												0:begin
												       MPU401_OutBB(MIDI_NoteOn,5,69,127);
												       MPU401_pitchBend(5,16384);
												end;
												1..120:MPU401_pitchBend(5,12288-n*102+trunc(4096*sin(n/2.5)));
												125:begin
												       MPU401_OutBB(MIDI_NoteOff,5,69,127);
													     MPU401_OutBB(MIDI_NoteOn ,9,38,127);
												       MPU401_pitchBend(5,0);
												end;
												135:begin
													     MPU401_OutBB(MIDI_NoteOff ,9,38,127);
													     MPU401_OutBB(MIDI_NoteOn ,9,35,127);
													     MPU401_OutBB(MIDI_NoteOn ,9,40,127);
												end;
												170:   MPU401_OutBB(MIDI_NoteOn ,9,49,127);
												180:begin
													     MPU401_OutBB(MIDI_NoteOff,9,38,127);
													     MPU401_OutBB(MIDI_NoteOff,9,35,127);
													     MPU401_OutBB(MIDI_NoteOff,9,40,127);
													     MPU401_OutBB(MIDI_NoteOff,9,49,127);
												end;
											end;
											t:=n div 24;
										end else begin
											case n of
												0..120: outFreq(0,880-n*5+trunc(220*sin(n/2)),$0B,0);
												135,155:outFreq(0,0,0,0);
												125,145:outFreq(0,55,$0F,0);
											end;
											t:=n div 21;
										end;
										gameKeyCheck;
										if not(soundOn) then killVoices;
									end;
									if (t>7) then t:=7;
									with player.cSprite^ do begin
										buffer_copySourceDest8x8(currentX,currentY);
										bufferWriteTile(currentX,currentY,$50+t);
										bufferShow(currentX,currentY);
									end;
									inc(n);
								end;
							until n>=181;
							if soundOn then killVoices;
							wait(45);
							with player.cSprite^ do begin
								buffer_copySourceDest8x8(currentX,currentY);
								bufferShow(currentX,currentY);
							end;
							dec(lives);
							drawLives;
							if (lives>0) then begin
								resetSprites;
								behaviorCounter:=240; { 240 scatter before resume chase }
								buffer_writeSpritesToBackBuffer;
								buffer_copySpritesToScreen;
								buffer_eraseSpritesFromBuffer;
								fonts^.outTextCentered(43,50,readyString,c_yellow);
								wait(120);
								eraseReady;
							end else begin
								fonts^.outtextCentered(44,40,'GAME OVER',c_yellow);
								wait(240);
							end;
						end;
					end;
				end;
			end;
			current:=next;
		end;
	until current=nil;
end;

procedure midiSirenSet(note:byte);
begin
	if (midiSiren>0) then MPU401_OutBB(MIDI_NoteOff,5,midiSiren,127);
	midiSiren:=note;
	MPU401_OutBB(MIDI_NoteOn,5,midiSiren,127);
end;

procedure gameLoop;
var
	fruitLeft,t,n,frameThrottle,altThrottle:word;
	firstRun:boolean;
	cPtr:pointer;
begin

	chompSound:=0;
	siren:=0;
	midiSiren:=0;
	score:=0;
	level:=startingLevel;
	lives:=startingLives;
	firstRun:=true;

	repeat

		joyUpdate;

		dots:=startingDots;
		fruitLeft:=2;

		inc(level);

		if (level>21) then truncLevel:=21 else truncLevel:=level;

		setupPlayfield;

		bonus.reset;

		fonts^.outTextCentered(43,50,readyString,c_yellow);

		if firstRun and soundOn then begin
			firstRun:=false;
			playTheme;
			wait(30);
		end else wait(120);

		eraseReady;

		frameSpeed:=levelData[truncLevel].rate;
		frameThrottle:=frameSpeed-1;


		globalJailCounterEnable:=false;
		globalJailCounter:=0;
		globalDotCounter:=0;
		fleeTotal:=0;

		behaviorStep:=0;
		behaviorUpdate;
		altThrottle:=0;
		pelletBlinkCounter:=0;
		gainLifeCounter:=0;

		nextGhost:=200;

		userClockCounter:=0;

		repeat

			if userTimerExpired(timerInterval) then begin

				frameThrottle:=(frameThrottle+1) mod frameSpeed;
				{
					dividing up the tasks across multiple user timer ticks
					makes for smoother gameplay on 4.77mhz machines

					Using the timer ISR for this could actually be slower and less
					accurate as there's no way to 'provide' for missed ticks and/or
					roll-overs. This way differences are sucked up/distributed about.
				}
				case frameThrottle of
					0:begin
						pelletBlinkCounter:=(pelletBlinkCounter+1) mod 6;
						cPtr:=@pelletData[0];
						case pelletBlinkCounter of
							0:begin
								repeat
									with pPelletData(cptr)^ do begin
										if tileMap[tileY,tileX]=$21 then buffer_nullTile4x3(x,y);
									end;
									inc(pPelletData(cPtr));
								until longint(cPtr)>longint(@pelletData[3]);
							end;
							3:begin
								buffer_sourceRender; { make dest be buffer }
								tileSource:=mapTiles.dataStart;
								repeat
									with pPelletData(cPtr)^ do begin
										if tileMap[tileY,tileX]=$21 then buffer_tile3(x,y,$21);
									end;
									inc(pPelletData(cPtr));
								until longint(cPtr)>longint(@pelletData[3]);
								tileSource:=spriteTiles.dataStart;
								buffer_sourceBackground; { make dest be background }
							end;
						end;
						buffer_writeSpritesToBackBuffer;
					end;

					1:begin
						buffer_copySpritesToScreen;
						joyUpdate;
					end;

					2:begin
						buffer_eraseSpritesFromBuffer;
					end;

					3:begin
						player.update;
						fleeTotal:=0;
						pStinky^.update;
						if (lives>0) then testCollisions;
						bonus.update;
{$IFDEF PROFILE}
	inc(profileCount);
{$ENDIF}
					end;
				end;

				if (globalDotCounter<120) then begin
					inc(globalDotCounter);
				end else begin
					globalDotCounter:=0;
					if pHinky^.exitCounter>0 then dec(pHinky^.exitCounter);
					if pBlaine^.exitCounter>0 then dec(pBlaine^.exitCounter);
				end;

				if (globalFleeCounter>0) then begin
					dec(globalFleeCounter);
					if globalFleeCounter=0 then nextGhost:=200;
				end;

				inc(altThrottle);

				if ((altThrottle and $01)=0) and (behaviorCounter>0) then begin
					dec(behaviorCounter);
					if (behaviorCounter=0) then behaviorUpdate;
				end;

				{sound handler }
				if soundOn then begin
					if soundIsMidi then begin
						if (frameThrottle and $01)=0 then begin
							siren:=(siren+1) mod 24;
							if (fleeTotal=0) then begin
								if (siren<12) then begin
									n:=siren*356;
								end else n:=(24-siren)*341;
								if (dots<144) then begin
									if (dots<44) then t:=89 else t:=85;
								end else t:=81;
								if midiSiren<t then midiSirenSet(t);
							end else begin
								n:=(siren mod 12)*744;
								if not(midiSiren=69) then midiSirenSet(69);
							end;
							MPU401_pitchBend(5,n);
						end;
						if (gainLifeCounter>0) then begin
							dec(gainLifeCounter);
							case gainLifeCounter of
								0:MPU401_OutBB(MIDI_NoteOff,6,81,127);
								89:MPU401_OutBB(MIDI_NoteOn,6,81,127);
							end;
							MPU401_pitchBend(6,(90-gainLifeCounter)*92);
						end;
						if (chompSound>0) then begin
							dec(chompSound);
							case chompSound of
								0:begin
									MPU401_OutBB(MIDI_NoteOff,9,61,127);
									MPU401_OutBB(MIDI_NoteOff,4,45,127);
								end;
								4:begin
									MPU401_OutBB(MIDI_NoteOn, 9,61,127);
								end;
								7:begin
									MPU401_OutBB(MIDI_NoteOn, 4,45,127);
								end;
							end;
						end;
					end else begin { not midi }
						if (frameThrottle and $01)=0 then begin
							siren:=(siren+1) mod 24;
							if (fleeTotal=0) then begin
								if (siren<13) then t:=noteToFreq[siren+69] else t:=noteToFreq[93-siren];
								if (dots<144) then begin
									if (dots<44) then t:=(t*4) div 3 else t:=(t*5) div 4;
								end;
								outFreq(0,t,$0B,0);
							end else outFreq(0,440-(siren mod 12)*20,$0B,0);
						end;
						if (gainLifeCounter>0) then begin
							dec(gainLifeCounter);
							if gainLifeCounter=0 then begin
								outFreq(2,0,0,0);
							end else outFreq(2,660-(gainLifeCounter*11) div 3,$0C,2);
						end;
						if (chompSound>0) then begin
							dec(chompSound);
							if chompSound=0 then begin
								outFreq(1,0,0,0);
							end else outFreq(1,220+chompSound*$30,$0F,1);
						end;
					end;
				end;

			end; { userTimerExpired }

			gameKeyCheck;

{$IFDEF PROFILE}
			inc(profile[frameThrottle]);
{$ENDIF}

		until (lives<=0) or (dots<=0);

		if soundOn then silence;

		if (dots=0) then begin
			wait(90);
			buffer_hideSprites;
			tg_bar(jail_left,jail_top,jail_right,jail_bottom+5,c_black);
			player.cSprite^.currentTile:=$43;

			whitePlayField;
			buffer_sourceBackground;
			for t:=0 to 2 do begin
				wait(30);
				showDestPlayField;
				wait(30);
				buffer_sourceRender;
				showDestPlayField;
				buffer_sourceBackground;
			end;
			wait(60);
		end;
		buffer_copySource2Dest;
		buffer_hideSprites;

	until (level<=0) or (lives<=0);

	scoreList.update;

end;

procedure menuLoop;
var
	ch:char;
	b,color:byte;
	t,n,
	counter,
	borderCounter,
	mt32Counter:word;
begin
	ch:=#255;
	score:=0;
	counter:=0;
	borderCounter:=0;
	mt32Counter:=0;
	color:=c_green;
	soundOn:=true;
	drawMenu;
	userClockCounter:=0;
	repeat
		if userTimerExpired(timerInterval) then begin

			counter:=(counter+1) and $1F;

			case (counter and $0F) of
				$00:begin
					n:=32;
					if (counter=$00) then t:=0 else t:=1;
					repeat
						buffer_copySourceDest8x8(90,n);
						buffer_tile5(90,n,t);
						buffer_show8x6(89,n);
						inc(n,7);
						inc(t,8);
					until t>=32;
				end;
				$01,$09:begin
					for n:=0 to 3 do begin
						borderCounter:=(bordercounter+1) and $03;
						b:=borderColors[borderCounter];
						t:=n+30;
						repeat
							tg_putpixel( t+57,   29,b);
							tg_putpixel(187-t,   60,b);
							tg_putpixel(   87, 89-t,b);
							tg_putpixel(  157,    t,b);
							inc(t,4);
						until t>60;
						inc(t,57);
						repeat
							tg_putpixel(    t,   29,b);
							tg_putpixel(244-t,   60,b);
							inc(t,4);
						until t>157;
					end;
					inc(bordercounter);
				end;
				$04,$0C:begin
					pelletBlinkCounter:=(pelletBlinkCounter+1) mod 6;
					curPellet:=@pelletData;
					case pelletBlinkCounter of
						0:begin
							repeat
								with curPellet^ do tg_bar(x,y,x+2,y+2,0);
								inc(curPellet);
							until longint(curPellet)>longint(@pelletData[3]);
							tg_bar(101,80,103,82,c_black);
						end;
						3:begin
							tileSource:=mapTiles.dataStart;
							repeat
								with curPellet^ do tg_Tile3(x,y,$21);
								inc(curPellet);
							until longint(curPellet)>longint(@pelletData[3]);
							tg_tile3(101,80,$21);
							tileSource:=spriteTiles.dataStart;
						end;
					end;
				end;
				$08:begin
					fonts^.outtext(98,15,'ENTER',color);
					color:=color xor $08;
					fonts^.outtext(103,21,'ESC',color);
				end;
			end;

			if (soundSource=sound_MT32) and (counter=$1E) then begin
				if (mt32Counter and $01)>0 then begin
					mt32_Display('***  PAKU  PAKU  ***');
				end else mt32_Display('     PAKU  PAKU     ');
				inc(mt32Counter);
			end;

		end; {timerinterval}

		if keypressed then begin
			ch:=readkey;
			if ch=#13 then begin
				gameloop;
				drawMenu;
			end else checkGlobalKeys(ch,true);
		end else if (
			joyEnabled and
			(joystickButton(0) or joystickButton(1))
		) then begin
			gameloop;
			drawMenu;
		end;
	until ch=#27;
	silence;
	flushKeyBuffer;
end;

begin
	sWrite(titleString);
	if paramExists('/?') or paramExists('/help') then begin
		writeText('help');
	end else begin
		loadData;
{$IFDEF PROFILE}
		for profileCount:=9 downto 0 do profile[profileCount]:=0;
{$ENDIF}
		tg_init;
		joyInit;
		menuLoop;
		tg_term;
		sWrite(titleString);
		cleanup;
	end;
	writeText('disclaimer');
{$IFDEF PROFILE}
	sWrite(
		CRLF+'PROFILING ENABLED'+
		CRLF+
		CRLF+'Frame Count : '+strint(profileCount,0)+
		CRLF+
		CRLF+'TimeSlice Ticks:'+CRLF;
	);
	for profileCount:=0 to 9 do begin
		sWrite(
			strint(profileCount,0)+' : '+
			strint(profile[profileCount],0)+CRLF
		);
	end;
{$ENDIF}
end.