.intel_syntax noprefix
.global main
main:
	PUSH rsi
	PUSH rdi
	LEA rdi, log_file.path
        MOV rsi, 255
        MOV rax, 79
        SYSCALL
	LEA rax, log_file.path
main.null_terminator_byte_is_not_found1:
        ADD rax, 1
        CMP BYTE PTR [rax], 0
        JNE main.null_terminator_byte_is_not_found1
        MOV BYTE PTR [rax], '/'
        ADD rax, 1
	LEA rbx, log_file.name
	MOV rcx, 6
main.log_filename_length_not_reached:
        MOV dl, [rbx]
        MOV BYTE PTR [rax], dl
        ADD rax, 1
        ADD rbx, 1
	SUB rcx, 1
        CMP rcx, 0
        JNE main.log_filename_length_not_reached
	MOV rax, 2
        LEA rdi, log_file.path
        MOV rsi, 0b10001000001
        MOV rdx, 0b111111111
        SYSCALL
	MOV QWORD PTR [log_file.descriptor], rax
	PUSH rax
	PUSH rbx
	LEA rax, log.entering_te_at_address
	MOV rbx, 24
	CALL write_log
	LEA rax, main
	CALL integer_to_string
	CALL write_log
	LEA rax, line_break
	MOV rbx, 1
	CALL write_log
	POP rbx
	POP rax
	POP rdi
	CMP rdi, 2
	JE main.two_typed_arguments
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, error_msg.args_count
	MOV rdx, 60
	SYSCALL
	LEA rax, log.2_command_line_arguments_were_not_entered
	MOV rbx, 43
	CALL write_log
	LEA rax, log.exiting_te_with_exit_status_code
        MOV rbx, 33
        CALL write_log
	LEA rax, log.1
	MOV rbx, 4
	CALL write_log
	CALL close_log
	MOV rdi, 1
	CALL exit
main.two_typed_arguments:
	PUSH rax
        PUSH rbx
	LEA rax, log.2_command_line_arguments_were_entered
	MOV rbx, 39
	CALL write_log
	LEA rax, log.looking_for_a_forwardslash_on_the_second_command_line_argument
	MOV rbx, 64
	CALL write_log
        POP rbx
        POP rax
	POP rsi
	MOV rsi, [rsi + 8]
	MOV QWORD PTR [second_command_line_argument_pointer], rsi
main.null_byte_not_found_when_finding_backslash:
	CMP BYTE PTR [rsi], '/'
	JNE main.backslash_not_found
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, error_msg.forwardslash
	MOV rdx, 45
	SYSCALL
	LEA rax, log.exiting_te_with_exit_status_code
        MOV rbx, 33
        CALL write_log
	LEA rax, log.2
	MOV rbx, 4
	CALL write_log
	CALL close_log
	MOV rdi, 2
	CALL exit
main.backslash_not_found:
	ADD rsi, 1
	CMP BYTE PTR [rsi], 0
        JNE main.null_byte_not_found_when_finding_backslash
	PUSH rax
        PUSH rbx
	LEA rax, log.printing_the_command_line_interface
	MOV rbx, 37
	CALL write_log
        POP rbx
        POP rax
	MOV rax, 1
	MOV rdi, 1
        LEA rsi, ANSI.clear_screen_move_cursor_home_white_background_black_foreground
        MOV rdx, 16
        SYSCALL
	MOV rax, [second_command_line_argument_pointer]
	MOV rbx, 0
	PUSH rax
	PUSH rbx
	LEA rax, log.getting_the_length_of_the_second_command_line_argument
	MOV rbx, 56
	CALL write_log
	POP rbx
	POP rax
