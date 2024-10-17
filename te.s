.data
file_contents_offset:
	.quad 1
move_cursor:
	.ascii "\033[" # length = 2
position:
	.skip 20, 0
file_contents_pointer:
	.quad file_contents
terminal_row_pointer:
	.quad 2
terminal_column_pointer:
	.quad 1
	.byte 0
file_contents:
        .skip 99999, 0
file_length:
	.quad 0
        .skip 18, 0
digits_msg_last_byte:
        .byte 0
working_directory:
        .skip 255, 0
error_msg:
        .ascii "te: The entered command is wrong.\n" # length = 34
ANSI_white_background_black_foreground:
        .ascii "\033[30m\033[107m" # length = 11
ANSI_yellow:
	.ascii "\033[33m" # length = 5
ANSI_reset_color:
	.ascii "\033[0m" # length = 4
ANSI_move_cursor_up:
	.ascii "\033[1A" # length = 4
ANSI_move_cursor_down:
	.ascii "\033[1B" # length = 4
ANSI_move_cursor_right:
	.ascii "\033[1C" # length = 4
ANSI_move_cursor_left:
	.ascii "\033[1D" # length = 4
ANSI_move_cursor_left_by_8:
	.ascii "\033[8D" # length = 4
ANSI_clear_screen_move_cursor_home_white_background_black_foreground:
        .ascii "\033c\033[H\033[30m\033[107m" # length = 16
ANSI_clear_screen_move_cursor_home:
	.ascii "\033c\033[H" # length = 5
ANSI_move_cursor_home:
	.ascii "\033[H" # length = 3
line_break:
	.ascii "\n" # length = 1
ANSI_reset_color_line_break:
	.ascii "\033[0m\n" # length = 5
termios:
c_iflag:
	.long 0
c_oflag:
	.long 0
c_cflag:
	.long 0
c_lflag:
	.long 0
c_cc:
	.skip 20, 0
original_termios:
	.skip 36, 0
terminal_dimensions:
rows:
	.word 0
columns:
	.word 0
	.word 0
	.word 0
keyboard_input:
	.byte 0
scrolling_index:
	.quad 0
cursor_at_last_character_flag:
	.quad 0
cursor_at_first_column_msg:
	.ascii "Cursor_in first column!" # length = 23
debug:
	.ascii "Debugged!"
.text
.intel_syntax noprefix
.macro debug pointer length
	PUSH rax
	PUSH rdi
	PUSH rsi
	PUSH rdx
	MOV rax, 1
	MOV rdi, 1
	LEA rsi pointer
	MOV rdx, length
	SYSCALL
	POP rdx
	POP rsi
	POP rdi
	POP rax
.endm
.global _start
_start:
/* handle the command line arguments */
	CMP QWORD PTR [rsp], 2
	JE _start.two_typed_arguments
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, error_msg
	MOV rdx, 34
	SYSCALL
	JMP _start.exit
_start.two_typed_arguments:
	MOV rax, [rsp + 16]
_start.null_byte_not_found_when_finding_backslash:
	CMP BYTE PTR [rax], '/'
	JNE _start.backslash_not_found
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, error_msg
	MOV rdx, 34
	SYSCALL
	JMP _start.exit
_start.backslash_not_found:
	ADD rax, 1
	CMP BYTE PTR [rax], 0
        JNE _start.null_byte_not_found_when_finding_backslash
/* set default user interface */
	MOV rax, 1
	MOV rdi, 1
        LEA rsi, ANSI_clear_screen_move_cursor_home_white_background_black_foreground
        MOV rdx, 16
        SYSCALL
	MOV rax, [rsp + 16]
	MOV rbx, 0
