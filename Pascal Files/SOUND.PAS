unit sound;

interface

uses
	jfunc,
	timer; { timer included for PIT constants }

const
	sound_none=0;
	sound_pcSpeaker=1;
	sound_tandy=2;
	sound_cms=3;
	sound_adlib=4;
	{
		MIDI not implemented YET, included for later use
	}
	sound_generalMidi=5;
	sound_mt32=6;
	sound_customMidi=7;

	noteToFreq:array[21..119] of word=(
		0028, 0029, 0031, 0032, 0034, 0037, 0039, 0042, 0044, 0046, 0049, 0052,
		0055, 0058, 0062,	0065, 0070,	0073,	0078, 0082, 0087, 0093, 0098, 0104,
		0110, 0117, 0123,	0131,	0139, 0147,	0156, 0165, 0175, 0185, 0196, 0208,
		0220, 0233, 0247,	0262, 0277, 0294,	0311, 0330, 0349, 0370, 0392, 0415,
		0440, 0466, 0494,	0523, 0554, 0587,	0622, 0659, 0698, 0740, 0784, 0831,
		0880, 0932, 0987,	1047, 1109, 1175,	1245, 1329, 1397, 1480, 1568, 1661,
		1760, 1865, 1976,	2093, 2217, 2349, 2489, 2637, 2794, 2960, 3136, 3322,
		3520, 3729, 3951,	4186, 4435, 4699,	4978, 5274, 5588, 5920, 6272, 6645,
		7040, 7459, 7902
	);

	MIDI_NoteOff          = $80;
	MIDI_NoteOn           = $90;
	MIDI_PolyKeyPressure  = $A0;
	MIDI_ControlChange    = $B0;
	MIDI_ProgramChange    = $C0;
	MIDI_ChannelPressure  = $D0;
	MIDI_PitchWheelChange = $E0;
	MIDI_SystemExclusive  = $F0;
	MIDI_SongPointer      = $F2;
	MIDI_SongSelect       = $F3;
	MIDI_TuneRequest      = $F6;
	MIDI_EndExclusive     = $F7;
	MIDI_TimingClock      = $F8;
	MIDI_Start            = $FA;
	MIDI_Continue         = $FB;
	MIDI_Stop             = $FC;
	MIDI_ActiveSensing    = $FE;
	MIDI_Reset            = $FF;

	SysEx_Send            = $12;
	SysEx_Recieve         = $11;

	Patch_lead    = $00;
	Patch_harmony = $01;
	Patch_bass    = $02;
	Patch_drone   = $03;
	Patch_piano   = $04;
	Patch_square  = $08;
	Patch_FX1     = $09;
	Patch_FX2     = $0A;
	Patch_FX3     = $0B;

type
	pPatch=^tPatch;
	tPatch=array[0..15] of byte;

	tAdlibDualReg=array[0..1] of byte;
	pAdlibInstrument=^tAdlibInstrument;
	tAdlibInstrument=record
		characteristics:tAdlibDualReg; { $2x }
		levelScaling:   tAdlibDualReg; { $4x }
		attackDecay:	  tAdlibDualReg; { $6x }
		sustainRelease: tAdlibDualReg; { $8x }
		waveform:       tAdlibDualReg; { $Ex }
		feedback:       byte;          { $Cx }
		extra:          array[0..5] of byte;
	end;
	tAdlibInstrumentArray=array[0..16] of byte;

	tNoteStreamHeader=record
		channel,patch:byte;
		dataSize:word;
	end;

	pMusicData=^tMusicData;
	tMusicData=object
		info:tNoteStreamHeader;
		next:pMusicData;
		currentNote,wait:byte;
		playing:boolean;
		volume:word;
		curData,
		data:pByte;
		constructor init(var f:file);
		procedure rewind;
		function tick:boolean;
		destructor term;
	end;

	tMusic=object
		tracks:byte;
		tempoCalc:word;
		tickDelay:word;
		first:pMusicData;
		constructor init(fn:st8);
		procedure rewind;
		function step:boolean;
		destructor term;
	end;

	sysEx_ID=array[0..2] of byte; { three bytes to ID device }
	MT32_DisplayString=string[20];

