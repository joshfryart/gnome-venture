-- haven-floating-flower-market : Dal Lake (Kashmir) morning flower market of shikara boats, Himalaya behind. Boats heaped with flowers, garlands, a gnome florist.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 56
local RED = "#d6322b"
local FL = { "#f08a24", "#f5cf6a", "#f6a0c4", "#f08a24", "#e8a41c", "#f6b8cf", "#fff1c8" }

local function bloom(x, y, col, r)
  c:part(c:ellipse(x, y, r or 3, r or 3), GV.ramp(col), { flat = true, gloss = false, outline = false, contour = "#4a2c1a" })
  c:px(x, y, "#f5cf6a"); 
end
local function boat(x, y, rx, tone, flowers, canopy)
  -- shikara hull: long, low, prow and stern sweep up to points
  c:part(c:poly({ {x - rx - 8, y - 8}, {x - rx - 3, y - 3}, {x + rx + 3, y - 3}, {x + rx + 8, y - 8}, {x + rx - 2, y + 7}, {x - rx + 2, y + 7} }), GV.ramp(tone), { cres = 4, deep = 6, gloss = false })
  c:seam({ {x - rx, y + 1}, {x + rx, y + 1} }, { on = 2, off = 1 })
  c:fill(c:rect(x - rx - 3, y - 3, x + rx + 3, y - 3), "#ecc58a")
  if canopy then
    -- fringed canopy on posts at the rear half
    local cx0 = x + 2
    c:part(c:rect(cx0 - 2, y - 23, x + rx + 2, y - 14), GV.ramp(canopy), { cres = 2, deep = 3, gloss = false })
    for fx = cx0, x + rx, 2 do c:fill(c:rect(fx, y - 13, fx, y - 12), "#f5cf6a") end
    c:fill(c:rect(cx0 + 1, y - 13, cx0 + 1, y - 4), "#8a4f2a"); c:fill(c:rect(x + rx - 1, y - 12, x + rx - 1, y - 4), "#8a4f2a")
  end
  local fl = canopy and { x - rx - 2, x + 2 } or { x - rx - 2, x + rx + 4 }
  -- marigold and lotus heaped in the open part of the boat
  for i = 0, 4 do
    local lx = fl[1] + 3 + i * (fl[2] - fl[1] - 6) / 4
    c:part(c:ellipse(lx, y - 6, 4, 3), GV.ramp("#4a8a3e"), { flat = true, gloss = false, outline = false, contour = "#2a1a10" })
  end
  for i, col in ipairs(flowers) do
    local fx = fl[1] + 4 + (i - 1) * (fl[2] - fl[1] - 8) / math.max(1, #flowers - 1)
    bloom(fx, y - 7 - (i % 2) * 4, col, 3 + (i % 2))
  end
end
local function gnome(x, y, hat, shirt)
  c:part(c:ellipse(x, y - 5, 6, 6), GV.ramp(shirt), { cres = 3, deep = 4, gloss = false })
  c:part(c:ellipse(x, y - 14, 6, 5.5), "skin", { cres = 3, deep = 4, gloss = false })
  c:part(c:poly({ {x - 7, y - 19}, {x + 1, y - 34}, {x + 7, y - 19} }), GV.ramp(hat), { cres = 3, deep = 4, gloss = false })
  c:eye(x - 5, y - 17, true); c:eye(x + 2, y - 17, true)
  c:fill(c:rect(x - 4, y - 11, x + 4, y - 8), "#f2e4c0")
  c:px(x - 1, y - 13, "#d9885a"); c:px(x, y - 13, "#d9885a")
end

-- sky and Himalaya --------------------------------------------------------------------------------------------------
L.sky(c, "day", HOR)
L.cloud(c, 38, 18, 16); L.cloud(c, 150, 10, 14); L.cloud(c, 214, 26, 16); L.cloud(c, 90, 30, 10)
local function snowpeak(pts, col, cap)
  c:part(c:poly(pts), GV.ramp(col), { cres = 5, gloss = false, rim = false, outline = false })
  if cap then c:fill(c:poly(cap), "#f4f0e0") end
end
snowpeak({ {10,HOR},{50,24},{66,12},{78,22},{92,16},{140,HOR} }, "#6a8ab8", { {66,12},{57,24},{63,22},{67,28},{72,23},{77,27},{78,22} })
snowpeak({ {120,HOR},{160,28},{182,14},{198,26},{222,18},{240,36},{240,HOR} }, "#5a7aa8", { {182,14},{172,28},{178,25},{183,31},{189,26},{195,29},{198,26} })
c:part(c:poly({ {0,HOR},{0,46},{40,42},{70,50},{100,HOR} }), GV.ramp("#4a7a4a"), { cres = 4, gloss = false, rim = false, outline = false })
c:part(c:poly({ {150,HOR},{190,48},{240,42},{240,HOR} }), GV.ramp("#5a8a50"), { cres = 4, gloss = false, rim = false, outline = false })
c:part(c:rect(0, 60, W - 1, 74), GV.ramp("#5a8a50"), { cres = 3, gloss = false, rim = false, outline = false })
-- poplars and chinar trees on the far shore
local function poplar(x, base, h)
  c:part(c:ellipse(x, base - h / 2, 4, h / 2), GV.ramp("#3a7a3a"), { cres = 2, gloss = false, outline = false })
end
local function chinar(x, base)
  c:fill(c:rect(x - 1, base - 12, x + 1, base), "#5a3a22")
  c:part(c:ellipse(x, base - 16, 10, 8), GV.ramp("#e07a2a"), { cres = 3, deep = 4, gloss = false })
  c:part(c:ellipse(x - 6, base - 11, 5, 4), GV.ramp("#c8502a"), { flat = true, gloss = false, outline = false })
end
poplar(4, 74, 34); poplar(12, 74, 28); poplar(88, 74, 32); poplar(96, 74, 26); poplar(146, 74, 30); poplar(236, 74, 34); poplar(228, 74, 26)
chinar(44, 74); chinar(176, 74)
-- Kashmiri wooden lakeside houses: lattice windows, steep pitched roofs
local function house(x0, x1, y0, wall, roof)
  c:part(c:rect(x0, y0, x1, 74), GV.ramp(wall), { cres = 4, deep = 6, gloss = false })
  c:part(c:poly({ {x0 - 3, y0 + 1}, {x0 + 4, y0 - 10}, {x1 - 4, y0 - 10}, {x1 + 3, y0 + 1} }), GV.ramp(roof), { cres = 3, deep = 5, gloss = false })
  for wx = x0 + 4, x1 - 8, 8 do
    c:part(c:rect(wx, y0 + 6, wx + 4, y0 + 13), GV.ramp("#5a3a22"), { gloss = false, outline = false, contour = "#2a1a10" })
    c:fill(c:rect(wx + 1, y0 + 7, wx + 3, y0 + 8), "#f5cf6a"); c:fill(c:rect(wx + 1, y0 + 10, wx + 3, y0 + 11), "#f5cf6a")
    c:fill(c:rect(wx - 1, y0 + 14, wx + 5, y0 + 14), "#f08a24")
  end
end
house(14, 40, 54, "#c89a62", "#7a5a48"); house(54, 84, 50, "#d9a660", "#6a4a3a")
house(186, 212, 52, "#c89a62", "#7a5a48"); house(150, 172, 56, "#e0b878", "#6a4a3a")
-- Mughal garden pavilion with a chhatri dome, centre-back
c:part(c:rect(100, 54, 126, 74), GV.ramp("#f2e4c0", { dot = "#fff3c8", gloss = "#fff3c8" }), { cres = 4, deep = 7, pale = true, gloss = false })
for _, ax in ipairs({ 103, 111, 119 }) do c:fill(c:rect(ax, 60, ax + 4, 74), "#35285c"); c:fill(c:ellipse(ax + 2, 60, 2.5, 2.5), "#35285c") end
c:part(c:poly({ {98,54},{101,50},{125,50},{128,54} }), GV.ramp("#d9a660"), { cres = 2, gloss = false })
c:part(c:ellipse(113, 46, 9, 7), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 3, deep = 4, gloss = false })
c:fill(c:rect(112, 33, 114, 40), "#d4a02a"); c:px(113, 32, "#f5cf6a")
c:part(c:ellipse(113, 33, 2, 2), GV.ramp("#d4a02a"), { flat = true, gloss = false, outline = false })
-- water --------------------------------------------------------------------------------------------------------------
c:bands(c:rect(0, 75, W - 1, H - 1), { "#5aa8c8", "#4a98bc", "#3f8fb0", "#3584a6", "#2f78a0", "#2a6c94" }, { dir = "v" })
c:fill(c:rect(0, 75, W - 1, 75), "#2f5a2a")
for i = 0, 18 do local x = (i * 37 + 9) % 226; local y = 80 + (i * 9) % 50; c:fill(c:rect(x, y, x + 5 + i % 4 * 2, y), "#8fcbd8") end
for _, r in ipairs({ {14,78,"#c89a62"},{56,80,"#d9a660"},{154,78,"#e0b878"},{190,80,"#c89a62"},{104,78,"#f2e4c0"} }) do
  c:fill(c:rect(r[1], r[2], r[1] + 20, r[2]), r[3]); c:fill(c:rect(r[1] + 4, r[2] + 3, r[1] + 16, r[2] + 3), r[3])
