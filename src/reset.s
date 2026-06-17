.code 32
.extern startup
.global reset

.section .reset_text

reset:

    B startup

.end