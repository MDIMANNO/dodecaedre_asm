; external functions from X11 library
extern XOpenDisplay
extern XDisplayName
extern XCloseDisplay
extern XCreateSimpleWindow
extern XMapWindow
extern XRootWindow
extern XSelectInput
extern XFlush
extern XCreateGC
extern XSetForeground
extern XDrawLine
extern XNextEvent

; external functions from stdio library (ld-linux-x86-64.so.2)    
extern exit
extern printf

%define	StructureNotifyMask	131072
%define KeyPressMask		1
%define ButtonPressMask		4
%define MapNotify		19
%define KeyPress		2
%define ButtonPress		4
%define Expose			12
%define ConfigureNotify		22
%define CreateNotify 16
%define QWORD	8
%define DWORD	4
%define WORD	2
%define BYTE	1

global main


section .bss
display_name:	      resq	1
screen:		      resd	1
depth:         	      resd	1
connection:    	      resd	1
width:         	      resd	1
height:        	      resd	1
window:		      resq	1
gc:		      resq	1

section .data
question1:           db      "Valeur X = %f , Y = %f  , Z = %f",10,0
questionCount:       db      "Valeur de CountPF = %d",10,0
questionf:           db      "Valeur = %f",10,0
questionpl1:         db      "PL1 = %d - PL2 = %d",10,0
questionV:           db      "V1 = %d  - V2 = %d",10,0
questionCo:          db      "X1 = %f - Y1 = %f - Z1 = %f",10,0
questionCo2:         db      "X2 = %f - Y2 = %f - Z2 = %f",10,0
questionPrime:       db      "Xprime1 = %f - Yprime1 = %f",10,0
questionPrime2:      db      "Xprime2 = %f - Yprime2 = %f",10,0
questionTest:        db      "Test conversion x1 = %d - y1 = %d",10,0
questionTest2:       db      "Test conversion x2 = %d - y2 = %d",10,0
questionTopBot:      db      "topDiv = %f - botDiv = %f",10,0
questionNormal:      db      "A = %d - B = %d",10,0
questionNormal2:     db      "Normal = %d",10,0
fenetre:             db      0

tabPoint:            db      0
countPoint:          db      0
countFace:           db      0
nFace:               db      0
boucleP:             db      0  
pointLec1:           db      0
pointLec2:           db      0

A:                   db      0
B:                   db      0
C:                   db      0
xA:                  dd      0
xB:                  dd      0
xC:                  dd      0
yA:                  dd      0
yB:                  dd      0
yC:                  dd      0
xBA:                 dd      0
xBC:                 dd      0
yBA:                 dd      0
yBC:                 dd      0
normal:              dd     0



x1:                  dd      0
y1:                  dd      0
z1:                  dd      0

x2:                  dd      0
y2:                  dd      0
z2:                  dd      0

v1:                  db      0
v2:                  db      0

df:                  dd      400.0
zoff:                dd      400.0
xoff:                dd      200.0
yoff:                dd      200.0
topvdiv:             dd      0
botdiv:              dd      0

xP1:                 dd      0
yP1:                 dd      0
xP2:                 dd      0
yP2:                 dd      0

x1C:                 dd     0
y1C:                 dd     0
x2C:                 dd     0
y2C:                 dd     0

topDiv:              dd      0
botDiv:              dd      0


event:		times	24 dq 0

; Un point par ligne sous la forme X,Y,Z
dodec:	        dd	0.0,50.0,80.901699		; point 0
		dd 	0.0,-50.0,80.901699		; point 1
		dd 	80.901699,0.0,50.0		; point 2
		dd 	80.901699,0.0,-50.0		; point 3
		dd 	0.0,50.0,-80.901699		; point 4
		dd 	0.0,-50.0,-80.901699	        ; point 5
		dd 	-80.901699,0.0,-50.0	        ; point 6
		dd 	-80.901699,0.0,50.0		; point 7
		dd 	50.0,80.901699,0.0		; point 8
		dd 	-50.0,80.901699,0.0		; point 9
		dd 	-50.0,-80.901699,0.0	        ; point 10
		dd	50.0,-80.901699,0.0		; point 11

