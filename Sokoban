//Program przygotwał Szymon Skierski
#include <fenv.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

//Poniższy program ma za zadanie odtwarzać japońską grę Sokoban ,ma wczytywać polecenia od użytkownika i wykonywać zadane przez niego zadania
//funkcja pomocnicza do przyszłej tablicy_wspolrzednych
void uzupełnianie(int tab[123][2]) {
    int i = 0;
    while (i<123) {
        tab[i][0] = -1;
        tab[i][1] = -1;
        i++;
    }
}
//Funckja zczytuje mapę i kończy zczytywanie gdy będą dwa entery
void pobieranie_i_tworzenie_mapy(int*** mapa, int **dlugosci_wierszy, int *ile_wierszy, int tablica_wspolrzednych_skrzyn[123][2], int *maksymalna_dlugosc_wierszy) {
    bool koniecmapy = false;
    bool nowalinia = false;
    int znak;
    int nast_znak = '\n';
    int i = 0;
    int j = 0;
    int lKolumn = 0;
    int lKolumn_max = 0;
    *mapa = (int**)malloc(sizeof(int*));

    while (koniecmapy == false) {

        nowalinia = false;
        j = 0;
        (*mapa)[i] = NULL;

        while (nowalinia == false) {

            if (j == 0 && nast_znak != '\n') {

                znak = nast_znak;
            } else {

                znak = getchar();
            }
            if (znak != '\n') {

                (*mapa)[i] = (int*)realloc((*mapa)[i], sizeof(int)*(size_t)(j + 1));
                (*mapa)[i][j] = znak;

                if ((znak >= 'a' && znak <= 'z') || (znak >= '@' && znak <= 'Z') || (znak == '*')) {

                    if (znak >= 'A' && znak <= 'Z') {

                        tablica_wspolrzednych_skrzyn[znak + 32][0] = j;
                        tablica_wspolrzednych_skrzyn[znak + 32][1] = i;
                    } else if (znak == '*') {

                        tablica_wspolrzednych_skrzyn['@'][0] = j;
                        tablica_wspolrzednych_skrzyn['@'][1] = i;
                    } else {

                        tablica_wspolrzednych_skrzyn[znak][0] = j;
                        tablica_wspolrzednych_skrzyn[znak][1] = i;
                    }
                }
                j++;
                lKolumn++;
            } else {

                if (lKolumn > lKolumn_max) {

                    lKolumn_max = lKolumn;
                }
                i++;
                *dlugosci_wierszy = (int*)realloc(*dlugosci_wierszy, sizeof(int) * (size_t)i);
                (*dlugosci_wierszy)[i - 1] = lKolumn;
                nowalinia = true;
                if (*maksymalna_dlugosc_wierszy < lKolumn) {

                    *maksymalna_dlugosc_wierszy = lKolumn;
                }
                *mapa = (int**)realloc(*mapa, sizeof(int*) * (size_t)(i + 1));
                lKolumn = 0;
            }
        }

        nast_znak = getchar();
        if (nast_znak == '\n') {

            koniecmapy = true;
        }
    }

    *ile_wierszy = i;
}
// funkcja pomocnicza do sprawdzania czy da się zrobić ruch BFS
void same_zera(int *długosc_wierszy, int ***tablica_zer, int ile_wierszy) {
    int i = 0;
    int j = 0;
    *tablica_zer = (int**)malloc(sizeof(int*)*(size_t)ile_wierszy);
    while(i < ile_wierszy){

        j = 0;
        (*tablica_zer)[i] = (int*)malloc(sizeof(int)*(size_t)(długosc_wierszy[i]));
        while (j<długosc_wierszy[i]) {

            (*tablica_zer)[i][j] = 0;
            j++;
        }
        i++;
    }
}

// kolejka będzie potrzebna do algorytmu bfs
// są poniżej funkcje dodyczące kolejki typu czy kolejka pusta ...
struct kolejka {
    int (*T)[2];
    int pocz,kon;
    int pojemnosc;
};
typedef struct kolejka Tkolejka;

int Nastepny(int j,int ile_wierszy,int maksymalna_dlugosc_wierszy) {
    if (j == ile_wierszy*maksymalna_dlugosc_wierszy-1) return 0;
    return j+1;
}

