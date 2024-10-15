.data
file_contents_offset:
	.quad 0
move_cursor:
	.ascii "\033["
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
ANSI_white_background_black_foregound:
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
ANSI_clear_screen_move_cursor_home_white_background_black_foregound:
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
.text

.intel_syntax noprefix

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
        LEA rsi, ANSI_clear_screen_move_cursor_home_white_background_black_foregound
        MOV rdx, 16
        SYSCALL

	MOV rax, [rsp + 16]
	CALL get_null_terminated_buffer_length

	PUSH rax

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
	CALL get_null_terminated_buffer_length

	LEA rbx, working_directory

	ADD rbx, rax

	MOV BYTE PTR [rbx], '/'

	ADD rbx, 1

	MOV rax, [rsp + 16]
	CALL get_null_terminated_buffer_length

	MOV rcx, rax
	MOV rax, [rsp + 16]
	CALL copy_ram

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
	CALL get_null_terminated_buffer_length

	MOV QWORD PTR [file_length], rax

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
_start.loop:

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

	JMP _start.loop
_start.new_line_not_found:

	CMP BYTE PTR [rax] , 0
	JE _start.null_byte_is_found

	ADD rax, 1

	ADD rbx, 1

	JMP _start.loop
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
	CALL get_null_terminated_buffer_length

	PUSH rax

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

	CMP BYTE PTR [terminal_column_pointer], 1
        JNE _start.move_cursor_left_not_in_first_column

	CMP QWORD PTR [terminal_row_pointer], 2
	JE _start.move_cursor_left_exit

	CMP QWORD PTR [terminal_row_pointer], 3
	JNE _start.move_cursor_left_cursor_column_is_not_3

	MOV r10, 1

_start.move_cursor_left_cursor_column_is_not_3:

	SUB QWORD PTR [terminal_row_pointer], 1

	LEA rcx, position

	MOV r9, 2

	MOV rax, [terminal_row_pointer]
	CALL integer_to_string

_start.move_cursor_left_row_string_length_not_found:

	MOV dl, [rax]

	MOV BYTE PTR [rcx], dl

	ADD rax, 1

	ADD rcx, 1

	ADD r9, 1

	SUB rbx, 1

	CMP rbx, 0
	JNE _start.move_cursor_left_row_string_length_not_found

	CMP r10, 1
	JE _start.move_cursor_left_cursor_row_is_3

	MOV rax, [file_contents_pointer]

	SUB rax, 1

	MOV QWORD PTR [terminal_column_pointer], 0

_start.move_cursor_left_loop:

	SUB rax, 1

	ADD QWORD PTR [terminal_column_pointer], 1

	CMP BYTE PTR [rax], '\n'
	JNE _start.move_cursor_left_loop

	JMP _start.move_cursor_left_continue

_start.move_cursor_left_cursor_row_is_3:

	MOV rax, [file_contents_pointer]

	MOV QWORD PTR [terminal_column_pointer], -1

_start.move_cursor_left_loop1:

	SUB rax, 1

	ADD QWORD PTR [terminal_column_pointer], 1

	CMP BYTE PTR [rax], 0
	JNE _start.move_cursor_left_loop1

_start.move_cursor_left_continue:

	MOV BYTE PTR [rcx], ';'

	ADD rcx, 1

	ADD r9, 1

	MOV rax, [terminal_column_pointer]
	CALL integer_to_string

_start.move_cursor_left_column_string_length_not_found:

	MOV dl, [rax]

	MOV BYTE PTR [rcx], dl

	ADD rax, 1

	ADD rcx, 1

	ADD r9, 1

	SUB rbx, 1

	CMP rbx, 0
	JNE _start.move_cursor_left_column_string_length_not_found

	MOV BYTE PTR [rcx], 'H'

	ADD r9, 1

	MOV rax, 1
	MOV rdi, 1
	LEA rsi, move_cursor
	MOV rdx, r9
	SYSCALL

	SUB QWORD PTR [file_contents_offset], 1

	SUB QWORD PTR [file_contents_pointer], 1

	JMP _start.move_cursor_left_exit

_start.move_cursor_left_not_in_first_column:

	MOV rax, 1
	MOV rdi, 1
	LEA rsi, ANSI_move_cursor_left
	MOV rdx, 4
	SYSCALL

	SUB QWORD PTR [file_contents_offset], 1 

	SUB QWORD PTR [file_contents_pointer], 1

	SUB QWORD PTR [terminal_column_pointer], 1

_start.move_cursor_left_exit:

	MOV BYTE PTR [keyboard_input], 0

	JMP _start.loop_normal

