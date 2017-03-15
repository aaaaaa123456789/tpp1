# TPP1 specification

* [Definition and scope](#definition-and-scope)
* [Introduction](#introduction)
* [Features](#features)
* [Address blocks](#address-blocks)
* [Mapper registers](#mapper-registers)
    * [MR0 and MR1: ROM bank selection](#mr0-and-mr1-rom-bank-selection)
    * [MR2: SRAM bank selection](#mr2-sram-bank-selection)
    * [MR3: control register](#mr3-control-register)
    * [MR4: status register](#mr4-status-register)
* [Initial status](#initial-status)
* [Control register operation](#control-register-operation)
    * [A000-BFFF mapping control](#a000-bfff-mapping-control)
    * [RTC control](#rtc-control)
    * [Rumble control](#rumble-control)
* [RTC operation](#rtc-operation)
* [Cartridge header](#cartridge-header)

## Definition and scope

This document aims to define a specification for a memory/hardware mapper for GameBoy and GameBoy Color cartridges, as a functional superset of the various commonly used mappers, particularly the Memory Bank Controller (MBC) series. The scope of this document is to define the software interface to interact with said mapper — the actual hardware to support it is not part of the current specification.

**Note: all numbers in this document are hexadecimal unless otherwise stated.** Also, size units are binary, with SI-recommended prefixes for clarity (e.g., 1 kiB = 400 bytes, as opposed to 1 KB = 3E8 bytes).

## Introduction

The GameBoy allocates two address blocks to the cartridge: an 8000-byte area for read-only data, and a 2000-byte area for various purposes, typically (but not exclusively) read/write non-volatile RAM. The cartridge can detect reads and writes in both of these areas, and thus writes to the read-only block (which would otherwise be invalid, discarded operations) are processed by cartridge hardware to expand these capabilities. This specification does not deviate from that standard, and it also adheres to the convention of splitting the 8000-byte block read-only area into a 4000-byte fixed area (the home bank) and a 4000-byte remappable area (the bankable ROM area).

On the other hand, it does not intend to be compatible with previous mappers (just like the various MBCs are not compatible with one another). The features supported are a superset of the various MBCs', and they are meant to be future-proof as well as easy to use; the specification is also intentionally designed to be easily extensible if the need ever arises.

## Features

This specification supports the following features in the cartridge:

* 1 GiB ROM size (10000 banks)
* 2 MiB SRAM size (100 banks)
* Real-time clock, accurate to 1 second, with a 5 year capacity
* Rumble, with up to 3 different speeds

## Address blocks

This mapper uses the address blocks assigned to the cartridge for its own functioning, besides their regular purposes. In particular, the three address blocks that are used as the following ones:

* **0000-3FFF:** ROM home bank block. ROM bank 0 is always mapped to this area, and it cannot be changed. Writing to this area writes to the mapper registers.
* **4000-7FFF:** ROM banking block. Any ROM bank can be mapped to this area, as selected by the MR0 and MR1 registers, as it will be explained later in this document. Writes to this area pass through to the ROM itself (the full address being partially specified by the MR0 and MR1 registers as well as the actual address accessed) — this is normally a dummy write with no effect, but it can be used for controlling hardware such as flash cartridges.
* **A000-BFFF:** RAM block. This area is conventionally used for in-cartridge non-volatile RAM (that is, SRAM) accessing. This mapper allows mapping any bank of SRAM to that area, as well as read-only copies of its internal registers, or RTC data.

## Mapper registers

Five internal registers control the functioning of the mapper. These registers, identified as MR0 through 4, serve the following purposes:

* **MR0:** ROM bank, low byte
* **MR1:** ROM bank, high byte
* **MR2:** SRAM bank
* **MR3:** control register (write-only)
* **MR4:** status register (read-only)

Registers MR0, MR1, MR2 and MR3 can be written to directly, via the lower half of the ROM addressing space (0000-3FFF): the _lowest_ two bits of the address select which register to write to. (The remaining bits are ignored.) That is, writing to 0000, 0004, 0008, ..., 3FF8, 3FFC writes to the MR0 register; 0001, 0005, ... write to the MR1 register, and so on for MR2 and MR3.

Registers MR0, MR1, MR2 and MR4 can be read; the way that this can be done is explained later in this document. (Reading from addresses in the 0000-3FFF range will naturally return ROM contents, not the contents of these registers.)

Note that there is no way to read MR3, nor to write to MR4 directly. This is intentional and by design.

### MR0 and MR1: ROM bank selection

ROM banks are 4000-byte contiguous and aligned portions of ROM, identified by 2-byte numbers incrementing from 0 (where 0 is the home bank). Bank number 0 is always mapped to the 0000-3FFF block; this cannot be changed. The bank that is mapped to the 4000-7FFF block is selected by the MR0 and MR1 registers, where MR0 contains the low-order byte and MR1 the high-order byte.

Writing to either register shall change the mapped bank immediately. Writing 0 to both registers maps bank 0 to the 4000-7FFF area; no "0 to 1" conversion is performed, as opposed to the behavior shown by MBC1-3. (In other words, selecting bank 0 behaves as in MBC5.) If a bank number that is higher than the highest available bank (as indicated by the cartridge header) is selected, behavior (with respect to the 4000-7FFF block) is undefined as long as that bank remains selected.

### MR2: SRAM bank selection

SRAM banks are 2000-byte contiguous and aligned portions of the non-volatile RAM in the cartridge, and they can be mapped to the A000-BFFF area. When SRAM is indeed mapped to this area (as controlled by the MR3 register), the MR2 register selects which SRAM bank is mapped to it; the banks are numbered sequentially from 0 with no gaps. If a bank number that is higher than the highest available bank (as indicated by the cartridge header) is selected and SRAM is mapped to A000-BFFF, behavior (with respect to that block) is undefined as long as those conditions remain true.

### MR3: control register

The control register is used to control the in-cart hardware and to select what is mapped to the A000-BFFF area. Writing to this register causes the hardware to respond immediately; this register cannot be read in any way.

The following values can be written to MR3. Writing a value not in this list can cause any unspecified hardware behavior. (Our recommendation to emulators is to simply halt all operations if an invalid value is written to MR3.)

* A000-BFFF mapping control:
    * **00:** map control registers
    * **02:** map SRAM banks, read-only
    * **03:** map SRAM banks, read/write
    * **05:** map RTC latched registers
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

Note that bits other than the ones described above are undefined, and may contain any value. (Our recommendation, for consistency with other unused bits throughout the hardware, is to return set bits for all unused bits. However, this is an optional recommendation, and thus software must not rely on it.)

## Initial status

The cartridge shall behave on power-up in a predictable, established way. In particular, the following behavior is required for the cartridge and the mapper, and can be assumed by the software:

* MR0, MR1 and MR2 are respectively initialized to one, zero and zero;
* ROM bank 1 is mapped to the 4000-7FFF area as a consequence of the above;
* Control registers are mapped to the A000-BFFF area, as if 00 had been written to MR3;
* Rumble features are off (as if 20 had been written to MR3), and MR4 reflects this; and
* RTC retains its settings, including an updated clock if it was set to continue ticking while powered off. (If the cartridge (or at least its RTC features) had not been used before, the RTC should be off (i.e., not ticking), with undefined initial values.)

## Control register operation

This section describes how the hardware responds whenever a value is written to MR3. Note that only documented values are explained here; undocumented values are intentionally unspecified.

### A000-BFFF mapping control

These values determine exactly what is mapped to the A000-BFFF area. The cartridge shall behave on power-up as if 00 was written to MR3. Note that attempting to map non-existent hardware to this area (such as SRAM when zero banks of it have been declared, or RTC latch registers when the cartridge header declares no RTC) results in undefined behavior with respect to this area as long as nothing else is mapped to it.

* **00:** control registers are mapped to the A000-BFFF area, in read-only mode. The MR0, MR1, MR2 and MR4 registers can be read from this area; the lowest two bits of the address select which register is read. Writing to this area is ignored when control registers are mapped to it. (Note that MR0, MR1 and MR2 can still be written to in the usual way.) The registers are mirrored every four bytes across the entire address block: A000, A004, and so on are mapped to MR0; A001, A005 and so on to MR1; A002, A006 and so on to MR2; and A003, A007 and so on to MR4.
* **02:** a bank of SRAM is mapped to the A000-BFFF area, in read-only mode. Writes are silently discarded while in this mode. (The bank that is mapped is selected by the MR2 register.)
* **03:** a bank of SRAM is mapped to the A000-BFFF area, in read/write mode. SRAM can be both read and written to in this mode. (The bank that is mapped is selected by the MR2 register.) Note that this value is equivalent in functionality to the SRAM enable value in MBC1-5 mappers.
* **05:** the RTC latch registers are mapped to the A000-BFFF area, in read/write mode. (Note that the RTC latch registers contain garbage on power-up, and are only read from the actual RTC registers when 10 is written to MR3.) Just like the control registers, the RTC registers are mirrored every four bytes across the entire addressing block; in ascending order of addresses, the RTC latch registers are mapped in this order: RTCW, RTCDH, RTCM, RTCS. (The RTC will be explained in detail in a later section of this document.)

### RTC control

These values control the functioning of the RTC. The software must wait 3 microseconds before attempting to access RTC latch registers after writing 10 or 11 to MR3.

* **10:** latches the real RTC registers into the RTC latch registers, thus allowing these values to be read. (The real RTC registers are inaccessible to the user.) The RTC latch registers can then be accessed (both to read and to write them) by writing 05 to MR3.
* **11:** sets the RTC's time, by copying the value of the RTC latch registers into the real RTC registers. (Note that the RTC latch registers can be set by writing 05 to MR3 and accessing them in the A000-BFFF area.) This is the only way the real RTC registers can be written to.
* **14:** clears the RTC overflow flag in MR4.
* **18:** stops the RTC, causing the RTC registers to stop incrementing. This also clears the RTC on flag in MR4.
* **19:** starts the RTC, causing the real RTC registers to update themselves as time passes. This also sets the RTC on flag in MR4.

### Rumble control

These values are used to start and stop the rumble in the cartridge, and to control the speed of the engine causing the rumble. Up to 3 speeds may be supported by the cartridge. Writing values from 20 to 23 to MR3 selects one of these speeds (where 20 is off, and 21-23 are the possible speeds from lowest to highest); this also updates the rumble speed bits in MR4.

Note that if the cart doesn't support as many as three different speeds, a lower speed may be selected when a higher one is requested: a cart that only supports two speeds would select speed 2 when 23 is written to MR3, and a cart that only supports one speed would always select that one speed (speed 1) when any value in the 21-23 range is written to MR3. A cart that doesn't support rumble at all would always select speed 0. This behavior is permitted, as long as the true selected speed is reflected in MR4 — for instance, writing 23 to MR3 in a cart that only supports one rumble speed should cause the rumble speed bits in MR4 to read 1, not 3.

A consequence of the above is that hardware that doesn't support rumble at all can still be compliant with this specification, as long as it shows that lack of support by setting the rumble speed bits in MR4 to 0 at all times. (The software can easily test whether the cart supports rumble or not by testing the relevant MR4 bits after writing to MR3.)

## RTC operation

The RTC contains four registers, which can track up to 100 weeks of time (almost 5 years) without overflowing, up to a precision of one second (disregarding oscillator inaccuracies). The real RTC registers are inaccesible to the user; the RTC also contains four latch registers, which the user can read and write, which are used to temporarily store the value of the RTC while it continues to tick in the background, and to update the time of the RTC when needed. This prevents a race condition between the oscillator and the user software.

The four registers, identified as RTCW, RTCDH, RTCM and RTCS, split the time into five different components: seconds, minutes, hours, day of the week and week number. As usual, there are 3C seconds in a minute, 3C minutes in an hour, 18 hours in a day and 7 days in a week. That means that, under normal operations, the seconds and minutes are constrained to the 0-3B range, the hours to 0-17 and the day of the week to 0-6.

The RTCDH register contains two fields: the upper 3 bits contain the day of the week, and the lower 5 bits contain the hour. The other three registers (RTCW, RTCM and RTCS) respectively contain the week number, the minutes and the seconds; all bits of the respective registers are used for that purpose.

As long as the RTCS, RTCM and RTCDH registers are set to values within their valid ranges, the RTC hardware must ensure that they roll over properly (seconds into minutes, minutes into hours, and so on); if the values are set to out of range values, behavior is unspecified. The RTCW register does not have a constrained range of validity, since all values in the 0-FF range are valid week numbers; if this register "rolls over", the RTC overflow flag (in MR4) must be set. Note that the RTC overflow flag is never cleared by the RTC hardware; instead, the software must explicitly clear it by writing 14 to MR3.

**Important:** after writing 10 or 11 to MR3, the software must wait at least 3 microseconds before attempting to access the RTC latch registers. (That is 3 clock cycles in normal speed mode, or 6 cycles in GBC double speed mode; the duration of a `nop` instruction is considered to be 1 cycle.) Not following this wait period may result in any undefined behavior, even if the registers are only accessed for reading.

## Cartridge header

The cartridge ROM stores in its header values that identify the kind of hardware in the cartridge itself. Since these values have been chosen in a rather haphazard and inextensible way (for instance, values of 3, 4 and 5 in the RAM size field indicate respectively 4, 10 and 8 RAM banks; likewise, values of 5, 54 and 6 in the ROM size field indicate respectively 40, 60 and 80 ROM banks), this specification chooses to set those fields to unique (and otherwise unknown/invalid) values, and store the true values elsewhere.

Therefore, for cartridges using this specification, the following values must be set in the header, including an extended four-byte header beyond the regular header area:

* **0147, 0149, 014A:** identification values. These values regularly contain the mapper type, RAM size and destination code; for this specification, these values must be set to BC, C1 and 65 respectively.
* **0148:** ROM size. This value is set in the usual way, with some extended values. Namely, the value is a shift count; the size of the ROM can be obtained by shifting the value 2 (for banks) or 8000 (for bytes) by the amount specified here. The maximum value that this byte can take is F, for a ROM size of 10000 banks (or 40000000 bytes, that is, 1 GiB).
* **0150:** major version number. For this version of the specification, this byte must contain the value 1.
* **0151:** minor version number. For this version of the specification, this byte must contain the value 0.
* **0152:** RAM size. Contains a value indicating the size of the SRAM in the cartridge. If no SRAM is present, this byte must be set to 0; otherwise, it must be set to a value between 1 and 9 indicating respectively 1, 2, 4, 8, 10, 20, 40, 80 or 100 banks of SRAM. (This value is therefore also a shift count.)
* **0153:** feature fields. This value contains bit flags indicating which features the cartridge uses. The flags are as follows, where a set bit indicates presence of the feature and a clear bit indicates absence (and bit 0 is the least significant bit): bit 0: rumble, bit 1: multiple rumble speeds (if this bit is clear, the highest rumble speed allowed is 1), bit 2: RTC. Upper (unused) bits must be unset.

A consequence of the permitted values above is that both ROM size and RAM size can only be set to a power of two that is at least as large as the size of the addressing spaces they respectively have assigned (with the exception of RAM size having zero as an acceptable value). This is intentional and by design.

Note that the hardware is not required to honor these fields strictly — any hardware that contains at least the selected features is acceptable. (For instance, if a ROM says it doesn't use rumble, the cartridge may have it anyway; it is acceptable for the rumble features to work normally when the corresponding values are written to MR3 even if the ROM declares that it doesn't use them. It is also acceptable for these features not to work at all.) While these fields are therefore advisory, it is strongly recommended for software writers to set them appropriately, as this allows emulators (and even real hardware, in some cases) to determine what features the software uses, and behave accordingly.
