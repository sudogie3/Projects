section .text
	global nsqrt
	
nsqrt:
	push rbx
	push r12
	push r13
	push r14
	push r15
	;rdi - adres pierwszych 64-bitów Q pod [rdi] jest ich wartosc
	;rsi - adres pierwszych 64-bitów X pod [rsi] jest ich wartosc
	;rdx - liczba bitów n
	;r15 - indkes jednyki w 4^(n-j)
	;r14 - numer bloku jedynki w 4^(n-j)
	;r13 - posiada maskowanie tam gdzie znajduje sie jedynka 4^(n-j)
	;r12 - posiada 2(n-j)
	;rbx - (j)
	;;rejestry rax,rcx,r11,r10,r9,r8 uznaje za pomocnicze zmienne ktore sie 
	;zmieniaja w zaleznosci od funckji
	
	;/////////////////////////////////
	;Zerowanie Q
	;/////////////////////////////////
	
	mov r8 , rdx ;rdx = n
	shr r8 , 6 ; w r8 jest n/64 
	mov r9 , rdi;
	
	
	.loop_zerowanie:

		mov qword [r9], 0; tu jest zero
		
		lea r9 , [r9+8] ; pojscie do kolejnego adresu
		dec r8 ; 
		jnz .loop_zerowanie
	
	;/////////////////////////////////
	;/////////////////////////////////
		
	
	;zmienna rbx = 1 (j)
	mov rbx , 1
	
	
	.loop_start:
		
		cmp rbx , rdx 
		ja exit ; jesli j - n > 0 to wychodzimy
		
		;obliczenie 2(n-j) w r12
		
		mov r12 , rdx ; r12 = n
		sub r12 , rbx; r12 = n-j
		shl r12 , 1 ; wynik to 2(n-j)
		
		
		;ustawianie r15 , r14 , r13
		mov r15 , r12 ; r15 = 2(n-j)
		and r15 , 63 ; czyli w r15 będzie indeks 
		;znajdowania sie jedynki 2(n-j)&64
		
		
		mov r14 , r12; r14 = 2(n-j)
		shr r14 , 6 ; czyli w r14 jest 2(n-j)/64 czyli inaczej blok 
		;gdzie znajduje sie jedynka
		
		mov r13 , 1 ; r13 = 1
		mov rcx , r15 ; rcx = 2(n-j)
		shl r13 , cl; tu jest maska bitu 2^2(n-j) 
		
		;/////////////////////////////////
		;Sprawdzenie czy można odjąć 4^(n-j) od X
		;/////////////////////////////////
		
		;jesli sie nie da to z automatu Q_n-1 jest wieksze 
		;rsi ma w sobie X;
		; wynik w rax, 0 jesli mozna, 1 wpp 
		;rax = 1 zakladam ze sie nie da 
	
		mov rax , 1
	
		lea r10 , [rsi + r14*8]; idziemy do bloku X który jest równolegy 
		;do 4^(n-j)
	
		;trzeba sprawdzic czy po 2(n-j) znajduje sie jedynka
		; w r13 jest maska bita 4^(n-j)
		cmp [r10] , r13 ; jesli [r10] wieksze rowne od maski 4^(n-j) to rax = 0
		jae .znal
	
		mov r8 , r14 ; takie iterator i, bo r14 posiada w sobie juz 2(n-j)/64
		inc r8
	
		lea r10 , [r10+8]
	
		mov r9 , rdx ; r9 = n
		shl r9 , 1 ; r9 = 2n
		shr r9 , 6 ; r9 = 2n/64
	
		; w tej petli sprawdzam czy wyzsze bity od 4^(n-j) są wieksze od zera
	
		.petla:
			cmp r8 , r9
			ja .kon
		
			cmp qword [r10], 0 ;porowanie z zerem
			ja .znal
		
			lea r10 , [r10+8]
			inc r8
		
			jmp .petla
			
		.znal:
			xor rax , rax ; wynik 0 jesli większy X 
		.kon:
			
		
		
		;/////////////////////////////////
		;/////////////////////////////////
		
		
		cmp rax , 0 ;jesli rax=0 tzn że da sie odjac 4^(n-j),jesli 1 to nie
	
		jnz .kolejny_obrot
		
		.odejmowanie:
			;w rsi jest X
			;odejmowanie będzie robione za pomoca carry flaga
			;wynik odejmowania będzie znajdował się w rsi

			lea r9 , [rsi + r14*8]; czyli jestem na tym bloku gdzie jest
			;jedynka w 4^(n-j)
			sub  [r9] , r13
			jc .pozyczka
			jmp .dalej3


		.pozyczka:
			lea r9 , [r9 + 8]
			sbb qword [r9] , 0
			jc .pozyczka
			
			
		.dalej3:
			
			;wynik odejmowania jest w rsi X - 4^(n-j)
			;teraz r15 ,r13 sa bezuzyteczne wiec mozna cos w nich zapisywac
			;teraz robie porownanie X - 4^(n-j) z 2*(n-j+1)*Q_n
		
			;/////////////////////////////////
			;Sparwdzenie czy można odjać od X - 4^(n-j) Q
			;/////////////////////////////////
			
			
			
			.czy_da_sie_odjac_Qn:
				;w rsi jest X - 4^(n-j)
				; w rdi jest Q dotychczasowe
				; jesli 0 da sie wpp nie da sie
				; ustawiam na 1 ,zakladam, że sie nie da

				mov rax , 1

				mov r9 , rdx; r9 = n
				shl r9 , 1; czyli jest tu 2n
				shr r9 , 6; 
				dec r9; czyli jest tu 2n/64 - 1

				mov r8 , rdx;
				shr r8 , 6;
				dec r8 ; czyli jest tu n/64 - 1


				lea r12 , [rsi + r9*8]; przesuniecie do ostatniego 
				;bloku X - 4^(n-j)
				lea r11 , [rdi + r8*8]; przesuniecie do ostatniego bloku Q


				mov r10 , rbx
				dec r10; (j-1)
				shr r10 , 6 ;(j-1)/64


				mov r15, rdx;
				sub r15, rbx
				inc r15 ; tu jest n-j+1
	
				and r15 , 63 ; (n-j+1)%64
				mov rcx, r15


				.loop:
					cmp r10 , 0 
					je .dalej
	
					mov r8 , [r12] ; mozna uzyc r8 bo jest juz bezuzyteczny
					cmp r8 , 0
					jne .end
	
					lea r12 , [r12 - 8]
					dec r10
	
					jmp .loop

	
	
				.dalej:	
					xor r8 , r8 ; 0x0000
	
					mov r9 , [r11]
	
					shld r8 , r9, cl ; wyrownanie blokow Q do bloku X
	
					cmp r8 , [r12]	
	
					ja .wyj
	
					jb .end

					lea r12 , [r12 - 8]; X - 4^(n-j)

					mov r10 , rdx
					shr r10 , 6 ; n/64
	
					.petla_spr:
						cmp r10 , 1
						je .ost_spr
		
						mov r8 , [r11]
						mov r9 , [r11-8]
		
						shld r8 ,r9 ,cl
		
						cmp r8 , [r12]
	
						ja .wyj
		
						jb .end
		
						dec r10
						lea r12 , [r12 - 8]
						lea r11 , [r11 - 8]
		
						jmp .petla_spr
	
					.ost_spr:
						xor r8 , r8 ; 0x0000
						mov r9 , [r11]
		
						shld r9 , r8 , cl
		
						cmp r9 , [r12]
						jbe .end
						ja .wyj
		
					.end:
						xor rax, rax	
					.wyj:
			
			
			;/////////////////////////////////
			;/////////////////////////////////
		
			cmp rax , 0
	
			je .odjecie

			jne .dodanie 
		
			.odjecie:
				;/////////////////////////////////
				;Odjecie od X-4^(n-j) Q*2^(n-j+1)
				;(wszystko dzieje sie w X)
				;/////////////////////////////////
			
				;w rsi jest X-4^(n-j)
				;w rdi jest Q
				;w rcx jest (n-j+1)%64

				mov rcx , rdx
				sub rcx , rbx
				inc rcx
				and rcx , 63

				mov r8 , rdx;
				shr r8 , 6; tu jest n/64


				mov r10 , rdx
				sub r10 , rbx
				inc r10
				shr r10 , 6 ;(n-j+1)/64 	


				lea r12 , [rsi + r10*8]; przusniecie sie do pierwszego bloku
				;rownoloeglego do Q bloku X-4^(n-j)
				lea r11 , [rdi]; przesuniecie do pierwszego bloku Q

				xor r9 , r9; r9 = 0x0000
				mov r13 , [r11]

				shld r13 , r9 , cl

				sub [r12] , r13


				lea r12 , [r12 + 8]; tu jest X - 4^(n-j)
				lea r11 , [r11 + 8]; tu jest Q
				dec r8

				jc .pozycz

				.loop_odj:
					cmp r8 , 0
					je .ostatni
					mov r9, [r11]
					mov r13 ,[r11 - 8]
	
					shld r9 , r13 , cl ; wyrowanie blokow Q do X
	
	
					sub [r12] , r9
	
	
					lea r12 , [r12 + 8]
					lea r11 , [r11 + 8]
	
					dec r8

					jc .pozycz
					jmp .loop_odj
	
	
	
				.pozycz:
					cmp r8 , 0 
					je .ostatni 

					mov r9 , [r11]
					mov r13 , [r11 - 8]
	
					setc r10b;sztuczka na zatrzymanie carry flaga po shld
					;bo shld zmienia CF
	
					shld r9 , r13 , cl 
					
					xor al , al
					sub al , r10b
	
					sub [r12] , r9
	
					lea r12 , [r12 + 8]
					lea r11 , [r11 + 8]
	
					dec r8
	
					jc .pozycz
					jmp .loop_odj
		

				.ostatni:
					xor r9 , r9; r9 = 0x0000
					mov r13 , [r11-8]
	
					setc r10b
	
					shld r9 , r13 , cl
	
					xor al , al
					sub al , r10b
	
	
					sbb [r12] , r9
					
					
					jc .pozycz2
					
					

				.pozycz2:
					lea r12, [r12 + 8]
	
					sbb qword [r12] , 0
	
					jc .pozycz2
				
				;/////////////////////////////////
				;/////////////////////////////////
			
				mov r14 , rdx
				sub r14 , rbx ; w r14 jest n-j
				
				
				;/////////////////////////////////
				;Dodanie do Qn 2^(n-j)
				;/////////////////////////////////
				
				
				.dodanie_do_Qn:
					mov r10 , r14; tu bedzie (n-j) / 64
					mov r9 , r14 ; tu bedzie (n-j)%64
					;r8 tu bedzie maska

					shr r10 , 6 ; (n-j)/64

					and r9 , 63 ; (n-j)%64

					mov rcx , r9
					mov r8 , 1
					shl r8 , cl; maska bita

					lea r11 , [rdi + r10*8]

					add [r11] , r8
				;/////////////////////////////////
				;/////////////////////////////////
			
			jmp .kolejny_obrot
		
		
		
		;/////////////////////////////////
		;Dodanie do X - 4^(n-j) 4^(n-j)
		;/////////////////////////////////
		
		
		.dodanie:
			
			;w r15 jest indkes gdzie jest jedynka 
			;w r14 jest blok gdzie jest jedynka 
			;w r13 jest maska
			;w rsi jest X-4^(n-j)
			
			lea r9 , [rsi + r14*8]
			add qword [r9] , r13
			jc .przeniesienie
			jnc .kolejny_obrot
			
		.przeniesienie:
			lea r9 , [r9 + 8]
			adc qword [r9] , 0
			jc .przeniesienie
		
		;/////////////////////////////////
		;/////////////////////////////////
			
			
		.kolejny_obrot:
			inc rbx
			jmp .loop_start
		
				
		exit:
			pop r15
			pop r14
			pop r13
			pop r12
			pop rbx
			ret
