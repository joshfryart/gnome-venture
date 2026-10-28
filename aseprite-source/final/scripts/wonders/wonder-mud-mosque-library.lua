-- wonder-mud-mosque-library.lua : "A tall mud-brick library, cool inside, its shelves full of old farming scrolls. The guide is a tortoise with spectacles."
-- Thing to do: the tortoise finds the scroll you need (Lore). Clear day, West/Central Asia (mud brick, turquoise tile, poplar).
local K = dofile("/home/user/gnome-venture/aseprite-source/final/scripts/wonders/w5lib.lua")
local L, GV, TINY = K.L, K.GV, K.TINY
local W, H = L.W, L.H
local c = L.new()
local function R(h, o) return GV.ramp(h, o) end
local MUD, MUDR = "#c9a96e", nil
local function mud(m, o) c:part(m, R(MUD, { rim = "#ecc58a" }), o or { gloss = false, cres = 5, deep = 7 }) end
local HOR = 78

L.sky(c, "day", HOR)
L.cloud(c, 30, 20, 16, "#f4f0e0", "#cfd8e4"); L.cloud(c, 190, 14, 18, "#f4f0e0", "#cfd8e4"); L.cloud(c, 225, 40, 10, "#f4f0e0", "#cfd8e4")
-- far snow mountains
c:fill(L.below(c, function(x) return 50 + 14 * math.abs(math.sin(x / 38)) end):clip(c:rect(0, 40, W - 1, HOR)), "#a894dc")
c:fill(L.below(c, function(x) return 50 + 14 * math.abs(math.sin(x / 38)) end):clip(c:rect(0, 40, W - 1, 58)), "#e8e4f4")
c:fill(L.below(c, function(x) return 66 + 6 * math.sin(x / 17 + 1) end):clip(c:rect(0, 40, W - 1, HOR)), "#c9a96e")
-- ground: sand courtyard
c:bands(c:rect(0, HOR, W - 1, H - 1), { "#e8d6a8", "#e2cc98", "#dbc388", "#d4b97c" }, { dir = "v" })

-- side buildings ------------------------------------------------------------------------------------------------
mud(c:rect(40, 56, 98, 104))
mud(c:rect(142, 56, 200, 104))
for _, side in ipairs({ { 40, 98 }, { 142, 200 } }) do
  for _, wx in ipairs({ side[1] + 8, side[1] + 26, side[1] + 44 }) do
    c:fill(c:rrect(wx, 66, wx + 5, 78, 2), "#3d2a1c"); c:fill(c:rect(wx, 71, wx + 5, 78), "#3d2a1c"); c:fill(c:rect(wx + 1, 77, wx + 4, 78), "#7a4a1f")
  end
  for y = 84, 100, 8 do c:seam({ { side[1] + 2, y }, { side[2] - 2, y } }, { free = true, on = 3, off = 2, gap = "#b07a45" }) end
  c:fill(c:rect(side[1], 56, side[2], 57), "#ecc58a")
end
-- minarets with turquoise bands
local function minaret(x, top)
  c:part(c:poly({ { x - 7, 104 }, { x - 5, top }, { x + 5, top }, { x + 7, 104 } }), R(MUD, { rim = "#ecc58a" }), { gloss = false, cres = 4, deep = 6 })
  for y = top + 8, 100, 14 do c:fill(c:rect(x - 6, y, x + 6, y + 3), "#3f8fb0"); c:fill(c:rect(x - 6, y + 1, x + 6, y + 1), "#8fcbd8"); c:fill(c:rect(x - 6, y + 3, x + 6, y + 3), "#2f6290") end
  c:part(c:rect(x - 7, top - 4, x + 7, top), R("#3f8fb0"), { gloss = false, cres = 2, deep = 3 })
  c:part(c:ellipse(x, top - 6, 5, 6), R("#3f8fb0", { rim = "#8fcbd8" }), { cres = 3, deep = 4 })
  c:fill(c:rect(x, top - 15, x, top - 10), "#e8a317"); c:px(x, top - 16, "#fff1c8")
