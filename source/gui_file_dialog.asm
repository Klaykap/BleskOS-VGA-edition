;BleskOS

%define TEXT_FILES_FOLDER 1

file_dialog_first_showed_file dw 0
file_dialog_selected_file dw 0
file_dialog_memory_pointer dw 0
file_dialog_segment dw 0

file_dialog_draw_files:
 ;print names of files
 mov ax, 0x2000
 mov es, ax ;folder segment

 mov ax, word [file_dialog_first_showed_file]
 mov bx, 16 ;every file name has 16 chars
 mul bx
 mov bp, ax ;pointer to name of first file

 mov dh, 1
 mov dl, 1

 mov cx, 21
 .print_file_name:
 push cx
  mov ah, 0x13
  mov al, 0
  mov bh, 0
  mov bl, 0x20
  dec dh
  IF byte [file_dialog_selected_file], dh, selected_line
   mov bl, 0x40
  ENDIF selected_line
  inc dh
  mov cx, 16
  int 10h

  inc dh ;next line
  add bp, 16 ;next name
 pop cx
 loop .print_file_name

 ret

file_dialog_open:
 pusha
 mov word [disk_packet_segment], 0x2000
 mov ax, 1
 call read_file ;read folder file

 DRAW_BACKGROUND 0x20
 PRINT 23, 1, str_down, '[esc] Back [enter] Open file'

 mov word [file_dialog_selected_file], 0
 call file_dialog_draw_files

 .file_dialog_open_halt:
  WAIT_FOR_KEYBOARD

  IF ah, KEY_ESC, key_esc
   popa
   ret
  ENDIF key_esc

  IF ah, KEY_UP, key_up
   IF word [file_dialog_selected_file], 0, up_of_screen
    jmp .file_dialog_open_halt
   ENDIF up_of_screen

   dec word [file_dialog_selected_file]
   call file_dialog_draw_files
  ENDIF key_up

  IF ah, KEY_DOWN, key_down
   IF word [file_dialog_selected_file], 20, down_of_screen
    jmp .file_dialog_open_halt
   ENDIF down_of_screen

   inc word [file_dialog_selected_file]
   call file_dialog_draw_files
  ENDIF key_down

  IF ah, KEY_ENTER, key_enter
   mov ax, word [file_dialog_segment]
   mov word [disk_packet_segment], ax
   mov ax, word [file_dialog_first_showed_file]
   add ax, word [file_dialog_selected_file]
   add ax, 2 ;to file data
   call read_file
   popa
   ret
  ENDIF key_enter
 jmp .file_dialog_open_halt

file_dialog_save:
 pusha
 mov word [disk_packet_segment], 0x2000
 mov ax, 1
 call read_file ;read folder file

 DRAW_BACKGROUND 0x20
 PRINT 23, 1, str_down_2, '[esc] Back [enter] Save file'

 mov word [file_dialog_selected_file], 0
 call file_dialog_draw_files

 file_dialog_save_halt:
  WAIT_FOR_KEYBOARD

  IF ah, KEY_ESC, key_esc
   popa
   ret
  ENDIF key_esc

  IF ah, KEY_UP, key_up
   IF word [file_dialog_selected_file], 0, up_of_screen
    jmp file_dialog_save_halt
   ENDIF up_of_screen

   sub word [file_dialog_memory_pointer], 16
   dec word [file_dialog_selected_file]
   call file_dialog_draw_files
  ENDIF key_up

  IF ah, KEY_DOWN, key_down
   IF word [file_dialog_selected_file], 20, down_of_screen
    jmp file_dialog_save_halt
   ENDIF down_of_screen

   add word [file_dialog_memory_pointer], 16
   inc word [file_dialog_selected_file]
   call file_dialog_draw_files
  ENDIF key_down

  IF ah, KEY_ENTER, key_enter
   PRINT 23, 1, name_str, 'Type name(length 16 chars): '
   SET_CURSOR 23, 29
   SHOW_CURSOR

   ;set pointer to memory
   mov ax, 0x2000
   mov fs, ax
   mov di, word [file_dialog_memory_pointer]

   mov cx, 16
   .read_file_name:
    WAIT_FOR_KEYBOARD
    mov byte [fs:di], al ;write char to memory
    mov ah, 0x0E
    int 10h ;write char on screen
    inc di
   loop .read_file_name

   HIDE_CURSOR
   mov word [disk_packet_segment], 0x2000
   mov ax, 1 ;folder
   call write_file ;save folder

   mov ax, word [file_dialog_segment]
   mov word [disk_packet_segment], ax
   mov ax, word [file_dialog_first_showed_file]
   add ax, word [file_dialog_selected_file]
   add ax, 2 ;to file data
   call write_file

   popa
   ret
  ENDIF key_enter
 jmp file_dialog_save_halt

file_dialog_select_folder:
 mov bx, 21
 mul bx
 mov word [file_dialog_first_showed_file], ax
 mov bx, 16 ;lenght of name of file
 mul bx
 mov word [file_dialog_memory_pointer], ax

 ret
