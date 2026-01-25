Enables traveling to your bases by pressing the number keys with the fast travel map open.

This just saves you the time of scrolling around to click on your bases every time. It also doesn't ask for confirmation when you use a hotkey to fast travel.

This mod respects the game's rules for when you are allowed to fast travel, but should be compatible with things like the AlwaysFastTravel mod on Nexus that allow you to fast travel from the normal map.

## Usage

The numbers are assigned to your bases in order from northmost to southmost on the map.

It is set up so that all the numbers 0-9 work (with 0 being the 10th base), in case you have turned that setting way up.

Sadly I don't render the numbers in game on the map, but the map already gets pretty cluttered.

## Installation

The recommended method is to install the mod by subscribing on the [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3653615602).

After you subscribe to the mod, do these steps to enable the mod:

1. Launch the game and wait until you get to the title screen.
2. Go to Options > Mod Management and make sure **Enable Mod** is set to **ON**.
3. Make sure the checkboxes next to Fast Travel Hotkeys and UE4SS Experimental (Palworld) are **CHECKED**
4. Click the blue **Save** button and the game will now restart.
5. Once the game starts up again, Fast Travel Hotkeys should now be enabled.

## Building

To build the mod use the following command in the root of the repository:

```bash
make FastTravelHotkeys
```

This will generate both a folder `./out/workshop/3653615602` which contains the steam workshop files. As this mod is just a UE4SS lua script the make step is just copying some of the files into a different folder.

You can use the following command to install the generated files into your local Steam Workshop folder so that the game will find them:

```bash
make install MODS=FastTravelHotkeys
```
