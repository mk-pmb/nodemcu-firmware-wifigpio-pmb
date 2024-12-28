
<!--#echo json="package.json" key="name" underline="=" -->
nodemcu-firmware-wifigpio-pmb
=============================
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
A NodeMCU firmware image for GPIO via WiFi.
<!--/#echo -->


Just a demo of how to use [nodemcu-firmware-build-as-github-action][nodemcu-baga].



Usage
-----

See [the tutorial repo][wifigpio-tutorial].



Caveats
-------

#### Which ESP8266 GPIO pins are safe for direct output?

* GPIO4 and GPIO5. All others will be high or at least have some lesser
  voltage on boot, which may interfere with external electronics.
  Source: [This pinout overview](
  https://randomnerdtutorials.com/esp8266-pinout-reference-gpios/),
  chapters "Pins used during Boot" and "Pins HIGH at Boot".
  Summary in the green box at the bottom of the latter.
* [Additional Information from Erich Flach
  ](https://rabbithole.wwwdotorg.org/2017/03/28/esp8266-gpio.html#additional-information-from-erich-flach)
  about the boot process.


#### Will the ESP8266 GPIO pins survive 5,3V inputs?

* [An experiment with a curve tracer](https://hackaday.com/?p=533904)
  showed that the specific specimen tested would probably be able to not
  immediately catch on fire if fed even slightly higher voltages.
* Comments have mixed feelings about that, some suspecting semi-official
  5V tolerance while others warn about dangers such as:
  * Potential long-term damage.
  * A possible "bad" production batch at any time in the future that might
    "merely" fit the datasheet specs, rather than vastly overperforming.
  * Potential sneaky (e.g. delayed) side effects/malfunctions that may arise
    while overpowered and may not be easy to detect reliably.
  * Overvoltage on inputs might raise VCC depending on which mode the GPIO
    pin is operating in and how that mode is implemented in the specific
    production batch, which may change at any time in the future.




Useful links
------------

* [ESP32 Pinout](https://randomnerdtutorials.com/esp32-pinout-reference-gpios/)
* [ESP8266 Pinout](https://randomnerdtutorials.com/esp8266-pinout-reference-gpios/)




<!--#toc stop="scan" -->
&nbsp;


  [nodemcu-baga]: https://github.com/mk-pmb/nodemcu-firmware-build-as-github-action
  [wifigpio-tutorial]: https://github.com/mk-pmb/nodemcu-wifigpio-tutorial-pmb/


License
-------

<!--#echo json="package.json" key=".license" -->
MIT
<!--/#echo -->
