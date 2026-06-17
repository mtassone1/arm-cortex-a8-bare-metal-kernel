__attribute__((section(".c_init_text"))) void *td3_memcopy(void *destino, const void *origen, unsigned int num_bytes){

    char *d = destino;
    const char *o = origen;
    
    while (num_bytes--)
        *d++ = *o++;
    
    return destino;
}