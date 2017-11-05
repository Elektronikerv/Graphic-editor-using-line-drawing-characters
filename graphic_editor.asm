.486
.model flat, stdcall
option casemap :none   
 
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\msvcrt.inc
include \masm32\macros\macros.asm

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\msvcrt.lib

wsprintfA PROTO C	:VARARG
.data 
hFile DWORD ?
key DWORD ?
cord COORD <0>
handleOut DWORD ?
handleIn DWORD ?
printBool BYTE 0
deleteBool BYTE 0
symbol byte 0
zeroSymbol BYTE 0
windowArray BYTE 1920 dup (0) 
index DWORD (0)
clearSymbol BYTE 0

useless BYTE 0
filename BYTE 50 dup  (?)
length1 BYTE (0)

.const
errorMes BYTE "File not found!", 0
fileSaved BYTE "File saved!", 0
filenameMes BYTE "Enter filename: ", 0
saveErrorMes BYTE "Invalid input!", 0
menuMes BYTE "Press:", 10, 13,
			 "F1 to run first task", 10, 13, 
			 "F2 to run second task", 10, 13,
			 "F4 to exit",0
tutorialMes BYTE "	F1:draw/move   F2:save    F3:new    F4:exit    F5:open", 0
V_SYMBOL BYTE 179     ; vertical symbol
H_SYMBOL BYTE 196     ; horizontal

.code
Main:

invoke GetStdHandle, -11
mov handleOut, eax
invoke GetStdHandle, -10
mov handleIn, eax


call clearScreen
call setInfoPos
invoke WriteConsole, handleOut, offset tutorialMes, sizeof tutorialMes, 0, 0
xor ecx, ecx
mov index, ecx
mov cord.y, 0
;------------------process key events----------------------
checkKeyEvents:
mov ebx, cord
invoke SetConsoleCursorPosition, handleOut,  ebx
call crt__getch
call crt__getch
mov key, eax

cmp key, 59      ; F1 - chamge mode
jne isPrint
not printBool
mov symbol, 0
pop ecx
isPrint:

cmp key, 60       ;F2 - save into file
je save
cmp key, 61	      ;F3 - create new
je new
cmp key, 62       ;F4-exit
je exitProgram
cmp key, 63       ;F5 - open from file
je load

cmp key, 75       ;move left
je left

cmp key, 77       ;mov right
je right

cmp key, 72       ;move up
je up

cmp key, 80       ;move down
je down
jmp checkKeyEvents

left:
dec cord.x
dec index
mov dl, H_SYMBOL
mov symbol, dl
jmp doesPrint

right:
inc cord.x
inc index
mov dl, H_SYMBOL
mov symbol, dl
jmp doesPrint

up:
dec cord.y
sub index, 80
mov dl, V_SYMBOL
mov symbol, dl
jmp doesPrint

down:
inc cord.y
add index, 80
mov dl, V_SYMBOL
mov symbol, dl
doesPrint:
;-------------check borders------------
cmp cord.y, 23         
jg up

cmp cord.y, 0            
jl down

cmp cord.x, 79           
jg left
cmp cord.x, 0           
jl right
;------------- draw line----------------------

cmp printBool, 0
je checkKeyEvents

invoke WriteConsole, handleOut, offset symbol, 1, 0, 0

mov  dl, symbol
mov ecx, index
mov windowArray[ecx], dl
jmp checkKeyEvents

;---------create new file--------------------------
new:
call createNew
jmp checkKeyEvents
;------------------open and read from file-----------------
load:
call getFilename
invoke CreateFile, offset filename, GENERIC_READ, NULL, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL 
mov hFile, eax
cmp eax, INVALID_HANDLE_VALUE
jne read
call clearString
invoke WriteConsoleA, handleOut, offset errorMes, sizeof errorMes, 0, 0
invoke Sleep, 2000d
call clearString
invoke WriteConsole, handleOut, offset tutorialMes, sizeof tutorialMes, 0, 0
call setStartPos
 