main.null_terminator_is_not_found0:
	ADD rax, 1
	ADD rbx, 1
	CMP BYTE PTR [rax], 0
	JNE main.null_terminator_is_not_found0
	PUSH rbx
	MOV rax, 1
        MOV rdi, 1
        MOV rsi, [second_command_line_argument_pointer]
	POP rdx
	SYSCALL
	MOV rax, 1
        MOV rdi, 1
        LEA rsi, ANSI.reset_color_line_break
        MOV rdx, 5
	SYSCALL
	PUSH rax
	PUSH rbx
	LEA rax, log.copying_the_working_directory_character_array_to_the_file.path_buffer
	MOV rbx, 71
	CALL write_log
	POP rbx
	POP rax
	LEA rdi, file.path
	MOV rsi, 255
	MOV rax, 79
	SYSCALL
	PUSH rax
        PUSH rbx
        LEA rax, log.getting_the_last_character_of_the_working_directory_buffer
        MOV rbx, 60
        CALL write_log
        POP rbx
        POP rax
	LEA rax, file.path
main.null_terminator_is_not_found1:
	ADD rax, 1
	CMP BYTE PTR [rax], 0
	JNE main.null_terminator_is_not_found1
	PUSH rax
        PUSH rbx
	LEA rax, log.creating_the_full_path_by_adding_forward_slash_and_the_second_command_line_argument_to_the_file.path_buffer
	MOV rbx,  109
	CALL write_log
        POP rbx 
        POP rax
	MOV BYTE PTR [rax], '/'
	ADD rax, 1
	MOV rbx, [second_command_line_argument_pointer]
main.second_argument_length_not_reached:
	MOV dl, [rbx]
	MOV BYTE PTR [rax], dl
        ADD rax, 1
	ADD rbx, 1
	CMP BYTE PTR [rbx], 0
        JNE main.second_argument_length_not_reached
	PUSH rax
	PUSH rbx
	LEA rax, log.opening_file
	MOV rbx, 14
	CALL write_log
	POP rbx
	POP rax
	LEA rdi, file.path
	MOV rsi, 0
        MOV rdx, 0
        MOV rax, 2
	SYSCALL
	PUSH rax
	PUSH rbx
	LEA rax, log.reading_file
	MOV rbx, 14
	CALL write_log
	POP rbx
	POP rax
	PUSH rax
	MOV r9, rax
	MOV rdi, rax
	LEA rsi, file.contents
	MOV rdx, 99998
        MOV rax, 0
        SYSCALL
	PUSH rax
	PUSH rbx
	LEA rax, log.close_file
	MOV rbx, 14
	CALL write_log
	POP rbx
	POP rax
	MOV rax, 3
        POP rdi
        SYSCALL
	PUSH rax
	PUSH rbx
	LEA rax, log.get_the_file_length
	MOV rbx, 25
	CALL write_log
	POP rbx
	POP rax
	LEA rax, file.contents
	MOV rbx, 0
main.finding_null_byte:
        CMP BYTE PTR [rax], 0
        JE main.null_byte_found
        ADD rax, 1
        ADD rbx, 1
	JMP main.finding_null_byte
main.null_byte_found:
	MOV QWORD PTR [file.length], rbx
	PUSH rax
	PUSH rbx
	LEA rax, log.getting_terminal_dimensions
	MOV rbx, 29
	CALL write_log
	POP rbx
	POP rax
	MOV rax, 16
	MOV rdi, 1
	MOV rsi, 0x5413
	LEA rdx, terminal.rows
	SYSCALL
	PUSH rax
	PUSH rbx
	LEA rax, log.printing_the_command_line_interface
	MOV rbx, 37
	CALL write_log
	POP rbx
	POP rax
	LEA rax, file.contents
	MOV rbx, 0
	LEA r9, file.contents
	MOV r10w, [terminal.rows]
	SUB r10w, 1
main.print_file_contents:
	CMP BYTE PTR [rax], '\n'
	JNE main.new_line_not_found
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
	JE main.null_byte_is_found
	ADD rax, 1
	ADD rbx, 1
	JMP main.print_file_contents
