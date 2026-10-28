-- wonder-the-singing-waterfall.lua : CB zone 3. Water tumbles down a green cliff in one long note; rare flowers grow where the spray lands; a ledge hides behind the curtain.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H

L.sky(c, "day", 100)
L.cloud(c, 30, 20, 14); L.cloud(c, 210, 26, 12)
-- rainbow in the spray (drawn first, cliff overlaps it)
local rb = { "#d6322b", "#f08a24", "#f5cf6a", "#7ab55c", "#3f8fb0", "#7b66b4" }
for i, col in ipairs(rb) do
  local r = 56 - (i - 1) * 2
  local m = c:ellipse(76, 104, r, r - 4); m:cut(c:ellipse(76, 104, r - 2, r - 6)); m:clip(c:rect(0, 0, W, 100))
  c:fill(m, col)
end
-- far green hills
c:fill(L.below(c, function(x) return 74 + 8 * math.sin(x / 21) end), "#7ab5a0")
c:fill(L.below(c, function(x) return 86 + 6 * math.sin(x / 15 + 1) end), "#5a9a7a")

-- the cliff --------------------------------------------------------------------------------------------
local cliff = c:poly({ {64,102},{70,44},{84,22},{100,14},{170,14},{186,26},{196,58},{204,102} })
c:part(cliff, GV.ramp("#4a8a3e"), { cres = 7, deep = 12, gloss = false })
-- rock bands and mossy tufts
for _, r in ipairs({ {72,60,18},{74,84,22},{160,50,22},{168,76,18},{98,40,16},{176,92,16} }) do
  c:fill(c:rect(r[1], r[2], r[1] + r[3], r[2] + 1), "#2f5a2a")
  c:fill(c:rect(r[1] + 2, r[2] + 2, r[1] + r[3] - 4, r[2] + 2), "#6a9a3a")
end
-- stone lip and the notch
c:part(c:rect(112, 12, 158, 18), GV.ramp("#8b8f96"), { cres = 3, deep = 5, gloss = false })
-- trees on top
for _, t in ipairs({ {86,14},{100,10},{170,12},{184,18} }) do
  c:fill(c:rect(t[1], t[2], t[1] + 1, t[2] + 5), "#5e2f1e")
  c:part(c:ellipse(t[1] + 1, t[2] - 2, 8, 6), GV.ramp("#2f7a3a"), { cres = 3, deep = 5, gloss = false })
end

-- hidden alcove behind the curtain
c:part(c:rrect(118, 60, 150, 86, 5), GV.ramp("#2a4a50"), { flat = true, gloss = false, contour = "#2a1a10" })
c:fill(c:rect(120, 80, 148, 86), "#8a6a44")           -- the ledge floor
c:fill(c:rect(120, 80, 148, 80), "#c9a96e")
-- rare flowers on the ledge
local function bloom(x, y, col, ctr)
  c:fill(c:rect(x, y, x, 80), "#4a8a3e")
  for _, d in ipairs({ {-1,0},{1,0},{0,-1},{0,1} }) do c:px(x + d[1] * 2, y + d[2] * 2, col); c:px(x + d[1], y + d[2], col) end
  c:px(x, y, ctr or "#fff1c8")
end
bloom(124, 72, "#e46a9b"); bloom(130, 74, "#7b66b4"); bloom(137, 71, "#f08a24"); bloom(143, 74, "#f6b8cf")
c:px(133, 77, "#7ab55c"); c:px(140, 78, "#7ab55c")

-- the curtain of water: long vertical bands, thinner / see-through at the alcove
local cur = c:rect(120, 16, 148, 104)
c:fill(cur, "#c8ecdc")
for x = 121, 147, 4 do c:fill(c:rect(x, 17, x, 104), "#e6f8f0") end
for x = 123, 147, 6 do c:fill(c:rect(x, 17, x, 103), "#8fcbd8") end
c:fill(c:rect(120, 16, 120, 104), "#8fcbd8"); c:fill(c:rect(148, 16, 148, 104), "#5a86b8")
-- see-through window over the alcove: re-show the dark behind in 1 px stripes
for x = 122, 146, 3 do c:fill(c:rect(x, 62, x, 79), "#2a4a50") end
for x = 121, 147, 6 do c:fill(c:rect(x, 62, x, 79), "#8fcbd8") end
-- ledge flowers pop over the stripes
bloom(124, 72, "#e46a9b"); bloom(130, 74, "#7b66b4"); bloom(137, 71, "#f08a24"); bloom(143, 74, "#f6b8cf")
-- smaller side streams
c:fill(c:rect(104, 22, 107, 56), "#c8ecdc"); c:fill(c:rect(105, 22, 105, 56), "#e6f8f0")
c:fill(c:rect(164, 26, 166, 70), "#c8ecdc"); c:fill(c:rect(165, 26, 165, 70), "#e6f8f0")