end
-- floating lotus pads in the shallows
for _, p in ipairs({ {70,86},{92,84},{168,86},{140,82},{26,88},{222,90} }) do
  c:part(c:ellipse(p[1], p[2], 5, 2), GV.ramp("#4a8a3e"), { flat = true, gloss = false, outline = false })
  c:part(c:ellipse(p[1] + 1, p[2] - 2, 2.5, 2.5), GV.ramp("#f6a0c4"), { flat = true, gloss = false, outline = false }); c:px(p[1] + 1, p[2] - 2, "#f5cf6a")
end
-- moored houseboat (carved eaves), back right
c:part(c:poly({ {128,74},{176,74},{172,82},{132,82} }), GV.ramp("#8a4f2a"), { cres = 3, deep = 4, gloss = false })
c:part(c:rect(134, 66, 170, 74), GV.ramp("#d9a660"), { cres = 3, deep = 4, gloss = false })
c:part(c:poly({ {131,67},{136,61},{168,61},{173,67} }), GV.ramp("#6a8a4a"), { cres = 2, gloss = false })
for wx = 138, 164, 8 do c:fill(c:rect(wx, 69, wx + 3, 72), "#35285c") end

-- garlands strung between poles ---------------------------------------------------------------------------------------------------
c:part(c:rect(6, 62, 8, 100), GV.ramp("#8a4f2a"), { cres = 1, gloss = false })
c:part(c:rect(232, 62, 234, 100), GV.ramp("#8a4f2a"), { cres = 1, gloss = false })
local function garland(x0, y0, x1, y1, sag, seed)
  local n = 24
  for i = 0, n do
    local t = i / n
    local x = x0 + (x1 - x0) * t; local y = y0 + (y1 - y0) * t + sag * math.sin(t * math.pi)
    c:fill(c:rect(x - 1, y, x + 1, y + 1), "#4a8a3e")
    if i % 2 == 0 then c:part(c:ellipse(x, y + 2, 2, 2), GV.ramp(FL[(i // 2 + seed) % #FL + 1]), { flat = true, gloss = false, outline = false }) end
  end
end
garland(8, 66, 232, 66, 22, 0)
garland(8, 74, 120, 80, 12, 3)

-- the three flower boats ------------------------------------------------------------------------------------------------------------------
boat(40, 100, 22, "#2f8a7a", { "#f08a24", "#f5cf6a", "#f08a24", "#e8a41c", "#f6a0c4" }, "#d6322b")
boat(196, 98, 22, "#a8582f", { "#f6a0c4", "#fff1c8", "#f08a24", "#f5cf6a", "#f6a0c4" }, "#3f8fb0")
-- centre-front boat with the florist gnome
boat(120, 124, 28, "#d9a660", { "#f08a24", "#f5cf6a", "#f6a0c4", "#f08a24", "#fff1c8", "#e8a41c", "#f6b8cf" })
gnome(130, 118, "#e46a9b", "#3f8fb0")
-- she holds up a garland
c:limb({ {124, 114}, {118, 108}, {114, 104} }, 3)
for i = 0, 9 do local x = 90 + i * 4; c:part(c:ellipse(x, 100 + (i % 2) * 3 + math.floor(6 * math.sin(i / 9 * 3.14)), 2, 2), GV.ramp(FL[i % #FL + 1]), { flat = true, gloss = false, outline = false }); end
-- paddle
c:fill(c:rect(148, 104, 149, 128), "#8a4f2a"); c:fill(c:rect(146, 126, 151, 131), "#d9a660")

-- floating petals, a duck family ----------------------------------------------------------------------------------------------------------------------------
for _, p in ipairs({ {20,116},{70,112},{80,130},{164,118},{210,122},{182,110},{16,130} }) do
  c:px(p[1], p[2], FL[(p[1] // 4) % #FL + 1]); c:px(p[1] + 1, p[2], FL[(p[1] // 4) % #FL + 1])
end
c:part(c:ellipse(214, 106, 6, 4), GV.ramp("#fff1c8", { dot = "#ffffff" }), { cres = 2, deep = 3, gloss = false })
c:part(c:ellipse(220, 100, 3.5, 3.5), GV.ramp("#fff1c8"), { cres = 2, gloss = false })
c:fill(c:rect(223, 100, 225, 101), "#f08a24"); c:eye(218, 98, true)
c:part(c:ellipse(228, 112, 3, 2.5), GV.ramp("#f2e4c0"), { flat = true, gloss = false })
c:part(c:ellipse(232, 109, 2, 2), GV.ramp("#f2e4c0"), { flat = true, gloss = false }); c:px(234, 109, "#f08a24")

L.finish(c, "haven-floating-flower-market")