_start.null_terminator_is_not_found0:
	ADD rax, 1
	ADD rbx, 1
	CMP BYTE PTR [rax], 0
	JNE _start.null_terminator_is_not_found0
	PUSH rbx
	MOV rax, 1
        MOV rdi, 1
        MOV rsi, [rsp + 24]
	POP rdx
	SYSCALL
	MOV rax, 1
        MOV rdi, 1
        LEA rsi, ANSI_reset_color_line_break
        MOV rdx, 5
	SYSCALL
	LEA rdi, working_directory
	MOV rsi, 255
	MOV rax, 79
	SYSCALL
	LEA rax, working_directory
_start.null_terminator_is_not_found1:
	ADD rax, 1
	CMP BYTE PTR [rax], 0
	JNE _start.null_terminator_is_not_found1
	MOV BYTE PTR [rax], '/'
	ADD rax, 1
	MOV rbx, [rsp + 16]
_start.second_argument_length_not_reached:
	MOV dl, [rbx]
	MOV BYTE PTR [rax], dl
        ADD rax, 1
	ADD rbx, 1
	CMP BYTE PTR [rbx], 0
        JNE _start.second_argument_length_not_reached
	LEA rdi, working_directory
        MOV rsi, 0
        MOV rdx, 0
        MOV rax, 2
	SYSCALL
	PUSH rax
	MOV r9, rax
	MOV rdi, rax
	LEA rsi, file_contents
	MOV rdx, 99998
        MOV rax, 0
        SYSCALL
	MOV rax, 3
        POP rdi
        SYSCALL
	LEA rax, file_contents
	MOV rbx, 0
_start.null_terminator_is_not_found2:
        ADD rax, 1
        ADD rbx, 1
        CMP BYTE PTR [rax], 0
        JNE _start.null_terminator_is_not_found2
	MOV QWORD PTR [file_length], rbx
	MOV rax, 16
	MOV rdi, 1
	MOV rsi, 0x5413
	LEA rdx, terminal_dimensions
	SYSCALL
	LEA rax, file_contents
	MOV rbx, 0
	LEA r9, file_contents
	MOV r10w, [rows]
	SUB r10w, 1
_start.print_file_contents:
	CMP BYTE PTR [rax], '\n'
	JNE _start.new_line_not_found
	PUSH rax
	PUSH rax
	MOV rax, 1
	MOV rdi, 1
	MOV rsi, r9
	MOV rdx, rbx
	SYSCALL
	POP r9
	MOV rbx, 0
	POP rax
	SUB r10w, 1
	CMP r10w, 0
	JE _start.null_byte_is_found
	ADD rax, 1
	ADD rbx, 1
	JMP _start.print_file_contents
_start.new_line_not_found:
	CMP BYTE PTR [rax] , 0
	JE _start.null_byte_is_found
	ADD rax, 1
	ADD rbx, 1
	JMP _start.print_file_contents
_start.null_byte_is_found:
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, ANSI_move_cursor_home
	MOV rdx, 3
	SYSCALL
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, ANSI_move_cursor_down
	MOV rdx, 4
	SYSCALL
	MOV rax, 16
	MOV rdi, 0
	MOV rsi, 0x5401
	LEA rdx, termios
	SYSCALL
	MOV rax, 16
	MOV rdi, 0
	MOV rsi, 0x5401
	LEA rdx, original_termios
	SYSCALL
/* set terminal mode to raw */
	MOV rax, 2
	NOT rax
	AND [c_cflag], rax
	MOV rax, 16
	MOV rdi, 0
	MOV rsi, 0x5406
	LEA rdx, termios
	SYSCALL
