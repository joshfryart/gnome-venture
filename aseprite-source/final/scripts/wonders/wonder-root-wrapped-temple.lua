-- wonder-root-wrapped-temple.lua : "A temple held in the arms of tree roots, a stone face looking out between the knuckles of the wood."
-- Thing to do: read the old script between the roots; a hidden panel swings open. Dim green jungle morning, South-East Asia.
local K = dofile("/home/user/gnome-venture/aseprite-source/final/scripts/wonders/w5lib.lua")
local L, GV, TINY = K.L, K.GV, K.TINY
local W, H = L.W, L.H
local c = L.new()
local function R(h, o) return GV.ramp(h, o) end
local ST = "#8b8f96"
local function stone(m, o) c:part(m, R(ST, { rim = "#c9c5bc" }), o or { gloss = false, cres = 4, deep = 6 }) end

-- jungle backdrop ---------------------------------------------------------------------------------------------------
c:bands(c:rect(0, 0, W - 1, H - 1), { "#1f3a3a", "#24452e", "#2f5a2a", "#3a6a34", "#4a8a3e", "#5a9a44" }, { dir = "v" })
-- light shafts
for _, s in ipairs({ { 30, 70 }, { 100, 140 }, { 180, 210 } }) do
  c:fill(c:poly({ { s[1], 0 }, { s[1] + 14, 0 }, { s[2] + 34, 135 }, { s[2], 135 } }), "#5a9a44")
  c:fill(c:poly({ { s[1] + 5, 0 }, { s[1] + 9, 0 }, { s[2] + 22, 135 }, { s[2] + 10, 135 } }), "#7ab55c")
end
-- distant trunks and canopy leaf clumps
for _, x in ipairs({ 14, 52, 196, 226 }) do c:fill(c:rect(x, 0, x + 5, 120), "#1f3a3a"); c:fill(c:rect(x, 0, x, 120), "#2f5a2a") end
for _, p in ipairs({ { 20, 6, 22 }, { 74, 2, 20 }, { 130, 0, 24 }, { 176, 4, 22 }, { 226, 8, 20 }, { 100, 14, 12 }, { 160, 18, 12 } }) do
  c:part(c:ellipse(p[1], p[2], p[3], 12), R("#2f5a2a"), { gloss = false, outline = false, cres = 4, deep = 6 })
end

-- the temple ------------------------------------------------------------------------------------------------------------
local TX = 120
stone(c:rect(66, 120, 174, 128)); stone(c:rect(76, 113, 164, 120)); stone(c:rect(86, 107, 154, 113))
stone(c:rrect(92, 62, 148, 108, 2))
stone(c:rrect(98, 24, 142, 64, 3))
for i = 0, 2 do stone(c:rect(102 + i * 5, 18 - i * 6 + 6, 138 - i * 5, 24 - i * 6 + 6), { gloss = false, cres = 2, deep = 3 }) end
c:part(c:ellipse(TX, 6, 2.5, 3), R("#e8a317"), { flat = true, gloss = false })
-- masonry courses
for y = 70, 104, 8 do c:seam({ { 94, y }, { 146, y } }, { free = true, on = 4, off = 3, gap = "#74808c" }) end
-- the stone face
c:fill(c:rect(104, 34, 136, 36), "#74808c")           -- brow band
c:eye(TX - 13, 38); c:eye(TX + 8, 38)
c:fill(c:rect(TX - 13, 38, TX - 9, 38), "#8b8f96"); c:fill(c:rect(TX + 8, 38, TX + 12, 38), "#8b8f96")     -- heavy lids
c:part(c:rrect(TX - 3, 40, TX + 3, 52, 2), R("#74808c"), { flat = true, gloss = false, outline = false })
c:fill(c:rect(TX - 5, 51, TX + 5, 52), "#5b6470")
c:fill(c:rect(TX - 12, 56, TX + 12, 57), "#2a1a10"); c:px(TX - 13, 55, "#2a1a10"); c:px(TX + 13, 55, "#2a1a10"); c:px(TX - 14, 54, "#2a1a10"); c:px(TX + 14, 54, "#2a1a10")
c:fill(c:rect(TX - 8, 58, TX + 8, 58), "#c9c5bc")
-- door with a warm lamp inside
c:fill(c:rrect(111, 80, 129, 108, 8), "#2a1a10"); c:fill(c:rect(111, 90, 129, 108), "#2a1a10")
c:fill(c:rrect(114, 86, 126, 108, 6), "#3d2a1c")
c:fill(c:ellipse(TX, 98, 2, 3), "#e8a317"); c:fill(c:ellipse(TX, 98, 1, 2), "#fff1c8")
-- carved script panel on the left wall (the hidden panel), glyph columns
c:fill(c:rect(95, 72, 107, 100), "#5b6470"); c:fill(c:rect(96, 73, 106, 99), "#6a7480")
for i = 0, 3 do for j = 0, 6 do
  local gx, gy = 97 + i * 3, 75 + j * 4
  if (i * 3 + j * 5) % 4 ~= 1 then c:px(gx, gy, "#2a1a10"); c:px(gx + 1, gy, "#2a1a10") end
  if (i + j) % 3 == 0 then c:px(gx, gy + 1, "#2a1a10") end