; Une face par ligne, chaque face est composée de 3 points tels que numérotés dans le tableau dodec ci-dessus
; Les points sont donnés dans le bon ordre pour le calcul des normales.
; Exemples :
; pour la première face (0,8,9), on fera le produit vectoriel des vecteurs 80 (vecteur des points 8 et 0) et 89 (vecteur des points 8 et 9)	
; pour la deuxième face (0,2,8), on fera le produit vectoriel des vecteurs 20 (vecteur des points 2 et 0) et 28 (vecteur des points 2 et 8)
; etc...
faces:	        db	0,8,9,0
		db	0,2,8,0
		db	2,3,8,2
		db	3,4,8,3
		db	4,9,8,4
		db	6,9,4,6
		db	7,9,6,7
		db	7,0,9,7
		db	1,10,11,1
		db	1,11,2,1
		db	11,3,2,11
		db	11,5,3,11
		db	11,10,5,11
		db	10,6,5,10
		db	10,7,6,10
		db	10,1,7,10
		db	0,7,1,0
		db	0,1,2,0
		db	3,5,4,3
		db	5,6,4,5


section .text


;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################

main:

    calculNormal:
    mov al,4
    mul byte[nFace]
    mov byte[tabPoint],al               ;tabPoint = 4 * nFace
    
    movzx ecx,byte[tabPoint]        
    mov al,byte[faces+ecx]              ;récupere le numéro du point par apport a Nface
    mov byte[A],al                      ;A = poisition dans le tableau en fonction de count
    
    inc byte[tabPoint]
    
    movzx ecx,byte[tabPoint]        
    mov al,byte[faces+ecx]              ;récupere le numéro du point par apport a Nface
    mov byte[B],al                      ;A = poisition dans le tableau en fonction de count
    
    inc byte[tabPoint]
    
    movzx ecx,byte[tabPoint]        
    mov al,byte[faces+ecx]              ;récupere le numéro du point par apport a Nface
    mov byte[C],al                      ;A = poisition dans le tableau en fonction de count
    
    ;Coordonée A
    mov al,3
    mul byte[A] 
    mov byte[v1],al                  ;On multiplie PointLec1 directement pour juste incrémenté apres
    
    movzx ecx,byte[v1]
    movss xmm0,dword[dodec+ecx*DWORD]  ;cherche la position de X2 en fonction de V1 dans dodec
    movss dword[xA],xmm0

    inc byte[v1]
    
    movzx ecx,byte[v1]
    movss xmm0,dword[dodec+ecx*DWORD]  ;cherche la position de y2 en fonction de V1 dans dodec
    movss dword[yA],xmm0
    
    ;Coordonée B
    mov al,3
    mul byte[B] 
    mov byte[v1],al                  ;On multiplie PointLec1 directement pour juste incrémenté apres
    
    movzx ecx,byte[v1]
    movss xmm0,dword[dodec+ecx*DWORD]  ;cherche la position de X2 en fonction de V1 dans dodec
    movss dword[xB],xmm0

    inc byte[v1]
    
    movzx ecx,byte[v1]
    movss xmm0,dword[dodec+ecx*DWORD]  ;cherche la position de y2 en fonction de V1 dans dodec
    movss dword[yB],xmm0
    
    ;Coordonée C
    mov al,3
    mul byte[C] 
    mov byte[v1],al                  ;On multiplie PointLec1 directement pour juste incrémenté apres
    
    movzx ecx,byte[v1]
    movss xmm0,dword[dodec+ecx*DWORD]  ;cherche la position de X2 en fonction de V1 dans dodec
    movss dword[xC],xmm0

    inc byte[v1]
    
    movzx ecx,byte[v1]
    movss xmm0,dword[dodec+ecx*DWORD]  ;cherche la position de y2 en fonction de V1 dans dodec
    movss dword[yC],xmm0
    
    MathsNormal:
    movss xmm0,dword[xA]
    movss xmm1,dword[xB]
    subss xmm0,xmm1
    movss dword[xBA],xmm0           ;calcul de xBA
    
    movss xmm0,dword[xC]
    movss xmm1,dword[xB]
    subss xmm0,xmm1
    movss dword[xBC],xmm0           ;calcul de xBC
    
    movss xmm0,dword[yA]
    movss xmm1,dword[yB]
    subss xmm0,xmm1
    movss dword[yBA],xmm0           ;calcul de yBA
    
    movss xmm0,dword[yC]
    movss xmm1,dword[yB]
    subss xmm0,xmm1
    movss dword[yBC],xmm0           ;calcul de yBC
    
    movss xmm0,dword[xBA]
    mulss xmm0,[yBC]                ;xBA* yBC -> xmm0
    
    movss xmm1,dword[yBA]
    mulss xmm1,[xBC]                ; yBA * xBC -> xmm1
    
    subss xmm0,xmm1                 ; normal = xmm0 - xmm1
    
    cvtss2si eax,xmm0       ;Conversion en entier
    mov dword[normal],eax       ;normal en entier dword
    
    cmp dword[normal],0
    jg boucleFace              ;si supérieur à 0 on retourne en bas sans dessin
                                ;sinon on continue et dessine


    bouclePoint:
    cmp byte[countPoint],3
    jae boucleFace
    
    mov al,4
    mul byte[nFace]
    add al,byte[countPoint]
    mov byte[tabPoint],al               ;tabPoint = 4 * nFace
    
    movzx ecx,byte[tabPoint]        
    mov al,byte[faces+ecx]              ;récupere le numéro du point par apport a Nface
    mov byte[pointLec1],al              ;PL1 = poisition dans le tableau en fonction de count
    
    inc byte[tabPoint]
    inc byte[countPoint]
    
    movzx ecx,byte[tabPoint]        
    mov al,byte[faces+ecx]              
    mov byte[pointLec2],al              ;PL2 = PL1 + 1 dans le tableau

    ;Coordonée P1
    mov al,3
    mul byte[pointLec1] 
    mov byte[v1],al                  ;On multiplie PointLec1 directement pour juste incrémenté apres
    
    movzx ecx,byte[v1]
    movss xmm0,dword[dodec+ecx*DWORD]  ;cherche la position de X2 en fonction de V1 dans dodec
    movss dword[x1],xmm0

    inc byte[v1]
    
    movzx ecx,byte[v1]
    movss xmm0,dword[dodec+ecx*DWORD]  ;cherche la position de y2 en fonction de V1 dans dodec
    movss dword[y1],xmm0
    
    inc byte[v1]
    
    movzx ecx,byte[v1]
    movss xmm0,dword[dodec+ecx*DWORD]  ;cherche la position de z2 en fonction de V1 dans dodec
    movss dword[z1],xmm0
    
    ;Coordonée P2
    mov al,3
    mul byte[pointLec2] 
    mov byte[v2],al 
    
    movzx ecx,byte[v2]
    movss xmm0,dword[dodec+ecx*DWORD]  ;cherche la position de X2 en fonction de V1 dans dodec
    movss dword[x2],xmm0
    
    inc byte[v2]
    
    movzx ecx,byte[v2]
    movss xmm0,dword[dodec+ecx*DWORD]  ;cherche la position de y2 en fonction de V1 dans dodec
    movss dword[y2],xmm0
    
    inc byte[v2]
    
    movzx ecx,byte[v2]
    movss xmm0,dword[dodec+ecx*DWORD]  ;cherche la position de z2 en fonction de V1 dans dodec
    movss dword[z2],xmm0
    
    maths3D:
    ;x1'
        ;topdiv = (df * x1)
        movss xmm0,dword[df]
        mulss xmm0,[x1]
        movss dword[topDiv],xmm0
        
        ;botdiv = z1 + zoff 
        movss xmm1,dword[z1]
        addss xmm1,[zoff] 
        movss dword[botDiv],xmm1
      
        ;x1' = (topdov / botdiv)  + xoff
        divss xmm0,xmm1
        addss xmm0,[xoff]
        movss dword[xP1],xmm0
   
        cvtss2si eax,xmm0       ;Conversion en entier
        mov dword[x1C],eax
 
    ;y1'
        ;topdiv = (df * y1)
        movss xmm0,dword[df]
        mulss xmm0,[y1]
        movss dword[topDiv],xmm0
        
        ;botdiv = z1 + zoff 
        movss xmm1,dword[z1]
        addss xmm1,[zoff]     
        movss dword[botDiv],xmm1
      
        ;y1' = (topdov / botdiv) + yoff
        divss xmm0,xmm1
        addss xmm0,[yoff]
        movss dword[yP1],xmm0
   
        cvtss2si eax,xmm0       ;Conversion en entier
        mov dword[y1C],eax    
        
              
     ;x2'
        ;topdiv = (df * x2)
        movss xmm0,dword[df]
        mulss xmm0,[x2]
        movss dword[topDiv],xmm0
        
        ;botdiv = z2 + zoff 
        movss xmm1,dword[z2]
        addss xmm1,[zoff]
        
        movss dword[botDiv],xmm1
      
        ;x2' = (topdov / botdiv) + xoff
        divss xmm0,xmm1
        addss xmm0,[xoff]
        movss dword[xP2],xmm0
   
        cvtss2si eax,xmm0       ;Conversion en entier
        mov dword[x2C],eax
        
          
      ;y2'
        ;topdiv = (df * y2)
        movss xmm0,dword[df]
        mulss xmm0,[y2]
        movss dword[topDiv],xmm0
        
        ;botdiv = z2 + zoff 
        movss xmm1,dword[z2]
        addss xmm1,[zoff]
        movss dword[botDiv],xmm1
      
        ;y2' = (topdov / botdiv) + yoff
        divss xmm0,xmm1
        addss xmm0,[yoff]
        movss dword[yP2],xmm0
   
        cvtss2si eax,xmm0       ;Conversion en entier
        mov dword[y2C],eax    
        

    affichage:
    
    ;lecture Point1 et Point2 du tableau Faces
        push rbp
        mov rdi,questionNormal
        movzx rsi,byte[pointLec1]
        movzx rdx,byte[pointLec2]

        mov rax,0
        call printf
        pop rbp
        
        push rbp
        mov rdi,questionNormal2
        xor rsi,rsi
        mov esi,dword[normal]
        mov rax,0
        call printf
        pop rbp
        

