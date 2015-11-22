# COSMAC1802-VIPDSKYCLOCK
Demonstrates an  Apollo Guidance Computer Simulator (AGC) Display Keyboard (DSKY) Unit with a 1970's vintage RCA 1802 COSMAC VIP. Microprocessor. 


This project started as a test to see if a COSMAC 1082 VIP Microcomputer I built back in 1979 - 1980 still worked. It had been sitting on a shelf in my garage (not the cleanest environment) and was covered with dust and cobwebs. This version was actually the 3rd version I built which was a clone of the RCA COSMAC VIP trainer. The first two versions had 256 -bytes of RAM and 8 toggle switches and LEDs to enter programs. The 1802 video chip was a break through technology for the late 1970's and when I built this it was the first computer my friends and family had ever seen. The CDP1802 chip has some 5000 transistors and a 2MHZ clock speed and was rumored to be the first "space-rated" microprocessor. 

COSMAC 1802

The other fascinating technology from about that same era was the Apollo Guidance Computer or known as the (AGC). I have heard folks say that a modern wrist watch has a much power as that machine - not true- So I decided a "useful" project would be a video clock, so I combined the two to come up with this project or at least the user interface part of the AGC called the ** Display Keyboard or (DSKY).** Read all about a real emulator that even runs Apollo software. Virtual AGC Homepage

Scope

What this program is and isn't. It does not run the original source code for Apollo, it only emulates some of the VERB + NOUN sequences and simulates them on the VIP 1861 PIXIE Graphics. The good simulators in the above links can run the actual Apollo source code, sadly, mine cannot. To do this I would need to write an interpreter which would probably produce many lines of 1802 source code. Since the original AGC ran at about the same clock speed (2048Hz) it would run many times slower and produce many more lines of code so I took the "demo" approach and wrote my version of these VERBs. 

--------------------------------------------------------------------------------

UPDATES:

Version 02AUGUST2015: Fixed issue in VERB23 RTC move seconds. Now you can set the clock.


DEMO of Latest S/W

Version 02AUGUST2015: Verb 16 (MONITOR DEC) works with NOUNs 65 and 36 only. Enter DECIMAL to R1 R2 and R3 works now so the clock can finally be set! the E and C key functions are reversed, to save the REG press [C]lear to clear the register (start over) press [E]nter ley. I know, it is a little off but the demo still works so I released the new version. The next experiment is to load this image onto the VIP through the cassette port.
 Use: 


V16N65E ("A" 1 6 "B" 6 5 "E" -> Shows Mission Elapsed Time on R1, R2, and R3)

V16N36E ("A" 1 6 "B" 3 6 "E" -> Shows Mission Elapsed Time on R1, R2, and R3)

V35E ("A" 3 5 "E") -> All REGs +88888 and Flashes VERB (V1, V2) and NOUN (N1, N2) and PROG (P1, P2) Displays... NOTE: This will not stop after 5 seconds, to stop press the PRO Key "D" 

V36E ("A" 3 6 "E") clears R1, R2, R3, and resets NOUN, VERB and PROG Displays to "00"

V21E ("A" 2 1 "B" xx "E") Blanks REG1, "F" key will cycle thru signs, enter 5 digits...


NOTE: Issue with input will continue to write digits to VERBs NOTE: After 5 digits, press "C" (clear?) to ENTER save in REG1 to correct an error press "E" starts the line over (this is an issue that needs to be fixed, but it works functionally, just the "E" and "C" keys are swapped

Example: "A", "F", "F", 0, 0, 0, 2, 3, "C" sets REG1 to +00023 or 23: hours! "A", "F", "F", 0, 0, 0, 2, 3, "E" resets REG1 to retry enter R1 incase you made a mistake

V22E ("A" 2 2 "B" xx "E") Write to REG 2 ( Same as above) 

V23E ("A" 2 3 "B" xx "E") Write to REG 2 ( Same as above) 

Version 21JULY2015: The NOUNS really don't do any thing currently. The following VERBS work: V35E - LAMP TEST the only difference is it will flash NOUN and VERB "All BALLS" until the "D" key is pressed. V16 - MONITOR DECIMAL in R1, R2, R3 Currently it only shows Mission Elapsed Time (displays Hours, Mins, and Secs on the DSKY) This clock will roll over at 23:59:59 -> 00:00:00 which the real AGC software won't do.

The following VERBs almost work:

*V21 *V22 *V23

Currently they only blank the lines, and if you press the "F" Key the sign will change, but no numbers input into the REGs - so I still can't set my clock to the correct time!

History

Only a switch, power wires, and a brief cleaning the COSMAC powered up. After resurrecting the computer, it powered up and the "Q" LED flashed to the key presses. I had somehow remembered to hold in the "C" key and cycle the momentary switch would evoke the VIP MONITOR ROM. I had no idea if the display worked. I found a notebook with lots of info and keyed in a quick program to flash the LED - in the blind. Here are the VIP MONITOR Commands: KEY OPERATION "0" Memory Write (MW) "A" Memory Read (MR) "B" Tape Read (TR) "F" Tape Write (TW)

To start the monitor: RUN/HALT + "C" - it is kind of a techy thing just push RUN/HLT switch then PRESS "C" release RUN/HLT while holding the "C" Key. 


As you can see in the video, i did not have the technique down solid yet!

Next Enter "0000" 

"0" (MW) 

 0000: 7A F8 0F BF 2F 9F 3A 04 

 0008: 31 00 7B 30 01 00 00 00  

Finally, cycle the *RUN/HLT *switch to run program in RAM at 0000

It works!

Then I keyed in a 256 byte VIP clock program it is at about the limit of what you want to key in by hand. It took several key and edit sessions to get it all in correctly. Is This reminded me of what the Apollo astronauts must have gone thru? Anyway, As this program got more complicated, it became impossible to do anything with it. I had hex listings I typed in and printed out. I decided to try the A18 cross assembler. It worked great but now I had a bunch of hex digits- no real software. I converted the ASCII HEX file I had to binary and used DASM140x to produce the source code. You can find some of the original L000 labels and I left the CHECKSUM of the original clock in the header. 

Here is what the early program looked like running: VIP CLOCK

This is a work in progress so stay tuned... I will put up some pictures and a few documents soon.

Some other useful links:

If you don't happen to have a 1979 COSMAC you can still run this program using this very nice simulator. This emulator made writing debugging this extremely easy. Emma02 These tools were not available when I struggled back in the day with writing software, this tool along with this cross assembler A18 Cross Assembler and three decades of experience helelped make this a fun project. 

--------------------------------------------------------------------------------

Simulator

Runs on an RCA VIP or if you don't happen to have a 40year old computer, it runs fine with an RCA 1802 Simulator: The hex file runs on the EMMA02 COSMAC Emulator. EMMA02


By the way, it have only got it to run on the Emma02's VIP settings, I need to see why it won't run on generic COSMAC 1802. I am working on getting a .WAV file and cable to try to load this version on my real machine soon. 

--------------------------------------------------------------------------------
  TODO
  
The "Issues" has the needed fixes and errata.