main.new_line_not_found:
	CMP BYTE PTR [rax] , 0
	JE main.null_byte_is_found
	ADD rax, 1
	ADD rbx, 1
	JMP main.print_file_contents
main.null_byte_is_found:
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, ANSI.move_cursor_home
	MOV rdx, 3
	SYSCALL
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, ANSI.move_cursor_down
	MOV rdx, 4
	SYSCALL
	PUSH rax
	PUSH rbx
	LEA rax, log.getting_terminal_settings
	MOV rbx, 27
	CALL write_log
	POP rbx
	POP rax
	MOV rax, 16
	MOV rdi, 0
	MOV rsi, 0x5401
	LEA rdx, termios.c_iflag
	SYSCALL
	MOV rax, 16
	MOV rdi, 0
	MOV rsi, 0x5401
	LEA rdx, original_termios
	SYSCALL
	PUSH rax
	PUSH rbx
	LEA rax, log.setting_terminal_settings
	MOV rbx, 27
	CALL write_log
	POP rbx
	POP rax
	MOV rax, 2
	NOT rax
	AND [termios.c_cflag], rax
	MOV rax, 16
	MOV rdi, 0
	MOV rsi, 0x5406
	LEA rdx, termios.c_iflag
	SYSCALL
	PUSH rax
	PUSH rbx
	LEA rax, log.entering_normal_event_loop
	MOV rbx, 28
	CALL write_log
	POP rbx
	POP rax
main.loop_normal:
	MOV rax, 0
	MOV rdi, 0
	LEA rsi, keyboard_input
	MOV rdx, 1
	SYSCALL
	CMP BYTE PTR [keyboard_input], 's'
	JE main.s_pressed
	CMP BYTE PTR [keyboard_input], 'i'
	JE main.i_pressed
	CMP BYTE PTR [keyboard_input], 27
        JNE main.escape_sequence_not_pressed_normal
	MOV rax, 0
	MOV rdi, 0
	LEA rsi, keyboard_input
	MOV rdx, 1
	SYSCALL
	CMP BYTE PTR [keyboard_input], 27
	JE main.escape_pressed_normal
	CMP BYTE PTR [keyboard_input], '['
	JNE main.escape_sequence_not_pressed_normal
	MOV rax, 0
	MOV rdi, 0
	LEA rsi, keyboard_input
	MOV rdx, 1
	SYSCALL
	CMP BYTE PTR [keyboard_input], 'D'
	JE main.left_arrow_pressed
	CMP BYTE PTR [keyboard_input], 'C'
	JE main.right_arrow_pressed
main.escape_sequence_not_pressed_normal:
	MOV BYTE PTR [keyboard_input], 0
	JMP main.loop_normal
main.i_pressed:
	PUSH rax
        PUSH rbx
        LEA rax, log.entering_insert_event_loop
        MOV rbx, 28
        CALL write_log
        POP rbx
        POP rax
	MOV BYTE PTR [keyboard_input], 0
	JMP main.loop_insert
main.s_pressed:
	PUSH rax
        PUSH rbx
	LEA rax, log.saving_the_file
	MOV rbx, 17
        CALL write_log
        POP rbx
        POP rax
	MOV rax, 2
	LEA rdi, file.path
	MOV rsi, 0b1001000001
	MOV rdx, 0b111111111
	SYSCALL
	MOV QWORD PTR [file.descriptor], rax
	LEA rax, file.contents
main.null_terminator_is_not_found3:
      	CMP BYTE PTR [rax], 0
       	JE main.null_terminator_is_found
       	ADD rax, 1
       	ADD rbx, 1
	JMP main.null_terminator_is_not_found3
main.null_terminator_is_found:
	PUSH rbx
	MOV rdi, [file.descriptor]
	LEA rsi, file.contents
	POP rdx
	MOV rax, 1
	SYSCALL
	MOV rax, 3
	MOV rdi, [file.descriptor]
	SYSCALL
	MOV BYTE PTR [keyboard_input], 0
	JMP main.loop_normal
