-- wonder-lantern-festival-river.lua : "Paper lanterns drift down a dark river, each one a wish, and you're handed one to float."
-- Thing to do: float a lantern (Luck buff). Night, South-East Asia (pagoda, arched bridge, paper lanterns).
local K = dofile("/home/user/gnome-venture/aseprite-source/final/scripts/wonders/w5lib.lua")
local L, GV, TINY = K.L, K.GV, K.TINY
local W, H = L.W, L.H
local c = L.new()
local function R(h, o) return GV.ramp(h, o) end
local HOR = 46

L.sky(c, "night", HOR + 4)
L.stars(c, 46, 40, 11)
-- moon, upper left
local moon = c:ellipse(30, 20, 8, 8)
c:fill(c:ellipse(30, 20, 11, 11), "#322c6c"); c:fill(c:ellipse(30, 20, 9.5, 9.5), "#3e3680")
c:fill(moon, "#fff1c8"); c:fill(moon:copy():clip(c:rect(0, 23, W, 40)), "#f5cf6a")
L.cloud(c, 100, 30, 14, "#3e3680", "#322c6c"); L.cloud(c, 200, 22, 16, "#4a428e", "#3e3680")
-- far hills
c:fill(L.below(c, function(x) return 42 + 7 * math.sin(x / 22 + 1) end):clip(c:rect(0, 30, W - 1, 60)), "#26225a")
c:fill(L.below(c, function(x) return 47 + 4 * math.sin(x / 13 + 4) end):clip(c:rect(0, 30, W - 1, 62)), "#1c1a48")

-- banks and river --------------------------------------------------------------------------------------------
c:fill(c:rect(0, HOR + 4, W - 1, H - 1), "#1f3a3a")
local function xc(y) return 128 + 38 * math.sin((y - 50) / 24) end
local function hw(y) return 12 + (y - 50) * 0.95 end
local river = c:mask()
for y = HOR + 4, H - 1 do
  local a, b = math.floor(xc(y) - hw(y)), math.floor(xc(y) + hw(y))
  for x = math.max(0, a), math.min(W - 1, b) do river:set(x, y) end
end
c:bands(river, L.SEA.night, { dir = "v" })
-- bank texture and bank edge lights
for i = 0, 70 do
  local y = HOR + 6 + (i * 7) % (H - HOR - 10); local x = (i * 53 + 17) % W
  if not river:has(x, y) then c:px(x, y, (i % 3 == 0) and "#2f5a2a" or "#2a4a3a") end
end
local redge = river:copy():cut(river:copy():shrink(1))
c:fill(redge, "#3a5f9a")

-- far temple on the hill (left) --------------------------------------------------------------------------------
local PX, PY = 58, 50
for i = 0, 2 do
  local w = 11 - i * 3; local y = PY - i * 9
  c:part(c:rect(PX - w + 2, y - 7, PX + w - 2, y), R("#8a4f2a"), { gloss = false, outline = false, cres = 2, deep = 3 })
  c:fill(c:rect(PX - 1, y - 5, PX + 1, y - 2), "#f5cf6a")
  c:part(c:poly({ { PX - w - 3, y - 6 }, { PX + w + 3, y - 6 }, { PX + w - 1, y - 10 }, { PX - w + 1, y - 10 } }), R("#6b1b2c"), { gloss = false, outline = false, cres = 2, deep = 3 })
end
c:fill(c:rect(PX, PY - 36, PX, PY - 30), "#e8a317")
-- ground glow under temple
c:fill(c:ellipse(PX, PY + 2, 18, 2), "#2f5a2a")

-- bridge ----------------------------------------------------------------------------------------------------------------
local BY = 60
local bridge = c:rect(98, BY - 5, 178, BY + 5)
local arch = c:ellipse(xc(BY + 6), BY + 7, 21, 11)
bridge:cut(arch)
c:part(bridge, R("#8b8f96"), { gloss = false, cres = 4, deep = 5 })
c:fill(arch:copy():clip(c:rect(0, 0, W, BY + 8)), "#142248")
c:fill(arch:copy():clip(c:rect(0, 0, W, BY + 8)):edge(), "#25446e")
-- rail posts with hanging lanterns
for x = 102, 174, 12 do
  c:fill(c:rect(x, BY - 9, x + 1, BY - 5), "#5b6470")
  c:part(c:ellipse(x, BY - 4, 2.5, 3), R("#e0501f"), { flat = true, gloss = false, outline = false })
  c:px(x, BY - 4, "#fff1c8")
end
c:fill(c:rect(100, BY - 9, 176, BY - 9), "#5b6470")
-- small lanterns drifting beyond the arch
for _, p in ipairs({ { 132, BY + 4 }, { 143, BY + 6 } }) do c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "#f5cf6a") end