_start.right_arrow_pressed:

	MOV rax, [file_length]

	SUB rax, 1

	CMP QWORD PTR [file_contents_offset], rax
	JE _start.move_cursor_right_exit

	MOV rax, 0

	MOV ax, [rows]

	CMP [terminal_row_pointer], rax
	JNE _start.move_cursor_right_last_row_not_reached

	MOV rax, [file_contents_pointer]

	ADD rax, 1

	MOV rbx, 1 

_start.move_cursor_right_finding_line_break_line_break_not_found:

	ADD rax, 1

	ADD rbx, 1

	CMP BYTE PTR [rax], '\n' 
	JNE _start.move_cursor_right_finding_line_break_line_break_not_found

	CMP QWORD PTR [terminal_column_pointer], rbx
	JE _start.move_cursor_right_exit

	JMP _start.move_cursor_right_print_selected_char

_start.move_cursor_right_last_row_not_reached:

	MOV rax, [file_contents_pointer]

	CMP BYTE PTR [rax], '\n'
	JE _start.move_cursor_right_new_line_is_found

_start.move_cursor_right_print_selected_char:

	MOV rax, 1
	MOV rdi, 1
	MOV rsi, [file_contents_pointer]
	MOV rdx, 1
	SYSCALL

	ADD QWORD PTR [file_contents_offset], 1

	ADD QWORD PTR [file_contents_pointer], 1

	ADD QWORD PTR [terminal_column_pointer], 1

	JMP _start.move_cursor_right_exit

_start.move_cursor_right_new_line_is_found:

	ADD QWORD PTR [terminal_row_pointer], 1

	LEA rcx, position

	MOV r9, 2

	MOV rax, [terminal_row_pointer]
	CALL integer_to_string

_start.move_cursor_right_string_length_not_reached:

	MOV dl, [rax]

	MOV BYTE PTR [rcx], dl

	ADD rax, 1

	ADD rcx, 1

	ADD r9, 1

	SUB rbx, 1

	CMP rbx, 0
	JNE _start.move_cursor_right_string_length_not_reached

	MOV BYTE PTR [rcx], ';'

	ADD rcx, 1

	MOV BYTE PTR [rcx], '1'

	ADD rcx, 1

	MOV BYTE PTR [rcx], 'H'

	ADD r9, 3

	MOV rax, 1
	MOV rdi, 1
	LEA rsi, move_cursor
	MOV rdx, r9
	SYSCALL

	ADD QWORD PTR [file_contents_offset], 1

	MOV QWORD PTR [terminal_column_pointer], 1

	ADD QWORD PTR [file_contents_pointer], 1

_start.move_cursor_right_exit:

	MOV BYTE PTR [keyboard_input], 0

	JMP _start.loop_normal
_start.page_down_pressed:
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
Output:
        rax = pointer to string
	rbx = length of string
*/
integer_to_string:
        PUSH rcx
        PUSH rdx
	PUSH r9
	PUSH r10
	CMP rax, 0
	JGE integer_to_string.integer_is_positive
	NEG rax
	MOV r9, 1
integer_to_string.integer_is_positive:
        LEA rcx, digits_msg_last_byte
        MOV rbx, 10
	MOV r10, 0
integer_to_string.quotient_is_not_null:
        MOV rdx, 0
        DIV rbx
        ADD rdx, 48
	MOV [rcx], dl
        SUB rcx, 1
	ADD r10, 1
        CMP rax, 0
        JNE integer_to_string.quotient_is_not_null
	CMP r9, 1
	JNE integer_to_string.integer_is_not_negative
	MOV BYTE PTR [rcx], '-'
integer_to_string.integer_is_not_negative:
	ADD rcx, 1
	MOV rax, rcx
	MOV rbx, r10
	POP r10
	POP r9
        POP rdx
        POP rcx
        RET

/*
Input:
        rax = pointer to null terminated buffer
Output:
        rax = null terminated buffer length
*/
get_null_terminated_buffer_length:
	PUSH rbx
	MOV rbx, 0
get_null_terminated_buffer_length.null_terminator_is_not_found:
	ADD rax, 1
	ADD rbx, 1
	CMP BYTE PTR [rax], 0
	JNE get_null_terminated_buffer_length.null_terminator_is_not_found
	MOV rax, rbx
	POP rbx
	RET

/*
Input:
        rax = pointer to source
        rbx = pointer to destination
	rcx = length
*/
copy_ram:
        PUSH rcx
	PUSH rbx
	PUSH rax
	PUSH rdx
copy_ram.copying_memory:
	MOV dl, [rax]
        MOV BYTE PTR [rbx], dl
        ADD rax, 1
        ADD rbx, 1
	SUB rcx, 1
	CMP rcx, 0
        JNE copy_ram.copying_memory
	POP rdx
        POP rax
	POP rbx
	POP rcx
        RET