main.left_arrow_pressed:
	PUSH rax
	PUSH rbx
	LEA rax, log.left_arrow_key_was_pressed
	MOV rbx, 28
	CALL write_log
	POP rbx
	POP rax
	CMP QWORD PTR [terminal.column_pointer], 1
	JNE main.move_cursor_left_not_in_first_column
	PUSH rax
        PUSH rbx
        LEA rax, log.cursor_position_is_column_1
        MOV rbx, 30
        CALL write_log
        POP rbx
        POP rax
	CMP QWORD PTR [terminal.row_pointer], 2
	JE main.move_cursor_left_exit
	PUSH rax
        PUSH rbx
        LEA rax, log.cursor_position_is_not_row_2
        MOV rbx, 31
        CALL write_log
        POP rbx
        POP rax
	CMP QWORD PTR [terminal.row_pointer], 3
	JNE main.move_cursor_left_cursor_row_is_not_3
	PUSH rax
	PUSH rbx
	LEA rax, log.cursor_position_is_row_3
	MOV rbx, 27
	CALL write_log
	POP rbx
	POP rax
	PUSH rax
	PUSH rbx
	LEA rax, log.getting_the_length_of_the_anterior_line_relative_to_cursor_position
	MOV rbx, 70
	CALL write_log
	POP rbx
	POP rax
	MOV rax, [file.contents_pointer]
	MOV QWORD PTR [terminal.column_pointer], -1
main.move_cursor_left_loop0:
	SUB rax, 1
	ADD QWORD PTR [terminal.column_pointer], 1
	CMP BYTE PTR [rax], 0
	JNE main.move_cursor_left_loop0
	MOV r10, 1
main.move_cursor_left_cursor_row_is_not_3:
	PUSH rax
	PUSH rbx
	LEA rax, log.cursor_position_is_not_row_3
	MOV rbx, 30
	CALL write_log
	LEA rax, log.convert_long_cursor_position_to_string
	MOV rbx, 43
	CALL write_log
	POP rbx
	POP rax
	SUB QWORD PTR [terminal.row_pointer], 1
	LEA r12, position
	MOV r11, 2
	MOV rax, [terminal.row_pointer]
	CALL integer_to_string
	PUSH rax
	PUSH rbx
	LEA rax, log.copying_ram_from_digits_msg_buffer_to_the_position_buffer
	MOV rbx, 59
	CALL write_log
	POP rbx
	POP rax
main.move_cursor_left_row_string_length_not_found:
	MOV dl, [rax]
	MOV BYTE PTR [r12], dl
	ADD rax, 1
	ADD r12, 1
	ADD r11, 1
	SUB rbx, 1
	CMP rbx, 0
	JNE main.move_cursor_left_row_string_length_not_found
	CMP r10, 1
	JE main.move_cursor_left_cursor_row_is_3
	PUSH rax
	PUSH rbx
	LEA rax, 
	POP rbx
	POP rax
	MOV rax, [file.contents_pointer]
	SUB rax, 1
	MOV QWORD PTR [terminal.column_pointer], 0
main.move_cursor_left_loop:
	SUB rax, 1
	ADD QWORD PTR [terminal.column_pointer], 1
	CMP BYTE PTR [rax], '\t'
	JNE main.move_cursor_left_tab_not_found
	ADD QWORD PTR [terminal.column_pointer], 7
main.move_cursor_left_tab_not_found:
	CMP BYTE PTR [rax], '\n'
	JNE main.move_cursor_left_loop
main.move_cursor_left_cursor_row_is_3:
	MOV BYTE PTR [r12], ';'
	ADD r12, 1
	ADD r11, 1
	MOV rax, [terminal.column_pointer]
	CALL integer_to_string
