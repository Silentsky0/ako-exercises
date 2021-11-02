; wczytywanie i wy�wietlanie tekstu wielkimi literami
; (inne znaki si� nie zmieniaj�)
.686
.model flat
extern _ExitProcess@4 : PROC
extern __write : PROC ; (dwa znaki podkre�lenia)
extern __read : PROC ; (dwa znaki podkre�lenia)
public _main
.data
tekst_pocz db 10, 'Prosz� napisa� jaki� tekst '
db 'i nacisnac Enter', 10
koniec_t db ?
magazyn dd 80 dup (?)
nowa_linia db 10
liczba_znakow dd ?

male_litery dd 0c485h, 0c487h, 0c499h, 0c582h, 0c584h, 0c3b3h, 0c59bh, 0c5bah, 0c5bch
duze_litery dd 0c484h, 0c486h, 0c498h, 0c581h, 0c583h, 0c393h, 0c59ah, 0c5b9h, 0c5bbh

.code
_main PROC
; wy�wietlenie tekstu informacyjnego
; liczba znak�w tekstu
 mov ecx,(OFFSET koniec_t) - (OFFSET tekst_pocz)
 push ecx
 push OFFSET tekst_pocz ; adres tekstu
 push 1					; nr urz�dzenia (tu: ekran - nr 1)
 call __write			; wy�wietlenie tekstu pocz�tkowego
 add esp, 12			; usuniecie parametr�w ze stosu
						; czytanie wiersza z klawiatury
 push 80				
 ; maksymalna liczba znak�w
 push OFFSET magazyn
 push 0					; nr urz�dzenia (tu: klawiatura - nr 0)
 call __read			; czytanie znak�w z klawiatury
 add esp, 12			; usuniecie parametr�w ze stosu
						; kody ASCII napisanego tekstu zosta�y wprowadzone
						; do obszaru 'magazyn'
						; funkcja read wpisuje do rejestru EAX liczb�
						; wprowadzonych znak�w
	mov liczba_znakow, eax
						; rejestr ECX pe�ni rol� licznika obieg�w p�tli
	mov ecx, eax
	mov ebx, 0			; indeks pocz�tkowy
ptl: 
	mov dx, magazyn[ebx] ; pobranie kolejnego znaku

	cmp dx, 'a'
	jb dalej			; skok, gdy znak nie wymaga zamiany

	cmp dx, 'z'
	ja dalej			; skok, gdy znak nie wymaga zamiany

	; jezeli znak jest w tabeli polskie male to zamien,
	; jezeli nie to dalej
	xor	cl, cl			; wyzeruj cl
	sprawdz_kolejne_litery:
	inc	cl
	; if znak == male_polskie_litery[cl] then dx = duze_polskie_litery[cl]
	cmp dx, male_polskie_litery[cl]

	cmp cl, 9
	jne	sprawdz_kolejne_litery

	sub dx, 20H			; zamiana na wielkie litery		
	jmp do_pamieci

polskie:
	
do_pamieci:
	mov magazyn[ebx], dx; odes�anie znaku do pami�ci
dalej: 
	inc ebx				; inkrementacja indeksu
	loop ptl			; sterowanie p�tl�
						; wy�wietlenie przekszta�conego tekstu

	push liczba_znakow
	push OFFSET magazyn
	push 1
	call __write		; wy�wietlenie przekszta�conego tekstu

	add esp, 12			; usuniecie parametr�w ze stosu
	push 0
	call _ExitProcess@4 ; zako�czenie programu
_main ENDP
END