var
	soundIsMidi:boolean;
	soundSource:integer;
	soundPort:word;
	patchKit:tDynamicData;

procedure startSound;
procedure killSound;
procedure outFreq(iChannel,iFreq,iLevel,iPriority:word);
procedure killVoices;
procedure adlibSetVoice(voice:byte; instrument:pAdlibInstrument);
procedure MPU401_WriteCommand(command:byte);
procedure MPU401_WriteData(data:byte);
function MPU401_ReadData:byte;
function MPU401_CommandOk:boolean;
function MPU401_detect:boolean;
procedure MPU401_OutB(command,channel,data:byte);
procedure MPU401_OutBB(command,channel,data1,data2:byte);
procedure MPU401_allNotesOff(channel:byte);
procedure MPU401_volume(channel,volume:byte);
procedure MPU401_pitchBend(channel:byte; bend:word);
procedure MPU401_sysExStart;
procedure MPU401_sysExEnd;
procedure MPU401_MidiReset;
procedure MPU401_sendRPN(index:word; value:word);
procedure MPU401_sendNRPN(index:word; value:word);
procedure Roland_SendSysExData(address:longint; data:pointer; dataSize:word);
procedure MT32_Display(st:MT32_DisplayString);

implementation

type

	tVoice=record
		freq,
		priority:word;
	end;

	tScanSet=array[0..11] of word;

	tCardString=record
		parm:string[10];
		description:string[20];
		scanSet:byte;
		defaultPort:word;
	end;

	tCmsOctaveStore=array[0..11] of byte;

const
	SPK_Control=$61;
	tandyFreq=3579545;
	tandyDivider=tandyFreq/32;
	tandyIntDivider=round(tandyDivider);

	adlibOffsets:tAdlibInstrumentArray=(
		$20,$23,$40,$43,$60,$63,$80,$83,$E0,$E3,$C0,0,0,0,0,0,0
	);

	noScanSet   = 0;
	cmsScanSet  = 1;
	midiScanSet = 2;

	scanArray:array[1..2] of tScanSet=(
		($200,$210,$220,$240,$250,$000,$000,$000,$000,$000,$000,$000), {CMS}
		($220,$230,$240,$250,$300,$320,$330,$332,$334,$336,$340,$350)  {MPU401}
	);

	cardData:array[0..7] of tCardString=(
		(
			parm:'/auto';
			description:'None/AutoDetect';
			scanSet:noScanSet;
			defaultPort:0
		),(
			parm:'/speaker';
			description:'PC Speaker';
			scanSet:noScanSet;
			defaultPort:$61
		),(
			parm:'/tandysound';
			description:'Tandy/PCJr';
			scanSet:noScanSet;
			defaultPort:$C0
		),(
			parm:'/cms';
			description:'C/MS or Game Blaster';
			scanSet:cmsScanSet;
			defaultPort:$220
		),(
			parm:'/adlib';
			description:'Adlib';
			scanSet:noScanSet;
			defaultPort:$388
		),(
			parm:'/gm';
			description:'General MIDI';
			scanSet:midiScanSet;
			defaultPort:$330
		),(
			parm:'/mt32';
			description:'Roland MT32/SC100';
			scanSet:midiScanSet;
			defaultPort:$330
		),(
			parm:'/midi';
			description:'Custom MIDI';
			scanSet:midiScanSet;
			defaultPort:$330
		)
	);

	CMSFreqMap:packed array[0..127] of byte=(
		000,003,007,011,015,019,023,027,
		031,034,038,041,045,048,051,055,
		058,061,064,066,069,072,075,077,
		080,083,086,088,091,094,096,099,
		102,104,107,109,112,114,116,119,
		121,123,125,128,130,132,134,136,
		138,141,143,145,147,149,151,153,
		155,157,159,161,162,164,166,168,
		170,172,174,175,177,179,181,182,
		184,186,188,189,191,193,194,196,
		197,199,200,202,203,205,206,208,
		209,210,212,213,214,216,217,218,
		219,221,222,223,225,226,227,228,
		229,231,232,233,234,235,236,237,
		239,240,241,242,243,244,245,246,
		247,249,250,251,252,253,254,255
	);

	UARTMode  = $3F;
	writeFlag = $40;
	readFlag  = $80;
	commandOk = $FE;
	MPUreset  = $FF;

