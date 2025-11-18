//Autor zadania Szymon Skierski

#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>

// Koncept na rozwiąznie zadania
// Mój program robi operacje na tablicy dwuwymiarowej o wymiarach ilość rzędów na ilość kolumn
// Każdy ruch jaki będzie wykonywany będzie sprowadzany do problemu obrócenia jedynie ściany frontowej, jeśli np będzie prośba o przesunięcia ściany tylnie to na początku
// przestawiam ściany tak, że zmieniam perspektywę i tylnia ściana jest tą "frontową". Dzięki temu każdy wariant obrócenia niezostanie pominięcty.


#ifndef N
#define N 3
#endif

#define kolumny N*5+2 // bo gdy jest kostka 1x1x1 to musi wyswitelac jeszce "|"
#define rzedy N*3

void tworzenie_kostki(int kostka[rzedy][kolumny]) {
    int i = 0;
    int j = 0;
    while (i< rzedy) {
        j = 0;
        while (j< kolumny) {
            if (i >= 0 && i<N && j>N && j <= 2*N) kostka[i][j] = 0;
            else if (i >= N && i<2*N && j>=0 && j < N) kostka[i][j] = 1;
            else if (i >= N && i<2*N && j>N && j <= 2*N) kostka[i][j] = 2;
            else if (i >= N && i<2*N && j>2*N+1 && j <= 3*N+1) kostka[i][j] = 3;
            else if (i >= N && i<2*N && j>3*N+2 && j <= 4*N+2) kostka[i][j] = 4;
            else if (i >= 2*N && i<3*N && j>N && j <= 2*N) kostka[i][j] = 5;
            else if (i >=N && i< 2*N && (j ==N||j==2*N+1|| j== 3*N+2)) kostka[i][j] = -2;
            else kostka[i][j] = -1;
            j ++;
        }
        i++;
    }
}
void wypisywanie_stanu_kostki(int kostka[rzedy][kolumny]) {
    printf("\n");
    int i = 0;
    int j = 0;
    while (i<rzedy) {
        j = 0;
        while(j<kolumny) {
            while (kostka[i][j] == -1 && j < N+1) {printf(" "),j++;}
            if (kostka[i][j] == -1 && j>2*N) break;
            else if (kostka[i][j] == -2) printf("|");
            else printf("%d",kostka[i][j]);
            j ++;

        }
        if (i != rzedy-1)printf("\n");
        i ++;
    }
    printf("\n");
}
void zamiana(int kostka[rzedy][kolumny],int i, int j, int k,int l) { // ta funkcja przyda mi sie np do zamiany scian kostki
    int pom;
    pom= kostka[i][j];
    kostka[i][j] = kostka[k][l];
    kostka[k][l] = pom;
}
void obrot_sciany_w_lewo(int kostka[rzedy][kolumny],int x,int y) {
    int po_i = 0;//
    int po_j = 0;// tzn współrzędna punktu(i,j) po obróceniu
    int i = 0;
    int j = 0;
    int pomoc[N][N] = {0};
    while (i<N) {
        j = 0;
        while (j<N) {
            po_j = i;
            po_i = N-j-1;
            pomoc[po_i][po_j] = kostka[i+x][j+y];
            j++;
        }
        i++;
    }
    i =0;
    while (i< N) {
        j = 0;
        while (j<N) {
            kostka[i+x][j+y] = pomoc[i][j];
            j++;
        }
        i++;
    }
}

void obrot_sciany_dwa_razy_w_prawo(int kostka[rzedy][kolumny],int x, int y) {
    int i = 0;
    while (i<2) {
        obrot_sciany_w_lewo(kostka,x,y);
        i++;
    }
}

void obrot_sciany_w_prawo(int kostka[rzedy][kolumny],int x, int y) {
    int i = 0;
    while (i<3) {
        obrot_sciany_w_lewo(kostka,x,y);
        i++;
    }
}

void obrot_w_lewo(int kostka[rzedy][kolumny],int liczba_wartsw_do_przesuniecia) {// tzn przesunięcie sąsiadujących krawędzi w lewo
    //(funkcja obrot sciany w lewo oznaczał jedynie obrot sciany bez krawędzi na sąsiadujących ścianach kostki)
    if (liczba_wartsw_do_przesuniecia != 0) liczba_wartsw_do_przesuniecia --;
    int i = 0;
    while (liczba_wartsw_do_przesuniecia >= 0 && liczba_wartsw_do_przesuniecia<N) {
        i= 0;
        while (i<N) {
            zamiana(kostka,N+i,2*N+2+liczba_wartsw_do_przesuniecia,2*N+liczba_wartsw_do_przesuniecia,2*N-i);
            i++;
        }
        i = 0;
        while (i<N) {
            zamiana(kostka,2*N+liczba_wartsw_do_przesuniecia,2*N-i,2*N-1-i,N-1-liczba_wartsw_do_przesuniecia);
            i++;
        }
        i = 0;
        while (i<N) {
            zamiana(kostka,2*N-1-i,N-1-liczba_wartsw_do_przesuniecia,N-1-liczba_wartsw_do_przesuniecia,N+1+i);
            i++;
        }
        liczba_wartsw_do_przesuniecia --;
    }
}
void zamiana_scian(int kostka[rzedy][kolumny],int x,int y,int a,int b) {// x,y oznacza skrajnie lewą górną wspołrzędną pierwszej ściany i a,b oznacza to samo tylko innej ściany
    int i = 0;
    int j = 0;
    while (i<N) {
        j = 0;
        while (j<N) {
            zamiana(kostka,x+i,y+j,a+i,b+j);
            j++;
        }
        i++;
    }
}


