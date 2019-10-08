/*
 * audio_fifo.c
 *
 *  Created on: Sep 10, 2019
 *      Author: Zach
 */

#include "xgpio_l.h"
#include "fsl.h"


#include "audio_fifo.h"


void push_to_fifo(uint32_t data) {
	putfslx(data, FSL_ID, FSL_DEFAULT);
}