end
minaret(34, 30); minaret(206, 34)
-- domes
c:part(c:ellipse(70, 56, 15, 11):clip(c:rect(0, 0, W, 56)), R("#3f8fb0", { rim = "#8fcbd8" }), { cres = 4, deep = 6 })
c:part(c:ellipse(170, 56, 15, 11):clip(c:rect(0, 0, W, 56)), R("#3f8fb0", { rim = "#8fcbd8" }), { cres = 4, deep = 6 })
for _, x in ipairs({ 70, 170 }) do c:fill(c:rect(x, 38, x, 42), "#e8a317") end

-- the grand portal (pishtaq) ------------------------------------------------------------------------------------------------
mud(c:rect(92, 28, 148, 104), { gloss = false, cres = 6, deep = 8 })
c:fill(c:rect(92, 28, 148, 31), "#3f8fb0"); c:fill(c:rect(92, 29, 148, 29), "#8fcbd8"); c:fill(c:rect(92, 31, 148, 31), "#2f6290")
-- tile bands: diamonds
for x = 94, 144, 6 do
  c:fill(c:poly({ { x, 36 }, { x + 3, 33 }, { x + 6, 36 }, { x + 3, 39 } }), "#2f6290"); c:px(x + 3, 36, "#f2e4c0")
  c:fill(c:poly({ { x, 96 }, { x + 3, 93 }, { x + 6, 96 }, { x + 3, 99 } }), "#2f6290"); c:px(x + 3, 96, "#f2e4c0")
end
for _, wx in ipairs({ 100, 134 }) do for _, wy in ipairs({ 44, 62 }) do c:fill(c:rect(wx, wy, wx + 5, wy + 8), "#3f8fb0"); c:fill(c:rect(wx + 1, wy + 1, wx + 4, wy + 7), "#2a3c6c"); c:px(wx + 2, wy + 3, "#f5cf6a") end end
-- arch opening: warm lit interior with shelves
local arch = c:poly({ { 105, 104 }, { 105, 70 }, { 108, 62 }, { 114, 54 }, { 120, 49 }, { 126, 54 }, { 132, 62 }, { 135, 70 }, { 135, 104 } })
c:fill(arch, "#e0a85c")
c:fill(arch:copy():clip(c:rect(0, 0, W, 104)):shrink(1), "#f5cc92")
for y = 58, 100, 9 do
  c:fill(arch:copy():clip(c:rect(106, y, 134, y + 1)), "#8a4f2a")
  for x = 107, 133, 4 do
    if arch:has(x, y - 3) then
      local col = ({ "#f2e4c0", "#e46a9b", "#7ab55c", "#f2e4c0", "#d9885a" })[(((x * 3) + y) % 5) + 1]
      c:fill(c:rect(x, y - 4, x + 2, y - 1), col); c:px(x + 1, y - 3, "#fff3c8")
    end
  end
end
c:fill(c:rect(119, 49, 121, 49), "#fff1c8")
c:fill(arch:copy():clip(c:rect(0, 0, W, 104)):edge(), "#3d2a1c")
-- doorstep
c:part(c:rect(98, 102, 142, 106), R("#e8e4dc"), { gloss = false, cres = 2, deep = 3 })

-- poplars and a palm ---------------------------------------------------------------------------------------------------
for _, t in ipairs({ { 14, 104, 36 }, { 228, 106, 32 }, { 24, 108, 24 } }) do
  c:part(c:ellipse(t[1], t[2] - t[3] / 2, 4.5, t[3] / 2), R("#4a8a3e"), { gloss = false, outline = false, cres = 3, deep = 5 })
  c:fill(c:rect(t[1], t[2], t[1] + 1, t[2] + 2), "#5e2f1e")
end