void odbicie(int kostka[rzedy][kolumny]) { // funckja ta odbija lustrzanie ściane pionowo, jedynie gdy do obrócenia jest N wartsw, zawsze odbija ściany która po zamianie ścian jest "tylnia"
    for (int i = 0; i < N; i++) {
        for (int j = 0; j <N / 2; j++) {
            int temp = kostka[i][j];
            kostka[i][j] = kostka[i][N - j - 1];
            kostka[i][N - j - 1] = temp;
        }
    }
}

void ile_obortow(int kostka[rzedy][kolumny],int liczba_warstw_do_przesuniecia,char kat_obrotu) { // funkcja obraca kostkę w zależności od warstw
    int p =0;
    if (kat_obrotu == ' ') {
        while (p<3) {
            obrot_w_lewo(kostka,liczba_warstw_do_przesuniecia);
            obrot_sciany_w_lewo(kostka,N,N+1);
            p ++;
        }
        if (liczba_warstw_do_przesuniecia == N) {
            odbicie(kostka);
            obrot_sciany_w_lewo(kostka,N,3*N+3);
            odbicie(kostka);
        }
    }

    else if (kat_obrotu == '\"') {
        while (p<2) {
            obrot_w_lewo(kostka,liczba_warstw_do_przesuniecia);
            obrot_sciany_w_lewo(kostka,N,N+1);
            p++;
        }
        if (liczba_warstw_do_przesuniecia == N) {
            odbicie(kostka);
            obrot_sciany_dwa_razy_w_prawo(kostka,N,3*N+3);
            odbicie(kostka);
        }
    }
    else if(kat_obrotu == '\'') {
        while(p<1) {
            obrot_w_lewo(kostka,liczba_warstw_do_przesuniecia);
            obrot_sciany_w_lewo(kostka,N,N+1);
            p++;
        }
        if (liczba_warstw_do_przesuniecia == N) {
            odbicie(kostka);
            obrot_sciany_w_prawo(kostka,N,3*N+3);
            odbicie(kostka);
        }
    }
}
void zmiana_w_kostce(int kostka[rzedy][kolumny], int liczba_warstw_do_przesuniecia, char sciana, char kat_obrotu) {
    // funkcja ta jest najważniejsza w moim programie, w zależności od wskazanej ściany przeranżuje  kostke tak aby wybrana ściana byłą tą 'frontową' i wykona zadane polecenie
    if (sciana == 'f') {
        ile_obortow(kostka,liczba_warstw_do_przesuniecia,kat_obrotu);
    }
    if (sciana == 'l') {
        obrot_sciany_w_lewo(kostka,0,N+1);
        obrot_sciany_w_prawo(kostka,2*N,N+1);
        zamiana_scian(kostka,N,0,N,N+1);
        zamiana_scian(kostka,N,2*N+2,N,3*N+3);
        zamiana_scian(kostka,N,0,N,2*N+2);
        ile_obortow(kostka,liczba_warstw_do_przesuniecia,kat_obrotu);
        zamiana_scian(kostka,N,0,N,2*N+2);
        zamiana_scian(kostka,N,2*N+2,N,3*N+3);
        zamiana_scian(kostka,N,0,N,N+1);
        obrot_sciany_w_prawo(kostka,0,N+1);
        obrot_sciany_w_lewo(kostka,2*N,N+1);
    }
    else if (sciana == 'r') {
        obrot_sciany_w_lewo(kostka,2*N,N+1);
        obrot_sciany_w_prawo(kostka,0,N+1);
        zamiana_scian(kostka,N,2*N+2,N,N+1);
        zamiana_scian(kostka,N,2*N+2,N,0);
        zamiana_scian(kostka,N,2*N+2,N,3*N+3);
        ile_obortow(kostka,liczba_warstw_do_przesuniecia,kat_obrotu);
        zamiana_scian(kostka,N,2*N+2,N,3*N+3);
        zamiana_scian(kostka,N,2*N+2,N,0);
        zamiana_scian(kostka,N,2*N+2,N,N+1);
        obrot_sciany_w_lewo(kostka,0,N+1);
        obrot_sciany_w_prawo(kostka,2*N,N+1);
    }
    else if(sciana =='b') {
        obrot_sciany_dwa_razy_w_prawo(kostka,0,N+1);
        obrot_sciany_dwa_razy_w_prawo(kostka,2*N,N+1);
        zamiana_scian(kostka,N,N+1,N,3*N+3);
        zamiana_scian(kostka,N,0,N,2*N+2);
        ile_obortow(kostka,liczba_warstw_do_przesuniecia,kat_obrotu);
        obrot_sciany_dwa_razy_w_prawo(kostka,0,N+1);
        obrot_sciany_dwa_razy_w_prawo(kostka,2*N,N+1);
        zamiana_scian(kostka,N,N+1,N,3*N+3);
        zamiana_scian(kostka,N,0,N,2*N+2);
    }
    else if(sciana == 'u') {
        zamiana_scian(kostka,0,N+1,N,N+1);
        zamiana_scian(kostka,0,N+1,2*N,N+1);
        zamiana_scian(kostka,0,N+1,N,3*N+3);
        obrot_sciany_w_lewo(kostka,N,2*N+2);
        obrot_sciany_dwa_razy_w_prawo(kostka,N,3*N+3);
        obrot_sciany_w_prawo(kostka,N,0);
        obrot_sciany_dwa_razy_w_prawo(kostka,0,N+1);
        ile_obortow(kostka,liczba_warstw_do_przesuniecia,kat_obrotu);
        obrot_sciany_dwa_razy_w_prawo(kostka,0,N+1);
        obrot_sciany_w_lewo(kostka,N,0);
        obrot_sciany_dwa_razy_w_prawo(kostka,N,3*N+3);
        obrot_sciany_w_prawo(kostka,N,2*N+2);
        zamiana_scian(kostka,0,N+1,N,3*N+3);
        zamiana_scian(kostka,0,N+1,2*N,N+1);
        zamiana_scian(kostka,0,N+1,N,N+1);
    }
    else if(sciana == 'd') {
        zamiana_scian(kostka,2*N,N+1,N,N+1);
        zamiana_scian(kostka,2*N,N+1,0,N+1);
        zamiana_scian(kostka,2*N,N+1,N,3*N+3);
        obrot_sciany_dwa_razy_w_prawo(kostka,N,3*N+3);
        obrot_sciany_w_lewo(kostka,N,0);
        obrot_sciany_dwa_razy_w_prawo(kostka,2*N,N+1);
        obrot_sciany_w_prawo(kostka,N,2*N+2);
        ile_obortow(kostka,liczba_warstw_do_przesuniecia,kat_obrotu);
        obrot_sciany_w_lewo(kostka,N,2*N+2);
        obrot_sciany_dwa_razy_w_prawo(kostka,2*N,N+1);
        obrot_sciany_w_prawo(kostka,N,0);
        obrot_sciany_dwa_razy_w_prawo(kostka,N,3*N+3);
        zamiana_scian(kostka,2*N,N+1,N,3*N+3);
        zamiana_scian(kostka,2*N,N+1,0,N+1);
        zamiana_scian(kostka,2*N,N+1,N,N+1);
    }
}


