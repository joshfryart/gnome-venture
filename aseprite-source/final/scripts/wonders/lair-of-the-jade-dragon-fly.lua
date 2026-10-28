-- lair-of-the-jade-dragon-fly.lua : Boss lair (EA, zone 4). A jade dragon-fly hovers over a misty lotus pond below karst peaks and a pagoda. Day. Params out= ase=
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 96
L.sky(c, "day", HOR)
L.cloud(c, 40, 20, 18, "#f4f0e0", "#cfe0e8"); L.cloud(c, 200, 14, 16, "#f4f0e0", "#cfe0e8"); L.cloud(c, 150, 30, 12, "#f4f0e0", "#cfe0e8")
-- karst peaks in mist: far pale, near teal
local function karst(x, top, hw, col, cap)
  local m = c:poly({ {x - hw, HOR + 2}, {x - hw * 0.7, top + 14}, {x - hw * 0.35, top + 3}, {x, top}, {x + hw * 0.35, top + 4}, {x + hw * 0.7, top + 16}, {x + hw, HOR + 2} })
  c:fill(m, col)
  c:fill(m:copy():clip(c:rect(0, 0, W, top + 5)), cap)
end
karst(30, 36, 20, "#9ac4c8", "#b4d4d4"); karst(100, 46, 18, "#9ac4c8", "#b4d4d4"); karst(180, 30, 22, "#9ac4c8", "#b4d4d4"); karst(226, 50, 18, "#9ac4c8", "#b4d4d4")
c:fill(c:rect(0, 74, W, 78), "#cfe8f0"); c:fill(c:rect(0, 79, W, 82), "#e2f0e0")
karst(60, 52, 24, "#5a9a8a", "#7ab8a0"); karst(150, 58, 20, "#5a9a8a", "#7ab8a0"); karst(210, 66, 22, "#4a8a7e", "#6aa890")
c:fill(c:rect(0, 90, W, 94), "#cfe8f0")
-- pond
L.water(c, HOR, { "#8fcbd8", "#7bbcc8", "#6aaec0", "#5a9ebc", "#4a90b0", "#3f8fb0" })
for _, w in ipairs({ {8,104,10},{30,112,14},{190,106,12},{214,116,10},{70,124,12},{176,126,14},{110,128,10} }) do c:fill(c:rect(w[1], w[2], w[1] + w[3], w[2]), "#c8ecdc") end
-- pagoda on the left shore
c:part(c:poly({ {0,H},{0,100},{34,98},{54,104},{66,H} }), GV.ramp("#8b8f96"), { cres = 6, deep = 8, gloss = false })
local function tier(y, hw, h) c:part(c:rect(30 - hw + 3, y, 30 + hw - 3, y + h), GV.ramp("#f2e4c0"), { cres = 2, deep = 3, gloss = false }); c:part(c:poly({ {30 - hw - 3, y + 1}, {30, y - 5}, {30 + hw + 3, y + 1} }), "red", { cres = 3, deep = 4 }) end
tier(88, 14, 9); tier(74, 11, 8); tier(62, 8, 7)
c:part(c:ellipse(30, 50, 2, 2), GV.ramp("#e8a317"), { flat = true }); c:fill(c:rect(30, 40, 30, 50), "#2a1a10")
c:fill(c:rect(28, 92, 31, 97), "#8a4f2a")
-- bamboo clump on the right
for i, x in ipairs({ 206, 214, 222, 230 }) do
  local top = 22 + (i * 11) % 24
  c:part(c:rect(x, top, x + 2, 112), GV.ramp("#7ab55c"), { cres = 2, deep = 3, gloss = false })
  for y = top + 10, 108, 12 do c:fill(c:rect(x, y, x + 2, y), "#4a8a3e") end
  c:part(c:poly({ {x + 2, top + 14}, {x + 16, top + 8}, {x + 4, top + 20} }), GV.ramp("#a4b86a"), { flat = true, outline = false })
