;BleskOS VGA edition

main_screen:
 HIDE_CURSOR

 DRAW_BACKGROUND 0x20

 DRAW_LINE 0, 0, 80, 0x40
 DRAW_LINE 24, 0, 80, 0x40
 DRAW_COLUMN 0, 0, 25, 0x40
 DRAW_COLUMN 0, 79, 25, 0x40

 PRINT 2, 2, str_up, 'Welcome to BleskOS'
 PRINT 4, 2, str_you_can, 'You can open programs with keyboard:'
 PRINT 6, 2, str_te, '[a] Text editor'
 PRINT 22, 2, str_down, 'You can shutdown computer by pressing power button'

 halt:
  WAIT_FOR_KEYBOARD

  IF al, 'a', text_editor
   jmp text_editor
  ENDIF text_editor
 jmp halt
