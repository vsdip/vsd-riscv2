#include <stdint.h>
#include "io.h"

#define PWM_BASE    0x400030

#define PWM_CTRL    0x00
#define PWM_PERIOD  0x04
#define PWM_DUTY    0x08
#define PWM_STATUS  0x0C

#define PWM_REG(offset) (*(volatile uint32_t *)(PWM_BASE + (offset)))

static void uart_puts(const char *s)
{
    while (*s) {
        while (IO_IN(IO_UART_CNTL) & (1u << 9)) {
            /* Wait while UART is busy */
        }
        IO_OUT(IO_UART_DAT, *s++);
    }
}

int main(void)
{
    PWM_REG(PWM_PERIOD) = 12000000;
    PWM_REG(PWM_DUTY)   = 6000000;
    PWM_REG(PWM_CTRL)   = 1;

    uart_puts("\r\nPWM TEST START\r\n");
    uart_puts("PWM PERIOD = 12000000\r\n");
    uart_puts("PWM DUTY   = 6000000\r\n");
    uart_puts("PWM ENABLE = 1\r\n");
    uart_puts("PWM RUNNING\r\n");

    while (1) {
        /* Keep PWM running */
    }

    return 0;
}
