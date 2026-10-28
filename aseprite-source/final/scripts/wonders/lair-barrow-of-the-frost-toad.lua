-- lair-barrow-of-the-frost-toad.lua : boss lair, NWE, cold dawn. A great cold toad squats before an old grassy barrow.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, c, W, H = L.GV, L.new(), L.W, L.H
local SLUG = "lair-barrow-of-the-frost-toad"

c:bands(c:rect(0, 0, W - 1, 88), { "#5a6aa8", "#7484bc", "#92a2cc", "#b0bedc", "#cdd8ea", "#e4ecf4", "#f4e8dc" }, { dir = "v" })
L.cloud(c, 40, 30, 18, "#dfe6f2", "#b0bedc"); L.cloud(c, 190, 22, 20, "#dfe6f2", "#b0bedc"); L.cloud(c, 120, 48, 14, "#e8eef8", "#c0cce2")
-- pale low sun
c:fill(c:ellipse(205, 70, 9, 9):clip(c:rect(0, 0, W, 80)), "#fbe0a8"); c:fill(c:ellipse(205, 70, 6, 6):clip(c:rect(0, 0, W, 80)), "#fff1c8")
-- distant hills
c:fill(L.below(c, function(x) return 78 + 6 * math.sin(x / 35 + 2) + 2 * math.sin(x / 11) end), "#8c9cc4")
c:fill(L.below(c, function(x) return 88 + 4 * math.sin(x / 27) end), "#9ab4bc")
-- ground, frosty meadow
local g = L.below(c, function(x) return 100 + 2 * math.sin(x / 18) end)
c:fill(g, "#a4c0a8")
c:fill(g:copy():clip(c:rect(0, 114, W, H)), "#8cb098")
c:fill(g:copy():clip(c:rect(0, 124, W, H)), "#7aa088")
for i = 0, 40 do
  local x = (i * 53 + 7) % W; local y = 104 + (i * 17) % 26
  c:fill(c:rect(x, y, x + 2 + i % 3, y), "#e8f0f4")
end
for i = 0, 30 do
  local x = (i * 71 + 19) % W; local y = 103 + (i * 13) % 24
  c:px(x, y, "#4a8a3e"); c:px(x + 1, y - 1, "#7ab55c"); c:px(x + 2, y, "#4a8a3e")
end

-- the barrow: a grassy mound with a stone doorway
local mound = c:ellipse(66, 112, 64, 50):clip(c:rect(0, 66, W, 116))
c:part(mound, GV.ramp("#6a9a7a"), { cres = 7, deep = 12, gloss = false })
-- frost patches on the mound
for _, f in ipairs({ {30,82,10},{52,72,12},{78,74,9},{96,84,8},{20,96,6},{108,96,6} }) do
  c:fill(c:rect(f[1], f[2], f[1] + f[3], f[2]), "#e8f0f4"); c:fill(c:rect(f[1] + 2, f[2] + 1, f[1] + f[3] - 3, f[2] + 1), "#cfe0e8")
end
-- standing stones on the crown
for _, s in ipairs({ {44,60,50,72},{60,57,67,70},{76,61,82,72} }) do
  c:part(c:rrect(s[1], s[2], s[3], s[4], 2), GV.ramp("#8b8f96"), { cres = 3, deep = 5, gloss = false })
  c:fill(c:rect(s[1], s[2], s[3], s[2]), "#e8f0f4")
