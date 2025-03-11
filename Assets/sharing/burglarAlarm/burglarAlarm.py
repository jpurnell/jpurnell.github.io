import machine
import time

snsr_bedroom = machine.Pin(28, machine.Pin.IN, machine.Pin.PULL_DOWN)
snsr_living_room = machine.Pin(18, machine.Pin.IN, machine.Pin.PULL_DOWN)

# Add a pin out for the first led light, call it "led_bedroom"
led_bedroom = machine.Pin(15, machine.Pin.OUT)

# Add an additional pin out for the second led light, call it "led_living_room"
led_living_room = machine.Pin(11, machine.Pin.OUT)
buzzer = machine.Pin(14, machine.Pin.OUT)

def pir_handler(pin):
    time.sleep_ms(100)
    if pin.value():
        if pin is snsr_bedroom:
            print("ALARM! Motion detected in bedroom!")
            for i in range(10):
                led_bedroom.toggle()
                buzzer.toggle()
                time.sleep_ms(100)
        elif pin is snsr_living_room:
            print("ALARM! Motion detected in living room!")
            for i in range(10):
                led_living_room.toggle()
                buzzer.toggle()
                time.sleep_ms(100)

snsr_bedroom.irq(trigger=machine.Pin.IRQ_RISING, handler=pir_handler)
snsr_living_room.irq(trigger=machine.Pin.IRQ_RISING, handler=pir_handler)

#both LEDs will blink so that we know that the system is working
while True:
    led_bedroom.toggle()
    led_living_room.toggle()
    time.sleep(1)