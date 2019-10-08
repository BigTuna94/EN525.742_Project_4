/*
 * serial_audio_lib.h
 *
 *  Created on: Sep 16, 2019
 *      Author: Zach
 */

#ifndef SRC_SERIAL_AUDIO_LIB_H_
#define SRC_SERIAL_AUDIO_LIB_H_

typedef enum {
	UNKNOWN = 0,
	LOAD = 1,
	PLAY_CONTINUOUS = 2,
	PLAY_ONCE = 3,
} User_Option;

void print_main_menu(void);
User_Option get_option(void);
void load_new_file(void);
void play_loaded_file(void);
void play_loaded_file_loop(void);
void sin_audio_test(void);

#endif /* SRC_SERIAL_AUDIO_LIB_H_ */