void wczyt_polecen_i_wyknoywanie(int kostka[rzedy][kolumny]) {
    bool koniecprogramu = false;
    bool nowalinia = false;
    int symbol;
    while(koniecprogramu == false){
        nowalinia = false;
        while(nowalinia == false){
            symbol = getchar();
            if(symbol == '\n'){
                nowalinia = true;
                continue;
            }
            else if(symbol == '.'){
                nowalinia = true;
                koniecprogramu = true;
                continue;
            }
            int liczbawierszy = 1;
            char sciana = 'f';
            char kat = ' ';
            if(symbol > '0' && symbol <= '9'){
                liczbawierszy = symbol - '0';
                while((symbol = getchar()) >= '0' && symbol <= '9'){
                    liczbawierszy *= 10;
                    liczbawierszy += symbol-'0';
                }
            }
            if(symbol > 'a' && symbol < 'z'){
                switch(symbol){
                    case 'b': sciana = 'b'; break;
                    case 'd': sciana = 'd'; break;
                    case 'f': sciana = 'f'; break;
                    case 'l': sciana = 'l'; break;
                    case 'r': sciana = 'r'; break;
                    case 'u': sciana = 'u'; break;
                }
                symbol = getchar();
            }
            if(symbol == '\''){
                kat = '\'';
            }
            else if(symbol == '"'){
                kat = '\"';
            }
            else{
                kat = ' ';
                ungetc(symbol, stdin);
            }
            zmiana_w_kostce(kostka, liczbawierszy, sciana, kat);
        }
        if(koniecprogramu == false){
            wypisywanie_stanu_kostki(kostka);
        }
    }
}
int main(void) {
    int kostka[rzedy][kolumny];
    tworzenie_kostki(kostka);
    wczyt_polecen_i_wyknoywanie(kostka);
    return 0;
}