end
-- doorway: two posts, a lintel, dark inside with an icy glow
c:fill(c:rect(54, 90, 82, 112), "#291d4a")
c:fill(c:rect(57, 93, 79, 112), "#3e2f66")
c:fill(c:rect(61, 99, 75, 112), "#8fcbd8")
c:fill(c:rect(64, 103, 72, 112), "#c8ecdc")
c:part(c:rrect(50, 88, 57, 113, 2), GV.ramp("#8b8f96"), { cres = 3, deep = 5, gloss = false })
c:part(c:rrect(79, 88, 86, 113, 2), GV.ramp("#8b8f96"), { cres = 3, deep = 5, gloss = false })
c:part(c:rrect(47, 82, 89, 90, 2), GV.ramp("#8b8f96"), { cres = 3, deep = 6 })
c:fill(c:rect(48, 82, 88, 82), "#e8f0f4")
-- icicles on the lintel
for _, x in ipairs({ 52, 58, 66, 74, 80 }) do c:fill(c:rect(x, 91, x + 1, 93 + (x % 3)), "#cfe0e8") end
-- the Frost Toad
local TX, TY = 158, 100
local icy = GV.ramp("#5a9aa8", { rim = "#a8d8e0", gloss = "#c8ecdc" })
-- back legs
c:part(c:ellipse(TX - 34, TY + 8, 12, 14), icy, { cres = 5, deep = 8 })
c:part(c:ellipse(TX + 34, TY + 8, 12, 14), icy, { cres = 5, deep = 8 })
-- body
c:part(c:ellipse(TX, TY, 36, 27), icy, { cres = 7, deep = 12 })
-- belly
c:part(c:ellipse(TX, TY + 12, 20, 12), GV.ramp("#d6ecec", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false, contour = "#2a1a10" })
-- front feet (three toes)
for _, fx in ipairs({ TX - 20, TX + 20 }) do
  c:part(c:ellipse(fx, TY + 24, 9, 5), icy, { cres = 3, deep = 5, gloss = false })
  for _, dx in ipairs({ -6, 0, 6 }) do c:fill(c:rect(fx + dx - 1, TY + 27, fx + dx, TY + 28), "#a8d8e0") end
end
-- big eye bumps on the head
for _, ex in ipairs({ TX - 17, TX + 17 }) do
  c:part(c:ellipse(ex, TY - 22, 9, 8), icy, { cres = 4, deep = 6 })
  c:fill(c:ellipse(ex, TY - 21, 6, 6), "#e8c860")
  c:eye(ex - 2, TY - 24)
end
-- wide cold frown / mouth (dark line with a pale lip below)
local mp = { {-24,-6},{-22,-5},{-20,-4},{-18,-3},{-16,-2},{-14,-1},{-12,-1},{-10,0},{-8,0},{-6,0},{-4,0},{-2,0},{0,0},{2,0},{4,0},{6,0},{8,0},{10,0},{12,-1},{14,-1},{16,-2},{18,-3},{20,-4},{22,-5},{24,-6} }
for _, p in ipairs(mp) do c:fill(c:rect(TX + p[1], TY + p[2], TX + p[1] + 1, TY + p[2] + 1), "#2a1a10"); c:px(TX + p[1], TY + p[2] + 2, "#a8d8e0") end
-- nostrils and warts
c:px(TX - 4, TY - 11, "#2a1a10"); c:px(TX + 4, TY - 11, "#2a1a10")
for _, w in ipairs({ {-28,-10},{-24,-2},{26,-12},{30,-3},{-12,-16},{14,-15},{-30,10},{32,12},{0,-30} }) do
  c:fill(c:rect(TX + w[1], TY + w[2], TX + w[1] + 2, TY + w[2] + 1), "#a8d8e0"); c:px(TX + w[1], TY + w[2] + 1, "#2f6290")
end
-- ice crown between the eyes
for _, k in ipairs({ {-9,-28,-12,-46,-4,-30},{-3,-30,0,-52,4,-30},{4,-30,10,-48,12,-27} }) do
  c:part(c:poly({ {TX+k[1],TY+k[2]},{TX+k[3],TY+k[4]},{TX+k[5],TY+k[6]} }), GV.ramp("#a8e0f0"), { cres = 2, deep = 3, gloss = false })
end
c:ground(TX, 128, 44, 3)
-- snowflakes drifting
for _, p in ipairs({ {20,20},{36,44},{100,16},{130,34},{210,40},{226,60},{70,30},{175,18} }) do c:px(p[1], p[2], "#ffffff" == nil and "" or "#f4f8fc") end

L.finish(c, SLUG)
