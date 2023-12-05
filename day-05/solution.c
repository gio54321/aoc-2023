#include <stdio.h>
#include <immintrin.h>
#include <math.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>

#define LEN 64
#define MAP_N 7

struct map {
    size_t map_length;
    uint64_t map[LEN][3];
};

char* map_names[] = {
    "seed-to-soil map:",
    "soil-to-fertilizer map:",
    "fertilizer-to-water map:",
    "water-to-light map:",
    "light-to-temperature map:",
    "temperature-to-humidity map:",
    "humidity-to-location map:"
};



size_t parse_seeds(FILE* f, uint64_t* seeds){
    fscanf(f, "seeds:");
    uint64_t seed = 0;
    int res, i=0;
    while((res = fscanf(f, "%lu", &seed))) {
        seeds[i] = seed;
        ++i;
    }

    // Apparently if you forget the return statement, g++ will emit ud2 instruction
    // causing illegal hw instruction fault, while gcc will happily compile normally,
    // without moving any value to rax ¯\_(ツ)_/¯
    return i;
}

size_t parse_map(FILE* f, uint64_t map[LEN][3], char* name) {
    fscanf(f, name);
    uint64_t seed = 0;
    int res, i=0;
    while((res = fscanf(f, "%lu", &seed))) {
        map[i/3][i%3] = seed;
        ++i;
    }
    return i / 3;
}

uint64_t table_lookup(uint64_t seed, uint64_t map[LEN][3], size_t map_len, bool* is_found){

    // !!1!!!11!! blazing fast !!1!!11!!

    __m256i accumulator = _mm256_setzero_si256();
    __m256i is_found_vec = _mm256_setzero_si256();
    __m256i seeds = _mm256_set_epi64x(seed, seed, seed, seed);

    for (size_t map_page = 0; map_page < map_len; map_page += 4){
        __m256i input_start = _mm256_setr_epi64x(
            map[map_page + 0][1], 
            map[map_page + 1][1], 
            map[map_page + 2][1], 
            map[map_page + 3][1]);
        __m256i output_start = _mm256_setr_epi64x(
            map[map_page + 0][0], 
            map[map_page + 1][0], 
            map[map_page + 2][0], 
            map[map_page + 3][0]);
        __m256i length = _mm256_setr_epi64x(
            map[map_page + 0][2], 
            map[map_page + 1][2], 
            map[map_page + 2][2], 
            map[map_page + 3][2]);
        __m256i input_end = _mm256_add_epi64(input_start, length);


        // comparisons set 0xffffffffffffffff if they are true, else 0
        __m256i comp1 = _mm256_cmpgt_epi64(seeds, input_start);
        __m256i compeq = _mm256_cmpeq_epi64(seeds, input_start);
        __m256i comp2 = _mm256_cmpgt_epi64(input_end, seeds);
        __m256i in_range = _mm256_or_si256(_mm256_and_si256 (comp1, comp2), compeq);

        __m256i result_sub = _mm256_sub_epi64(seeds, input_start);
        __m256i result_add = _mm256_add_epi64(result_sub, output_start);
        __m256i result = _mm256_and_si256(result_add, in_range);

        accumulator = _mm256_add_epi64(accumulator, result);
        is_found_vec = _mm256_or_si256(is_found_vec, in_range);

        __attribute__ ((aligned (32))) uint64_t output[4];
        _mm256_store_epi64(output, output_start);
    }

    __attribute__ ((aligned (32))) uint64_t output[4];
    _mm256_store_epi64(output, accumulator);

    // apparently there is no hadd for 64 bit integers :(
    uint64_t map_output = output[0] + output[1] + output[2] + output[3];

    _mm256_store_epi64(output, is_found_vec);

    // also there is no reduction with or (?) idk
    *is_found = (output[0] | output[1] | output[2] | output[3]) != 0;

    return map_output;
}


int main() {
    FILE* f = fopen("input.txt", "r");

    uint64_t seeds[LEN];
    memset(seeds, 0, sizeof(seeds));

    size_t seeds_len = parse_seeds(f, seeds);
    
    struct map maps[MAP_N];
    for (size_t i = 0; i < MAP_N; ++i) {
        memset(maps[i].map, 0xff, sizeof(maps[i].map));
        maps[i].map_length = parse_map(f, maps[i].map, map_names[i]);
    }

    uint64_t result = __UINT64_MAX__;
    for (size_t i = 0; i < seeds_len; ++i) {
        uint64_t curr = seeds[i];
        for (size_t map_i = 0; map_i < MAP_N; ++map_i){
            bool is_found = false;
            uint64_t res = table_lookup(curr, maps[map_i].map, maps[map_i].map_length, &is_found);
            if (is_found) {
                curr = res;
            }
        }
        printf("Mapping seed %lu -> %lu\n", seeds[i], curr);
        if (curr < result) {
            result = curr;
        }
    }
    printf("The solution is %lu\n", result);

    return 0;
}