var
	soundActive:boolean;
	voiceTable:array[0..2] of tVoice;
	cmsOctaveStore:^tCmsOctaveStore;
	oldExitProc:pointer;
	MPU401_Port:word;
	Synth_ID:sysEx_ID;

function MPU401_Wait:boolean; assembler;
{
	parameters:
		ah = writeFlag or readFlag
}
asm
	mov  dx,MPU401_Port
	inc  dx
	mov  cx,$00FF
@loop:
	in   al,dx
	and  al,ah
	loopnz @loop
	mov  al,cl
end;

procedure MPU401_WriteCommand(command:byte); assembler;
asm
	mov  ah,writeFlag
	call MPU401_Wait
	mov  al,command
	out  dx,al
end;

procedure MPU401_WriteData(data:byte); assembler;
asm
	mov  ah,writeFlag
	call MPU401_Wait
	dec  dx
	mov  al,data
	out  dx,al
end;

function MPU401_ReadData:byte; assembler;
asm
	mov  ah,readFlag
	call MPU401_Wait
	dec  dx
	in   al,dx
end;

function MPU401_CommandOk:boolean; assembler;
asm
	mov    cx,$0020 { 32 read attempts should be enough }
	mov    dx,MPU401_port
	mov    ah,commandOk
	mov    bh,readFlag
	@readLoop:
	mov    bl,cl { faster than push/pop for inner loop }
	mov    cl,$FF
	inc    dx
	@flagLoop:
	in     al,dx
	cmp    al,bh
	loopne @flagLoop
	mov    cl,bl
	dec    dx
	in     al,dx
	cmp    al,ah
	loopne @readLoop
	mov    al,cl
end;

function MPU401_detect:boolean; { also sets UART mode if detected }
begin
	MPU401_WriteCommand(MPUreset);
	if MPU401_CommandOk then begin
		MPU401_WriteCommand(UARTMode);
		MPU401_detect:=MPU401_CommandOk;
	end else MPU401_detect:=false;
end;

procedure MPU401_OutB(command,channel,data:byte);
begin
	MPU401_WriteData((command and $F0) or (channel and $0F));
	MPU401_WriteData(data);
end;

procedure MPU401_OutBB(command,channel,data1,data2:byte);
begin
	MPU401_WriteData((command and $F0) or (channel and $0F));
	MPU401_WriteData(data1);
	MPU401_WriteData(data2);
end;

procedure MPU401_allNotesOff(channel:byte);
begin
	MPU401_OutBB(MIDI_ControlChange,channel,$7B,0);
end;

procedure MPU401_volume(channel,volume:byte);
begin
	MPU401_OutBB(MIDI_ControlChange,channel,$07,volume);
end;

procedure MPU401_pitchBend(channel:byte; bend:word);
begin
	MPU401_WriteData(MIDI_PitchWheelChange or (channel and $0F));
	MPU401_writeData(bend and $7F);
	MPU401_WriteData(bend shr 7);
end;

procedure MPU401_sysExStart;
begin
	MPU401_WriteData(MIDI_SystemExclusive);
	MPU401_WriteData(ord(Synth_ID[0]));
	MPU401_WriteData(ord(Synth_ID[1]));
	MPU401_WriteData(ord(Synth_ID[2]));
end;

procedure MPU401_sysExEnd;
begin
	MPU401_WriteData(MIDI_EndExclusive);
end;

procedure MPU401_MidiReset;
var
	t:word;
begin
	for t:=0 to 15 do begin
		MPU401_allNotesOff(t);
		MPU401_volume(t,100);
		MPU401_pitchBend(t,8192);
	end;
end;