bool Pusta(Tkolejka k) {
    return (k.pocz == k.kon);
}
void TworzPustą(Tkolejka *k, int pojemnosc) {
    k->T = malloc(sizeof(int[2])*(size_t)pojemnosc);
    k -> pocz = 0;
    k -> kon = 0;
}
void Wstaw(Tkolejka *k, int element1, int element2,int ile_wierszy,int maksymalna_dlugosc_wierszy) {
    k -> T[k-> kon][0] = element1;
    k-> T[k->kon][1] = element2;
    k -> kon = Nastepny(k-> kon,ile_wierszy, maksymalna_dlugosc_wierszy);
}
void Pobierz(Tkolejka*k,int obecne_wsp[2],int ile_wierszy,int maksymalna_dlugosc_wierszy) {
    int x,y;
    x = k->T[k->pocz][0];
    y = k->T[k->pocz][1];
    k-> pocz = Nastepny(k-> pocz, ile_wierszy,maksymalna_dlugosc_wierszy);
    obecne_wsp[0] = x;
    obecne_wsp[1] = y;
}
// stso mapy będzie potrzebny gdy użytowknik będzie chciał cofnąć ruch
struct stos_map {
    int **w;
    struct stos_map *nast;
};
typedef struct stos_map Lstos;


bool Pusty_stos(Lstos *s) {
    return s == NULL;
}

void Inicjowanie(Lstos **s) {
    *s = NULL;
}

void Pchnicie_stosu(Lstos **s , int **mapa, int ile_wierszy,int *dlugosc_wierszy) {
    Lstos *pom;
    pom = (Lstos*)malloc(sizeof(Lstos));
    pom->w = (int **)malloc((size_t)ile_wierszy * sizeof(int *));
    for (int i = 0; i < ile_wierszy; i++) {
        pom->w[i] = (int *)malloc((size_t)dlugosc_wierszy[i] * sizeof(int));
        for (int j = 0; j < dlugosc_wierszy[i]; j++) {
            pom->w[i][j] = mapa[i][j];
        }
    }
    pom->nast = *s;
    *s = pom;
}

void Usun_ze_stosu(Lstos **s,int ile_wierszy) {
    Lstos *pom = *s;

    int **tablica = pom->w;
    for (int i = 0; i < ile_wierszy; i++) {
        free(tablica[i]);
    }
    free(tablica);
    *s = pom->nast;
    free(pom);
}
void Wyczysc(Lstos **s,int ile_wierszy) {
    while (!Pusty_stos(*s)) Usun_ze_stosu(s,ile_wierszy);
}
//jeśli użytownik zechce cofnąć ruch, wtedy funckja się uruchamia i każdej literze i @ przyporządkuje 'stare'współrzędne
void szczyt_stosu(Lstos **s, int ***mapa, int tablica_wspołrzędnych_skrzyn[123][2], int ile_wierszy, int *dlugosc_wierszy) {
    int i = 0;
    int j = 0;
    int k = 'a';

    while (i < ile_wierszy) {

        j = 0;

        while (j < dlugosc_wierszy[i]) {

            (*mapa)[i][j] = (*s)->w[i][j];

            k = 'a';
            while (k < 123) {

                if ((*s)->w[i][j] == k) {

                    tablica_wspołrzędnych_skrzyn[k][0] = j;
                    tablica_wspołrzędnych_skrzyn[k][1] = i;
                }
                if ((*s)->w[i][j] == (k - 32)) {

                    tablica_wspołrzędnych_skrzyn[k][0] = j;
                    tablica_wspołrzędnych_skrzyn[k][1] = i;
                }
                k++;
            }

            if ((*s)->w[i][j] == '@' || (*s)->w[i][j] == '*') {

                tablica_wspołrzędnych_skrzyn['@'][0] = j;
                tablica_wspołrzędnych_skrzyn['@'][1] = i;
            }
            j++;
        }
        i++;
    }
}