end end
c:px(104, 77, "#fff1c8"); c:px(105, 77, "#f5cf6a"); c:px(104, 78, "#f5cf6a")   -- the glint of the key glyph
-- moss
for _, p in ipairs({ { 94, 62, 12 }, { 126, 62, 14 }, { 100, 24, 10 }, { 78, 113, 10 }, { 140, 107, 12 }, { 112, 120, 18 } }) do
  c:fill(c:rect(p[1], p[2], p[1] + p[3], p[2] + 1), "#7ab55c"); c:fill(c:rect(p[1] + 2, p[2] + 2, p[1] + p[3] - 3, p[2] + 2), "#4a8a3e")
end

-- the roots ----------------------------------------------------------------------------------------------------------------
local function root(pts, w)
  c:part(c:line(pts, w), R("#8a4f2a", { rim = "#d9a660" }), { gloss = false, cres = 3, deep = 5 })
end
-- right: great trunk with roots draping over the temple's shoulder and down its right side
root({ { 196, -4 }, { 192, 20 }, { 180, 32 }, { 164, 30 }, { 150, 36 } }, 9)
root({ { 150, 36 }, { 158, 54 }, { 156, 62 }, { 150, 84 }, { 160, 108 }, { 176, 124 } }, 7)
root({ { 150, 66 }, { 140, 76 }, { 144, 98 } }, 4)
root({ { 200, 20 }, { 204, 60 }, { 214, 96 }, { 226, 124 } }, 8)
-- left: roots wrap the left shoulder, knuckled around the face
root({ { 50, -4 }, { 60, 18 }, { 82, 32 }, { 92, 30 }, { 92, 40 } }, 8)
root({ { 92, 40 }, { 88, 52 }, { 86, 66 }, { 82, 90 }, { 66, 112 }, { 52, 126 } }, 7)
root({ { 90, 60 }, { 100, 56 }, { 108, 62 } }, 4)
root({ { 40, 10 }, { 28, 50 }, { 20, 96 }, { 8, 124 } }, 8)
-- a root across the front steps, framing the scene
root({ { 76, 126 }, { 100, 120 }, { 128, 124 }, { 150, 119 } }, 4)
-- hanging vines
for _, x in ipairs({ 60, 78, 170, 186, 214 }) do
  local len = 20 + (x % 7) * 4
  c:fill(c:rect(x, 0, x, len), "#4a8a3e"); c:px(x + 1, 3, "#7ab55c"); c:px(x + 1, len - 6, "#7ab55c")
  c:part(c:ellipse(x, len + 2, 2, 2), R("#7ab55c"), { flat = true, gloss = false, outline = false })
end

-- foreground: stone steps, ferns and a watching monkey -----------------------------------------------------------------------
stone(c:rect(70, 128, 170, 135), { gloss = false, cres = 2, deep = 3, outline = false })
c:fill(c:rect(0, 126, W - 1, H - 1), "#2f5a2a"); c:fill(c:rect(0, 126, W - 1, 127), "#3a6a34")
stone(c:rect(76, 126, 164, 135), { gloss = false, cres = 3, deep = 4 })
c:seam({ { 78, 130 }, { 162, 130 } }, { free = true, on = 4, off = 2, gap = "#74808c" })
local function fern(x, y, n, col)
  for i = -n, n do
    local len = 12 - math.abs(i) * 2
    c:fill(c:line({ { x, y }, { x + i * 4, y - len } }, 2), col)
    c:px(x + i * 4, y - len - 1, "#a4b86a")
  end
end
fern(24, 134, 3, "#4a8a3e"); fern(50, 135, 2, "#6a9a3a"); fern(196, 135, 3, "#4a8a3e"); fern(222, 134, 2, "#6a9a3a")
-- little macaque on the left root, scroll in paw
local MX, MY = 36, 120
c:part(c:ellipse(MX, MY, 8, 7), R("#8a6a4a"), { gloss = false, cres = 3, deep = 4 })
c:part(c:ellipse(MX, MY - 11, 7, 6), R("#8a6a4a"), { gloss = false, cres = 3, deep = 4 })
c:part(c:ellipse(MX, MY - 9, 4.5, 3.5), R("#e9b98a"), { flat = true, gloss = false, outline = false })
c:part(c:ellipse(MX - 7, MY - 11, 2.5, 2.5), R("#e9b98a"), { flat = true, gloss = false, outline = false })
c:part(c:ellipse(MX + 7, MY - 11, 2.5, 2.5), R("#e9b98a"), { flat = true, gloss = false, outline = false })
c:eye(MX - 5, MY - 14, true); c:eye(MX + 2, MY - 14, true)
c:fill(c:rect(MX - 2, MY - 8, MX + 1, MY - 7), "#2a1a10")
c:part(c:rect(MX + 6, MY - 2, MX + 14, MY + 3), R("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false })
c:seam({ { MX + 7, MY + 1 }, { MX + 13, MY + 1 } }, { free = true, on = 1, off = 1, gap = "#8a4f2a" })
c:limb({ { MX + 6, MY + 2 }, { MX + 6, MY - 2 } }, 2)
-- fireflies and dust motes in the light
for _, p in ipairs({ { 46, 40 }, { 112, 78 }, { 160, 52 }, { 24, 66 }, { 206, 74 }, { 76, 92 } }) do c:px(p[1], p[2], "#fff1c8") end
L.finish(c, "wonder-root-wrapped-temple")
