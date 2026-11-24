# wkDirect3D with other WormKit modules

What was tested, with what result, failures and gaps included. Worms Armageddon 3.8.1 (Steam), Direct3D 9 (shader palette)
renderer, windowed, vsync off, in an isolated copy of the game playing a replay. "Check" means wkDirect3D's own picture check
(`WKD3D_CHECK`): every drawing call is made a second time by WA alone into a second frame, and the GPU's picture is compared
with that frame pixel by pixel.

**These are first passes (2026-11-24).** They show that the modules load and run together and what the frame rate does.
They do **not** yet exercise most of the other modules' own drawing features (fog, added sprites, full-colour land); zoom
only for wkMapZoom and wkZoom. See "Not tested yet".

## First pass: each module alone and with wkDirect3D (1280x720, full detail, `ttrr` replay, 20 s each)

| Module | fps alone | fps with wkDirect3D | wkDirect3D drew | Check | Notes |
|---|---|---|---|---|---|
| (none) | 994 | 2256 | every frame | 1200 frames, 0 differ | |
| wkMapZoom 4.3 beta 2 | 828 | 1912 | every frame (100% zoom) | 499 of 1000 frames differ | the differing pixels are wkMapZoom's speedometer dial, which it draws itself: present in the GPU's picture, not in WA's own, as it should be |
| wkRemapKeys | 914 | 2139 | every frame | 1000 frames, 0 differ | |
| wkRealTime 0.0.9.2 (wkZRealTime) | 921 | 2185 | every frame | 1200 frames, 0 differ | |
| WormForge 0.9.9 (wkLua) | 879 | 2086 | every frame | 1000 frames, 0 differ | no mods enabled in this run |
| wkVista 0.1.4 | 291 | 778 | every frame | 600 frames, 0 differ | at 1x, ordinary map; wkVista's own true-colour step is not run in frames wkDirect3D draws (same picture) |
| wkZoom 0.2.0 | 848 | 2228 | every frame | 1200 frames, 0 differ | default scale |
| wkRGBA (repo build) | 896 | 2217 | every frame | 1200 frames, 0 differ | no full-colour map in this run |
| wkJellyWorm 3.8.1 v1 | 934 | 2358 | every frame | 800 frames, 0 differ | its own renderer is off by default (and needs WA's OpenGL renderer) |
| wkTerrainSync 1.2.6.1 | 1014 | 2284 | every frame | 1200 frames, 0 differ | |
| wkTrackMeBetter 3.8.1 | 916 | 2212 | every frame | 1200 frames, 0 differ | |
| wkPin 1.0.0.8 | 948 | 2276 | every frame | 1200 frames, 0 differ | |
| wkVolumeControl | 975 | 2168 | every frame | 1000 frames, 0 differ | |
| wkWall2Wall | 874 | 2175 | every frame | 1200 frames, 0 differ | |
| wkSuperFrontend | 915 | 2231 | every frame | 1200 frames, 0 differ | |
| nine at once (wkRealTime, wkTerrainSync, wkTrackMeBetter, wkPin, wkVolumeControl, wkWall2Wall, wkSuperFrontend, wkRemapKeys, wkMapZoom) | 879 | 1903 | every frame | 493 of 1000 frames differ | wkMapZoom's dial again |

No crash, no ERRORLOG.TXT, in any of the 48 runs.

## Second pass: more modules, and several at once (wkDirect3D 0.3 beta, same settings)

| Module | fps alone | fps with wkDirect3D | wkDirect3D drew | Check | Notes |
|---|---|---|---|---|---|
| wkHelp | 840 | 2225 | every frame | 1000 frames, 0 differ | |
| wkTrackTime | 898 | 2212 | every frame | 1000 frames, 0 differ | |
| wkPlaceWorms | 951 | 2151 | every frame | 1000 frames, 0 differ | |
| wkRopeRaceDirection | 735 | 2261 | every frame | 1000 frames, 0 differ | |
| wkSetRes (wkSetResCustom) | 991 | 2287 | every frame | 800 frames, 0 differ | |
| wkGolf | 793 | 1408 | every frame | 1000 frames, 0 differ | |
| wkCrateEditor 1.0 | 937 | 2187 | every frame | 1000 frames, 0 differ | |
| wkD3D9Wnd 0.7.1.1 | 929 | 2282 | every frame | 1200 frames, 0 differ | made for WA 3.7; nothing seen of it on 3.8.1 |

| Loaded together | fps | wkDirect3D drew |
|---|---|---|
| wkDirect3D + wkFastDraw + wkMapZoom (100% zoom) | 1539 | every frame |
| the same + WormForge 0.9.9 | 1810 to 1861 | every frame; the notice about WormForge is shown |
| the same + wkVista 0.1.4 | 1553 | every frame |
| the same + wkRealTime, wkTerrainSync, wkTrackMeBetter, wkPin, wkVolumeControl, wkWall2Wall, wkSuperFrontend, wkRemapKeys | 1473 | every frame |

No crash, no ERRORLOG.TXT, in any of these 28 runs. These replays hardly use what the eight modules are for (placing
worms, golf, crates, help screens), so this shows that they load and run beside wkDirect3D, not that every feature of
theirs was drawn.

## wkZoom 0.2.0 with its own zoom (wkDirect3D 0.3 beta)

| `wkZoom.ini`, `[Camera] Scale=` | wkZoom alone | wkZoom + wkDirect3D |
|---|---|---|
| `Auto` (1:1 here) | 848 fps | 2228 fps, wkDirect3D draws, check 0 differ |
| `2` (zoomed in) | 1361 to 1516 fps | 1418 to 1537 fps: wkZoom draws the picture itself, wkDirect3D stands aside after 8 frames; picture as with wkZoom alone |

(Each number is one 20 second run; runs of the same thing differ by about 10%.)
| `0.5` | 831 fps | 2208 fps, check 0 differ; wkZoom did not zoom out on this map (picture 1:1 in both) |

Before 0.3 beta's last change wkDirect3D kept drawing in the zoomed-in case: the picture was right but slower (1091
fps), because wkZoom's finished picture went to the graphics card a second way. Now it steps aside when a frame arrives
almost whole from elsewhere.