-- floating lanterns (glow ring on the water, reflection, paper lantern) ---------------------------------------------------
local cols = { "#d6322b", "#f08a24", "#f5cf6a", "#e46a9b", "#e0501f", "#f08a24", "#d6322b" }
local function lantern(x, y, r, col, refl)
  c:fill(c:ellipse(x, y + 1, r * 3.2, r * 1.5), "#1e3466"); c:fill(c:ellipse(x, y + 1, r * 2.2, r * 1.0), "#2a4a86")
  for i = 1, refl do
    c:fill(c:rect(x - r + (i % 2), y + r + i * 2, x + r - 1 - (i % 2), y + r + i * 2), (i < 3) and "#f5cf6a" or "#e39a86")
  end
  if r <= 2 then
    c:part(c:ellipse(x, y, r + 0.5, r), R(col), { flat = true, gloss = false, outline = false }); c:px(x, y, "#fff1c8")
  else
    c:part(c:ellipse(x, y, r + 1, r), R(col), { gloss = false, outline = false, cres = 2, deep = 3 })
    c:fill(c:ellipse(x, y, r - 1.5, r - 1.5), "#ffd98a")
    c:fill(c:rect(x - r + 1, y + r - 1, x + r - 1, y + r), "#e8a317"); c:fill(c:rect(x - 1, y - r - 1, x + 1, y - r), "#e8a317")
  end
end
local L1 = {
  { 136, 74, 2, 1 }, { 124, 80, 2, 1 }, { 146, 86, 3, 2 }, { 112, 90, 3, 2 }, { 152, 100, 3, 3 }, { 100, 104, 3, 3 },
  { 128, 98, 3, 3 }, { 168, 112, 4, 3 }, { 90, 118, 4, 3 }, { 122, 114, 4, 3 }, { 150, 124, 4, 2 }, { 74, 128, 4, 2 }, { 114, 128, 4, 2 }, { 196, 120, 4, 2 },
}
for i, l in ipairs(L1) do lantern(l[1], l[2], l[3], cols[(i % #cols) + 1], l[4]) end
-- the bend: a glow on the far water
c:fill(c:rect(146, 54, 154, 54), "#3a5f9a"); c:fill(c:rect(138, 56, 144, 56), "#3a5f9a")

-- foreground right bank: the lantern keeper with the lantern to float -------------------------------------------------------
c:part(c:ellipse(220, 134, 40, 10), R("#2f5a2a"), { gloss = false, outline = false, cres = 3, deep = 5 })
K.gnome(c, 216, 129, { tunic = "#d9885a", hat = "#e8a317", look = -1, lean = -2 })
-- big paper lantern held out toward the river
c:fill(c:line({ { 211, 120 }, { 205, 118 }, { 201, 114 } }, 2), "#e9b98a")
local lx, ly = 197, 109
c:fill(c:ellipse(lx, ly + 1, 14, 9), "#1e3466")
c:fill(c:ellipse(lx, ly + 1, 11, 7), "#2a4a86")
c:part(c:ellipse(lx, ly, 8, 7), R("#e0501f"), { gloss = false, outline = false, cres = 3, deep = 4 })
c:fill(c:ellipse(lx, ly, 5.5, 4.5), "#ffd98a"); c:fill(c:ellipse(lx, ly - 1, 3, 2), "#fff1c8")
c:fill(c:rect(lx - 6, ly + 6, lx + 6, ly + 7), "#e8a317"); c:fill(c:rect(lx - 4, ly - 8, lx + 4, ly - 7), "#e8a317")
c:fill(c:rect(lx, ly - 12, lx, ly - 8), "#e8a317")
-- a second gnome on the left bank, wishing
K.gnome(c, 26, 124, { tunic = "#7a4a9a", hat = "#f2e4c0", look = 1, lean = 3 })
K.gnome(c, 46, 130, { tunic = "#3f8fb0", hat = "#d6322b", look = 1, lean = -2 })
-- string of lanterns between trees on the left bank
c:fill(c:rect(8, 76, 8, 112), "#2a1a10"); c:fill(c:rect(70, 80, 70, 114), "#2a1a10")
c:part(c:ellipse(8, 68, 8, 9), R("#2f5a2a"), { gloss = false, outline = false, cres = 3, deep = 5 })
c:part(c:ellipse(70, 74, 8, 9), R("#2f5a2a"), { gloss = false, outline = false, cres = 3, deep = 5 })
for i = 0, 5 do
  local t = i / 5; local x = 12 + t * 54; local y = 82 + 10 * math.sin(t * 3.14159)
  c:px(math.floor(x), math.floor(y) - 1, "#2a1a10"); c:px(math.floor(x) + 1, math.floor(y) - 1, "#2a1a10")
  c:part(c:ellipse(math.floor(x), math.floor(y) + 2, 2, 2.5), R(cols[(i % #cols) + 1]), { flat = true, gloss = false, outline = false })
  c:px(math.floor(x), math.floor(y) + 2, "#fff1c8")
end
-- fireflies
for _, p in ipairs({ { 20, 100 }, { 60, 96 }, { 180, 90 }, { 206, 84 }, { 232, 100 } }) do c:px(p[1], p[2], "#c8d77a") end
L.finish(c, "wonder-lantern-festival-river")
