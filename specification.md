# MBCX specification (draft)

This document aims to define a specification for a memory/hardware mapper for GameBoy and GameBoy Color cartridges, as a functional superset of the various commonly used mappers, particularly the MBC series. The scope of this document is to define the software interface to interact with said mapper — the actual hardware to support it is not part of the current specification.

**Note: all numbers in this document are hexadecimal unless otherwise stated.** Also, size units are binary: 1 KB is 400 bytes, not 3E8 bytes.

## Introduction

The GameBoy allocates two address blocks to the cartridge: an 8000-byte area for read-only data, and a 2000-byte area for various purposes, typically (but not exclusively) read/write non-volatile RAM. The cartridge can detect reads and writes in both of these areas, and thus writes to the read-only block (which would otherwise be invalid, discarded operations) are processed by cartridge hardware to expand these capabilities. This specification does not deviate from that standard, and it also adheres to the standard of splitting the 8000-block read-only area into a 4000-byte fixed area (the home bank) and a 4000-byte remappable area (the bankable ROM area).

On the other hand, it does not intend to be compatible with previous mappers (just like the various MBCs are not compatible with one another). The features supported are a superset of the various MBCs', and they are meant to be future-proof as well as easy to use; the specification is also intentionally designed to be easily extensible if the need ever arises.

## Features

This specification supports the following features in-cart:

* 1 GB ROM size (10000 banks)
* 2 MB SRAM size (100 banks)
* Real-time clock, accurate to 1 second, with a 5 year capacity
* Rumble, with 3 different speeds

## MBCX registers

Five internal registers control the functioning of the MBCX mapper. These registers, identified as MR0 through 4, serve the following purposes:

* **MR0:** ROM bank, low byte
* **MR1:** ROM bank, high byte
* **MR2:** SRAM bank
* **MR3:** control register (write-only)
* **MR4:** status register (read-only)

Registers MR0, MR1, MR2 and MR3 can be written to directly, via the ROM addressing space (0000-7FFF): the _lowest_ two bits of the address select which register to write to. (The remaining bits are ignored.) That is, writing to 0000, 0004, 0008, ..., 7FF8, 7FFC writes to the MR0 register; 0001, 0005, ... write to the MR1 register, and so on for MR2 and MR3.

Registers MR0, MR1, MR2 and MR4 can be read; the way that this can be done is explained later in this document. (Reading from addresses in the 0000-7FFF range will naturally return ROM contents, not the contents of these registers.)

Note that there is no way to read MR3, nor to write to MR4 directly. This is intentional and by design.

### MR0 and MR1: ROM bank selection

ROM banks are 4000-byte contiguous and aligned portions of ROM, identified by 16-bit numbers incrementing from 0 (where 0 is the home bank). Bank number 0 is always mapped to the 0000-3FFF block; this cannot be changed. The bank that is mapped to the 4000-7FFF block is selected by the MR0 and MR1 registers, where MR0 contains the low-order byte and MR1 the high-order byte.

Writing to either register shall change the mapped bank immediately. Writing 0 to both registers maps bank 0 to the 4000-7FFF area; no "0 to 1" conversion is performed as in MBC1-3. Writing a bank number that is too high (i.e., higher than the last bank in the ROM) maps nothing to the area; all reads return FF.

### MR2: SRAM bank selection

SRAM banks are 2000-byte contiguous and aligned portions of the non-volatile RAM in the cartridge, and they can be mapped to the A000-BFFF area. When SRAM is indeed mapped to this area (as controlled by the MR3 register), the MR2 register selects which SRAM bank is mapped to it; the banks are numbered sequentially from 0 with no gaps. Writing a bank number that is too high (i.e., higher than the last bank in the in-cart RAM) causes nothing to be mapped to this area (all reads return FF and all writes are ignored).

### MR3: control register

The control register is used to control the in-cart hardware and to select what is mapped to the A000-BFFF area. Writing to this register causes the hardware to respond immediately; this register cannot be read in any way.

The following values can be written to MR3. Writing a value not in this list can cause any unspecified hardware behavior. (Our recommendation to emulators is to simply halt all operations if an invalid value is written to MR3.)