procedure MPU401_sendRPN(index:word; value:word);
begin
	MPU401_WriteData($64);
	MPU401_WriteData(index and $FF);
	MPU401_WriteData($65);
	MPU401_WriteData(index shr 8);
	MPU401_WriteData($06);
	MPU401_WriteData(value and $FF);
	MPU401_WriteData($26);
	MPU401_WriteData(value shr 8);
	MPU401_WriteData($64);
	MPU401_WriteData($7F);
	MPU401_WriteData($65);
	MPU401_WriteData($7F);
end;

procedure MPU401_sendNRPN(index:word; value:word);
begin
	MPU401_WriteData($62);
	MPU401_WriteData(index and $FF);
	MPU401_WriteData($63);
	MPU401_WriteData(index shr 8);
	MPU401_WriteData($06);
	MPU401_WriteData(value and $FF);
	MPU401_WriteData($26);
	MPU401_WriteData(value shr 8);
	MPU401_WriteData($62);
	MPU401_WriteData($7F);
	MPU401_WriteData($63);
	MPU401_WriteData($7F);
end;

procedure Roland_SendSysExData(address:longint; data:pointer; dataSize:word);
var
	current,dataEnd:pByte;
	temp,cSum:byte;
begin
	MPU401_WriteData(SysEx_Send);
	temp:=address shr 16;
	cSum:=temp;
	MPU401_WriteData(temp);
	temp:=(address shr 8) and $FF;
	cSum:=cSum+temp;
	MPU401_WriteData(temp);
	temp:=address and $FF;
	cSum:=cSum+temp;
	MPU401_WriteData(temp);
	current:=data;
	dataEnd:=pByte(longint(current)+dataSize);
	while not(current=dataEnd) do begin
		cSum:=cSum+current^;
		MPU401_WriteData(current^);
		inc(current);
	end;
	cSum:=(not(cSum) and $7F)+1;
	MPU401_WriteData(cSum);
end;

procedure MT32_Display(st:MT32_DisplayString);
var
	t:word;
begin
	mpu401_sysExStart;
	Roland_SendSysExData($200000,pbyte(@st[1]),20);
	mpu401_sysExEnd;
end;

procedure GM_SetPitchBendRange(range:byte);
begin
	MPU401_SendRPN($0000,range);
end;

