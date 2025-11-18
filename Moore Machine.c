//
// Created by szyme on 13.04.2025.
//#include <stdio.h>
#include <assert.h>
#include <errno.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>

#define sufit(x) ((x) % 64 ? (x) / 64 + 1 : (x) / 64)

typedef struct moore moore_t;

typedef void (*transition_function_t)(uint64_t *next_state, uint64_t const *input,
                                      uint64_t const *state, size_t n, size_t s);

typedef void (*output_function_t)(uint64_t *output, uint64_t const *state,
                                  size_t m, size_t s);

typedef struct lista_konekcji_i_kto_go_posiada_t {
    size_t in;
    moore_t *automat;
    size_t out;
    struct lista_konekcji_i_kto_go_posiada_t *nast;
} lista_konekcji_t;

typedef struct lista_konekcji {
    moore_t *automat;
    size_t out;
} lista_t;

struct moore {
    size_t n;
    size_t m;
    size_t s;

    transition_function_t funkcja_przejscia;
    output_function_t funkcja_wyjscia;

    uint64_t *wejscie;
    uint64_t *wyjscie;
    uint64_t *stan;

    lista_konekcji_t *lista_podlaczen;
    lista_konekcji_t *lista_posiadaczy;

    lista_t *bity_podlaczone;
};


void ustaw_bit(uint64_t *tab, size_t indeks, uint64_t value) {
    size_t pod = indeks / 64;
    size_t poz = indeks % 64;
    tab[pod] = (tab[pod] & ~(1ULL << poz)) | ((value & 1) << poz);
}

uint64_t pobierz_bit(uint64_t const *tab, size_t indeks) {
    size_t pod = indeks / 64;
    size_t poz = indeks % 64;
    return (tab[pod] >> poz) & 1;
}


moore_t *ma_create_full(size_t n, size_t m, size_t s, transition_function_t t,
                        output_function_t y, uint64_t const *q) {
    if (m == 0 || s == 0 || t == NULL || y == NULL || q == NULL) {
        errno = EINVAL;
        return NULL;
    }

    moore_t *automat = (moore_t *) malloc(sizeof(moore_t));
    if (automat == NULL){
        errno = ENOMEM;
        return NULL;
    }

    automat->n = n;
    automat->m = m;
    automat->s = s;
    automat->funkcja_przejscia = t;
    automat->funkcja_wyjscia = y;

    size_t wejscie_size = sufit(n);
    size_t wyjscie_size = sufit(m);
    size_t stan_size = sufit(s);

    automat->wejscie = calloc(wejscie_size, sizeof(uint64_t));
    automat->wyjscie = calloc(wyjscie_size, sizeof(uint64_t));
    automat->stan = calloc(stan_size, sizeof(uint64_t));
    automat->bity_podlaczone = calloc(n, sizeof(lista_t));

    if (automat->wejscie == NULL || automat->wyjscie == NULL ||
        automat->stan == NULL || automat->bity_podlaczone == NULL) {
        free(automat->wejscie);
        free(automat->wyjscie);
        free(automat->stan);
        free(automat->bity_podlaczone);
        free(automat);
        errno = ENOMEM;
        return NULL;
    }

    automat->lista_podlaczen = NULL;
    automat->lista_posiadaczy = NULL;

    for (size_t i = 0; i < stan_size; i++) {
        automat->stan[i] = q[i];
    }

    automat->funkcja_wyjscia(automat->wyjscie, automat->stan, m, s);

    for (size_t j = 0; j < n; j++) {
        automat->bity_podlaczone[j].automat = NULL;
        automat->bity_podlaczone[j].out = 0;
    }

    return automat;
}

int dodaj_do_listy(lista_konekcji_t **lista, moore_t *automat, size_t in, size_t out) {
    lista_konekcji_t *nowy = malloc(sizeof(lista_konekcji_t));
    if (nowy == NULL) {
        errno = ENOMEM;
        return -1;
    }
    nowy->automat = automat;
    nowy->in = in;
    nowy->out = out;
    nowy->nast = *lista;
    *lista = nowy;
    return 0;
}