end
c:part(c:poly({ {186,H},{186,114},{210,108},{W,106},{W,H} }), GV.ramp("#7ab55c"), { cres = 5, deep = 8, gloss = false })
-- red arched bridge in the mid-ground
c:part(c:poly({ {64,110},{80,102},{108,102},{124,110},{124,113},{108,106},{80,106},{64,113} }), "red", { cres = 2, deep = 3, gloss = false })
for _, x in ipairs({ 76, 90, 100, 112 }) do c:fill(c:rect(x, 104, x, 110), "#8a4f2a") end
-- lotus pads and flowers
local function lotus(x, y, bloom)
  c:part(c:ellipse(x, y, 8, 3), GV.ramp("#4a8a3e"), { flat = true, gloss = false })
  c:px(x + 2, y, "#6a9a3a")
  if bloom then
    c:part(c:poly({ {x - 3, y - 1}, {x, y - 8}, {x + 3, y - 1} }), GV.ramp("#f6b8cf"), { flat = true }); c:part(c:poly({ {x - 6, y - 1}, {x - 3, y - 6}, {x, y - 1} }), GV.ramp("#e46a9b"), { flat = true, outline = false }); c:part(c:poly({ {x, y - 1}, {x + 3, y - 6}, {x + 6, y - 1} }), GV.ramp("#e46a9b"), { flat = true, outline = false })
  end
end
lotus(84, 124, true); lotus(148, 120, true); lotus(122, 130, false); lotus(172, 128, true); lotus(62, 128, false); lotus(196, 124, false)

-- the jade dragon-fly (from above): four wings, long segmented abdomen, whiskers
local JADE = GV.ramp("#3fae8a")
local function wing(pts)
  local m = c:poly(pts)
  c:part(m, GV.ramp("#c8ecdc"), { cres = 3, deep = 4, gloss = false, pale = true })
  return m
end
local function mir(pts) local r = {}; for i, p in ipairs(pts) do r[i] = { 240 - p[1], p[2] } end; return r end
local fw = { {116,60},{90,44},{50,32},{24,38},{30,50},{62,62},{104,68} }
local hw = { {116,70},{92,70},{54,82},{40,92},{56,96},{92,88},{116,80} }
for _, side in ipairs({ 1, -1 }) do
  local a, b = fw, hw
  if side == -1 then a, b = mir(fw), mir(hw) end
  local m1 = wing(b); local m2 = wing(a)
  for _, v in ipairs({ { {112,62},{44,38} }, { {108,66},{40,52} } }) do
    local p, q = v[1], v[2]
    if side == -1 then p = { 240 - p[1], p[2] }; q = { 240 - q[1], q[2] } end
    c:fill(m2:copy():clip(c:line({ p, q }, 1)), "#6aaec0")
  end
  for _, v in ipairs({ { {112,74},{50,90} }, { {108,78},{60,94} } }) do
    local p, q = v[1], v[2]
    if side == -1 then p = { 240 - p[1], p[2] }; q = { 240 - q[1], q[2] } end
    c:fill(m1:copy():clip(c:line({ p, q }, 1)), "#6aaec0")
  end
  c:fill(m2:copy():clip(c:rect(side == 1 and 24 or 210, 36, side == 1 and 32 or 216, 40)), "#2f78a0") -- pterostigma
end
-- abdomen: segmented tail with gold bands
local ab = c:poly({ {114,78},{126,78},{124,126},{116,126} })
c:part(ab, JADE, { cres = 3, deep = 5, gloss = false })
for y = 84, 120, 6 do c:fill(c:rect(115 + (y > 100 and 1 or 0), y, 125 - (y > 100 and 1 or 0), y), "#e8a317") end
-- thorax and head
c:part(c:ellipse(120, 66, 11, 10), JADE, { cres = 4, deep = 6 })
c:seam({ {114,60},{114,72} }, { free = true }); c:seam({ {126,60},{126,72} }, { free = true })
c:part(c:ellipse(120, 48, 16, 12), GV.ramp("#3fae8a"), { cres = 4, deep = 7 })
-- big compound eyes (jade-gold discs) with the locked eye drawn on top
c:part(c:ellipse(107, 46, 7, 7), GV.ramp("#e8a317"), { flat = true }); c:part(c:ellipse(133, 46, 7, 7), GV.ramp("#e8a317"), { flat = true })
c:eye(105, 43); c:eye(131, 43)
-- little gold horns and long whiskers
c:part(c:poly({ {110,38},{108,28},{114,36} }), GV.ramp("#f5cf6a"), { flat = true }); c:part(c:poly({ {130,38},{132,28},{126,36} }), GV.ramp("#f5cf6a"), { flat = true })
for _, s in ipairs({ -1, 1 }) do
  c:fill(c:line({ {120 + s * 10, 56}, {120 + s * 22, 58}, {120 + s * 30, 66}, {120 + s * 28, 76} }, 1), "#e8a317")
  c:part(c:ellipse(120 + s * 28, 78, 2, 2), GV.ramp("#f5cf6a"), { flat = true })
end
c:fill(c:rect(117, 54, 123, 54), "#2a1a10")
L.finish(c, "lair-of-the-jade-dragon-fly")
