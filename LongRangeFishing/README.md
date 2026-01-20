# Long Range Fishing

This mod extends the range at which you can use fishing rods so that it no longer feels awkwardly short.

The basic fishing rod is left unchanged and each level increases the range by 20%, so the level 6 rod is now double what it was in the base game.

## Installation

The recommended method is to install the mod by subscribing on the [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3627071990).

After you subscribe to the mod, do these steps to enable the mod:

1. Launch the game and wait until you get to the title screen.
2. Go to Options > Mod Management and make sure **Enable Mod** is set to **ON**.
3. Make sure the checkboxes next to Long Range Fishing, UE4SS Experimental (Palworld), and PalSchema are **CHECKED**
4. Click the blue **Save** button and the game will now restart.
5. Once the game starts up again, Long Range Fishing should now be enabled.

## Building

To build the mod use the following command in the root of the repository:

```bash
make LongRangeFishing
```

This will generate both a folder `./out/workshop/3627071990` which contains the steam workshop files. As this mod is just using PalSchema the make step is just copying some of the files into a different folder.

You can use the following command to install the generated files into your local Steam Workshop folder so that the game will find them:

```bash
make install MODS=LongRangeFishing
```
