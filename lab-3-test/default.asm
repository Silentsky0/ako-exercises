.686
.model flat

extern _ExitProcess@4 : proc
extern __write : proc
extern __read : proc

public _main

.data

znaki_eax db 12 dup (?)

obszar db 12 dup (?) ; 12 znak�w
dziesiec dd 10 ; mno�nik

.code

wyswietl_EAX proc
	
	pusha

	mov	esi, 10 ; indeks w tablicy znaki_eax , 10 bo maksymalna wartosc eax ma tyle cyfr
	mov ebx, 10 ; dzielnik rowny 10

konwersja:
	mov edx, 0 ; wyzeruj starsz� cz�� dzielnej
	div ebx ; dzielenie przez 10, iloraz w eax, reszta w edx

	add dl, 30h ; zamiana na ascii

	mov znaki_eax[esi], dl ; zapisz znak w ascii

	dec esi ; zmniejsz indeks
	cmp eax, 0 ; porownaj dzieln� z zerem
	jne konwersja ; powtarzaj dopoki dzielna nie jest zerem

wypelnij:
	or esi, esi
	jz wyswietl ; wyswietl kiedy esi == 0

	mov byte ptr znaki_eax[esi], 20h ; zapisz spacje
	dec esi
	jmp wypelnij

wyswietl:
	mov byte ptr znaki_eax[0], 0ah ; pierwszy i ostatni element znakow beda '\n'
	mov byte ptr znaki_eax[11], 0ah

	push dword ptr 12 ; liczba znakow tekstu
	push dword ptr offset znaki_eax
	push dword ptr 1
	call __write
	add esp, 12

	popa
	ret
wyswietl_EAX endp

ciag proc
	pusha

	mov esi, 1 ; ustaw esi na 1
	pierwsze_50:

	mov eax, esi
	mul eax ; policz eax^2

	sub eax, esi ; policz eax^2 - eax
	add eax, 2; policz eax^2 - eax + 2

	mov ecx, 2
	div	ecx ; policz (eax^2 - eax + 2)/2

	call wyswietl_EAX ; wyswietl wynik obliczen

	inc esi
	cmp esi, 51
	jne pierwsze_50 ; powtarzaj dopoki esi nie jest 50

	popa
	ret
ciag endp

wczytaj_do_eax proc
	push ebx
	push ecx
	push edx
	push esi
	push edi


	; max ilo�� znak�w wczytywanej liczby
	push dword PTR 12
	push dword PTR OFFSET obszar ; adres obszaru pami�ci
	push dword PTR 0; numer urz�dzenia (0 dla klawiatury)
	call __read ; odczytywanie znak�w z klawiatury
				;(dwa znaki podkre�lenia przed read)
	add esp, 12 ; usuni�cie parametr�w ze stosu

; bie��ca warto�� przekszta�canej liczby przechowywana jest
; w rejestrze EAX; przyjmujemy 0 jako warto�� pocz�tkow�
	mov eax, 0
	mov ebx, OFFSET obszar ; adres obszaru ze znakami
pobieraj_znaki:
	xor ecx, ecx
	mov cl, [ebx]	; pobranie kolejnej cyfry w kodzie
					; ASCII
	inc ebx		; zwi�kszenie indeksu
	cmp cl,10	; sprawdzenie czy naci�ni�to Enter
	je byl_enter	; skok, gdy naci�ni�to Enter

	
	sub cl, 30H ; zamiana kodu ASCII na warto�� cyfry
	movzx ecx, cl ; przechowanie warto�ci cyfry wrejestrze ECX

		; mno�enie wcze�niej obliczonej warto�ci razy 10
	mul dword PTR dziesiec
	add eax, ecx ; dodanie ostatnio odczytanej cyfry
	jmp pobieraj_znaki ; skok na pocz�tek p�tli
byl_enter:
; warto�� binarna wprowadzonej liczby znajduje si� teraz w 


	pop ebx
	pop ecx
	pop edx
	pop esi
	pop edi
	ret
wczytaj_do_eax endp

_main proc
	
	call wczytaj_do_eax

	or eax, eax

	call wyswietl_EAX	

	push	0
	call _ExitProcess@4
_main endp

END