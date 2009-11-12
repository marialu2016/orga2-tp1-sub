BITS 32
mov eax, page_table_0
or 	eax, 0x3		;supervisor, read/write, present
mov [page_dir], eax


page_dir:
	dd 	0x00000000
	
%rep	0x400 - 1
	dd	0x00000002		;supervisor, read/write, not present
%endrep

page_table_0:
%assign i 0x0000
%rep    0x400
	
    dd 	i | 3			;supervisor, read/write, present
				
%assign i i+4096 
%endrep