int usun_z_listy(lista_konekcji_t **lista, moore_t *do_usuniecia) {
    lista_konekcji_t *obency = *lista;
    lista_konekcji_t *poprzedni = NULL;
    int usunieto = 0;

    while (obency != NULL) {
        if (obency->automat == do_usuniecia) {
            lista_konekcji_t *znaleziony = obency;
            if (poprzedni == NULL) {
                *lista = obency->nast;
            }
            else {
                poprzedni->nast = obency->nast;
            }
            obency = obency->nast;
            free(znaleziony);
            usunieto = 1;
        }
        else {
            poprzedni = obency;
            obency = obency->nast;
        }
    }
    return usunieto;
}


int ma_connect(moore_t *a_in, size_t in, moore_t *a_out, size_t out, size_t num) {
    if (a_in == NULL || a_out == NULL || num == 0){
        errno = EINVAL;
        return -1;
    }
    if (in + num > a_in->n || out + num > a_out->m){
        errno = EINVAL;
        return -1;
    }

    for (size_t i = 0; i < num; i++){
        size_t obecny_in = in + i;
        size_t obecny_out = out + i;

        size_t pod_out = obecny_out / 64;
        size_t poz_out = obecny_out % 64;
        uint64_t bit_out = (a_out->wyjscie[pod_out] >> poz_out) & 0x1;

        size_t pod_in = obecny_in / 64;
        size_t poz_in = obecny_in % 64;
        a_in->wejscie[pod_in] = (a_in->wejscie[pod_in] & ~(1ULL << poz_in)) | (bit_out << poz_in);

        a_in->bity_podlaczone[obecny_in].automat = a_out;
        a_in->bity_podlaczone[obecny_in].out = obecny_out;

        if (dodaj_do_listy(&a_in->lista_posiadaczy, a_out, obecny_in, obecny_out) != 0 ||
            dodaj_do_listy(&a_out->lista_podlaczen, a_in, obecny_out, obecny_in) != 0){
            return -1;
        }
    }
    return 0;
}

int ma_disconnect(moore_t *a_in, size_t in, size_t num) {
    if (a_in == NULL || num == 0) {
        errno = EINVAL;
        return -1;
    }
    if (in + num > a_in->n)  {
        errno = EINVAL;
        return -1;
    }

    for (size_t i = 0; i < num; i++) {
        size_t obecny_bit = in + i;
        moore_t *a_out = a_in->bity_podlaczone[obecny_bit].automat;

        if (a_out != NULL) {
            usun_z_listy(&a_out->lista_podlaczen, a_in);
            usun_z_listy(&a_in->lista_posiadaczy, a_out);
            a_in->bity_podlaczone[obecny_bit].automat = NULL;
            ustaw_bit(a_in->wejscie, obecny_bit, 0);
        }
    }

    return 0;
}

int ma_set_input(moore_t *a, uint64_t const *input) {
    if (a == NULL || input == NULL){
        errno = EINVAL;
        return -1;
    }

    for (size_t i = 0; i < a->n; i++) {
        if (a->bity_podlaczone[i].automat == NULL) {
            uint64_t bit = pobierz_bit(input, i);
            ustaw_bit(a->wejscie, i, bit);
        }
    }
    return 0;
}

int ma_set_state(moore_t *a, uint64_t const *state) {
    if (a == NULL || state == NULL){
        errno = EINVAL;
        return -1;
    }

    for (size_t i = 0; i < a->s; i++){
        uint64_t bit = pobierz_bit(state, i);
        ustaw_bit(a->stan, i, bit);
    }

    a->funkcja_wyjscia(a->wyjscie, a->stan, a->m, a->s);
    return 0;
}

uint64_t const *ma_get_output(moore_t const *a) {
    if (a == NULL){
        errno = EINVAL;
        return NULL;
    }
    return a->wyjscie;
}

void funkcja_id(uint64_t *output, uint64_t const *state, size_t m, size_t s) {
    size_t pod = sufit(s);
    for (size_t i = 0; i < pod; i++) {
        output[i] = state[i];
    }
}

moore_t *ma_create_simple(size_t n, size_t s, transition_function_t t) {
    if (s == 0 || t == NULL) {
        errno = EINVAL;
        return NULL;
    }

    uint64_t *q = calloc(sufit(s), sizeof(uint64_t));
    if (q == NULL) {
        errno = ENOMEM;
        return NULL;
    }

    moore_t *automat = ma_create_full(n, s, s, t, funkcja_id, q);
    free(q);

    if (automat == NULL) {
        errno = ENOMEM;
    }
    return automat;
}