main.move_cursor_left_column_string_length_not_found:
	MOV dl, [rax]
	MOV BYTE PTR [r12], dl
	ADD rax, 1
	ADD r12, 1
	ADD r11, 1
	SUB rbx, 1
	CMP rbx, 0
	JNE main.move_cursor_left_column_string_length_not_found
	MOV BYTE PTR [r12], 'H'
	ADD r11, 1
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, move_cursor
	MOV rdx, r11
	SYSCALL
	SUB QWORD PTR [file.contents_offset], 1
	SUB QWORD PTR [file.contents_pointer], 1
	JMP main.move_cursor_left_exit
main.move_cursor_left_not_in_first_column:
	MOV rax, [file.contents_pointer]
	SUB rax, 1
	CMP BYTE PTR [rax], '\t'
	JNE main.move_cursor_left_tab_not_found0
	MOV rax, 1
       	MOV rdi, 1
       	LEA rsi, ANSI.move_cursor_left_by_8
	MOV rdx, 4
       	SYSCALL
	SUB QWORD PTR [terminal.column_pointer], 7
	JMP main.move_cursor_left_handle_ram
main.move_cursor_left_tab_not_found0:
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, ANSI.move_cursor_left
	MOV rdx, 4
	SYSCALL
	CMP QWORD PTR [cursor_at_last_character_flag], 1
	JE main.move_cursor_left_exit
main.move_cursor_left_handle_ram:
	SUB QWORD PTR [terminal.column_pointer], 1
	SUB QWORD PTR [file.contents_offset], 1 
	SUB QWORD PTR [file.contents_pointer], 1
main.move_cursor_left_exit:
	MOV QWORD PTR [cursor_at_last_character_flag], 0
	MOV BYTE PTR [keyboard_input], 0
	JMP main.loop_normal
main.right_arrow_pressed:
	PUSH rax
	PUSH rbx
	LEA rax, log.right_arrow_key_was_pressed
	MOV rbx, 29
	CALL write_log
	POP rbx
	POP rax
	MOV rax, [file.length]
	CMP QWORD PTR [file.contents_offset], rax
	JE main.move_cursor_right_exit
	MOV rax, 0
	MOV ax, [terminal.rows]
	CMP [terminal.row_pointer], rax
	JE main.move_cursor_right_last_row_reached
	MOV rax, [file.contents_pointer]
	CMP BYTE PTR [rax], '\n'
	JE main.move_cursor_right_line_break_at_cursor_position
       	CMP BYTE PTR [rax], '\t'
       	JNE main.move_cursor_right_tab_not_found0
	ADD QWORD PTR [terminal.column_pointer], 7
main.move_cursor_right_tab_not_found0:
	MOV rax, 1
       	MOV rdi, 1
       	MOV rsi, [file.contents_pointer]
       	MOV rdx, 1
       	SYSCALL
	ADD QWORD PTR [terminal.column_pointer], 1
       	ADD QWORD PTR [file.contents_offset], 1
       	ADD QWORD PTR [file.contents_pointer], 1
       	JMP main.move_cursor_right_exit
main.move_cursor_right_last_row_reached:
	MOV rax, [file.contents_pointer]
	MOV rbx, [terminal.column_pointer]
main.move_cursor_right_finding_line_break_line_break_not_found:
	ADD rax, 1
	ADD rbx, 1
	CMP BYTE PTR [rax], '\t'
	JNE main.move_cursor_right_tab_not_found # if 
	ADD rbx, 7
	JMP main.move_cursor_right_finding_line_break_line_break_not_found
main.move_cursor_right_tab_not_found:
	CMP BYTE PTR [rax], '\n' 
	JNE main.move_cursor_right_finding_line_break_line_break_not_found
	MOV rax, [terminal.column_pointer]
	ADD rax, 1
	CMP rax, rbx
	JE main.move_cursor_right
	ADD QWORD PTR [terminal.column_pointer], 1	
	MOV rax, [file.contents_pointer]
	CMP BYTE PTR [rax], '\t'
	JNE main.move_cursor_right_tab_not_found00
	ADD QWORD PTR [terminal.column_pointer], 7
