-- haven-floating-flower-market : Andean lake-town canal at morning. Boats heaped with flowers, garlands, a gnome florist.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 56
local RED = "#d6322b"
local FL = { "#e46a9b", "#f5cf6a", RED, "#f6b8cf", "#f08a24", "#c3b2ea", "#fff1c8" }

local function bloom(x, y, col, r)
  c:part(c:ellipse(x, y, r or 3, r or 3), GV.ramp(col), { flat = true, gloss = false, outline = false, contour = "#4a2c1a" })
  c:px(x, y, "#f5cf6a"); 
end
local function boat(x, y, rx, tone, flowers)
  -- hull (curved prow and stern)
  c:part(c:poly({ {x - rx - 5, y - 3}, {x + rx + 5, y - 3}, {x + rx - 2, y + 8}, {x - rx + 2, y + 8} }), GV.ramp(tone), { cres = 4, deep = 6, gloss = false })
  c:seam({ {x - rx, y + 2}, {x + rx, y + 2} }, { on = 2, off = 1 })
  c:fill(c:rect(x - rx - 5, y - 3, x + rx + 5, y - 3), "#ecc58a")
  -- leaves then blooms heaped above
  for i = 0, 5 do
    local lx = x - rx + 3 + i * (2 * rx - 6) / 5
    c:part(c:ellipse(lx, y - 6, 4, 3), GV.ramp("#4a8a3e"), { flat = true, gloss = false, outline = false, contour = "#2a1a10" })
  end
  for i, col in ipairs(flowers) do
    local fx = x - rx + 4 + (i - 1) * (2 * rx - 8) / math.max(1, #flowers - 1)
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

-- sky and Andes -------------------------------------------------------------------------------------------------
L.sky(c, "day", HOR)
L.cloud(c, 38, 18, 16); L.cloud(c, 128, 10, 14); L.cloud(c, 210, 24, 16); L.cloud(c, 84, 36, 10)
c:part(c:poly({ {20,HOR},{60,20},{74,12},{84,24},{96,18},{130,HOR} }), GV.ramp("#6a8ab8"), { cres = 5, gloss = false, rim = false, outline = false })
c:part(c:poly({ {74,12},{66,26},{72,24},{76,30},{82,26},{86,28},{84,24} }), GV.ramp("#f4f0e0"), { cres = 2, gloss = false, rim = false, outline = false })
c:part(c:poly({ {110,HOR},{150,26},{170,18},{186,30},{214,HOR} }), GV.ramp("#5a7aa8"), { cres = 5, gloss = false, rim = false, outline = false })
c:part(c:poly({ {170,18},{161,32},{167,29},{171,35},{177,30},{182,33},{186,30} }), GV.ramp("#f4f0e0"), { cres = 2, gloss = false, rim = false, outline = false })
c:part(c:poly({ {0,HOR},{0,44},{40,40},{70,48},{100,HOR} }), GV.ramp("#6a9a3a"), { cres = 4, gloss = false, rim = false, outline = false })
c:part(c:poly({ {160,HOR},{190,46},{240,38},{240,HOR} }), GV.ramp("#7ab55c"), { cres = 4, gloss = false, rim = false, outline = false })
-- terrace lines
for _, y in ipairs({ 46, 50, 54 }) do c:fill(c:rect(2, y, 38, y), "#4a8a3e") end
for _, y in ipairs({ 46, 50, 54 }) do c:fill(c:rect(200, y, 236, y), "#6a9a3a") end

c:part(c:rect(0, 60, W - 1, 74), GV.ramp("#6a9a3a"), { cres = 3, gloss = false, rim = false, outline = false })
-- far shore: pastel colonial houses --------------------------------------------------------------------------------
local function casa(x0, x1, y0, col, roof)
  c:part(c:rect(x0, y0, x1, 74), GV.ramp(col), { cres = 4, deep = 6, gloss = false })
  c:part(c:poly({ {x0 - 3, y0}, {x0 + 3, y0 - 8}, {x1 - 3, y0 - 8}, {x1 + 3, y0} }), GV.ramp(roof), { cres = 3, deep = 5, gloss = false })
  for wx = x0 + 4, x1 - 8, 9 do
    c:part(c:rect(wx, y0 + 6, wx + 4, y0 + 13), GV.ramp("#2f5a8a"), { gloss = false, outline = false, contour = "#2a1a10" })
    c:fill(c:rect(wx + 1, y0 + 7, wx + 3, y0 + 9), "#8fcbd8")
    c:fill(c:rect(wx - 1, y0 + 14, wx + 5, y0 + 15), "#e46a9b")   -- flower box
  end
end
casa(6, 40, 52, "#f5cf6a", "#c64a2a"); casa(42, 80, 48, "#e46a9b", "#a8582f"); casa(150, 190, 50, "#8fcbd8", "#c64a2a"); casa(192, 234, 54, "#f08a24", "#a8582f")
-- church tower in the middle-back
c:part(c:rect(104, 40, 120, 74), GV.ramp("#f2e4c0", { dot = "#fff3c8", gloss = "#fff3c8" }), { cres = 4, deep = 7, pale = true, gloss = false })
c:part(c:poly({ {102,40},{112,28},{122,40} }), GV.ramp("#c64a2a"), { cres = 3, deep = 5, gloss = false })
c:fill(c:rect(109, 46, 115, 54), "#35285c"); c:fill(c:rect(110, 47, 114, 49), "#4e3a8a")
c:part(c:ellipse(112, 62, 3, 3), GV.ramp("#f5cf6a"), { flat = true, gloss = false })
c:fill(c:rect(111, 22, 111, 27), "#2a1a10"); c:fill(c:rect(109, 24, 113, 24), "#2a1a10")

-- water ----------------------------------------------------------------------------------------------------------------
c:bands(c:rect(0, 75, W - 1, H - 1), { "#5aa8c8", "#4a98bc", "#3f8fb0", "#3584a6", "#2f78a0", "#2a6c94" }, { dir = "v" })
c:fill(c:rect(0, 75, W - 1, 75), "#2f5a2a")   -- bank edge shadow
for i = 0, 18 do local x = (i * 37 + 9) % 226; local y = 80 + (i * 9) % 50; c:fill(c:rect(x, y, x + 5 + i % 4 * 2, y), "#8fcbd8") end
-- reflections of houses (broken colour dashes)
for _, r in ipairs({ {10,78,"#f5cf6a"},{50,80,"#e46a9b"},{158,78,"#8fcbd8"},{200,80,"#f08a24"},{108,78,"#f2e4c0"} }) do
  c:fill(c:rect(r[1], r[2], r[1] + 20, r[2]), r[3]); c:fill(c:rect(r[1] + 4, r[2] + 3, r[1] + 16, r[2] + 3), r[3])
end

-- stone bridge, centre back ---------------------------------------------------------------------------------------------------
c:part(c:poly({ {128,75},{128,70},{150,70},{150,75} }), GV.ramp("#8b8f96"), { cres = 2, gloss = false })

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
boat(40, 100, 22, "#b07a45", { "#e46a9b", "#f5cf6a", RED, "#f6b8cf", "#f08a24" })
boat(196, 98, 22, "#a8582f", { "#c3b2ea", "#fff1c8", "#e46a9b", "#f5cf6a", "#f08a24" })
-- centre-front boat with the florist gnome
boat(120, 124, 28, "#d9a660", { "#d6322b", "#f5cf6a", "#e46a9b", "#fff1c8", "#f6b8cf", "#f08a24", "#c3b2ea" })
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