## wkMapZoom 4.3 beta 2 (1920x1080, full detail, `ttrr`)

| | wkMapZoom alone | wkMapZoom + wkDirect3D |
|---|---|---|
| 100% zoom | 486 fps | 1373 fps: wkDirect3D draws; wkMapZoom's work on WA's show-frame (its safety net, its dial) still runs each frame |
| zoomed out to 35% | 104 fps | 101 fps: wkMapZoom draws the map as ever, wkDirect3D keeps out (no gain yet: that is stage 3) |

Pictures looked at in both cases: as without wkDirect3D.

With wkMapZoom's settings as they come (its automatic zoom on), wkMapZoom draws some stretches of a replay itself: there
wkDirect3D stands aside (8 frames in, then for 64 to 512 frames at a time) and draws again when WA does. In those runs
wkDirect3D drew nearly every frame, at 1494 to 1565 fps.

wkMapZoom's own test script with wkDirect3D loaded (0.3 beta): a resolution switch (no crash; wkDirect3D lets go of its
graphics objects when WA re-makes its frame) and the graphics device lost for 30 frames and made anew at 100% zoom
(objects released, made again, wkDirect3D draws every frame again at 1500 to 1800 fps).

## wkMapZoom 5.0 beta and wkSpeedometer 1.0 (wkDirect3D 0.4 beta)

wkMapZoom 5 has no drawing of its own: wkDirect3D draws its zoomed map (README, "Zoom"). wkSpeedometer's dial and
movement line are laid over the picture by wkDirect3D in true colour (or go into WA's frame in WA's colours when
wkDirect3D is not there).

