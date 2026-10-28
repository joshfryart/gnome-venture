-- lair-snowcrown-peak.lua : Boss lair (ESA, zone 2). The Mountain Lion of the Snowpeak, on a rock below a snow-crowned African peak. Bright day. Params out= ase=
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
L.sky(c, "day", 92)
for _, cl in ipairs({ {36,26,16},{206,20,18},{170,46,14},{70,50,12} }) do L.cloud(c, cl[1], cl[2], cl[3]) end
-- the peak: rock flanks, snow crown with a zig-zag crown edge
local peak = c:poly({ {30,100},{70,70},{98,44},{112,24},{128,24},{142,44},{170,70},{210,100},{210,H},{30,H} })
c:part(peak, GV.ramp("#8a7a8a"), { cres = 10, deep = 14, gloss = false, outline = false })
local snow = peak:copy():clip(c:poly({ {0,0},{W,0},{W,44},{160,52},{150,44},{140,56},{130,46},{120,58},{110,46},{100,56},{90,44},{80,52},{0,44} }))
c:part(snow, GV.ramp("#eef0f8"), { cres = 5, deep = 7, gloss = false, outline = false })
for _, l in ipairs({ { {104,64},{98,80},{102,92} }, { {136,62},{144,78},{140,90} }, { {120,70},{118,86} } }) do c:fill(c:line(l, 2), "#6a5a6a") end
-- cloud belt around the peak
L.cloud(c, 80, 78, 22, "#f4f0e0", "#cfd8e4"); L.cloud(c, 168, 82, 24, "#f4f0e0", "#cfd8e4")
-- foothill heath and savanna
c:part(L.below(c, function(x) return 98 + math.sin(x * 0.05 + 1) * 5 end), GV.ramp("#6a9a3a"), { outline = false, gloss = false, cres = 3, deep = 4 })
c:part(L.below(c, function(x) return 108 + math.sin(x * 0.06) * 3 end), GV.ramp("#c9a96e"), { outline = false, gloss = false, cres = 3, deep = 4 })
-- acacia trees
local function acacia(x, y, s)
  c:part(c:poly({ {x - 1, y}, {x - 1, y - 12 * s}, {x - 5, y - 18 * s}, {x - 2, y - 16 * s}, {x + 1, y - 12 * s}, {x + 3, y - 18 * s}, {x + 5, y - 17 * s}, {x + 2, y - 12 * s}, {x + 2, y} }), GV.ramp("#8a4f2a"), { flat = true, gloss = false })
  local cr = c:ellipse(x, y - 21 * s, 17 * s, 5 * s)
  c:part(cr, GV.ramp("#6a9a3a"), { cres = 3, deep = 4, gloss = false })
  c:part(c:ellipse(x - 7 * s, y - 25 * s, 7 * s, 3 * s), GV.ramp("#7ab55c"), { flat = true, outline = false })
end
acacia(28, 122, 1); acacia(214, 124, 1.1); acacia(60, 112, 0.6); acacia(188, 110, 0.6)
-- giant lobelia on the slopes
for _, p in ipairs({ {40,100},{46,104},{196,102} }) do c:fill(c:rect(p[1], p[2] - 8, p[1] + 1, p[2]), "#4a8a3e"); c:part(c:ellipse(p[1] + 0.5, p[2] - 10, 2.5, 4), GV.ramp("#a4b86a"), { flat = true }) end
-- the lion's rock
c:part(c:poly({ {64,H},{72,118},{90,106},{150,106},{168,118},{176,H} }), GV.ramp("#a89a82"), { cres = 8, deep = 11, gloss = false })
c:seam({ {82,120},{96,116},{104,122} }, { free = true, on = 3, off = 0, gap = "#4a3a2a" }); c:seam({ {140,118},{154,120},{160,126} }, { free = true, on = 3, off = 0, gap = "#4a3a2a" })
-- the Mountain Lion
local CX = 120
local TAWNY, MANE = GV.ramp("#d9a660"), GV.ramp("#8a4f2a")
c:part(c:line({ {CX + 22, 108}, {CX + 34, 100}, {CX + 32, 84} }, 4), TAWNY, { cres = 2, deep = 3, gloss = false })   -- tail
c:part(c:ellipse(CX + 32, 80, 4, 5), MANE, { cres = 2, deep = 3, gloss = false })
c:part(c:ellipse(CX, 96, 22, 14), TAWNY, { cres = 5, deep = 7 })                                  -- body
for _, sx in ipairs({ -9, 9 }) do c:part(c:rrect(CX + sx - 4, 100, CX + sx + 3, 112, 2), TAWNY, { cres = 2, deep = 3, gloss = false }); c:part(c:ellipse(CX + sx, 112, 5, 3), GV.ramp("#f2e4c0"), { flat = true }) end
c:part(c:ellipse(CX, 66, 28, 25), MANE, { cres = 6, deep = 9 })                                   -- mane
for _, a in ipairs({ -22, -12, 12, 22 }) do c:part(c:poly({ {CX + a - 4, 86}, {CX + a, 94}, {CX + a + 4, 86} }), MANE, { flat = true, outline = false }) end
for _, s in ipairs({ -1, 1 }) do c:part(c:ellipse(CX + s * 17, 48, 5, 5), TAWNY, { flat = true }); c:part(c:ellipse(CX + s * 17, 48, 2, 2), GV.ramp("#d9885a"), { flat = true, outline = false }) end
c:part(c:ellipse(CX, 68, 17, 15), TAWNY, { cres = 4, deep = 6 })                                  -- face
c:part(c:ellipse(CX, 76, 9, 6), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 2, deep = 3, gloss = false })
c:fill(c:rect(CX - 3, 69, CX + 2, 72), "#2a1a10"); c:px(CX - 2, 73, "#2a1a10"); c:px(CX + 1, 73, "#2a1a10")
c:fill(c:rect(CX - 5, 77, CX - 1, 77), "#2a1a10"); c:fill(c:rect(CX + 0, 77, CX + 4, 77), "#2a1a10")
c:eye(CX - 12, 60); c:eye(CX + 7, 60)
for k = 0, 4 do c:px(CX - 13 + k, (k < 3) and 58 or 59, "#2a1a10"); c:px(CX + 13 - k, (k < 3) and 58 or 59, "#2a1a10") end
-- a little snow crown the lion has stolen: tiny pale zig-zag circlet on the mane
c:fill(c:poly({ {CX - 8, 44}, {CX - 6, 39}, {CX - 3, 43}, {CX, 38}, {CX + 3, 43}, {CX + 6, 39}, {CX + 8, 44} }), "#eef0f8")
c:px(CX, 39, "#fff1c8")
-- birds and grass
for _, g in ipairs({ {50,60},{180,66},{196,30} }) do c:px(g[1], g[2], "#2a1a10"); c:px(g[1] + 1, g[2] + 1, "#2a1a10"); c:px(g[1] + 2, g[2], "#2a1a10"); c:px(g[1] + 3, g[2] + 1, "#2a1a10"); c:px(g[1] + 4, g[2], "#2a1a10") end
for _, x in ipairs({ 16, 44, 70, 176, 200, 228 }) do c:px(x, 126 + x % 4, "#a4b86a"); c:px(x + 1, 125 + x % 4, "#c8d77a"); c:px(x + 2, 126 + x % 4, "#a4b86a") end
c:ground(CX, 113, 24, 2)
L.finish(c, "lair-snowcrown-peak")