// funkcja pomocnicza do sprawdzania czy możliwe jest pchnięcie, aktualizuje wsp docelowe
void wsp_docelowe(int *x , int *y, int litera, int gdzie, int tablica_wspołrzędnych_skrzyn[123][2]) {
    int x_wsp_docelowa;
    int y_wsp_docelowa;
    if (gdzie == 2) {

        x_wsp_docelowa = tablica_wspołrzędnych_skrzyn[litera][0];
        y_wsp_docelowa = tablica_wspołrzędnych_skrzyn[litera][1]-1;
    }
    else if (gdzie == 4) {

        x_wsp_docelowa = tablica_wspołrzędnych_skrzyn[litera][0]+1;
        y_wsp_docelowa = tablica_wspołrzędnych_skrzyn[litera][1];
    }
    else if (gdzie == 6) {

        x_wsp_docelowa = tablica_wspołrzędnych_skrzyn[litera][0] -1;
        y_wsp_docelowa = tablica_wspołrzędnych_skrzyn[litera][1];
    }
    else {

        x_wsp_docelowa = tablica_wspołrzędnych_skrzyn[litera][0];
        y_wsp_docelowa = tablica_wspołrzędnych_skrzyn[litera][1] +1;

    }
    *x = x_wsp_docelowa;
    *y = y_wsp_docelowa;
}
void czyszczenie_tablicy(int ***tablica, int ile_wierszy) {
    int i = 0;
    while (i < ile_wierszy){

        free((*tablica)[i]);
        i++;
    }
}
// funkcja ma za zadania za pomoca algoyrtmu BFS sprawdzić w optymalnym czasie czy da się wykonać ruch jęsli tak zwraca 1 wpp 0
bool czy_mozliwe_pchniecie_BFS(int litera, int gdzie, int x_wsp_postaci, int y_wsp_postaci, int **mapa, int ile_wierszy, int *dlugosc_wierszy, int tablica_wspołrzędnych_skrzyn[123][2], int **tablica_odwiedzonych, int maksymalna_dlugosc_wierszy) {
    int x_wsp_docelowa;
    int y_wsp_docelowa;

    same_zera(dlugosc_wierszy, &tablica_odwiedzonych, ile_wierszy);

    wsp_docelowe(&x_wsp_docelowa, &y_wsp_docelowa, litera, gdzie, tablica_wspołrzędnych_skrzyn);

    if (gdzie == 2 && (y_wsp_docelowa + 2 >= ile_wierszy || (mapa[y_wsp_docelowa + 2][x_wsp_docelowa] != '@' && mapa[y_wsp_docelowa + 2][x_wsp_docelowa] != '*' && mapa[y_wsp_docelowa + 2][x_wsp_docelowa] != '-' && mapa[y_wsp_docelowa + 2][x_wsp_docelowa] != '+'))) {
        return false;
    }

    if (gdzie == 8 && (y_wsp_docelowa - 2 < 0 || x_wsp_docelowa > dlugosc_wierszy[y_wsp_docelowa - 2] || (mapa[y_wsp_docelowa - 2][x_wsp_docelowa] != '@' && mapa[y_wsp_docelowa - 2][x_wsp_docelowa] != '*' && mapa[y_wsp_docelowa - 2][x_wsp_docelowa] != '-' && mapa[y_wsp_docelowa - 2][x_wsp_docelowa] != '+'))) {
        return false;
    }

    if (gdzie == 4 && (x_wsp_docelowa - 2 < 0 || y_wsp_docelowa < 0 || (mapa[y_wsp_docelowa][x_wsp_docelowa - 2] != '@' &&mapa[y_wsp_docelowa][x_wsp_docelowa - 2] != '*' && mapa[y_wsp_docelowa][x_wsp_docelowa - 2] != '-' && mapa[y_wsp_docelowa][x_wsp_docelowa - 2] != '+'))) {
        return false;
    }

    if (gdzie == 6 && (x_wsp_docelowa + 2 >= dlugosc_wierszy[y_wsp_docelowa] || y_wsp_docelowa >= ile_wierszy || (mapa[y_wsp_docelowa][x_wsp_docelowa + 2] != '@' && mapa[y_wsp_docelowa][x_wsp_docelowa + 2] != '*' && mapa[y_wsp_docelowa][x_wsp_docelowa + 2] != '-' && mapa[y_wsp_docelowa][x_wsp_docelowa + 2] != '+'))) {
        return false;
    }

    if (y_wsp_postaci == y_wsp_docelowa && x_wsp_postaci == x_wsp_docelowa) {
        return true;
    }

    Tkolejka bfs;
    TworzPustą(&bfs, ile_wierszy * maksymalna_dlugosc_wierszy);
    Wstaw(&bfs, y_wsp_postaci, x_wsp_postaci, ile_wierszy, maksymalna_dlugosc_wierszy);

    int nowy_x, nowy_y, x, y;
    int obecne_wsp[2];
    int kierunki[4][2] = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}};

    while (!Pusta(bfs)) {
        Pobierz(&bfs, obecne_wsp, ile_wierszy, maksymalna_dlugosc_wierszy);
        y = obecne_wsp[1];
        x = obecne_wsp[0];

        if (x == x_wsp_docelowa && y == y_wsp_docelowa) {
            return true;
        }

        for (int i = 0; i < 4; i++) {

            nowy_y = y + kierunki[i][0];
            nowy_x = x + kierunki[i][1];

            if (nowy_y >= 0 && nowy_y < ile_wierszy && nowy_x >= 0 && nowy_x < dlugosc_wierszy[nowy_y] && tablica_odwiedzonych[nowy_y][nowy_x] == 0 && (mapa[nowy_y][nowy_x] == '-' || mapa[nowy_y][nowy_x] == '+')) {
                tablica_odwiedzonych[nowy_y][nowy_x] = 1;
                Wstaw(&bfs, nowy_x, nowy_y, ile_wierszy, maksymalna_dlugosc_wierszy);
            }
        }
    }
    return false;
}