cmp byte[fenetre],1
je prog_principal

;####################################
;## Code de création de la fenêtre ##
;####################################
mov byte[fenetre],1
xor     rdi,rdi
call    XOpenDisplay	; Création de display
mov     qword[display_name],rax	; rax=nom du display

mov     rax,qword[display_name]
mov     eax,dword[rax+0xe0]
mov     dword[screen],eax

mov rdi,qword[display_name]
mov esi,dword[screen]
call XRootWindow
mov rbx,rax

mov rdi,qword[display_name]
mov rsi,rbx
mov rdx,10
mov rcx,10
mov r8,400	; largeur
mov r9,400	; hauteur
push 0xFFFFFF	; background  0xRRGGBB
push 0x00FF00
push 1
call XCreateSimpleWindow
mov qword[window],rax

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,131077 ;131072
call XSelectInput

mov rdi,qword[display_name]
mov rsi,qword[window]
call XMapWindow

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,0
mov rcx,0
call XCreateGC
mov qword[gc],rax

mov rdi,qword[display_name]
mov rsi,qword[gc]
mov rdx,0x000000	; Couleur du crayon
call XSetForeground

; boucle de gestion des évènements
boucle: 
	mov rdi,qword[display_name]
	mov rsi,event
	call XNextEvent

	cmp dword[event],ConfigureNotify
	je prog_principal
	cmp dword[event],KeyPress
	je closeDisplay
jmp boucle

;###########################################
;## Fin du code de création de la fenêtre ##
;###########################################



;############################################
;##	Ici commence le programme principal ##
;############################################ 
prog_principal:

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,qword[gc]
mov ecx,dword[x1C]	; coordonnée source en x
mov r8d,dword[y1C]	; coordonnée source en y
mov r9d,dword[x2C]	; coordonnée destination en x
push qword[y2C]		; coordonnée destination en y
call XDrawLine

jmp bouclePoint

 

       boucleFace:
        ;numéro de la face pour le tableau Faces
        ;La boucle prend fin quand nFace > 20 apres le dessin
        inc byte[nFace]
        cmp byte[nFace],19
        ja flush
        
        
        mov byte[countPoint],0          ;on remet notre count à 0
        jmp calculNormal


;##############################################
;##	Ici se termine VOTRE programme principal ##
;##############################################																																																																																																																																	     		     		jb boucle
jmp flush



flush:
mov rdi,qword[display_name]
call XFlush
jmp boucle
mov rax,34
syscall

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor	    rdi,rdi
    call    exit

	