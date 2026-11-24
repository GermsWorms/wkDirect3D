# wkDirect3D

Makes the graphics card draw the in-game picture of **Worms Armageddon 3.8.1**, instead of the CPU. The picture stays the
same, pixel for pixel; it is only drawn sooner.

It is a WormKit module: one file, `wkDirect3D.dll`, with nothing to set up.

**This is a beta (0.5).** It has been tested on one PC, in a window, on replays. See "Not tested yet" before you rely on it.

New in 0.4: it draws the **zoomed map** for [wkMapZoom](https://github.com/GermsWorms/wkMapZoom) 5 (see "Zoom"), and other
modules can have true-colour pictures and lines drawn over the game through it
([wkSpeedometer](https://github.com/GermsWorms/wkSpeedometer) does).

## How much faster

Frames a second on one desktop PC, 3.8.1 with the Direct3D 9 (shader) renderer, in a window, vsync off, full detail:

| | WA 3.8.1 | with [wkFastDraw](https://github.com/GermsWorms/wkFastDraw) | with wkDirect3D |
|---|---|---|---|
| 1920x1080 | 470 | 1120 to 1230 | 1850 to 1950 |
| 1920x1080, a match full of explosions | 350 | 1050 to 1160 | 2380 to 2460 |
| 2560x1440 | 310 to 340 | 670 to 840 | 1830 to 1860 |
| 3840x2160 | 210 | 360 to 390 | 1580 |
| 3840x2160, a large open map | 100 | 250 | 1960 to 2010 |
| 1920x1080, on 4 CPU threads | | 1430 | 2100 to 2200 |

Your numbers will differ with your PC and the map. The bigger the picture, the more it helps: the CPU's work grows with every
pixel, the graphics card hardly notices. With vsync on, the frame rate stays your monitor's and WA uses less of your CPU
instead: at 120 Hz and 1080p, WA's main thread used 11% of one core (14% with wkFastDraw).

## Zoom

With [wkMapZoom](https://github.com/GermsWorms/wkMapZoom) 5 loaded, wkDirect3D draws the zoomed map too. wkMapZoom decides
the zoom (the mouse wheel, its auto zoom, its speed zoom) and has WA draw the whole area the zoomed view shows; wkDirect3D
draws that at full size into a picture of its own, exactly as it draws an ordinary frame, and then puts it on the screen at
the zoom, each screen pixel the average of the map pixels it covers. The HUD stays at its normal size.

Frames a second, a large open map at full detail, vsync off:

| | wkMapZoom 4.3 (draws on the CPU) | wkMapZoom 5 + wkDirect3D |
|---|---|---|
| 1920x1080 at 35% | 57 to 60 | 1440 |
| 1920x1080 at 35%, on 4 CPU threads | 62 | 1520 |
| 2560x1440 at 35% | 39 to 42 | 1180 |
| 1920x1080 at 25% | | 1310 |
| 2560x1440 at 25% | | 900 |
| 3840x2160 at 50% | | 870 |
| 3840x2160 at 25% | | 460 |

The full-size map is checked the same way as an ordinary frame (see below): 0 pixels differ from WA's own drawing, from
25% to 800%. Zoomed out, that map is big: at 25% sixteen times the screen (at 3840x2160, 664 MB on the graphics card). If
the card cannot make it, wkMapZoom's zoom goes less far out, and the log says so.

## How it works

WA 3.8.1 is drawn by the CPU. Every frame, one thread puts the whole picture together in memory, one byte a pixel (a number
from 0 to 255: the colour's place in the palette). The graphics card only gets the finished picture and turns the numbers
into colours.

wkDirect3D takes over the big, simple part of that work:

1. **Land, sky, back layers, fills and sprites** are not copied by the CPU any more. Each becomes a rectangle in a list,
   and the graphics card draws the list. The pieces of the map are kept on the card as textures; sprites are sent each
   frame.
2. The card draws them into a picture that still holds **palette numbers, not colours**, with the same see-through rule as
   WA (one colour number of each piece is skipped). So the result is the same numbers in the same places.
3. **Everything else is still drawn by WA's own code** (lines, single pixels, the dotted see-through sprites, sprites turned
   on their side, and sprites whose colours depend on what is under them). WA draws those into an empty frame, and the
   module lays the touched parts over the card's picture, in WA's drawing order.
4. At the end, the picture goes through WA's palette onto the screen, the way WA's Direct3D 9 (shader) renderer does it.

**How it gets in.** It changes nothing when WA loads it. When the first game is on the screen, it checks that this is WA
3.8.1 and swaps entries in a few of WA's function tables (and the target of four calls to WA's sprite routine). None of
WA's files are changed.

**It steps aside by itself.** With another renderer than Direct3D 9 (shader), it does nothing. A frame that another module
draws itself (a zoomed map, for example) is shown by WA as ever. Frames that Export Video reads are drawn by WA. If the
graphics device is lost or something is missing, WA draws.

**How "the same picture" was checked.** The module has a test mode in which every drawing call is made a second time by
WA's own code alone, into a second frame, and the card's picture is read back and compared with it pixel by pixel. Eight
replays, 3,600 to 27,400 frames each (one of them from its start to its end): 0 pixels differ. Screenshots: 0 of 2,073,600 pixels differ. Export Video: 121 of
121 frames the same as without the module.

## What it doesn't change

- **The game.** Only the picture is drawn elsewhere. Physics, random numbers, turns, replays and what is sent to other
  players are WA's own, so nobody else needs the module.
- **Input lag.** WA still hands over one frame at a time; with vsync on, the wait for the monitor measured the same as
  without the module (7.6 to 8.0 ms at 120 Hz), so no extra frame is queued.
- **A map drawn by another module.** wkMapZoom up to 4.3 draws the zoomed map itself, so wkDirect3D has nothing to
  speed up there (at 100% zoom it draws: 486 to 1373 fps at 1080p with 4.3 beta 2 loaded). wkMapZoom 5 leaves the
  drawing to wkDirect3D (see "Zoom").

## Install

1. Download [`release/wkDirect3D.dll`](release/wkDirect3D.dll) and put it in the WA folder, next to `WA.exe`.
2. In WA: Options > Advanced > turn on "Load WormKit modules", set Graphics API to **Direct3D 9 (shader)**, and restart WA.

To remove it, delete the file while WA is closed. `install.ps1` (and `install.ps1 -Remove`) does the same.

To switch it off without removing it, put a file `wkDirect3D.ini` next to `WA.exe` with these two lines (or, from 0.5,
switch it off and on in the game with [wkModMenu](https://github.com/GermsWorms/wkModMenu): Esc, Mods, wkDirect3D):

```
[wkDirect3D]
Enabled=0
```

`%LOCALAPPDATA%\wkDirect3D\wkDirect3D.log` says whether it is on, and why not if it isn't. It needs a graphics card with
pixel shader 2.0 (any card of the last 20 years) and a processor with SSE2.

## Other modules

Loaded together with wkDirect3D, each for a 20 second replay, with the picture check on (details, numbers and gaps in
[COMPATIBILITY.md](COMPATIBILITY.md)):

| Ran together, no crash | |
|---|---|
| Drawing and zoom | wkMapZoom 5 (its zoom is drawn by wkDirect3D) and 4.3 beta 2, wkSpeedometer, wkModMenu (its panel is drawn through wkDirect3D), wkFastDraw, wkVista 0.1.4, wkZoom 0.2.0, wkRGBA, wkJellyWorm (3.8.1 v1) |
| Modding | WormForge 0.9.9 |
| Game and maps | wkRealTime 0.0.9.2, wkTerrainSync 1.2.6.1, wkTrackMeBetter 3.8.1, wkWall2Wall, wkPin 1.0.0.8, wkPlaceWorms, wkGolf, wkCrateEditor 1.0, wkRopeRaceDirection, wkTrackTime |
| Controls, sound, menus | wkRemapKeys, wkVolumeControl, wkSuperFrontend, wkHelp, wkSetRes |

Two rules decide what happens when another module draws too:

- **A frame the other module draws itself is its own.** wkDirect3D stands aside (wkMapZoom or wkZoom zoomed, for
  example) and draws again when WA's own map drawing comes back.
- **A module that works on WA's finished picture** (WormForge, for example) is overridden in the frames wkDirect3D draws:
  what it would add there is left out, and a notice on the screen says so for 15 seconds at the start of the game (and
  the log). wkMapZoom is the exception: its part is kept running.

## For other modules

wkDirect3D.dll exports a few functions (cdecl, to be called on WA's thread while WA draws a frame; find them with
`GetModuleHandleA("wkDirect3D.dll")` and `GetProcAddress`). Their comments in [`src/wkDirect3D.c`](src/wkDirect3D.c)
say exactly what each takes.

- `wkDirect3D_Api()` returns the interface's number (1).
- `wkModSettings()` and `wkModSettingsChanged()` are for wkModMenu: what the settings are, and that one was changed.
- `wkDirect3D_Overlay(argb, w, h, pitch_bytes, x, y)` lays a true-colour picture (premultiplied A8R8G8B8) over the
  finished frame; `wkDirect3D_Triangles(vertices, count)` does the same with coloured, see-through triangles. Both
  return 0 when wkDirect3D is not drawing the frame, so the caller can draw into WA's own frame instead.
- `wkDirect3D_MapMax`, `wkDirect3D_MapBegin`, `wkDirect3D_MapEnd` are the zoom's: a module has WA draw a map bigger
  (or smaller) than the screen into a frame wkDirect3D hands out, and wkDirect3D puts it on the screen at a zoom.

## Not tested yet

- **Fullscreen, live games and online games.** Replays in a window only so far. Nothing the module does touches the game
  itself, but it has not been shown.
- **Two games in a row without closing WA.** One game from its start to its end was tested, and a replay started again
  in the same run. A second game started from WA's menus was not.
- **Weak or built-in graphics, other PCs, Windows 7/8/10, Wine.** One desktop PC with Windows 11.
- **GOG's WA 3.8.1.** Steam's was used.
- **The other drawing modules' own features** together with it: wkVista's zoom and full-colour maps, wkZoom's zoom,
  WormForge with mods on, wkRGBA with a full-colour map.
- **The zoom on a weak graphics card.** The numbers above are from a fast one.

If something looks wrong, switch it off (see Install) and please
[open an issue](https://github.com/GermsWorms/wkDirect3D/issues) with the log.

## Good to know

- With vsync **off** you get many more frames a second. WA measures the mouse flick that takes over the camera per drawn
  frame, so at very high frame rates that flick has to be quicker. Holding the left mouse button, Scroll Lock, WA's
  `CameraUnlockMouseSpeed` setting or vsync all get around it.
- With wkFastDraw loaded too, both work: wkDirect3D draws the frames it can, and wkFastDraw speeds up the ones WA draws.
- WA's own screenshots show the picture as drawn (zoomed too, then in WA's 256 colours), but not what other modules lay
  over it through wkDirect3D (wkSpeedometer's dial). Videos made with WA's Export Video are drawn by WA and are not
  zoomed.
- One colour number (253) means "nothing here" in the frame WA's leftovers are drawn into. Something drawn by the CPU in
  exactly that number would not show. The check found no such pixel in any test.
- As with every WormKit module, WA notes a scrambled checksum of the file in replays and sends it to the other players. WA
  does nothing with it.

## Build

`build.ps1` needs 32-bit MinGW gcc and makes `wkDirect3D.dll`. `build.ps1 -Shaders` also makes `src\shaders.h` again from
`tools\mkshaders.c` (needs Windows' `d3dcompiler_47.dll`).

## License

[MIT](LICENSE). Worms Armageddon is Team17's; this project is not affiliated with Team17.
