unit joystick;

interface

const
	stickFailPoint=$FFFF; { even a 3ghz dos machine shouldn't break 64K }

var
	stickPort:word;

function joyStick1Axis:longint;
function joyStick2Axis:longint;
function joystickButton(button:byte):boolean;
procedure joystickDebounce;

implementation

const
	defaultStickPort=$201;

function joyStick1Axis:longint; assembler;
asm
	xor   ax,ax
	xor   bx,bx
	mov   cx,$7FFF
	xor   di,di
	mov   dx,stickPort
	out   dx,al
@loop:
	shr   al,1
	adc   bx,0
	add   di,ax
	in    al,dx
	and   al,$03
	loopnz @loop
	mov   ax,bx
	mov   dx,di
end;

function joyStick2Axis:longint; assembler;
asm
	xor   ax,ax
	xor   bx,bx
	mov   cx,$7FFF
	xor   di,di
	mov   dx,stickPort
	out   dx,al
@loop:
	shr   al,1
	adc   bx,0
	add   di,ax
	in    al,dx
	and   al,$0F
	shr   al,1
	shr   al,1
	loopnz @loop
	mov   ax,bx
	mov   dx,di
end;

function joystickButton(button:byte):boolean; assembler;
asm
	mov  ah,$10
	mov  cl,button
	and  cl,$03
	shl  ah,cl
	mov  dx,stickPort
	in   al,dx
	test al,ah
	{ just grabbing the flags is WAY quicker than a jxx }
	lahf
	mov  al,ah
	and  al,$40
end;

procedure joystickDebounce; assembler;
asm
	mov  dx,stickPort
@loop:
	in   al,dx
	not  al
	and  al,$F0
	jnz  @loop
end;

begin
	{
		"stickPort" exists just so that if we do decide we want
		to use a non-standard port from a program, we can do so
		without editing this unit.
	}
	stickPort:=defaultStickPort;
end.