# TPP1

This repository aims to [define and specify a GB/GBC mapper](specification.md).

There is a test ROM available here. In order to build it, you will need
[RGBDS version 0.5.1 or later](https://github.com/gbdev/rgbds).

Once that is done, you can build the test ROM using the `make` command in the
repository's main directory; the output will be called `testrom.gb`. Using
`make clean` will remove the built files.

The compilation of the test ROM can be parameterized via four variables passed
to `make`, those being `ROMSIZE`, `RAMSIZE`, `RTC` and `RUMBLE`. For instance,
in order to set all of them to their maximum possible values, compile the test
ROM as `make ROMSIZE=F RAMSIZE=9 RTC=ON RUMBLE=MULTI`.

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

`RTC`: enables or disables RTC support in the header. Any non-empty value will
enable RTC support; set the variable to an empty value to disable it. Default
value is on.

`RUMBLE`: sets the type of rumble supported in the header. Setting the variable
to the value `MULTI` will enable three rumble speeds; any other non-empty value
will enable a single speed, and an empty value will disable rumble altogether.
Default is 3 speeds.