main.move_cursor_right_tab_not_found00:
	MOV rax, 1
	MOV rdi, 1
	MOV rsi, [file.contents_pointer]
	MOV rdx, 1
	SYSCALL
	ADD QWORD PTR [terminal.column_pointer], 1
	ADD QWORD PTR [file.contents_offset], 1
	ADD QWORD PTR [file.contents_pointer], 1
	JMP main.move_cursor_right_exit
main.move_cursor_right_line_break_at_cursor_position:
	ADD QWORD PTR [terminal.row_pointer], 1
	LEA r12, position
	MOV r11, 2
	MOV rax, [terminal.row_pointer]
	CALL integer_to_string
main.move_cursor_right_string_length_not_reached:
	MOV dl, [rax]
	MOV BYTE PTR [r12], dl
	ADD rax, 1
	ADD r12, 1
	ADD r9, 1
	SUB rbx, 1
	CMP rbx, 0
	JNE main.move_cursor_right_string_length_not_reached
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
	ADD QWORD PTR [file.contents_offset], 1
	MOV QWORD PTR [terminal.column_pointer], 1
	ADD QWORD PTR [file.contents_pointer], 1
	JMP main.move_cursor_right_exit
main.move_cursor_right:
	CMP QWORD PTR [cursor_at_last_character_flag], 1
	JE main.move_cursor_right_exit
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, ANSI.move_cursor_right
	MOV rdx, 4
	SYSCALL
	ADD QWORD PTR [terminal.column_pointer], 1
	MOV QWORD PTR [cursor_at_last_character_flag], 1
main.move_cursor_right_exit:
	MOV BYTE PTR [keyboard_input], 0
	JMP main.loop_normal
main.loop_insert:
	MOV rax, 0
	MOV rdi, 0
	LEA rsi, keyboard_input
	MOV rdx, 1
	SYSCALL
	CMP BYTE PTR [keyboard_input], 27
	JNE main.escape_sequence_not_pressed_insert	
	MOV rax, 0
	MOV rdi, 0
	LEA rsi, keyboard_input
	MOV rdx, 1
	SYSCALL
	CMP BYTE PTR [keyboard_input], 27
	JE main.escape_pressed_insert
	CMP BYTE PTR [keyboard_input], '['
	JNE main.escape_sequence_not_pressed_insert
	MOV BYTE PTR [keyboard_input], 0
	JMP main.loop_insert
main.escape_sequence_not_pressed_insert:
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, keyboard_input
	MOV rdx, 1
	SYSCALL
	MOV BYTE PTR [keyboard_input], 0
	JMP main.loop_insert
main.escape_pressed_insert:
	PUSH rax
        PUSH rbx
	LEA rax, log.escape_key_was_pressed_insert_loop
        MOV rbx, 39
        CALL write_log
        LEA rax, log.entering_normal_event_loop
        MOV rbx, 28
        CALL write_log
        POP rbx
	POP rax
	MOV BYTE PTR [keyboard_input], 0
	JMP main.loop_normal
main.escape_pressed_normal:
	LEA rax, log.escape_key_was_pressed_normal_loop
	MOV rbx, 39
	CALL write_log
	LEA rax, log.setting_terminal_settings
	MOV rbx, 27
	CALL write_log
	MOV rax, 16
      	MOV rdi, 1
	MOV rsi, 0x5403
       	LEA rdx, original_termios
       	SYSCALL
	LEA rax, log.printing_the_command_line_interface
	MOV rbx, 37
	CALL write
	MOV rax, 1
	MOV rdi, 1
	LEA rsi, ANSI.clear_screen_move_cursor_home
	MOV rdx, 5
	SYSCALL
	LEA rax, log.exiting_te_with_exit_status_code
	MOV rbx, 33
	CALL write_log
	LEA rax, log.0
	MOV rbx, 4
	CALL write_log
	CALL close_log
	MOV rdi, 0
	CALL exit
