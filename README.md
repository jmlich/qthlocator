# QTH Locator

This application calculates the Maidenhead Locator System (also known as QTH Locator or IARU Locator) geocode from your GPS position. It is used by amateur radio operators to accurately and succinctly describe their geographic coordinates.

## Features

* Calculate QTH Locator from GPS position
* Enter location in grid square coordinates
* Create a log of transmissions
* Quickly enter callsign, station location, human-readable location, and QTH Locator in a specified format into one text field
* Display distance and direction between the user and the called station
* For example, you can enter the following:

## Usage

On the main screen, you will find an entry field where you can enter a location in grid square coordinates. This field supports various types of input which are directly shown on the screen. The types of input include:

* Callsign: A unique identifier assigned to a radio station.
* Station Location: This can be `p` (portable), `m` (mobile), or `h` (home), representing the type of station.
* Human Readable Location: A descriptive name of the location, such as the name of a city.
* QTH Locator: Coordinates in the Maidenhead Locator System.

```
Tomas Praha p Mont Blanc JN35KT
```

This input consists of:

- `Tomas Praha`: The callsign
- `p`: The station type (portable)
- `Mont Blanc`: The human-readable location
- `JN35KT`: The QTH Locator for Mont Blanc

The application primarily uses GPS to determine your position, which may take some time on Ubuntu Touch devices. Once the GPS position is acquired, it is automatically displayed.

To manually select your position, double-click on the screen.

## Additional Resources

- [Translate](https://app.transifex.com/jozef-mlich/qthlocator/dashboard/)
- [Install from Open-Store](https://open-store.io/app/com.github.jmlich.qthlocator)

## License

Copyright (C) 2024  Jozef Mlich

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License version 3, as published by the
Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranties of MERCHANTABILITY, SATISFACTORY
QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <http://www.gnu.org/licenses/>.
