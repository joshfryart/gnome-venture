-- wonder-the-great-migration.lua : herds thunder across the savanna in dust; little treasures glint in the dust; a meerkat spots one.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, c, W, H = L.GV, L.new(), L.W, L.H
local SLUG = "wonder-the-great-migration"
local HOR = 70

c:bands(c:rect(0, 0, W - 1, HOR), { "#e8a070", "#f0b078", "#f5c488", "#f8d49a", "#fbe0ac", "#fdeec4" }, { dir = "v" })
c:fill(c:ellipse(150, HOR - 4, 20, 20), "#fdeec4"); c:fill(c:ellipse(150, HOR - 4, 14, 14), "#fff6d8")
L.cloud(c, 40, 22, 20, "#f8c488", "#e8a070"); L.cloud(c, 200, 30, 18, "#f8c488", "#e8a070"); L.cloud(c, 110, 14, 12, "#fbd49a", "#f0b078")
-- far kopje (rocky hills) and blue-hazy distance
c:fill(L.below(c, function(x) return 64 - 5 * math.sin(x / 26 + 0.5) end), "#c8a078")
c:fill(L.below(c, function(x) return HOR + 2 - 2 * math.sin(x / 12) end), "#d8b070")
-- savanna ground bands
c:part(L.below(c, function(x) return HOR + 4 end), GV.ramp("#d8a85a"), { cres = 6, deep = 9, outline = false, gloss = false })
c:fill(L.below(c, function(x) return 96 + 2 * math.sin(x / 20) end), "#c89a4a")
c:fill(L.below(c, function(x) return 112 + 3 * math.sin(x / 16 + 1) end), "#b08440")
-- grass tufts
for i = 0, 40 do
  local x = (i * 53 + 9) % 236; local y = HOR + 8 + (i * 17) % 56
  c:px(x, y, "#e8c86a"); c:px(x + 1, y - 1, "#a4b86a"); c:px(x + 2, y, "#e8c86a")
end

-- acacia (flat-topped) on the left
local function acacia(x, y, s)
  c:part(c:poly({ {x - 2 * s, y}, {x - 1, y - 14 * s}, {x + 2, y - 14 * s}, {x + 2 * s, y} }), GV.ramp("#5a3a20"), { cres = 2, deep = 3, gloss = false, outline = false })
  c:part(c:ellipse(x, y - 17 * s, 22 * s, 5 * s), GV.ramp("#4f9a45", { shade = "#2f5a2a" }), { cres = 3, deep = 5, gloss = false, outline = false })
  c:part(c:ellipse(x - 8 * s, y - 21 * s, 10 * s, 4 * s), GV.ramp("#5aa84a"), { cres = 2, deep = 3, gloss = false, outline = false })
  c:part(c:ellipse(x + 9 * s, y - 20 * s, 9 * s, 4 * s), GV.ramp("#5aa84a"), { cres = 2, deep = 3, gloss = false, outline = false })
end
acacia(28, 84, 1.1)
-- baobab-ish silhouette far right
c:part(c:rect(214, 52, 222, 76), GV.ramp("#8a6a58"), { cres = 3, deep = 5, gloss = false, outline = false })
for k = -1, 1 do c:fill(c:rect(214 + k * 5, 46, 215 + k * 5, 54), "#8a6a58"); c:fill(c:ellipse(214 + k * 5, 45, 3, 2), "#4f9a45") end