/*
Input:
	rax = integer
Output:
	rax = pointer to string
	rbx = string length
*/
integer_to_string:
	PUSH rcx
        PUSH rdx
        PUSH r9
        PUSH r10
	PUSH rdi
	PUSH rsi
        CMP rax, 0
        JGE integer_to_string.integer_is_positive
        NEG rax
        MOV r9, 1
integer_to_string.integer_is_positive:
        LEA rcx, digits_msg.last_byte
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
	ADD r10, 1
integer_to_string.integer_is_not_negative:
	ADD rcx, 1
	MOV rax, rcx
	MOV rbx, r10
	POP rsi
	POP rdi
        POP r10
        POP r9
        POP rdx
        POP rcx
        RET
/*
Input:
	rax = pointer to log ram
	rbx = ram log length
*/
write_log:
	PUSH rax
	PUSH rdx
	PUSH rdi
	PUSH rsi
	PUSH rbx
	PUSH rax
	MOV rdi, [log_file.descriptor]
	POP rsi
	POP rdx
	MOV rax, 1
	SYSCALL
	POP rsi
	POP rdi
	POP rdx
	POP rax
	RET

close_log:
	PUSH rax
        PUSH rdi
	MOV rax, 3
        MOV rdi, [log_file.descriptor]
        SYSCALL
        POP rdi
        POP rax
	RET

.data
space:
	.ascii " "
tab:
	.ascii "\t"
keyboard_input:
	.byte 0
scrolling_index:
	.quad 0
cursor_at_last_character_flag:
	.quad 0
line_break:
	.ascii "\n" # length = 1
move_cursor:
	.ascii "\033[" # length = 2
position:
	.skip 20, 0
second_command_line_argument_pointer:
	.quad 0
working_directory_length:
	.quad 0
original_termios:
	.skip 36, 0
log.copying_ram_from_digits_msg_buffer_to_the_position_buffer:
	.ascii "\tCopying ram from digits_msg buffer to the position buffer\n" # length = 59
log.convert_long_cursor_position_to_string:
	.ascii "\tConverting long cursor position to string\n" # length = 43
log.cursor_position_is_not_row_3:
	.ascii "\tCursor_position is not row 3\n" # length = 30
log.getting_the_length_of_the_anterior_line_relative_to_cursor_position:
	.ascii "\tGetting the length of the anterior line relative to cursor position!\n" # length = 70
log.cursor_position_is_column_1:
	.ascii "\tCursor position is column 1!\n" # length = 30
log.cursor_position_is_not_row_2:
	.ascii "\tCursor position is not row 2!\n" # length = 31
log.cursor_position_is_row_3:
	.ascii "\tCursor position is row 3!\n" # length = 27
log.escape_key_was_pressed_insert_loop:
	.ascii "Escape key was pressed in insert loop!\n" #length = 39
log.escape_key_was_pressed_normal_loop:
	.ascii "Escape key was pressed in normal loop!\n" #length = 39
log.right_arrow_key_was_pressed:
	.ascii "Right arrow key was pressed!\n" # length = 29
log.left_arrow_key_was_pressed:
	.ascii "Left arrow key was pressed!\n" # length = 28
log.2_command_line_arguments_were_not_entered:
	.ascii "2 command line arguments were not entered!\n" # length = 43
log.2_command_line_arguments_were_entered:
	.ascii "2 command line arguments were entered!\n" # length = 39
log.entering_normal_event_loop:
	.ascii "Entering normal event loop!\n" # length = 28
log.entering_insert_event_loop:
	.ascii "Entering insert event loop!\n" # length = 28
log.getting_terminal_settings:
	.ascii "Getting terminal settings!\n" # length = 27
log.setting_terminal_settings:
	.ascii "Setting terminal settings!\n" # length = 27
log.getting_terminal_dimensions:
	.ascii "Getting terminal dimensions!\n" # length = 29