/* get user input */
_start.loop_normal:
	MOV rax, 0
	MOV rdi, 0
	LEA rsi, keyboard_input
	MOV rdx, 1
	SYSCALL
	CMP BYTE PTR [keyboard_input], 's'
	JE _start.s_pressed
	CMP BYTE PTR [keyboard_input], 'i'
	JE _start.i_pressed
	CMP BYTE PTR [keyboard_input], 27
        JNE _start.escape_sequence_not_pressed_normal
	MOV rax, 0
	MOV rdi, 0
	LEA rsi, keyboard_input
	MOV rdx, 1
	SYSCALL
	CMP BYTE PTR [keyboard_input], 27
	JE _start.escape_pressed_normal
	CMP BYTE PTR [keyboard_input], '['
	JNE _start.escape_sequence_not_pressed_normal
	MOV rax, 0
	MOV rdi, 0
	LEA rsi, keyboard_input
	MOV rdx, 1
	SYSCALL
	CMP BYTE PTR [keyboard_input], 'D'
	JE _start.left_arrow_pressed
	CMP BYTE PTR [keyboard_input], 'C'
	JE _start.right_arrow_pressed
	_start.escape_sequence_not_pressed_normal:
	MOV BYTE PTR [keyboard_input], 0
	JMP _start.loop_normal
_start.i_pressed:
	MOV BYTE PTR [keyboard_input], 0
	JMP _start.loop_insert
_start.s_pressed:
/* save file */
	MOV rax, 2
	LEA rdi, working_directory
	MOV rsi, 0b1001000001
	MOV rdx, 0b111111111
	SYSCALL
	PUSH rax
	MOV r10, rax
	LEA rax, file_contents
	MOV rbx, 0
_start.null_terminator_is_not_found3:
      	CMP BYTE PTR [rax], 0
       	JE _start.null_terminator_is_found
       	ADD rax, 1
       	ADD rbx, 1
	JMP _start.null_terminator_is_not_found3
_start.null_terminator_is_found:
	PUSH rbx
	MOV rdi, r10
	LEA rsi, file_contents
	POP rdx
	MOV rax, 1
	SYSCALL
	MOV rax, 3
	POP rdi
	SYSCALL
	MOV BYTE PTR [keyboard_input], 0
	JMP _start.loop_normal
_start.left_arrow_pressed:
/* set new user interface */
	CMP BYTE PTR [terminal_column_pointer], 1 # if cursor is not in first column
	JNE _start.move_cursor_left_not_in_first_column
	.debug cursor_at_first_column_msg 23
	CMP QWORD PTR [terminal_row_pointer], 2 # if cursor is on the second row
	JE _start.move_cursor_left_exit
	CMP QWORD PTR [terminal_row_pointer], 3 # if cursor is not in the 3 row
	JNE _start.move_cursor_left_cursor_column_is_not_3
	MOV rax, [file_contents_pointer]
	MOV QWORD PTR [terminal_column_pointer], -1
_start.move_cursor_left_loop0:
	SUB rax, 1
	ADD QWORD PTR [terminal_column_pointer], 1
	CMP BYTE PTR [rax], 0 # if end of file has been dectected
	JNE _start.move_cursor_left_loop0
	MOV r10, 1
_start.move_cursor_left_cursor_column_is_not_3:
	SUB QWORD PTR [terminal_row_pointer], 1
	LEA r12, position
	MOV r11, 2
	MOV rax, [terminal_row_pointer]
	CMP rax, 0
        JGE _start.integer_is_positive0
        NEG rax
        MOV r9, 1
_start.integer_is_positive0:
        LEA rcx, digits_msg_last_byte
        MOV rbx, 10
        MOV r10, 0
_start.quotient_is_not_null0:
        MOV rdx, 0
        DIV rbx
        ADD rdx, 48
        MOV [rcx], dl
        SUB rcx, 1
        ADD r10, 1
        CMP rax, 0
        JNE _start.quotient_is_not_null0
        CMP r9, 1
        JNE _start.integer_is_not_negative0
        MOV BYTE PTR [rcx], '-'
        SUB rcx, 1
        ADD r10, 1
_start.integer_is_not_negative0:
        ADD r10, 1
        MOV rax, rcx
        MOV rbx, r10
