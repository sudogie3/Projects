; Autor – Szymon Skierski
; Data – 15.06.25

%define O_RDWR 2
%define PROT_READ_WRITE 3
%define PROT_WRITE 2
%define MAP_SHARED 1
%define SEEK_END 2
%define MS_SYNC 4

%define SYS_OPEN 2
%define SYS_CLOSE 3
%define SYS_LSEEK 8
%define SYS_MMAP 9
%define SYS_MSYNC 26
%define SYS_MUNMAP 11
%define SYS_EXIT 60

section .text
    global _start

_start:
    cmp     dword [rsp], 2      ; Porównanie liczby argumentów 
    							; (ma być: nazwa programu + nazwa pliku)
    jne     .błąd               ; Jeśli podano więcej, niż jeden 
    							; plik lub nic nie podano – błąd

    ; sys_open – otwarcie pliku
    mov     rax, SYS_OPEN
    mov     rdi, [rsp + 16]     ; Wskaźnik do nazwy pliku
    mov     rsi, O_RDWR         ; Otwarcie w trybie do odczytu i zapisu
    syscall

    cmp     rax, 0              ; W rax jest deskryptor pliku
    jl      .błąd               ; Jeśli deskryptor pliku (fd) < 0 – błąd otwarcia

    mov     r12, rax            ; r12 = deskryptor pliku

    ; sys_lseek – pobranie rozmiaru pliku
    mov     rax, SYS_LSEEK
    mov     rdi, r12            ; fd
    xor     rsi, rsi            ; offset = 0
    mov     rdx, SEEK_END       ; Przesunięcie na koniec
    syscall

    cmp     rax, 2              ; rax = rozmiar pliku w bajtach
    jl      .wyjście_zamknięcie ; Jeśli rozmiar < 2, to nie ma co robić

    mov     r13, rax            ; r13 = rozmiar pliku w bajtach

    ; sys_mmap – mapowanie pliku do pamięci
    mov     rax, SYS_MMAP
    xor     rdi, rdi             ; addr = 0
    mov     rsi, r13             ; Rozmiar pliku
    mov     rdx, PROT_READ_WRITE ; Odczyt i zapis
    mov     r10, MAP_SHARED      ; Flaga MAP_SHARED = 
    							 ; zmiany zapisywane do pliku po synchronizacji
    mov     r8,  r12             ; fd
    xor     r9,  r9              ; offset = 0
    syscall

    cmp     rax, 0                     ; rax = adres mapowanej pamięci
    js      .wyjście_zamknięcie        ; Jeśli rax < 0 – błąd mapowania

    ; -------------------------------
    ; Proces odwracania pliku
    ; -------------------------------
    ; Najpierw zamieniamy ze sobą qword-y,
    ; ponieważ instrukcja bswap jest szybsza, niż odwracanie bajtów ręcznie.
    ; Po zamianie qword-ów, 
    ; jeśli jakieś bajty jeszcze zostały, to je też odwracamy.
    ; -------------------------------

    mov     r14, rax                 ; r14 = adres mapowanej pamięci
    mov     rsi, r14                 ; Początek bufora
    lea     rdi, [r14 + r13 - 1]     ; Ostatni bajt

    mov     r15, r13
    shr     r15, 4                   ; r15 = liczba par qword-ów (rozmiar / 16)

.odwracanie_qwordów:
    cmp     r15, 0
    je      .odwracanie_bajtów ; Jeśli tak, to skaczemy do pojedynczych bajtów

	; Zamiana qword-ów
    mov     rax, [rsi]			; Skoro w rsi jest wskaźnik na początek to pod
								; [rsi] będą znajdowały sie wartości 
								; obecnych 8 pocztąkowych bajtów 
    bswap   rax
    mov     rbx, [rdi - 7] 		; Skoro w rdi jest wskaźnik na koniec to pod 
    							; [rdi-7] będą znajdowały się wartości
    							; obecnych 8 końcowych bajtów
    bswap   rbx
    
    mov     [rsi], rbx			
    mov     [rdi - 7], rax

    add     rsi, 8		   ; Przesunięcie wskaźnika początku w prawo o 8 bajtów
    sub     rdi, 8		   ; Przesunięcie wskaźnika końca w lewo o 8 bajtów
    dec     r15
    jmp     .odwracanie_qwordów

.odwracanie_bajtów:
    cmp     rsi, rdi
    jge     .koniec_odwracania        ; Jeśli wskaźniki się minęły – koniec

    ; Zamiana bajtów
    mov     al, [rsi]			   ; al = wartość obecnego początkowego bajta
    mov     bl, [rdi]			   ; bl = wartość obecnego końcowego bajta
    mov     [rsi], bl				
    mov     [rdi], al

    inc     rsi                       ; Przesunięcie wskaźnika początku w prawo
    dec     rdi                       ; Przesunięcie wskaźnika końca w lewo
    jmp     .odwracanie_bajtów

.koniec_odwracania:
    ; sys_msync – zapis zmian na dysk
    mov     rax, SYS_MSYNC
    mov     rdi, r14                 ; Adres pamięci
    mov     rsi, r13                 ; Rozmiar pliku
    mov     rdx, MS_SYNC             ; Wymuszenie zapisu
    syscall

    cmp     rax, 0            ; rax = 0 jeśli sukces, w przeciwnym wypadku błąd
    jb      .błąd_sync

    ; sys_munmap – zwolnienie mapowanej pamięci
    mov     rax, SYS_MUNMAP
    mov     rdi, r14				; Adres pamięci
    mov     rsi, r13				; Rozmiar pliku
    syscall

.wyjście_zamknięcie:
    ; sys_close – zamknięcie deskryptora pliku
    mov     rax, SYS_CLOSE
    mov     rdi, r12				; Deskryptor pliku
    syscall

.wyjście:
    ; sys_exit z kodem 0 (sukces)
    mov     rax, SYS_EXIT
    xor     rdi, rdi                 ; Kod zakończenia = 0
    syscall

.błąd_sync:
    ; sys_munmap – zwolnienie mapowanej pamięci
    mov     rax, SYS_MUNMAP
    mov     rdi, r14				; Adres pamięci
    mov     rsi, r13				; Rozmiar pliku
    syscall

    ; sys_close – zamknięcie pliku
    mov     rax, SYS_CLOSE
    mov     rdi, r12				; Deskryptor pliku
    syscall

.błąd:
    ; sys_exit z kodem 1 (błąd), wyjście z programu
    mov     rax, SYS_EXIT
    mov     rdi, 1                   ; Kod błędu = 1
    syscall