* A000-BFFF mapping control:
    * **00:** map control registers
    * **01:** map SRAM banks, read-only
    * **02:** map SRAM banks, read-write
    * **0A:** map RTC latched registers
* RTC control:
    * **10:** latch RTC registers
    * **11:** set RTC (copy latched registers to real registers)
    * **14:** clear RTC overflow flag
    * **18:** stop RTC
    * **19:** start RTC
* Rumble control:
    * **20:** rumble off
    * **21:** rumble on, slow
    * **22:** rumble on, medium
    * **23:** rumble on, fast

The exact operation of each of these values is explained in a later section of this document.

### MR4: status register

The MR4 register is a read-only register that contains information about the current status of the in-cart hardware. It is made of bit fields, as follows (where bit 0 is the least significant):

* bits 0-1: rumble speed
* bit 2: RTC on flag
* bit 3: RTC overflow flag

The rumble speed bits contain a value from 0 to 3 indicating the current speed of the rumble (off, slow, medium, fast). The RTC on flag indicates whether the RTC is ticking or not. The RTC overflow flag is set by the RTC hardware whenever the RTCW register overflows, and can only be cleared manually by writing 14 to the MR3 register.

## Control register operation

This section describes how the hardware responds whenever a value is written to MR3. Note that only documented values are explained here; undocumented values are intentionally unspecified.

### A000-BFFF mapping control

These values determine exactly what is mapped to the A000-BFFF area. The cartridge shall behave on power-up as if 00 was written to MR3.

* **00:** control registers are mapped to the A000-BFFF area, in read-only mode. The MR0, MR1, MR2 and MR4 registers can be read from this area; the lowest two bits of the address select which register is read. Writing to this area is ignored when control registers are mapped to it. (Note that MR0, MR1 and MR2 can still be written to in the usual way.) The registers are mirrored every four bytes across the entire address block: A000, A004, and so on are mapped to MR0; A001, A005 and so on to MR1; A002, A006 and so on to MR2; and A003, A007 and so on to MR4.
* **01:** a bank of SRAM is mapped to the A000-BFFF area, in read-only mode. Writes are silently discarded while in this mode. (The bank that is mapped is selected by the MR2 register.)
* **02:** a bank of SRAM is mapped to the A000-BFFF area, in read/write mode. SRAM can be both read and written to in this mode. (The bank that is mapped is selected by the MR2 register.) Note that this value is equivalent in functionality to the SRAM enable value in MBC1-5 mappers.
* **0A:** the RTC latch registers are mapped to the A000-BFFF area, in read/write mode. (Note that the RTC latch registers contain garbage on power-up, and are only read from the actual RTC registers when 10 is written to MR3.) Just like the control registers, the RTC registers are mirrored every four bytes across the entire addressing block; in ascending order of addresses, the RTC latch registers are mapped in this order: RTCW, RTCDH, RTCM, RTCS. (The RTC will be explained in detail in a later section of this document.)

### RTC control

These values control the functioning of the RTC.

* **10:** latches the real RTC registers into the RTC latch registers, thus allowing these values to be read. (The real RTC registers are inaccessible to the user.) The RTC latch registers can then be accessed (both to read and to write them) by writing 0A to MR3.
* **11:** sets the RTC's time, by copying the value of the RTC latch registers into the real RTC registers. (Note that the RTC latch registers can be set by writing 0A to MR3 and accessing them in the A000-BFFF area.) This is the only way the real RTC registers can be written to.
* **14:** clears the RTC overflow flag in MR4.
* **18:** stops the RTC, causing the RTC registers to stop incrementing. This also clears the RTC on flag in MR4.
* **19:** starts the RTC, causing the real RTC registers to update themselves as time passes. This also sets the RTC on flag in MR4.

### Rumble control

These values are used to start and stop the rumble in the cartridge, and to control the speed of the engine causing the rumble. Up to 3 speeds may be supported by the cartridge. Writing values from 20 to 23 to MR3 selects one of these speeds (where 20 is off, and 21-23 are the possible speeds from lowest to highest); this also updates the rumble speed bits in MR4.

