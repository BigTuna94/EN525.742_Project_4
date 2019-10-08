#include "serial_audio_lib.h"

#include "audio_fifo.h"

#include <stdlib.h>
#include <stdio.h>
#include "xparameters.h"
#include "xuartlite_l.h"


#define MAX_AUDIO_FILE_SAMPLES 4096

// In number of samples (one sample is 32 bits)
// i.e. you can read audio data as loaded_audio_file[sample]
static uint32_t audio_file_samples = 0;
static uint32_t loaded_audio_file[MAX_AUDIO_FILE_SAMPLES];


#define NUM_SIN_STEPS 9
void sin_audio_test(void) {
    uint16_t sin_0_to_2pi_scaled[NUM_SIN_STEPS] = {
    	16383, 	// sin(0pi/4)
		27968, 	// sin(1pi/4
		32766, 	// sin(2pi/4)
		27968, 	// sin(3pi/4)
		16383, 	// sin(4pi/4)
		 4798,  // sin(5pi/4)
		    0,  // sin(6pi/4)
		 4798,  // sin(7pi/4)
		16383   // sin(8pi/4)
    };

    for(uint32_t repeats = 0; repeats < 2048; repeats++) {
    	for (int i = 0; i < NUM_SIN_STEPS; i++) {
    		uint32_t new_data = (sin_0_to_2pi_scaled[i] << 16) | sin_0_to_2pi_scaled[i];
    		push_to_fifo( new_data );
    	}
    }
}


void print_main_menu(void) {
	xil_printf("\r\n\tWelcome to the Audio Playback System!\r\n");
	xil_printf("\t===== Main Menu =====\r\n");
	xil_printf("\tL - Load a new audio file\r\n");
	xil_printf("\tC - Playback loaded file continuously\r\n");
	xil_printf("\tP - Playback loaded file once\r\n");
	xil_printf("\r\nPress a key to continue...\r\n");
}


/*
 * Waits for entered option,
 * Sanitizes Entered option,
 * returns option
 */
User_Option get_option(void) {
	User_Option choice = UNKNOWN;
	char input_c =  getchar();
	switch (input_c) {
		case 'l':
		case 'L':
			choice = LOAD; break;
		case 'c':
		case 'C':
			choice = PLAY_CONTINUOUS; break;
		case 'p':
		case 'P':
			choice = PLAY_ONCE; break;
		default:
			xil_printf("[get_option] Unhandled character received: 0x%02x\r\n", input_c);
	}
	return choice;
}

static uint32_t bytes4_to_32bits (uint8_t *bytes) {
	uint32_t ret = 0;
	ret |= (bytes[3] << 24) & 0xFF000000;
	ret |= (bytes[2] << 16) & 0x00FF0000;
	ret |= (bytes[1] << 8)  & 0x0000FF00;
	ret |= (bytes[0]) 		& 0x000000FF;
	return ret;
}

static void empty_loaded_audio(void) {
	memset(loaded_audio_file, 0, sizeof(loaded_audio_file));
}

void load_new_file(void) {
	uint32_t new_audio_file_samples = 0; // in 32bit samples
	uint8_t byte_buff[4] = {0, 0, 0, 0};

	xil_printf("[load_new_file] Send new audio file now!\r\n");

	// Get the File size - First four bytes transfered
	for (int i = 0; i < 4; i++) {
		byte_buff[i] = inbyte();
 	}
	new_audio_file_samples = bytes4_to_32bits(byte_buff);

	// Validate new File Size
	if (new_audio_file_samples > MAX_AUDIO_FILE_SAMPLES) {
		xil_printf("Error! File size received [0x%lx] is larger than maximum file size! [0x%lx]", new_audio_file_samples, MAX_AUDIO_FILE_SAMPLES);
		// Dump received data --- kind of works, but doesn't get all the data
		while (!XUartLite_IsReceiveEmpty(XPAR_AXI_UARTLITE_BASEADDR)) {
			volatile char trash = (char)XUartLite_ReadReg(XPAR_AXI_UARTLITE_BASEADDR, XUL_RX_FIFO_OFFSET);
			(void)trash; // stop compiler warning
		}
	} else { // Load Audio Data

		// Free old audio data
		empty_loaded_audio();
		audio_file_samples = 0;

		// Read in new data
		uint32_t sample;
		for (sample = 0; sample < new_audio_file_samples; sample++) {
			// cheap way to wipe buffer
			byte_buff[0] = byte_buff[1] = byte_buff[2] = byte_buff[3] = 0;
			// get the next 4 bytes
			for (int sub_sample_byte = 0; sub_sample_byte < 4; sub_sample_byte++) {
				byte_buff[sub_sample_byte] = inbyte();
			}
			loaded_audio_file[sample] = bytes4_to_32bits(byte_buff);
			// xil_printf("Sample: 0x%lx data: 0x%08lx\r\n", sample, loaded_audio_file[sample]);
		}

		// Debug File Loading...
		//	xil_printf("[load_new_file] New audio file size: 0x%lx\r\n", new_audio_file_samples);
		//	xil_printf("[load_new_file] Received data:\r\n");
		//	for (uint32_t i=0; i < new_audio_file_samples; i++) {
		//		xil_printf("\tSample: 0x%08lx \tData: 0x%08lx\r\n", i, loaded_audio_file[i]);
		//	}

		audio_file_samples = new_audio_file_samples;
		xil_printf("[load_new_file] Completed loading new Audio file![size: %lu (0x%lx)]\r\n", audio_file_samples, audio_file_samples);
	}
}

static void dump_audio_to_fifo(void) {
	for (uint32_t sample = 0; sample < audio_file_samples; sample++) {
	 	push_to_fifo(loaded_audio_file[sample]);
	}
}

void play_loaded_file(void) {
	xil_printf("Starting Single Playback...\r\n");
	dump_audio_to_fifo();
	xil_printf("Single Playback loading complete.\r\n");
}

void play_loaded_file_loop(void) {
	char stop_char;

	xil_printf("Starting continuous playback...\r\n");
	xil_printf("Press 'S' to stop.\r\n");
	while (1) {
		dump_audio_to_fifo();

		// Check if new UART Data
		if (!XUartLite_IsReceiveEmpty(XPAR_AXI_UARTLITE_BASEADDR)) {
			// Get char, check if we should exit.
			stop_char = (char)XUartLite_ReadReg(XPAR_AXI_UARTLITE_BASEADDR, XUL_RX_FIFO_OFFSET);
			if (stop_char == 'S' || stop_char == 's') {
				break;
			}
		}
	}
	xil_printf("Continuous Playback stopped.\r\n");
}