//funkcja "pomoc" ma zmieniać planszę gry, w sposób jaki użytkownik będzie chciał
void pomoc(int ***mapa, int litera, int gdzie, int y_docelowe, int x_docelowe,int tablica_wspołrzędnych_skrzyn[123][2] ) {
    int pom_docelowe = (*mapa)[y_docelowe][x_docelowe];

    if (gdzie == 2) {

        if ((*mapa)[y_docelowe + 2][x_docelowe] == '+') {

            if ((*mapa)[y_docelowe + 1][x_docelowe] >= 'A' && (*mapa)[y_docelowe + 1][x_docelowe] <= 'Z') (*mapa)[y_docelowe + 1][x_docelowe] = '*';

            else (*mapa)[y_docelowe + 1][x_docelowe ] = '@';

            (*mapa)[y_docelowe + 2][x_docelowe] = (char)(litera - 32);
        }

        else {

            if ((*mapa)[y_docelowe + 1][x_docelowe] >= 'A' && (*mapa)[y_docelowe + 1][x_docelowe] <= 'Z') (*mapa)[y_docelowe + 1][x_docelowe] = '*';

            else (*mapa)[y_docelowe + 1][x_docelowe ] = '@';

            (*mapa)[y_docelowe + 2][x_docelowe] = (char)(litera);
        }

        tablica_wspołrzędnych_skrzyn[litera][1] = y_docelowe + 2;
        tablica_wspołrzędnych_skrzyn[litera][0] = x_docelowe;
        tablica_wspołrzędnych_skrzyn['@'][1] = y_docelowe + 1;
        tablica_wspołrzędnych_skrzyn['@'][0] = x_docelowe;

    } else if (gdzie == 8) {

        if ((*mapa)[y_docelowe - 2][x_docelowe] =='+') {

            if ((*mapa)[y_docelowe-1][x_docelowe] >= 'A' && (*mapa)[y_docelowe-1][x_docelowe] <= 'Z') (*mapa)[y_docelowe-1][x_docelowe] = '*';

            else (*mapa)[y_docelowe-1][x_docelowe] = '@';

            (*mapa)[y_docelowe - 2][x_docelowe] = (char)(litera - 32);
        }

        else {

            if ((*mapa)[y_docelowe - 1][x_docelowe] >= 'A' && (*mapa)[y_docelowe - 1][x_docelowe] <= 'Z') (*mapa)[y_docelowe - 1][x_docelowe ] = '*';

            else (*mapa)[y_docelowe - 1][x_docelowe] = '@';

            (*mapa)[y_docelowe - 2][x_docelowe] = (char)(litera);
        }

        tablica_wspołrzędnych_skrzyn[litera][1] = y_docelowe - 2;
        tablica_wspołrzędnych_skrzyn[litera][0] = x_docelowe;
        tablica_wspołrzędnych_skrzyn['@'][1] = y_docelowe - 1;
        tablica_wspołrzędnych_skrzyn['@'][0] = x_docelowe;
    } else if (gdzie == 4) {


        if ((*mapa)[y_docelowe][x_docelowe - 2] == '+') {

            if ((*mapa)[y_docelowe][x_docelowe - 1] >= 'A' && (*mapa)[y_docelowe][x_docelowe - 1] <= 'Z') (*mapa)[y_docelowe][x_docelowe - 1] = '*';

            else (*mapa)[y_docelowe][x_docelowe - 1] = '@';

            (*mapa)[y_docelowe][x_docelowe - 2] = (char)(litera - 32);
        }

        else {

            if ((*mapa)[y_docelowe][x_docelowe - 1] >= 'A' && (*mapa)[y_docelowe][x_docelowe - 1] <= 'Z') (*mapa)[y_docelowe][x_docelowe - 1] = '*';

            else (*mapa)[y_docelowe][x_docelowe - 1] = '@';

            (*mapa)[y_docelowe][x_docelowe - 2] = (char)(litera);

        }

        tablica_wspołrzędnych_skrzyn[litera][1] = y_docelowe;
        tablica_wspołrzędnych_skrzyn[litera][0] = x_docelowe - 2;
        tablica_wspołrzędnych_skrzyn['@'][1] = y_docelowe;
        tablica_wspołrzędnych_skrzyn['@'][0] = x_docelowe - 1;

    } else if (gdzie == 6){

        if ((*mapa)[y_docelowe][x_docelowe + 2] == '+') {

            if ((*mapa)[y_docelowe][x_docelowe + 1] >= 'A' && (*mapa)[y_docelowe][x_docelowe + 1] <= 'Z') (*mapa)[y_docelowe][x_docelowe + 1] = '*';

            else (*mapa)[y_docelowe][x_docelowe + 1] = '@';

            (*mapa)[y_docelowe][x_docelowe + 2] = (char)(litera - 32);
        }

        else {
            (*mapa)[y_docelowe][x_docelowe + 2] = (char)(litera);
            if ((*mapa)[y_docelowe][x_docelowe + 1] >= 'A' && (*mapa)[y_docelowe][x_docelowe + 1] <= 'Z') (*mapa)[y_docelowe][x_docelowe + 1] = '*';

            else (*mapa)[y_docelowe][x_docelowe + 1] = '@';

            (*mapa)[y_docelowe][x_docelowe + 2] = (char)(litera);
        }

        tablica_wspołrzędnych_skrzyn[litera][1] = y_docelowe;
        tablica_wspołrzędnych_skrzyn[litera][0] = x_docelowe + 2;
        tablica_wspołrzędnych_skrzyn['@'][1] = y_docelowe;
        tablica_wspołrzędnych_skrzyn['@'][0] = x_docelowe + 1;

    }

    if (pom_docelowe == '@') {

        (*mapa)[y_docelowe][x_docelowe] = '-';
    }

    else if (pom_docelowe == '*') {

        (*mapa)[y_docelowe][x_docelowe] = '+';
    }

    else {

        (*mapa)[y_docelowe][x_docelowe] = pom_docelowe;
    }

}