int ma_step(moore_t *at[], size_t num) {
    if (at == NULL || num == 0){
        errno = EINVAL;
        return -1;
    }

    for (size_t i = 0; i < num; i++) {
        if (at[i] == NULL) {
            errno = EINVAL;
            return -1;
        }
    }
    //najpierw ustawiamy nowy stan bez zmieniania inputów na podłączonych automatach
    for (size_t i = 0; i < num; i++) {
        moore_t *a = at[i];
        uint64_t *nowy_stan = calloc(sufit(a->s), sizeof(uint64_t));
        if (nowy_stan == NULL) {
            errno = ENOMEM;
            return -1;
        }

        a->funkcja_przejscia(nowy_stan, a->wejscie, a->stan, a->n, a->s);

        size_t pod = sufit(a->s);
        for (size_t j = 0; j < pod; j++) {
            a->stan[j] = nowy_stan[j];
        }
        free(nowy_stan);
    }
    // teraz zmieniamy outputy oraz zmieniamy bity wejsciowe automatą podłączonym do bitów w a[i]
    for (size_t i = 0; i < num; i++) {
        moore_t *a = at[i];
        a->funkcja_wyjscia(a->wyjscie, a->stan, a->m, a->s);

        lista_konekcji_t *obecny = a->lista_posiadaczy;
        while (obecny != NULL) {
            moore_t *podlaczony = obecny->automat;
            if (podlaczony != NULL) {
                size_t out_bit = obecny->out;
                size_t in_bit = obecny->in;

                uint64_t bit_val = pobierz_bit(a->wyjscie, out_bit);
                ustaw_bit(podlaczony->wejscie, in_bit, bit_val);
            }
            obecny = obecny->nast;
        }
    }

    return 0;
}

void ma_delete(moore_t *a) {
    if (a == NULL) return;

    // Odłączamy automaty, do których byliśmy podłączeni (jako źródło)
    lista_konekcji_t *obecny = a->lista_podlaczen;
    while (obecny != NULL) {
        moore_t *connected = obecny->automat;
        size_t in_bit = obecny->in;

        if (connected != NULL && in_bit < connected->n) {
            connected->bity_podlaczone[in_bit].automat = NULL;
        }

        usun_z_listy(&connected->lista_posiadaczy, a);

        lista_konekcji_t *next = obecny->nast;
        free(obecny);
        obecny = next;
    }

    // Odłączamy się od automatów, które nas miały jako źródło
    obecny = a->lista_posiadaczy;
    while (obecny != NULL) {
        moore_t *posiadacz = obecny->automat;
        size_t in_bit = obecny->in;
        if (posiadacz != NULL && in_bit < posiadacz->n) {
            posiadacz->bity_podlaczone[in_bit].automat = NULL;
        }

        usun_z_listy(&posiadacz->lista_podlaczen, a);

        lista_konekcji_t *nast = obecny->nast;
        free(obecny);
        obecny = nast;
    }

    free(a->wejscie);
    free(a->wyjscie);
    free(a->stan);
    free(a->bity_podlaczone);
    free(a);
}



#include "ma.h"
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <malloc.h>
#include <errno.h>

#define ASSERT(f)                        \
do {                                   \
if (!(f))                            \
return FAIL;                       \
} while (0)

#define PASS 0
#define FAIL -1
#define FAIL_PTR NULL

//Randomowe testy, co mi wpadlo do glowy.
//Nie wklejamy do ma_example, tylko kompilujemy z biblioteką i odpalamy.
//Pozdrawiam.

#include "ma.h"
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <malloc.h>
#include <errno.h>

#define PASS 0
#define FAIL -1
#define FAIL_PTR NULL

void t_one(uint64_t *next_state, uint64_t const *input,
           uint64_t const *old_state, size_t n, size_t s) {
    next_state[0] = old_state[0] + input[0];
    next_state[1] = old_state[1] + input[1];
}

void t_two(uint64_t *next_state, uint64_t const *input,
    uint64_t const *old_state, size_t n, size_t s) {
        next_state[0] = old_state[0] + input[0];
    }