_start.move_cursor_left_row_string_length_not_found:
	MOV dl, [rax]
	MOV BYTE PTR [r12], dl
	ADD rax, 1
	ADD r12, 1
	ADD r11, 1
	SUB rbx, 1
	CMP rbx, 0 # loop until the integer string has been copied
	JNE _start.move_cursor_left_row_string_length_not_found
	CMP r10, 1
	JE _start.move_cursor_left_cursor_row_is_3
	MOV rax, [file_contents_pointer]
	SUB rax, 1
	MOV QWORD PTR [terminal_column_pointer], 0
_start.move_cursor_left_loop:
	SUB rax, 1
	ADD QWORD PTR [terminal_column_pointer], 1
	CMP BYTE PTR [rax], '\t'
	JNE _start.move_cursor_left_tab_not_found
	ADD QWORD PTR [terminal_column_pointer], 7
_start.move_cursor_left_tab_not_found:
	CMP BYTE PTR [rax], '\n'
	JNE _start.move_cursor_left_loop
_start.move_cursor_left_cursor_row_is_3:
	MOV BYTE PTR [r12], ';'
	ADD r12, 1
	ADD r11, 1
	MOV rax, [terminal_column_pointer]
	CMP rax, 0
        JGE _start.integer_is_positive1
        NEG rax
        MOV r9, 1
_start.integer_is_positive1:
        LEA rcx, digits_msg_last_byte
        MOV rbx, 10
        MOV r10, 0
_start.quotient_is_not_null1:
        MOV rdx, 0
        DIV rbx
        ADD rdx, 48
        MOV [rcx], dl
        SUB rcx, 1
        ADD r10, 1
        CMP rax, 0
        JNE _start.quotient_is_not_null1
        CMP r9, 1
        JNE _start.integer_is_not_negative1
        MOV BYTE PTR [rcx], '-'
        SUB rcx, 1
        ADD r10, 1
_start.integer_is_not_negative1:
        ADD r10, 1
        MOV rax, rcx
        MOV rbx, r10
_start.move_cursor_left_column_string_length_not_found:
	MOV dl, [rax]
	MOV BYTE PTR [r12], dl
	ADD rax, 1
	ADD r12, 1
	ADD r11, 1
	SUB rbx, 1
	CMP rbx, 0
	JNE _start.move_cursor_left_column_string_length_not_found
	MOV BYTE PTR [r12], 'H'
	ADD r11, 1
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, move_cursor
	MOV rdx, r11
	SYSCALL
	SUB QWORD PTR [file_contents_offset], 1
	SUB QWORD PTR [file_contents_pointer], 1
	JMP _start.move_cursor_left_exit
_start.move_cursor_left_not_in_first_column:
	MOV rax, [file_contents_pointer]
	SUB rax, 1
	CMP BYTE PTR [rax], '\t'
	JNE _start.move_cursor_left_tab_not_found0
	MOV rax, 1
       	MOV rdi, 1
       	LEA rsi, ANSI_move_cursor_left_by_8
	MOV rdx, 4
       	SYSCALL
	SUB QWORD PTR [terminal_column_pointer], 7
	JMP _start.move_cursor_left_handle_ram
_start.move_cursor_left_tab_not_found0:
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, ANSI_move_cursor_left
	MOV rdx, 4
	SYSCALL
	CMP QWORD PTR [cursor_at_last_character_flag], 1
	JE _start.move_cursor_left_exit
_start.move_cursor_left_handle_ram:
	SUB QWORD PTR [terminal_column_pointer], 1
	SUB QWORD PTR [file_contents_offset], 1 
	SUB QWORD PTR [file_contents_pointer], 1
_start.move_cursor_left_exit:
	MOV QWORD PTR [cursor_at_last_character_flag], 0
	MOV BYTE PTR [keyboard_input], 0
	JMP _start.loop_normal