// funckja "pomoc" odgrywa tu główną rolę jednak robienie pchnięcia jest jedną z najważniejszych funkcji w programie
void robienie_pchniecia(int litera, int gdzie, int x_wsp_postaci,int y_wsp_postaci, int ***mapa,int tablica_wspołrzędnych_skrzyn[123][2]) {
    int x_docelowe;
    int y_docelowe;

    wsp_docelowe(&x_docelowe,&y_docelowe,litera,gdzie,tablica_wspołrzędnych_skrzyn);
    if ((*mapa)[x_wsp_postaci][y_wsp_postaci] == '*') {

        (*mapa)[x_wsp_postaci][y_wsp_postaci] = '+';
        pomoc(mapa,litera,gdzie,y_docelowe,x_docelowe,tablica_wspołrzędnych_skrzyn);
    }
    else {

        (*mapa)[x_wsp_postaci][y_wsp_postaci] = '-';
        pomoc(mapa,litera,gdzie,y_docelowe,x_docelowe,tablica_wspołrzędnych_skrzyn);
    }
}
void wydruk_mapy(int **mapa,int ile_wierszy,int *dlugosc_wierszy) {
    int i = 0;
    int j = 0;
    while (i < ile_wierszy) {

        j = 0;
        while (j<dlugosc_wierszy[i]) {

            printf("%c", mapa[i][j]);
            j++;
        }
        printf("\n");
        i++;
    }
}

