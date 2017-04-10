# TPP1

This repository aims to [define and specify a GB/GBC mapper](specification.md).

There is a test ROM available here. In order to compile it, you will need the
version of rgbds that is contained in this repository; build it by using the
`make` command inside the `rgbds` directory.

Once that is done, you can build the test ROM using the `make` command in the
repository's main directory; the output will be called `testrom.gb`. Using
`make clean` will remove the built files.

The compilation of the test ROM can be parameterized via three variables passed
to `make`, those being `ROMSIZE`, `RAMSIZE` and `ROMFLAGS`. For instance, in
order to set all three to their maximum possible values, compile the test ROM as
`make ROMSIZE=F RAMSIZE=9 ROMFLAGS=7`.

The values these variables can take are as follows:

`ROMSIZE`: sets the size of the ROM. Default value is 9.

|Value| Banks|   Size|
|:---:|-----:|------:|
|  0  |     2| 32 kiB|
|  1  |     4| 64 kiB|
|  2  |     8|128 kiB|
|  3  |    16|256 kiB|
|  4  |    32|512 kiB|
|  5  |    64|  1 MiB|
|  6  |   128|  2 MiB|
|  7  |   256|  4 MiB|
|  8  |   512|  8 MiB|
|  9  | 1,024| 16 MiB|
|  A  | 2,048| 32 MiB|
|  B  | 4,096| 64 MiB|
|  C  | 8,192|128 MiB|
|  D  |16,384|256 MiB|
|  E  |32,768|512 MiB|
|  F  |65,536|  1 GiB|

`RAMSIZE`: sets the size of the SRAM. Default value is 5.

|Value|Banks|   Size|
|:---:|----:|------:|
|  0  |    0|no SRAM|
|  1  |    1|  8 kiB|
|  2  |    2| 16 kiB|
|  3  |    4| 32 kiB|
|  4  |    8| 64 kiB|
|  5  |   16|128 kiB|
|  6  |   32|256 kiB|
|  7  |   64|512 kiB|
|  8  |  128|  1 MiB|
|  9  |  256|  2 MiB|

`ROMFLAGS`; sets the additional features declared in the ROM header. Default
value is 7.

|Value|Features              |
|:---:|:---------------------|
|  0  |No additional features|
|  1  |1 rumble speed        |
|  3  |3 rumble speeds       |
|  4  |RTC                   |
|  5  |1 rumble speed, RTC   |
|  7  |3 rumble speeds, RTC  |