_start.right_arrow_pressed:
	MOV rax, [file_length]
	CMP QWORD PTR [file_contents_offset], rax # if cursor is at the length of the file
	JE _start.move_cursor_right_exit
	MOV rax, 0
	MOV ax, [rows]
	CMP [terminal_row_pointer], rax # if cursor is at the last terminal row
	JE _start.move_cursor_right_last_row_reached
	MOV rax, [file_contents_pointer]
	CMP BYTE PTR [rax], '\n' # if cursor points to a line break
	JE _start.move_cursor_right_line_break_at_cursor_position
       	CMP BYTE PTR [rax], '\t' # if cursor does not point to a tab
       	JNE _start.move_cursor_right_tab_not_found0
	ADD QWORD PTR [terminal_column_pointer], 7
_start.move_cursor_right_tab_not_found0:
	MOV rax, 1
       	MOV rdi, 1
       	MOV rsi, [file_contents_pointer]
       	MOV rdx, 1
       	SYSCALL
	ADD QWORD PTR [terminal_column_pointer], 1
       	ADD QWORD PTR [file_contents_offset], 1
       	ADD QWORD PTR [file_contents_pointer], 1
       	JMP _start.move_cursor_right_exit
_start.move_cursor_right_last_row_reached:
	MOV rax, [file_contents_pointer]
	MOV rbx, [terminal_column_pointer]
_start.move_cursor_right_finding_line_break_line_break_not_found:
	ADD rax, 1
	ADD rbx, 1
	CMP BYTE PTR [rax], '\t'
	JNE _start.move_cursor_right_tab_not_found # if 
	ADD rbx, 7
	JMP _start.move_cursor_right_finding_line_break_line_break_not_found
_start.move_cursor_right_tab_not_found:
	CMP BYTE PTR [rax], '\n' 
	JNE _start.move_cursor_right_finding_line_break_line_break_not_found
	MOV rax, [terminal_column_pointer]
	ADD rax, 1
	CMP rax, rbx
	JE _start.move_cursor_right
	ADD QWORD PTR [terminal_column_pointer], 1	
	MOV rax, [file_contents_pointer]
	CMP BYTE PTR [rax], '\t'
	JNE _start.move_cursor_right_tab_not_found00
	ADD QWORD PTR [terminal_column_pointer], 7
_start.move_cursor_right_tab_not_found00:
	MOV rax, 1
	MOV rdi, 1
	MOV rsi, [file_contents_pointer]
	MOV rdx, 1
	SYSCALL
	ADD QWORD PTR [terminal_column_pointer], 1
	ADD QWORD PTR [file_contents_offset], 1
	ADD QWORD PTR [file_contents_pointer], 1
	JMP _start.move_cursor_right_exit
_start.move_cursor_right_line_break_at_cursor_position:
	ADD QWORD PTR [terminal_row_pointer], 1
	LEA r12, position
	MOV r11, 2
	MOV rax, [terminal_row_pointer]
	CMP rax, 0
	JGE _start.integer_is_positive2
	NEG rax
	MOV r9, 1
_start.integer_is_positive2:
        LEA rcx, digits_msg_last_byte
       	MOV rbx, 10
	MOV r10, 0
_start.quotient_is_not_null2:
       	MOV rdx, 0
       	DIV rbx
       	ADD rdx, 48
	MOV [rcx], dl
       	SUB rcx, 1
	ADD r10, 1
       	CMP rax, 0
       	JNE _start.quotient_is_not_null2
	CMP r9, 1
	JNE _start.integer_is_not_negative2
	MOV BYTE PTR [rcx], '-'
	SUB rcx, 1
	ADD r10, 1
_start.integer_is_not_negative2:
	ADD r10, 1
	MOV rax, rcx
	MOV rbx, r10
