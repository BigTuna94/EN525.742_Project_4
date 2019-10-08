/*
 * codec.c
 *
 *  Created on: Sep 9, 2019
 *      Author: Zach
 */
#include <stdint.h>
#include "xparameters.h"
#include "xspi.h"
#include "xstatus.h"
#include "malloc.h"

#include "codec.h"

static XSpi *Spi; /* The instance of the SPI device */


/*
 * Reference: https://www.analog.com/media/en/technical-documentation/data-sheets/ADAU1761.pdf
 */
static void write_reg(uint32_t reg, uint8_t val) {
	uint8_t chip_addr = 0;
	uint8_t addr_high, addr_low;

	addr_high = (reg & 0xFF00) >> 8;
	addr_low = (reg & 0x00FF);

	// Parse data into byte array
	uint8_t send_buffer[] = {chip_addr, addr_high, addr_low, val};
	uint8_t receive_buffer[] = {0, 0, 0, 0};

	// Send Data
	int transfer_status = XSpi_Transfer(Spi, send_buffer, receive_buffer, sizeof(send_buffer));
	if (transfer_status != XST_SUCCESS) {
		xil_printf("[codec.c::write_reg] ERROR! Spi Transfer failed with status: %d\r\n", transfer_status);
	}
}


static int init_spi(void) {
	int Status;
	XSpi_Config *ConfigPtr;	/* Pointer to Configuration data */

	if (Spi == NULL) {
		Spi = malloc(sizeof(XSpi));
	}

	if (Spi == NULL) {
		xil_printf("[codec.c::init_spi] Failed to malloc new Spi!\r\n");
		return XST_FAILURE;
	}

	/*
	 * Initialize the SPI driver so that it is  ready to use.
	 */
	ConfigPtr = XSpi_LookupConfig(XPAR_SPI_0_DEVICE_ID);
	if (ConfigPtr == NULL) {
		xil_printf("[codec.c::init_spi] device not found!\r\n");
		return XST_DEVICE_NOT_FOUND;
	}

	Status = XSpi_CfgInitialize(Spi, ConfigPtr,
				  ConfigPtr->BaseAddress);
	if (Status != XST_SUCCESS && Status != XST_DEVICE_IS_STARTED) {
		xil_printf("[codec.c::init_spi] configPtr Initialization failed!\r\n");
		return XST_FAILURE;
	}

	/*
	 * Perform a self-test to ensure that the hardware was built correctly
	 */
	Status = XSpi_SelfTest(Spi);
	if (Status != XST_SUCCESS) {
		xil_printf("[codec.c::init_spi] Self-Test failed!\r\n");
		return XST_FAILURE;
	}

	/*
	 * Set Slave Select mode
	 */
	Status = XSpi_SetSlaveSelect(Spi, 1);
	if (Status != XST_SUCCESS) {
		switch (Status) {
			case XST_DEVICE_BUSY:
				xil_printf("[codec.c::init_spi] Transfer in progress! Cannot select new slave!\r\n");
				break;
			case XST_SPI_TOO_MANY_SLAVES:
				xil_printf("[codec.c::init_spi] Cannot set more than one slave!\r\n");
				break;
			default:
				xil_printf("[codec.c::init_spi] unknown error selecting slave!\r\n");
		}
		return Status;
	}


	//Status = XSpi_SetOptions(Spi, XSP_MASTER_OPTION);
	Status = XSpi_SetOptions(Spi, XSP_MASTER_OPTION | XSP_MANUAL_SSELECT_OPTION);
	if (Status != XST_SUCCESS) {
		xil_printf("[codec.c::init_spi] SetOptions failed!\r\n");
		return XST_FAILURE;
	}

	XSpi_Start(Spi);

	/*
	 * Disable Global interrupt to use polled mode operation
	 */
	XSpi_IntrGlobalDisable(Spi);

	return XST_SUCCESS;
}

static void configure_codec(void) {
	write_reg(0x4000,1);
	write_reg(0x4000,1);
	write_reg(0x4000,1);
	write_reg(0x4000,1);
	write_reg(0x40f9,0x7f);
	write_reg(0x40fa,0x3);
	write_reg(0x401c,0x2d);
	write_reg(0x401e,0x4d);
	write_reg(0x4020,5);
	write_reg(0x4021,0x11);
	write_reg(0x4025,0xe6);
	write_reg(0x4026,0xe6);
	write_reg(0x4029,3);
	write_reg(0x402a,3);
	write_reg(0x4016,0x21);
	write_reg(0x40F2,0x1);
}


void init_codec(void) {
	xil_printf("\r\nInitializing CODEC System...\r\n");

	if ( init_spi() == XST_SUCCESS) {
		xil_printf("\tSPI Initialized Successfully!\r\n");
	} else {
		xil_printf("\tError initializing SPI!!!\r\n");
		return;
	}

	configure_codec();
	xil_printf("Completed Codec initialization and configuration.\r\n");
}