constructor tmusicData.init(var f:file);
begin
	next:=nil;
	blockread(f,info,sizeof(tNoteStreamHeader));
	{ rotate channels left 1, MT32 doesn't respond on channel 0! }
	if (info.channel<10) then info.channel:=(info.channel+1) mod 10;
	getmem(data,info.dataSize);
	blockread(f,data^,info.dataSize);
end;

procedure tMusicData.rewind;
begin
	wait:=1;
	volume:=$0F;
	playing:=true;
	curData:=data;
	currentNote:=0;
	if soundIsMidi then begin
		MPU401_allNotesOff(info.channel);
		MPU401_OutB(
			MIDI_ProgramChange,
			info.channel,
			pPatch(patchKit.dataStart)^[info.patch]
		);
	end else outFreq(info.channel,0,0,0);
	if not(next=nil) then next^.rewind;
end;

function tMusicData.tick:boolean;
var
	b,d:byte;
begin
	if (playing) then begin
		dec(wait);
		if (wait=0) then begin
			if (currentNote>0) then begin
				if soundIsMidi then begin
					MPU401_OutBB(
						MIDI_NoteOff,
						info.channel,
						currentNote,
						0
					);
				end else outFreq(info.channel,0,0,0);
				end;
			repeat
				b:=curData^;
				inc(curData);
				d:=b and $3F;
				case (b shr 6) of
					0:begin
						wait:=d;
						playing:=(d>0);
					end;
					1:begin
						wait:=d;
						currentNote:=curData^;
						if soundIsMidi then begin
							MPU401_OutBB(
								MIDI_NoteOn,
								info.channel,
								currentNote,
								trunc(volume*8.4)
							);
						end else outFreq(
							info.channel,
							noteToFreq[currentNote],
							volume,
							$FF-info.patch
						);
						inc(curData);
					end;
					2:volume:=d and $0F;
	{						3:setPatch(channel,b and $3F); }
				end;
			until (b=0) or (wait>0);
		end;
	end;
	if next=nil then tick:=playing else tick:=next^.tick or playing;
end;

destructor tMusicData.term;
begin
	freemem(data,info.dataSize);
	if not(next=nil) then dispose(next,term);
end;

constructor tMusic.init(fn:st8);
var
	f:file;
	current:pMusicData;
	t:byte;
begin
	assign(f,fn+'.DAT');
	reset(f,1);
	blockread(f,tracks,1);
	blockread(f,t,1);
	tempoCalc:=900 div t; { approximately 16th note resolution... kinda }
	new(first,init(f));
	current:=first;
	for t:=2 to tracks do begin
		new(current^.next,init(f));
		current:=current^.next;
	end;
	close(f);
	rewind;
end;

procedure tMusic.rewind;
begin
	tickDelay:=0;
	first^.rewind;
end;

function tMusic.step:boolean;
var
	current:pMusicData;
	result:boolean;
begin
	if (tickDelay>0) then begin
		dec(tickDelay);
		step:=true;
	end else begin
		tickDelay:=tempoCalc;
		step:=first^.tick;
	end;
end;

destructor tMusic.term;
begin
	dispose(first,term);
end;

procedure cmsWrite; assembler;
{
	parameters
	dx = port base+offset
	ah = register
	al = data
}
asm
	inc  dx
	xchg al,ah
	out  dx,al
	dec  dx
	xchg al,ah
	out  dx,al
end;

procedure cmsNull; assembler;
{
	parameters
	dx = port offset to null
}
asm
	add   dx,soundPort
	mov   cx,$20
	xor   ax,ax
@loop:           { null all 20 registers }
	call  cmsWrite
	inc   ah
	loop  @loop

	mov   ax,$1C02 { reset chip }
	call  cmsWrite

	mov   ax,$1C01 { enable this chip }
	call  cmsWrite
end;

procedure cmsReset; assembler;
asm
	mov  dx,0
	call cmsNull
	mov  dx,2
	call cmsNull
	les  di,cmsOctaveStore;
	xor  ax,ax
	stosw
	stosw
	stosw
end;

procedure cmsSound(voice,freq,octave,amplitudeLeft,amplitudeRight:byte); assembler;
asm
{ first get port base }
	mov   bl,voice
	xor   ah,ah
	mov   al,bl
	shr   al,1
	les   di,cmsOctaveStore
	add   di,ax
	mov   dx,soundport
	test  bl,$08
	jz    @setOctave
	add   dx,2
@setOctave:
	mov   ah,bl
	and   bl,$07 { this point on needs 7 bit split }
	cmp   ah,6
	jne   @orOctave
	sub   ah,6
@orOctave:
	shr   ah,1
	or    ah,$10
{
	ah now = register
		0,1,6,7=$10
		2,3,8,9=$11
		4,5,10,11=$12

	CMS octave regs are write only, so we have to track
	the values in adjoining voices manually
}
	mov   al,es:[di]
	mov   bh,octave
	test  bl,$01
	jnz   @shiftOctave
	and   al,$F0
	and   bh,$0F
	jmp   @outOctave
@shiftOctave:
	and   al,$0F
	mov   cl,4
	shl   bh,cl
@outOctave:
	or    al,bh
	mov   es:[di],al
	call  cmsWrite
@setAmp:
	mov   al,amplitudeLeft
	mov   ah,amplitudeRight
	and   al,$0F
	mov   cl,4
	shl   ah,cl
	or    al,ah
	mov   ah,bl
	call  cmsWrite
@setFreq:
	mov   al,freq
	or    ah,$08
	call  cmsWrite
@voiceEnable:
	mov   al,$14
	inc   dx
	out   dx,al
	dec   dx
	in    al,dx
	mov   ah,$01
	mov   cl,bl
	shl   ah,cl
	or    al,ah
	out   dx,al
	mov   ax,$1C01 { enable this chip again, cms on 386 bug?}
	call  cmsWrite
end;

procedure tandySound(voice:byte; tone:word; level:byte); assembler;
asm
	mov  dx,$C0

{	port[$C0]:=$80 or (voice*$20) or (tone and $0F); }
	mov  cl,voice
	mov  al,$10
	shl  al,cl
	and  al,$60
	or   al,$80
	mov  ch,al { save channel for level set }
	mov  bx,tone
	mov  ah,bl
	and  ah,$0F
	or   al,ah
	out  dx,al

{	port[$C0]:=tone shr 4; }
	mov  cl,4
	shr  bx,cl
	mov  al,bl
	out  dx,al

{	port[$C0]:=$90 or (voice*$20) or (level and $0F); }
	mov  al,level
	and  al,$0F
	or   al,ch
	or   al,$10
	out  dx,al
end;

function tandyDetect:boolean; assembler;
asm
	mov  bx,$FFFF
	mov  es,bx
	mov  di,$000E
	mov  al,$FD
	cmp  es:[di],al
	jne  @notJr
	mov  ax,bx
	ret
@notJr:
	mov  al,$FF
	cmp  es:[di],al
	jne  @notTandy
	mov  ax,$FC00
	mov  es,ax
	xor  di,di
	mov  al,$21
	cmp  es:[di],al
	jne  @notTandy
	mov  ax,bx
	ret
@notTandy:
	xor  ax,ax
end;

procedure adlibDelay(count:word); assembler;
asm
	mov cx,count
	mov dx,soundPort
@loop:
	in  al,dx
	loop @loop
end;

procedure outAdlibASM; assembler;
{
	AL = register
	AH = data
}
asm
	mov  dx,soundPort
	out  dx,al
	mov  cx,6 { wait for FM Chip }
@loop1:
	in   al,dx
	loop @loop1
	inc  dx
	mov  al,ah
	out  dx,al
	dec  dx
	mov  cx,35 { again, we have to wait for the FM chip }
@loop2:
	in   al,dx
	loop @loop2
end;

procedure outAdlib(register,data:byte); assembler;
asm
	mov  al,register
	mov  ah,data
	call outAdlibASM
end;

function adlibDetect:boolean;
begin
	soundPort:=cardData[sound_adlib].defaultPort;
	asm
		mov  @result,0
		mov  ax,$6004
		call outAdlibASM
		mov  ax,$8004
		call outAdlibASM
		in   al,dx
		and  al,$E0
		jnz  @done
		mov  ax,$FF02
		call outAdlibASM
		mov  ax,$2104
		call outAdlibASM
		mov  cx,128
	@loop:
		in  al,dx
		loop @loop
		and  al,$E0
		cmp  al,$C0
		jne  @cleanup
		mov  @result,1
	@cleanup:
		mov  ax,$6004
		call outAdlibASM
		mov  ax,$8004
		call outAdlibASM
	@done:
	end;
end;

procedure adlibSetVoice(voice:byte; instrument:pAdlibInstrument);
var
	t,v:word;
begin
	v:=((voice div 3) shr 3)+voice mod 3;
	for t:=0 to 10 do begin
		outAdlib(adlibOffsets[t]+v,tAdlibInstrumentArray(instrument^)[t]);
	end;
end;


procedure adlibAllOff; assembler;
asm
	mov  cx,$0015
	mov  ax,$FF40
@loop1:
	push ax
	push cx
	call outAdlibASM
	pop  cx
	pop  ax
	inc  al
	loop @loop1
	mov  cx,$0008
	mov  ax,$00B0
@loop2:
	push ax
	push cx
	call outAdlibASM
	pop  cx
	pop  ax
	inc  al
	loop @loop2
end;

procedure adlibKeyOff(voice:byte); assembler;
asm
	mov  al,$B0
	add  al,voice
	xor  ah,ah
	call outAdlibASM
end;

procedure adlibKeyOn(voice:byte; freq:word; octave:byte); assembler;
asm
	mov  bx,freq
	mov  ah,bl

	mov  bl,voice
	mov  al,$A0
	add  al,bl

	call outAdlibASM

	mov  al,$B0
	add  al,bl

	mov  ah,bh
	and  ah,$03

	mov  bl,octave
	and  bl,$07
	shl  bl,1
	shl  bl,1
	or   ah,bl
	or   ah,$20
	call outAdlibASM
end;

procedure adlibSetVolume(voice,level:byte); assembler;
asm
	mov  al,$40
	add  al,voice
	mov  ah,level
	and  ah,$3F
	call outAdlibASM;
end;

procedure adlibReset; assembler;
asm
	mov  cx,243
@loop:
	mov  al,cl
	inc  al
	xor  ah,ah
	mov  bx,cx
	call outAdlibASM;
	mov  cx,bx
	loop @loop
	mov  ax,$2001
	call outAdlibASM;
	mov  ax,$C0B0
	call outAdlibASM;
end;

procedure speakerSound(interval:word); assembler;
asm
	mov  ax,interval
	cmp  ax,0
	jne  @setLevel
	{ speaker off }
	in   al,SPK_Control
	and  al,$FC;
	out  SPK_Control,al
	jmp  @done
@setLevel:
  { speaker on }
	in   al,SPK_Control
	or   al,$03
	out  SPK_Control,al
	mov  al,PIT_Select2 or PIT_LSBMSB or PIT_Mode3
	out  PIT_Control,al
	mov  ax,interval
	out  PIT_Data2,al
	mov  al,ah
	out  PIT_Data2,al
@done:
end;

procedure outFreq(iChannel,iFreq,iLevel,iPriority:word);
var
	outOctave,
	outFreq,
	testPriority,
	t:word;
begin
	case soundSource of
		sound_pcSpeaker:begin
			with voiceTable[iChannel] do begin
				freq:=iFreq;
				priority:=iPriority+1;
			end;
			testPriority:=0;
			outFreq:=0;
			for t:=0 to 2 do with voiceTable[t] do begin
				if priority>testPriority then begin
					testPriority:=priority;
					outFreq:=freq;
				end;
			end;
			if (outFreq=0) then begin
				speakerSound(0);
			end else speakerSound(clock8253 div outFreq);
		end;
		sound_tandy:begin
			if (iFreq>0) then begin
				tandySound(
					iChannel,
					tandyIntDivider div iFreq,
					15-iLevel
				);
			end else tandySound(iChannel,0,15);
		end;
		sound_cms:begin
			if (iFreq<32) or (iFreq>7823) or (iLevel=0) then begin
				cmsSound(iChannel,0,0,0,0);
			end else begin
				outOctave:=4;
				outFreq:=iFreq;
				while (outFreq<489) do begin
					outFreq:=outFreq*2;
					dec(outOctave);
				end;
				while (outFreq>977) do begin
					outFreq:=outFreq div 2;
					inc(outOctave);
				end;
				cmsSound(
					iChannel,
					CMSFreqMap[((outFreq-489)*128) div 489],
					outOctave,
					iLevel,iLevel
				);
			end;
		end;
		sound_adlib:begin
			if (
				(iFreq<32) or
				(iFreq>7823) or
				(iLevel=0)
			) then begin
				adlibKeyOff(iChannel);
			end else begin
				outFreq:=iFreq*2 div 3;
				outOctave:=5;
				while (outFreq>2047) do begin
					outFreq:=outFreq+2;
					inc(outOctave);
				end;
				adlibKeyOn(iChannel,outFreq,outOctave);
			end;
		end;
	end;
end;

procedure killVoices;
var
	t:word;
begin
	if soundIsMidi then begin
		for t:=0 to 15 do MPU401_allNotesOff(t);
	end else for t:=0 to 2 do outFreq(t,0,0,0);
end;

procedure startSound; assembler;
asm
	mov  ax,soundSource
	cmp  ax,sound_pcSpeaker
	je   @pcSpeaker
	cmp  ax,sound_tandy
	je   @tandy
	cmp  ax,sound_adlib
	je   @adlib
	cmp  ax,sound_cms
	jne  @done
@cms:
	call cmsReset
	jmp  @done
@pcSpeaker:
	mov  cx,3
	mov  ax,$0001
	lea  bx,voiceTable
	mov  [bx],ax
	mov  [bx+4],ax
	mov  [bx+8],ax
	xor  ax,ax
	mov  [bx+2],ax
	mov  [bx+6],ax
	mov  [bx+10],ax
	jmp @done
@tandy:
	{ 1k/jr }
	mov  ax,$8003
	int  $1A
	{ manually set for older machines just in case }
	mov  al,$6C
	out  $61,al
	mov  ax,$8003
	int  $1A
	jmp @done
@adlib:
	call adlibReset;
@done:
	call killVoices
	mov  soundActive,1
end;

procedure killSound; assembler;
asm
	call KillVoices;
	mov  ax,soundSource
	cmp  ax,sound_pcSpeaker
	je   @pcSpeaker
	cmp  ax,sound_tandy
	je   @tandy
	cmp  ax,sound_adlib
	je   @adlib
	cmp  ax,sound_cms
	jne  @done
@cms:
	call cmsReset
	jmp  @done
@pcSpeaker:
	in   al,SPK_Control
	and  al,$FC;
	out  SPK_Control,al
	jmp  @done
@tandy:
	mov  dx,$C0
	mov  al,$9F
	out  dx,al
	mov  al,$BF
	out  dx,al
	mov  al,$DF
	out  dx,al
	jmp  @done
@adlib:
	call adlibAllOff;
	call adlibReset;
@done:
	mov soundActive,0
end;

procedure safeExit; far;
begin
	if soundActive then killSound;
	if soundSource=sound_CMS then dispose(cmsOctaveStore);
	if soundIsMidi then patchKit.term;
	exitProc:=oldExitProc;
end;

function assignSound(device,port:word):boolean;
begin
	soundSource:=device;
	soundPort:=port;
	case device of
		sound_generalMidi,
		sound_mt32,
		sound_customMidi:assignSound:=MPU401_detect;
		else assignSound:=true;
	end;
end;

function forceSound:boolean;
var
	t,n,b:word;
	st:string[4];
begin
	for t:=7 downto 0 do begin
		with cardData[t] do begin
			if paramExists(parm) then begin
				forceSound:=assignSound(t,defaultPort);
				exit;
			end else if (scanSet>0) then begin
				for n:=0 to 11 do begin
					b:=scanArray[scanset][n];
					if (b=0) then break;
					st:=word2hex(b);
					st[1]:=':';
					if paramExists(parm+st) then begin
						forceSound:=assignSound(t,b);
						exit;
					end;
				end;
			end;
		end;
	end;
	soundSource:=0;
	forceSound:=false;
end;

begin
	MPU401_Port:=$330;
	Synth_ID[0]:=$41;
	Synth_ID[1]:=$10;
	Synth_ID[2]:=$16;

	soundActive:=false;
	if not(forceSound) then begin
		sWrite('Autodetecting Sound'+CRLF);
		if adlibDetect then begin
			soundSource:=sound_adlib;
			soundPort:=cardData[sound_adlib].defaultPort;
		end else if tandyDetect then begin
			soundSource:=sound_tandy;
			soundPort:=cardData[sound_tandy].defaultPort;
		end else begin
			soundSource:=sound_pcSpeaker;
			soundPort:=cardData[sound_pcSpeaker].defaultPort;
		end;
	end;
	case soundSource of
		sound_adlib:begin
			soundIsMidi:=false;
			patchKit.init('PAT_ADLB.DAT');
		end;
		sound_generalMidi:begin
			soundIsMidi:=true;
			GM_SetPitchBendRange(24);
			patchKit.init('PAT_GM.DAT');
		end;
		sound_mt32:begin
			soundIsMidi:=true;
			patchKit.init('PAT_MT32.DAT');
		end;
		sound_customMidi:begin
			soundIsMidi:=true;
			GM_SetPitchBendRange(24);
			patchKit.init('PAT_CUST.DAT');
		end;
		else soundIsMidi:=false;
	end;
	sWrite(
		'Sound Card: '+cardData[soundSource].description+CRLF+
		'Base Port: 0x'+word2hex(soundPort)+CRLF
	);
	case soundSource of
		sound_cms:new(cmsOctaveStore);
	end;
	oldExitProc:=exitproc;
	exitproc:=@safeExit;
end.