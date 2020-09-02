#pragma once

typedef enum
{
    AXDANALYZ_NO_ERROR,
    AXDANALYZ_REC_FILE_NOT_FOUND
} axdanalyz_error_t;

void axdanalyz_gen_measure_signal(int sample_rate, const char* path, axdanalyz_error_t* error);
void axdanalyz_deconvolve_measure_signal(const char* path_rec, const char* path_brir_format, axdanalyz_error_t* error);