-- pool at the base -------------------------------------------------------------------------------------
c:bands(c:rect(0, 100, W - 1, H - 1), { "#6fd0c8", "#4ab8be", "#3aa0b4", "#3088a8", "#2a7498", "#256088" }, { dir = "v" })
for _, r in ipairs({ {20,106,10},{50,112,12},{176,108,12},{208,114,10},{90,118,14},{160,122,12},{12,124,10},{210,126,12} }) do c:fill(c:rect(r[1], r[2], r[1] + r[3], r[2]), "#c8ecdc") end
-- spray and foam where the water lands
for _, f in ipairs({ {128,104,7,4},{140,104,6,4},{116,106,5,3},{152,106,5,3},{134,108,10,3} }) do c:part(c:ellipse(f[1], f[2], f[3], f[4]), GV.ramp("#e6f8f0", { dot = "#fff3c8", rim = "#f5f0e0", shade = "#8fcbd8" }), { flat = true, gloss = false, outline = false }) end
-- mist puffs up the cliff base
for _, f in ipairs({ {110,96,6,3},{158,98,6,3},{126,98,5,3} }) do c:fill(c:ellipse(f[1], f[2], f[3], f[4]), "#e6f8f0") end
-- ripples rings
for _, r in ipairs({ {134,114,18,3},{134,118,30,5} }) do
  local m = c:ellipse(r[1], r[2], r[3], r[4]); m:cut(c:ellipse(r[1], r[2], r[3] - 1, r[4] - 1)); c:fill(m, "#8fe0d4")
end
-- stepping stones
for _, s in ipairs({ {88,112,7,3},{104,118,6,3},{176,116,7,3} }) do c:part(c:ellipse(s[1], s[2], s[3], s[4]), GV.ramp("#8b8f96"), { cres = 2, deep = 3, gloss = false }) end

-- foreground banks: left flower bank, right big leaves -------------------------------------------------------
local bankL = c:poly({ {0,H},{0,96},{20,92},{48,98},{64,106},{60,118},{40,H} })
c:part(bankL, GV.ramp("#6a9a3a"), { cres = 5, deep = 8, gloss = false })
local bankR = c:poly({ {W,H},{W,94},{214,96},{196,106},{190,122},{200,H} })
c:part(bankR, GV.ramp("#6a9a3a"), { cres = 5, deep = 8, gloss = false })
local function flower(x, y, col, ctr)
  c:fill(c:rect(x, y, x, y + 7), "#4a8a3e")
  c:part(c:ellipse(x, y - 1, 3, 3), GV.ramp(col), { flat = true, gloss = false, outline = false })
  c:fill(c:rect(x - 1, y - 2, x, y - 1), ctr or "#f5cf6a")
end
flower(8, 104, "#e46a9b"); flower(20, 108, "#f08a24"); flower(32, 104, "#7b66b4"); flower(44, 112, "#f6b8cf"); flower(14, 118, "#f6b8cf"); flower(28, 120, "#e46a9b")
flower(212, 106, "#f08a24"); flower(224, 110, "#7b66b4"); flower(206, 118, "#e46a9b"); flower(228, 122, "#f6b8cf")
-- big leaves
for _, p in ipairs({ {232,86,5,12},{218,92,5,10},{4,86,5,10},{16,84,4,8} }) do
  c:part(c:ellipse(p[1], p[2], p[3], p[4]), GV.ramp("#2f7a3a"), { cres = 3, deep = 5, gloss = false })
end
-- a little parrot-green bird (hummingbird) hovering at the spray, and music notes carried on the water's song
local bx, by = 94, 70
c:part(c:ellipse(bx, by, 5, 3), GV.ramp("#3f8fb0"), { cres = 2, deep = 3, gloss = false })
c:part(c:ellipse(bx - 5, by - 1, 3, 3), GV.ramp("#3f8fb0"), { flat = true, gloss = false }); c:eye(bx - 7, by - 3, true)
c:fill(c:rect(bx - 12, by, bx - 8, by), "#2a1a10"); c:fill(c:rect(bx + 4, by - 1, bx + 8, by), "#2a1a10")
c:part(c:ellipse(bx + 1, by - 5, 4, 2), GV.ramp("#8fcbd8"), { flat = true, gloss = false })
for _, n in ipairs({ {80,52},{70,42},{58,48} }) do
  c:fill(c:ellipse(n[1], n[2] + 5, 2, 1.5), "#fff1c8"); c:fill(c:rect(n[1] + 2, n[2] - 3, n[1] + 2, n[2] + 4), "#fff1c8")
  c:px(n[1] + 3, n[2] - 3, "#fff1c8"); c:px(n[1] + 4, n[2] - 2, "#fff1c8")
end

L.finish(c, "wonder-the-singing-waterfall")