log.get_the_file_length:
	.ascii "Getting the file length!\n" # length = 25
log.close_file:
	.ascii "Closing file!\n" # length = 14
log.reading_file:
	.ascii "Reading file!\n" # length = 14
log.opening_file:
	.ascii "Opening file!\n" # length = 14
log.creating_the_full_path_by_adding_forward_slash_and_the_second_command_line_argument_to_the_file.path_buffer:
	.ascii "Creating the full path by adding forward slash and the second command line argument to the file.path buffer!\n" #length = 110
log.copying_the_working_directory_character_array_to_the_file.path_buffer:
	.ascii "Copying the working directory character array to the file.path buffer!\n" # length = 71
log.getting_the_last_character_of_the_working_directory_buffer:
	.ascii "Getting the last character of the working_directory buffer!\n" # length = 53
log.entering_te_at_address:
	.ascii "Entering te at address: " # length = 24
log.exiting_te_with_exit_status_code:
	.ascii "Exiting te with exit status code " # length = 33
log.getting_the_length_of_the_second_command_line_argument:
	.ascii "Getting the length of the second command line argument!\n" # length = 56
log.printing_the_command_line_interface:
	.ascii "Printing the command line interface!\n" # length = 37
log.looking_for_a_forwardslash_on_the_second_command_line_argument:
	.ascii "Looking for a forwardslash on the second command line argument!\n" # length = 64
log.saving_the_file:
	.ascii "Saving the file!\n" # length = 17
log.0:
	.ascii "0!\n\n" # length = 4
log.1:
	.ascii "1!\n\n" # length = 4
log.2:
	.ascii "2!\n\n" # length = 4
log_file.descriptor:
	.quad 0
log_file.name:
	.ascii "te.log" # length = 6
log_file.path:
	.skip 255, 0
file.descriptor:
	.quad 0
file.contents_offset:
	.quad 1
file.contents_pointer:
	.quad file.contents
file.contents:
        .skip 99999, 0
file.length:
	.quad 0
file.path:
        .skip 255, 0
terminal.row_pointer:
	.quad 2
terminal.column_pointer:
	.quad 1
        .skip 18, 0
digits_msg.last_byte:
        .byte 0
error_msg.args_count:
        .ascii "te: The entered command does not contain 2 exact arguments!\n" # length = 60
error_msg.forwardslash:
	.ascii "te: The second argument has forward slashes!\n" # length = 45
ANSI.white_background_black_foreground:
        .ascii "\033[30m\033[107m" # length = 11
ANSI.yellow:
	.ascii "\033[33m" # length = 5
ANSI.reset_color:
	.ascii "\033[0m" # length = 4
ANSI.move_cursor_up:
	.ascii "\033[1A" # length = 4
ANSI.move_cursor_down:
	.ascii "\033[1B" # length = 4
ANSI.move_cursor_right:
	.ascii "\033[1C" # length = 4
ANSI.move_cursor_left:
	.ascii "\033[1D" # length = 4
ANSI.move_cursor_left_by_8:
	.ascii "\033[8D" # length = 4
ANSI.clear_screen_move_cursor_home_white_background_black_foreground:
        .ascii "\033c\033[H\033[30m\033[107m" # length = 16
ANSI.clear_screen_move_cursor_home:
	.ascii "\033c\033[H" # length = 5
ANSI.move_cursor_home:
	.ascii "\033[H" # length = 3
ANSI.save_cursor_position:
	.ascii "\033[s" # length = 3
ANSI.restore_cursor_position:
	.ascii "\033[u" # length = 3
ANSI.reset_color_line_break:
	.ascii "\033[0m\n" # length = 5
termios.c_iflag:
	.long 0
termios.c_oflag:
	.long 0
termios.c_cflag:
	.long 0
termios.c_lflag:
	.long 0
termios.c_cc:
	.skip 20, 0
terminal.rows:
	.word 0
terminal.columns:
	.word 0
	.word 0
	.word 0