-- animals -------------------------------------------------------------------------------------------
local DUST = { "#f8e8c0", "#ecd09a", "#c9a06a" }
local function puff(x, y, r) c:fill(c:ellipse(x, y, r, r * 0.7), DUST[1]); c:fill(c:ellipse(x, y + r * 0.35, r, r * 0.4), DUST[2]) end
local function gnu(x, y, s, d, ph)
  -- legs (running: spread)
  local lg = "#2a1a10"
  local sp = (ph % 2 == 0) and 4 or 2
  for _, o in ipairs({ -5 * s, -2 * s, 3 * s, 6 * s }) do
    c:fill(c:rect(math.floor(x + o), math.floor(y), math.floor(x + o) + (s >= 1.5 and 1 or 0), math.floor(y + 6 * s)), lg)
  end
  c:part(c:ellipse(x, y - 1 * s, 9 * s, 6 * s), GV.ramp("#7a6a62", { shade = "#5a4a48", deep = "#3a2a2c" }), { cres = 2 * s, deep = 4 * s, gloss = false, outline = (s >= 1.3) })
  c:part(c:ellipse(x - d * 8 * s, y - 2 * s, 4 * s, 4 * s), GV.ramp("#4a3c3a"), { cres = 1, deep = 2, gloss = false, outline = (s >= 1.3) })
  c:part(c:ellipse(x + d * 10 * s, y - 2 * s, 5 * s, 4 * s), GV.ramp("#6a5a52"), { cres = 2, deep = 3, gloss = false, outline = (s >= 1.3) })
  -- horns
  c:fill(c:rect(math.floor(x + d * 10 * s) - 1, math.floor(y - 8 * s), math.floor(x + d * 10 * s), math.floor(y - 5 * s)), "#f2e4c0")
  c:fill(c:rect(math.floor(x + d * 10 * s) + d * 2, math.floor(y - 9 * s), math.floor(x + d * 10 * s) + d * 3, math.floor(y - 8 * s)), "#f2e4c0")
  c:px(math.floor(x + d * 12 * s), math.floor(y - 4 * s), "#fff1c8")
  if s >= 1.3 then c:eye(math.floor(x + d * 10 * s) - 2, math.floor(y - 6 * s), true) else c:px(math.floor(x + d * 11 * s), math.floor(y - 4 * s), "#f2e4c0") end
  c:fill(c:rect(math.floor(x - d * 10 * s), math.floor(y - 3 * s), math.floor(x - d * 10 * s) + 1, math.floor(y + 3 * s)), "#2a1a10")
end
local function zebra(x, y, s, d)
  for _, o in ipairs({ -5 * s, -2 * s, 3 * s, 6 * s }) do c:fill(c:rect(math.floor(x + o), math.floor(y), math.floor(x + o) + (s >= 1.5 and 1 or 0), math.floor(y + 6 * s)), "#2a1a10") end
  c:part(c:ellipse(x, y - 1 * s, 9 * s, 6 * s), GV.ramp("#f6f2e8", { shade = "#c5c9d8", deep = "#9a9fb8" }), { cres = 2 * s, deep = 4 * s, gloss = false, outline = (s >= 1.3) })
  for k = -6, 6, 3 do c:fill(c:rect(math.floor(x + k * s), math.floor(y - 6 * s), math.floor(x + k * s), math.floor(y + 3 * s)), "#2a2230") end
  c:part(c:ellipse(x + d * 10 * s, y - 4 * s, 5 * s, 4 * s), GV.ramp("#f6f2e8", { shade = "#c5c9d8", deep = "#9a9fb8" }), { cres = 2, deep = 3, gloss = false, outline = (s >= 1.3) })
  c:fill(c:rect(math.floor(x + d * 12 * s), math.floor(y - 3 * s), math.floor(x + d * 14 * s), math.floor(y)), "#4a3a40")
  c:fill(c:rect(math.floor(x + d * 7 * s), math.floor(y - 10 * s), math.floor(x + d * 8 * s), math.floor(y - 6 * s)), "#2a2230")
  c:px(math.floor(x + d * 10 * s) - 1, math.floor(y - 6 * s), "#2a1a10")
end
-- far herd: rows of tiny silhouettes
for i = 0, 22 do
  local x = 8 + i * 10 + (i % 3) * 2; local y = HOR + 6 + (i % 2) * 2
  c:fill(c:rect(x, y - 2, x + 4, y), (i % 5 == 0) and "#f2e4c0" or "#5a4a42"); c:px(x + 5, y - 3, "#5a4a42"); c:fill(c:rect(x, y + 1, x, y + 2), "#3a2a2c"); c:fill(c:rect(x + 4, y + 1, x + 4, y + 2), "#3a2a2c")