-- the tortoise librarian with spectacles ---------------------------------------------------------------------------------------
local TX, TY = 120, 118
c:ground(TX, TY + 10, 20, 3)
for _, dx in ipairs({ -12, 8 }) do c:part(c:rrect(TX + dx, TY + 3, TX + dx + 4, TY + 10, 2), R("#7ab55c"), { flat = true, gloss = false }) end
c:part(c:ellipse(TX, TY - 2, 17, 11):clip(c:rect(0, 0, W, TY + 6)), R("#6a9a3a", { rim = "#c8d77a" }), { cres = 5, deep = 8 })
c:part(c:rect(TX - 17, TY + 3, TX + 17, TY + 6), R("#e8d6a8"), { gloss = false, cres = 2, deep = 3 })
-- shell plates
for _, p in ipairs({ { TX, TY - 8, 4 }, { TX - 9, TY - 3, 4 }, { TX + 9, TY - 3, 4 }, { TX, TY + 1, 4 } }) do
  c:fill(c:poly({ { p[1] - p[3], p[2] }, { p[1], p[2] - 3 }, { p[1] + p[3], p[2] }, { p[1], p[2] + 3 } }), "#4a8a3e"); c:px(p[1], p[2] - 1, "#8a9a5a")
end
-- head, pushed forward on the left
c:part(c:ellipse(TX - 19, TY - 6, 8, 7), R("#9ac36a", { rim = "#c8d77a" }), { cres = 3, deep = 5 })
c:eye(TX - 27, TY - 10); c:eye(TX - 19, TY - 10)
c:fill(c:rect(TX - 27, TY - 10, TX - 23, TY - 10), "#9ac36a")   -- wise, half-lidded
-- spectacles: gold rings round the eyes, bridge, arm
for _, ex in ipairs({ TX - 28, TX - 20 }) do
  c:fill(c:rect(ex, TY - 12, ex + 6, TY - 12), "#e8a317"); c:fill(c:rect(ex, TY - 6, ex + 6, TY - 6), "#e8a317")
  c:fill(c:rect(ex, TY - 12, ex, TY - 6), "#e8a317"); c:fill(c:rect(ex + 6, TY - 12, ex + 6, TY - 6), "#e8a317")
end
c:fill(c:rect(TX - 22, TY - 10, TX - 21, TY - 10), "#e8a317")
c:fill(c:rect(TX - 22, TY - 3, TX - 17, TY - 3), "#3d2a1c")   -- little smile
-- flipper holding an unrolled scroll, pointing at the margin note
c:part(c:rect(TX - 36, TY - 1, TX - 22, TY + 8), R("#f2e4c0", { dot = "#fff3c8" }), { gloss = false, cres = 2, deep = 3 })
c:fill(c:rect(TX - 36, TY - 2, TX - 22, TY - 2), "#d9a660"); c:fill(c:rect(TX - 36, TY + 8, TX - 22, TY + 9), "#d9a660")
for i = 0, 3 do c:fill(c:rect(TX - 34, TY + 1 + i * 2, TX - 25 + (i % 2) * 3, TY + 1 + i * 2), "#8a4f2a") end
c:fill(c:rect(TX - 24, TY + 7, TX - 22, TY + 7), "#e46a9b")    -- the margin note
c:part(c:rrect(TX - 32, TY + 5, TX - 26, TY + 9, 1), R("#9ac36a"), { flat = true, gloss = false, outline = false })
-- a gnome reader with a sheaf, and a stack of scrolls
K.gnome(c, 186, 122, { tunic = "#d9885a", hatkind = "turban", hat = "#f2e4c0", look = -1 })
c:part(c:rect(194, 108, 198, 122), R("#e8c880", { dot = "#fff3c8" }), { gloss = false, cres = 2, deep = 3 })
for _, x in ipairs({ 193, 195, 197, 199 }) do c:fill(c:rect(x, 104, x, 108), "#e8c880") end
c:seam({ { 194, 114 }, { 198, 114 } }, { free = true })
K.gnome(c, 58, 124, { tunic = "#3f8fb0", hatkind = "turban", hat = "#d6322b", look = 1 })
for i = 0, 3 do c:part(c:rrect(68 + (i % 2) * 2, 124 - i * 4, 82 + (i % 2) * 2, 127 - i * 4, 1), R(({ "#f2e4c0", "#e46a9b", "#f2e4c0", "#7ab55c" })[i + 1], { dot = "#fff3c8" }), { gloss = false, cres = 1, deep = 2 }) end
L.finish(c, "wonder-mud-mosque-library")
