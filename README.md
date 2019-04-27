# ATtiny85 & NRF24l01+  <======>  NRF24l01+ & ATtiny85
I wrote a little RISC assembly program for ATtiny85 to send data over NRF24l01+

## Summary
The transmitter side has a button. The receiver side has a LED. When the button is pressed on the one side, the LED is switched on, on the other side. 

To program the ATtinys I used AVR Studio 7.0, avrdude.exe, and an Arduino UNO as ISP.

## AVRDUDE Args

-C"C:\Program Files (x86)\arduino\hardware\tools\avr\etc\avrdude.conf" -v -pt85 -carduino -b19200 -PCOM3 -U lfuse:w:0x62:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m -Uflash:w:"$(ProjectDir)Debug\$(TargetName).hex":i

### Warings

Transmission power can influence the packet loss rate. When the RF modules are close together, choose the minimal power (-18dB).

