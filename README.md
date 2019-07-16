[![Snap Status](https://build.snapcraft.io/badge/robert-ancell/garage-door.svg)](https://build.snapcraft.io/user/robert-ancell/garage-door)

Runs a simple web server that exposes a button to control a garage door motor via a relay.
Runs on a Raspberry Pi (A+ model recommended).

Install with:

    snap install garage-door
    snap connect garage-door:gpio pi:bcm-gpio-4
    snap start garage-door