jmp checkKeyEvents
read:
call setInfoPos
invoke WriteConsole, handleOut, offset tutorialMes, sizeof tutorialMes, 0, 0
invoke ReadFile, hFile, offset windowArray, 1920, offset useless, NULL
invoke CloseHandle, hFile 
call printArray
jmp checkKeyEvents
;----------------------------save into file-----------------------
save:
call clearString

call getFilename
xor eax, eax
invoke CreateFile, offset filename, GENERIC_WRITE, NULL, NULL,CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
mov hFile, eax

cmp eax, INVALID_HANDLE_VALUE
jne saveInto

call clearString
invoke WriteConsoleA, handleOut, offset saveErrorMes, sizeof saveErrorMes, 0, 0
invoke Sleep, 1000d
call clearString
invoke WriteConsole, handleOut, offset tutorialMes, sizeof tutorialMes, 0, 0
call setStartPos
jmp checkKeyEvents

saveInto:
invoke WriteFile, hFile, offset windowArray, 1920, offset useless, NULL	
invoke CloseHandle, hFile 
call clearString
invoke WriteConsoleA, handleOut, offset fileSaved, sizeof fileSaved, 0, 0
invoke Sleep, 1000d
call clearString
invoke WriteConsole, handleOut, offset tutorialMes, sizeof tutorialMes, 0, 0
call setStartPos 
jmp checkKeyEvents
;------------exit-----------------------------------

invoke Sleep, 200000d
exitProgram:
invoke ExitProcess,0
;-----------------------procedures-------------------
printArray proc 
call setStartPos 
xor ecx, ecx
lea esi, windowArray
lab:
push ecx
invoke WriteConsole, handleOut, esi, 1, 0, 0
pop ecx
inc esi
inc ecx
cmp ecx, 1920
jl lab
ret
printArray endp
;------------------встановлення куросора в (0,0)-
setStartPos proc
mov cord.x, 0
mov cord.y, 0
mov ebx, cord
invoke SetConsoleCursorPosition, handleOut,  ebx
mov index, 0
ret
setStartPos  endp
;----------------------------------------------
getFilename proc
call clearString
mov cord.x, 0
mov cord.y, 24
mov ebx, cord
invoke SetConsoleCursorPosition, handleOut,  ebx	
invoke WriteConsoleA, handleOut, offset filenameMes, sizeof filenameMes, 0, 0
invoke ReadConsoleA, handleIn, offset filename, sizeof filename, offset length1, 0
xor ecx, ecx
mov cl, length1
sub cl, 2
mov filename[ecx], 0
ret
getFilename endp
;----------------------------------------------
createNew proc
call setStartPos
xor ecx, ecx
create:
push ecx
lea esi, zeroSymbol
mov windowArray[ecx], 0
invoke WriteConsole, handleOut, esi, 1, 0, 0
pop ecx
inc ecx
cmp ecx, 1920
jl create
ret
createNew endp
;---------------------------------------------------
clearScreen proc
call setStartPos
xor ecx, ecx
clear:
push ecx
lea esi, zeroSymbol
invoke WriteConsole, handleOut, esi, 1, 0, 0
pop ecx
inc ecx
cmp ecx, 2000
jl clear
call setStartPos
ret
clearScreen endp
;--------------------------------------------------------------
clearString proc
call setInfoPos
xor ecx, ecx
clearStr:
lea esi, zeroSymbol
push ecx
invoke WriteConsole, handleOut, esi, 1, 0, 0
pop ecx
inc ecx
cmp ecx, 80
jl clearStr
call setInfoPos
ret
clearString endp
;-------------------------------------------------------------
setInfoPos proc
mov cord.x, 0
mov cord.y, 24
mov ebx, cord
invoke SetConsoleCursorPosition, handleOut,  ebx
ret
setInfoPos endp


end Main