| Loaded together (1280x720, full detail, `ttrr`, 20 s each) | fps | |
|---|---|---|
| wkMapZoom 5 alone | 903 | stays at 100% ("the zoom needs wkDirect3D" in its log) |
| wkMapZoom 5 + wkDirect3D, 50% | 1551 | every frame zoomed, none refused |
| wkSpeedometer alone | 889 | the dial in WA's colours |
| wkSpeedometer + wkDirect3D | 1873 | the dial in true colour |
| wkDirect3D, wkFastDraw, wkMapZoom 5, wkSpeedometer, wkRemapKeys, wkRealTime, 35% | 1323 | every frame zoomed |
| the same with the auto zoom instead of a fixed zoom | 1510 | zooms in and out as it goes |
| wkDirect3D, wkFastDraw, wkMapZoom 5, wkSpeedometer and nine more (wkRealTime, wkTerrainSync, wkTrackMeBetter, wkPin, wkVolumeControl, wkWall2Wall, wkSuperFrontend, wkRemapKeys), 35% | 1323 | every frame zoomed |

Checked with the picture check on the zoomed map (every drawing call made again by WA alone at the map's full size,
compared pixel by pixel): 25%, 35%, 38%, 50%, 70%, 150%, 200%, and a scripted zoom from 25% to 800% and back: 0
pixels differ. A game played to its end while zoomed (with wkFastDraw and wkSpeedometer): WA closed by itself, no
crash. A screenshot taken while zoomed shows the zoomed picture. No crash, no ERRORLOG.TXT in about 40 runs.

wkMapZoom 4.3 beta 2 beside wkDirect3D 0.4 behaves as before (table below).

## How wkDirect3D keeps out of the way

- It changes nothing when WA loads it; it puts its hooks in when the first game is on the screen, so modules that check
  WA's code or function tables at load see WA's own.
- A frame in which another module draws the map itself (a zoomed frame of wkMapZoom) never reaches wkDirect3D's hooks: WA
  shows that frame as ever, and wkDirect3D waits until map drawing reaches it again. The same when frames arrive almost
  whole from another module with only the fixed parts drawn by WA (wkZoom zoomed in): after 8 such frames wkDirect3D
  stands aside and tries again now and then.
- A module that works on WA's finished picture in WA's show-frame step is overridden in the frames wkDirect3D draws (its
  step is not run there), and a notice on the screen says so for 15 seconds, and the log. Seen with WormForge 0.9.9
  (`wkLua.dll`); with no mods enabled nothing of it was missing from the picture. wkMapZoom's step is kept running.
- Frames that WA's Export Video reads are drawn by WA itself (checked: 121 of 121 exported frames equal to those without
  the module). Screenshots get the GPU's picture read back (checked: 0 of 2,073,600 pixels differ).
- What another module draws straight into WA's frame (wkMapZoom's dial and readout) is laid over the GPU's picture.

## Not tested yet

- **The other drawing modules' own features with wkDirect3D loaded:** wkVista's zoom and full-colour maps, wkZoom zoomed
  out and its HUD scale, WormForge with mods enabled (its GPU sprites, fog, zoom), wkRGBA with a full-colour map,
  wkJellyWorm's renderer. Expected (not shown): their zoomed frames are theirs; things they draw on the graphics card
  after WA's own show-frame are left out in frames wkDirect3D draws (with the notice).
- wkMapZoom's fullscreen switch with wkDirect3D loaded.
- Fullscreen, real games (replays only so far), online games, two games in a row without closing WA, weak or integrated
  graphics, GOG's WA, Wine.
- Could not be had from an author's own GitHub (The Ultimate Site or elsewhere only): RubberWorm, wkKick38, wkMapGEN, wkFOW,
  wkFileOverride, wkPackets, wkWormOrder, wkBigLobby. wkBindKeys and wkWormNAT2 need another DLL beside them and do not
  start in the test copy.