_start.move_cursor_right_string_length_not_reached:
	MOV dl, [rax]
	MOV BYTE PTR [r12], dl
	ADD rax, 1
	ADD r12, 1
	ADD r9, 1
	SUB rbx, 1
	CMP rbx, 0
	JNE _start.move_cursor_right_string_length_not_reached
	MOV BYTE PTR [r12], ';'
	ADD rcx, 1
	MOV BYTE PTR [r12], '1'
	ADD rcx, 1
	MOV BYTE PTR [r12], 'H'
	ADD r11, 3
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, move_cursor
	MOV rdx, r11
	SYSCALL
	ADD QWORD PTR [file_contents_offset], 1
	MOV QWORD PTR [terminal_column_pointer], 1
	ADD QWORD PTR [file_contents_pointer], 1
	JMP _start.move_cursor_right_exit
_start.move_cursor_right:
	CMP QWORD PTR [cursor_at_last_character_flag], 1
	JE _start.move_cursor_right_exit
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, ANSI_move_cursor_right
	MOV rdx, 4
	SYSCALL
	ADD QWORD PTR [terminal_column_pointer], 1
	MOV QWORD PTR [cursor_at_last_character_flag], 1
_start.move_cursor_right_exit:
	MOV BYTE PTR [keyboard_input], 0
	JMP _start.loop_normal
_start.loop_insert:
/* get user input */
	MOV rax, 0
	MOV rdi, 0
	LEA rsi, keyboard_input
	MOV rdx, 1
	SYSCALL
	CMP BYTE PTR [keyboard_input], 27
	JNE _start.escape_sequence_not_pressed_insert	
	MOV rax, 0
	MOV rdi, 0
	LEA rsi, keyboard_input
	MOV rdx, 1
	SYSCALL
	CMP BYTE PTR [keyboard_input], 27
	JE _start.escape_pressed_insert
	CMP BYTE PTR [keyboard_input], '['
	JNE _start.escape_sequence_not_pressed_insert
	MOV BYTE PTR [keyboard_input], 0
	JMP _start.loop_insert
_start.escape_sequence_not_pressed_insert:
/* set new user interface */
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, keyboard_input
	MOV rdx, 1
	SYSCALL
	MOV BYTE PTR [keyboard_input], 0
	JMP _start.loop_insert
_start.escape_pressed_insert:
	MOV BYTE PTR [keyboard_input], 0
	JMP _start.loop_normal
_start.escape_pressed_normal:
/* set terminal mode to cooked */
	MOV rax, 16
      	MOV rdi, 1
	MOV rsi, 0x5403
       	LEA rdx, original_termios
       	SYSCALL
/* set new user interface */
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, ANSI_clear_screen_move_cursor_home
	MOV rdx, 5
	SYSCALL
_start.exit:
/* exit the program */
	MOV rdi, 0
	MOV rax, 60
	SYSCALL
/*
Input:
	rax = integer
*/
print_integer_at_cursor_position:
	PUSH rcx
        PUSH rdx
        PUSH r9
        PUSH r10
	PUSH rax
	PUSH rdi
	PUSH rsi
        CMP rax, 0
        JGE print_integer_at_cursor_position.integer_is_positive
        NEG rax
        MOV r9, 1
print_integer_at_cursor_position.integer_is_positive:
        LEA rcx, digits_msg_last_byte
        MOV rbx, 10
        MOV r10, 0
print_integer_at_cursor_position.quotient_is_not_null:
        MOV rdx, 0
        DIV rbx
        ADD rdx, 48
        MOV [rcx], dl
        SUB rcx, 1
        ADD r10, 1
        CMP rax, 0
        JNE print_integer_at_cursor_position.quotient_is_not_null
        CMP r9, 1
        JNE print_integer_at_cursor_position.integer_is_not_negative
        MOV BYTE PTR [rcx], '-'
	SUB rcx, 1
	ADD r10, 1
print_integer_at_cursor_position.integer_is_not_negative:
	ADD r10, 1
	PUSH r10
        PUSH rcx
	MOV rax, 1
	MOV rdi, 1
	POP rsi
	POP rdx
	SYSCALL
	POP rsi
	POP rdi
	POP rax
        POP r10
        POP r9
        POP rdx
        POP rcx
        RET