void y_one(uint64_t *output, uint64_t const *state, size_t m, size_t s) {
    output[0] = state[0] + 1;
    output[1] = state[1] + 1;
}

int main() {
    //więcej niz 64 bity
    uint64_t *q1 = malloc(sizeof(uint64_t) * 2);
    q1[0] = 10;
    q1[1] = 20;
    moore_t *machine1 = ma_create_full(128, 128, 128, t_one, y_one,q1);
    const uint64_t *out1 = ma_get_output(machine1);
    assert(out1[0] == 11);
    assert(out1[1] == 21);

    uint64_t *q2 = malloc(sizeof(uint64_t) * 2);
    q2[0] = 5;
    q2[1] = 15;
    ma_set_state(machine1, q2);
    assert(out1[0] == 6);
    assert(out1[1] == 16);

    ma_set_input(machine1, q1);
    ma_step(&machine1, 1);
    assert(out1[0] == 16);
    assert(out1[1] == 36);

    uint64_t *zero = malloc(sizeof(uint64_t) * 2);
    zero[0] = 0;
    zero[1] = 1;
    ma_set_state(machine1, q1);
    ma_set_input(machine1, zero);

    moore_t *machine2 = ma_create_full(128, 128, 128, t_one, y_one,q2);
    ma_set_input(machine2, zero);
    const uint64_t *out2 = ma_get_output(machine2);

    ma_connect(machine2, 0, machine1, 0, 128);

    ma_step(&machine2, 1);
    assert(out2[0] == 17);
    assert(out2[1] == 37);

    free(q1);
    free(q2);
    free(zero);
    ma_delete(machine1);
    ma_delete(machine2);


    moore_t * machine3 = ma_create_simple(100, 100, t_one);

    uint64_t * q3 = malloc(sizeof(uint64_t) * 2);
    q3[0] = 6;
    q3[1] = 4;

    ma_set_input(machine3, q3);
    ma_step(&machine3, 1);
    const uint64_t * out3 = ma_get_output(machine3);
    assert(out3[0] == 6);
    assert(out3[1] == 4);

    ma_delete(machine3);
    free(q3);


    moore_t * machine4 = ma_create_simple(64, 64, t_two);
    moore_t * machine5 = ma_create_simple(64, 64, t_two);

    uint64_t jeden = 1;

    ma_set_state(machine4, &jeden);
    //Zakresy
    assert(ma_connect(machine5, 0, machine4, 0, 65) == FAIL);
    assert(errno == EINVAL);
    errno = 0;
    assert(ma_connect(machine5, 1, machine4, 0, 64) == FAIL);
    assert(errno == EINVAL);
    assert(ma_connect(machine5, 0, machine4, 1, 64) == FAIL);
    assert(errno == EINVAL);
    errno = 0;
    assert(ma_connect(machine5, 0, machine4, 0, 64) == PASS);
    assert(errno == 0);
    assert(ma_connect(machine5, 0, machine4, 1, 64) == FAIL);
    assert(errno == EINVAL);
    errno = 0;

    const uint64_t * out5 = ma_get_output(machine5);

    uint64_t in = (uint64_t)1 << 32;
    ma_set_input(machine5, &in);

    //Odłączanie przez usunięcie
    ma_step(&machine5, 1);
    assert(out5[0] == 1);
    ma_delete(machine4);
    ma_set_input(machine5, &in);
    ma_step(&machine5, 1);
    assert(out5[0] == in + 1);

    //Wpięcie sam w siebie
    assert(ma_connect(machine5, 0, machine5, 1, 40) == PASS);
    ma_set_state(machine5, &in);
    ma_step(&machine5, 1);
    assert(out5[0] == (uint64_t)3 << 31);

    //Synchroniczne ma_step
    moore_t * machine6 = ma_create_simple(64, 64, t_two);
    assert(ma_connect(machine6, 0, machine5, 0, 64) == PASS);
    moore_t * at[] = {machine5, machine6};
    const uint64_t * out6 = ma_get_output(machine6);
    ma_step(at, 2);
    assert(out5[0] == ((uint64_t)1 << 30) + ((uint64_t)1 << 33));
    assert(out6[0] == (uint64_t)3 << 31);
    ma_delete(machine5);
    ma_delete(machine6);

    return 0;
}
