/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include <io.h>
#include <unistd.h>
#include <time.h>
#include <sys/alt_stdio.h>
#include "system.h"

#define delay 1000

int main()
{
	while (1)
	{
		volatile alt_u16 click = IORD_16DIRECT(SRAM_0_BASE, 0);

		if (click > 40000)
		{
			printf(" Click! (value: %d)\n\n", click);
			printf("------------------------------------\n\n");
		}

		usleep(delay);
	}

	return 0;
}