Note that if the cart doesn't support as many as three different speeds, a lower speed may be selected when a higher one is requested: a cart that only supports two speeds would select speed 2 when 23 is written to MR3, and a cart that only supports one speed would always select that one speed (speed 1) when any value in the 21-23 range is written to MR3. A cart that doesn't support rumble at all would always select speed 0. This behavior is permitted, as long as the true selected speed is reflected in MR4 — for instance, writing 23 to MR3 in a cart that only supports one rumble speed should cause the rumble speed bits in MR4 to read 1, not 3. (As a consequence of this, the rumble speed bits in MR4 in hardware that doesn't support rumble at all would always read 0.)

## RTC operation

The RTC contains four registers, which can track up to 100 weeks of time (almost 5 years) without overflowing, up to a precision of one second (disregarding oscillator inaccuracies). The real RTC registers are inaccesible to the user; the RTC also contains four latch registers, which the user can read and write, which are used to temporarily store the value of the RTC while it continues to tick in the background, and to update the time of the RTC when needed. This prevents a race condition between the oscillator and the user software.

The four registers, identified as RTCW, RTCDH, RTCM and RTCS, split the time into five different components: seconds, minutes, hours, day of the week and week number. As usual, there are 3C seconds in a minute, 3C minutes in an hour, 18 hours in a day and 7 days in a week. That means that, under normal operations, the seconds and minutes are constrained to the 0-3B range, the hours to 0-17 and the day of the week to 0-6.

The RTCDH register contains two fields: the upper 3 bits contain the day of the week, and the lower 5 bits contain the hour. The other three registers (RTCW, RTCM and RTCS) respectively contain the week number, the minutes and the seconds; all bits of the respective registers are used for that purpose.

As long as the RTCS, RTCM and RTCDH registers are set to values within their valid ranges, the RTC hardware must ensure that they roll over properly (seconds into minutes, minutes into hours, and so on); if the values are set to out of range values, behavior is unspecified. The RTCW register does not have a constrained range of validity, since all values in the 0-FF range are valid week numbers; if this register "rolls over", the RTC overflow flag (in MR4) must be set.

## Cartridge header

The cartridge ROM stores in its header values that identify the kind of hardware in the cartridge itself. Since these values have been chosen in a rather haphazard and inextensible way (for instance, values of 3, 4 and 5 in the RAM size field indicate respectively 4, 10 and 8 RAM banks; likewise, values of 5, 54 and 6 in the ROM size field indicate respectively 40, 60 and 80 ROM banks), this specification chooses to set those fields to unique (and otherwise unknown/invalid) values, and store the true values elsewhere.

Therefore, for cartridges using this specification, the cartridge type, ROM size and RAM size bytes (that is, addresses 0147-0149) must all be set to the value BC. The true information is stored in a four-byte area beginning at 0150, containing the following fields:

* **0150-0151:** last ROM bank. This is the highest ROM bank that the software can validly use. For instance, a 2 MB cartridge would contain the value 7F, and a 10 MB cartridge would contain the value 3FF. This value is stored in little-endian form; that is, 0150 contains the least significant byte.
* **0152:** last SRAM bank. This value is similar in spirit to the previous one, but it is used to specify the highest SRAM bank. For instance, 20 KB SRAM cartridges (the usual amount for MBC3) would contain the value 3 here. If the following field indicates that the cartridge contains no SRAM at all, this value is meaningless and can be set to anything.
* **0153:** feature fields. This value contains bit flags indicating which features the cartridge uses. The flags are as follows, where a set bit indicates presence of the feature and a clear bit indicates absence (and bit 0 is the least significant bit): bit 0: SRAM, bit 1: rumble, bit 2: multiple rumble speeds (if this bit is clear, the highest rumble speed allowed is 1), bit 3: RTC.

Note that the hardware is not required to honor these fields strictly — any hardware that contains at least the selected features is acceptable. (For instance, if a ROM says it doesn't use rumble, the cartridge may have it anyway; it is acceptable for the rumble features to work normally when the corresponding values are written to MR3 even if the ROM declares that it doesn't use them. It is also acceptable for these features not to work at all.) While these fields are therefore advisory, it is strongly recommended for software writers to set them appropriately, as this allows emulators (and even real hardware, in some cases) to determine what features the software uses, and behave accordingly.