end
for i = 0, 6 do puff(14 + i * 34, HOR + 10, 7) end
-- mid herd
for i = 0, 8 do puff(24 + i * 26, 98, 8) end
local mid = { {40,92,1.0,1,0},{70,95,1.0,1,1},{100,91,1.0,1,0},{132,96,1.0,1,1},{164,92,1.0,1,0},{196,95,1.0,1,1},{226,91,1.0,1,0} }
for i, m in ipairs(mid) do if i % 3 == 0 then zebra(m[1], m[2], m[3], m[4]) else gnu(m[1], m[2], m[3], m[4], m[5]) end end
-- near herd (big, partial) : a big wildebeest and a zebra thundering past in front, right side
puff(160, 122, 12); puff(196, 126, 12); puff(222, 124, 9); puff(136, 124, 8)
gnu(196, 114, 1.6, 1, 0)
zebra(146, 112, 1.2, 1)

-- treasures glinting in the dust (left foreground)
local function sparkle(x, y, col) c:px(x, y, col); c:px(x - 1, y, col); c:px(x + 1, y, col); c:px(x, y - 1, col); c:px(x, y + 1, col) end
puff(64, 120, 12); puff(96, 124, 10)
-- gold coin
c:part(c:ellipse(70, 118, 4, 4), GV.ramp("#e8a317"), { cres = 2, deep = 3, gloss = false }); c:fill(c:ellipse(70, 118, 1.5, 1.5), "#b07a10")
sparkle(66, 112, "#fff1c8")
-- green gem
c:part(c:poly({ {86, 120}, {90, 114}, {96, 114}, {100, 120}, {93, 126} }), GV.ramp("#3fbf7f"), { cres = 3, deep = 4, gloss = false })
c:px(91, 116, "#d8ffe8"); c:px(92, 116, "#d8ffe8"); sparkle(103, 112, "#fff1c8")
-- pink bead
c:part(c:ellipse(110, 126, 3, 3), GV.ramp("#e46a9b"), { cres = 1, deep = 2, gloss = false }); c:px(109, 125, "#fff1c8")
-- the lucky meerkat on a termite mound, paw reaching
local MX, MY = 36, 116
c:part(c:poly({ {MX - 16, MY + 12}, {MX - 8, MY - 2}, {MX + 8, MY - 2}, {MX + 16, MY + 12} }), GV.ramp("#a8744a"), { cres = 4, deep = 7, gloss = false })
c:seam({ {MX - 10, MY + 4}, {MX + 10, MY + 4} }, { free = true, on = 2, off = 2, gap = "#6a4228" })
c:part(c:ellipse(MX, MY - 6, 5, 8), GV.ramp("#d8b080"), { cres = 2, deep = 4, gloss = false })
c:part(c:ellipse(MX, MY - 7, 3, 4), GV.ramp("#f0d8b0"), { flat = true, gloss = false, outline = false })
c:part(c:ellipse(MX, MY - 17, 6, 5.5), GV.ramp("#d8b080"), { cres = 2, deep = 4, gloss = false })
c:part(c:ellipse(MX - 5, MY - 16, 2, 3), GV.ramp("#3a2a20"), { flat = true, gloss = false, outline = false }); c:part(c:ellipse(MX + 5, MY - 16, 2, 3), GV.ramp("#3a2a20"), { flat = true, gloss = false, outline = false })
c:part(c:ellipse(MX + 1, MY - 13, 3, 2), GV.ramp("#f0d8b0"), { flat = true, gloss = false, outline = false }); c:px(MX + 2, MY - 14, "#2a1a10"); c:px(MX + 3, MY - 14, "#2a1a10")
c:eye(MX - 5, MY - 20, true); c:eye(MX, MY - 20, true)
c:limb({ {MX + 4, MY - 8}, {MX + 12, MY - 4}, {MX + 17, MY + 2} }, 2)
c:ground(MX, MY + 12, 18, 2)

L.finish(c, SLUG)