// gdy program posiada już mapę, potrzebuje poleceń, które wczytuje poniższa funkcja, oraz je wykonuje
void pobieranie_i_robienie_polecen(int **mapa,int ile_wierszy,int *dlugosc_wierszy,int tablica_wspołrzędnych_skrzyn[123][2],int **tablica_odwiedzonych, int maksymalna_dlugosc_wierszy) {
    bool koniec_polecen = false;
    bool nowalinia = false;
    int znak = ' ';
    int litera;
    int gdzie;
    Lstos *s;
    Inicjowanie(&s);
    Pchnicie_stosu(&s,mapa,ile_wierszy,dlugosc_wierszy);
    wydruk_mapy(mapa,ile_wierszy,dlugosc_wierszy);
    while (!koniec_polecen) {

        nowalinia = false;
        if (znak =='.') {

            nowalinia = true;
            koniec_polecen = true;
        }
        while (!nowalinia) {

            znak = getchar();
            if (znak == '.') {

                nowalinia = true;
                koniec_polecen = true;
                break;
            }
            else if (znak == '\n') {

                nowalinia = true;
                wydruk_mapy(mapa,ile_wierszy,dlugosc_wierszy);
            }
            else if (znak == '0') {

                if (!Pusty_stos(s)) {

                    szczyt_stosu(&s,&mapa,tablica_wspołrzędnych_skrzyn,ile_wierszy,dlugosc_wierszy);
                    Usun_ze_stosu(&s,ile_wierszy);
                    if(Pusty_stos(s)) {

                        Pchnicie_stosu(&s,mapa,ile_wierszy,dlugosc_wierszy);
                    }
                    else {

                        szczyt_stosu(&s,&mapa,tablica_wspołrzędnych_skrzyn,ile_wierszy,dlugosc_wierszy);
                    }
                }

            }
            else {

                litera = znak;
                gdzie = getchar();
                gdzie = gdzie - '0';
                if (czy_mozliwe_pchniecie_BFS(litera, gdzie, tablica_wspołrzędnych_skrzyn['@'][1], tablica_wspołrzędnych_skrzyn['@'][0], mapa,ile_wierszy,dlugosc_wierszy,tablica_wspołrzędnych_skrzyn,tablica_odwiedzonych,maksymalna_dlugosc_wierszy)) {

                    robienie_pchniecia(litera, gdzie, tablica_wspołrzędnych_skrzyn['@'][1], tablica_wspołrzędnych_skrzyn['@'][0], &mapa,tablica_wspołrzędnych_skrzyn);
                    Pchnicie_stosu(&s,mapa,ile_wierszy,dlugosc_wierszy);

                }
            }
        }
    }
    Wyczysc(&s,ile_wierszy);
    czyszczenie_tablicy(&mapa,ile_wierszy);
    free(dlugosc_wierszy);
}
int main(void) {
    int ile_wierszy = 0;
    int **tablica_odwiedzonych = NULL;
    int *dlugosc_wierszy = NULL;
    int tablica_wspołrzędnych_skrzyn[123][2];
    int maksymalna_dlugosc_wierszy = 0;
    int **mapa = NULL;
    uzupełnianie(tablica_wspołrzędnych_skrzyn);
    pobieranie_i_tworzenie_mapy(&mapa,&dlugosc_wierszy,&ile_wierszy,tablica_wspołrzędnych_skrzyn,&maksymalna_dlugosc_wierszy);
    pobieranie_i_robienie_polecen(mapa,ile_wierszy,dlugosc_wierszy,tablica_wspołrzędnych_skrzyn,tablica_odwiedzonych,maksymalna_dlugosc_wierszy);

}
