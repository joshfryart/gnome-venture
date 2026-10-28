-- delve-fynbos-fire-trails.lua : ESA zone 4 delve. "Scorched trails through hardy shrubs."
-- Ember-red dusk over a flat-topped mountain: a trail through scorched fynbos with charred shrub skeletons, green regrowth,
-- king proteas and fire lilies blooming from the ash, and a chibi rock hyrax (dassie) sniffing a protea.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, W, H = L.GV, L.W, L.H
local c = L.new()
local SLUG = "delve-fynbos-fire-trails"
local FL = { gloss = false, rim = false, bounce = false, outline = false }
local function fl(t) local r = {}; for k, v in pairs(FL) do r[k] = v end; for k, v in pairs(t or {}) do r[k] = v end; return r end

c:bands(c:rect(0, 0, W - 1, 84), { "#3a2a4a", "#5a3050", "#7a3a50", "#a8504a", "#d6703a", "#f0903a", "#f8b860" }, { dir = "v" })
-- smoke plumes drifting (dark hard clouds)
L.cloud(c, 60, 24, 24, "#4a3a54", "#3a2a4a"); L.cloud(c, 160, 16, 28, "#5a4258", "#3a2a4a"); L.cloud(c, 214, 36, 16, "#6a4a58", "#4a3a54"); L.cloud(c, 20, 44, 14, "#7a4a58", "#5a3a50")
for _, p in ipairs({ {100,60},{120,50},{34,66},{182,58},{200,70},{80,40} }) do c:px(p[1], p[2], "#fbe0a8") end -- drifting sparks
c:fill(c:ellipse(60, 80, 10, 10):clip(c:rect(0, 0, W, 84)), "#fbd890") -- hazy sun
c:fill(c:ellipse(60, 80, 6, 6):clip(c:rect(0, 0, W, 84)), "#fff1c8")

-- flat-topped mountain (Table Mountain) with cloud tablecloth
local mtn = c:poly({ {50,92},{70,64},{88,52},{150,50},{176,56},{202,70},{232,92} })
c:part(mtn, GV.ramp("#6a4a6a"), fl({ cres = 9, deep = 12 }))
L.cloud(c, 120, 50, 26, "#b8808a", "#8a5a6a")
-- ember lines on the far slopes
for _, l in ipairs({ {{80,74},{96,70},{112,76}}, {{150,70},{170,74},{186,72}}, {{98,84},{118,82}} }) do c:seam(l, { free = true, on = 2, off = 1, gap = "#d6703a" }) end

c:fill(c:rect(0, 84, W - 1, H - 1), "#5a3a3a")
-- distant ridges (ash grey-brown) 
c:part(L.below(c, function(x) return 92 - math.abs(math.sin(x / 15)) * 8 end):clip(c:rect(0, 70, W, 106)), GV.ramp("#5a3a3a"), fl({ cres = 4, deep = 6 }))

-- mid slope: scorched earth with green regrowth
c:part(L.below(c, function(x) return 98 + math.sin(x / 20 + 1) * 4 end), GV.ramp("#4a3228"), { cres = 6, deep = 10, gloss = false, rim = false })
-- regrowth patches (green)
for _, g in ipairs({ {20,108,9},{62,112,7},{96,104,8},{150,106,10},{190,108,8},{222,104,9},{36,98,6} }) do
  c:part(c:ellipse(g[1], g[2], g[3], 3), GV.ramp("#7ab55c"), fl({ cres = 2, deep = 3 }))
  for k = -g[3] + 2, g[3] - 2, 4 do c:px(g[1] + k, g[2] - 4, "#a4b86a"); c:px(g[1] + k, g[2] - 3, "#c8d77a") end
end
-- charred shrub skeletons (black-brown forks with glowing ember tips)
local function stump(x, y, h)
  local pts = { {x, y}, {x, y - h} }
  c:fill(c:rect(x, y - h, x + 1, y), "#2a1a10")
  c:fill(c:rect(x - 3, y - h + 3, x - 2, y - h + 5), "#2a1a10"); c:fill(c:rect(x - 3, y - h + 3, x, y - h + 4), "#2a1a10")
  c:fill(c:rect(x + 2, y - h + 5, x + 4, y - h + 6), "#2a1a10"); c:fill(c:rect(x + 4, y - h + 2, x + 5, y - h + 6), "#2a1a10")
  c:fill(c:rect(x - 1, y - h - 2, x - 1, y - h), "#2a1a10"); c:fill(c:rect(x + 1, y - h - 1, x + 2, y - h - 1), "#2a1a10")
  c:px(x - 3, y - h + 3, "#e0501f"); c:px(x + 5, y - h + 2, "#f08a24"); c:px(x - 1, y - h - 2, "#e0501f")
end
for _, s in ipairs({ {10,106,12},{40,104,10},{78,102,14},{130,104,12},{172,102,10},{208,106,12},{228,100,9},{108,100,7} }) do stump(s[1], s[2], s[3]) end

-- the trail: pale ash-grey winding path, wide at the front, narrowing to the hills
local trail = c:poly({ {64,H},{92,118},{112,108},{128,100},{140,96},{146,96},{140,102},{140,112},{140,H} })
trail = c:poly({ {50,H},{84,120},{108,110},{126,102},{140,98},{150,98},{148,104},{156,112},{176,H} })
c:part(trail, GV.ramp("#c9b8a0", { shade = "#a08a7a", deep = "#6a5a50" }), { cres = 4, deep = 7, gloss = false, rim = false })
-- paw / boot prints and trail stones
for _, p in ipairs({ {112,116},{122,110},{132,106} }) do c:px(p[1], p[2], "#a08a7a"); c:px(p[1] + 2, p[2], "#a08a7a") end
for _, p in ipairs({ {94,126,3,1},{150,124,3,2},{168,120,2,1} }) do c:part(c:ellipse(p[1], p[2], p[3], p[4]), GV.ramp("#8b8f96"), { flat = true, gloss = false }) end
-- cairn-style trail marker with a red ribbon
c:part(c:ellipse(188, 118, 8, 4), GV.ramp("#8b8f96"), { cres = 2, deep = 4, gloss = false })
c:part(c:ellipse(188, 112, 6, 3), GV.ramp("#a09ca0"), { cres = 2, deep = 3, gloss = false })
c:fill(c:rect(188, 98, 189, 110), "#7a4a1f"); c:fill(c:rect(190, 98, 196, 101), "#d6322b"); c:fill(c:rect(190, 98, 196, 98), "#e0501f")

-- king proteas (big pink flower heads) and fire lilies (orange spikes), foreground
local function protea(x, y, r)
  c:fill(c:rect(x, y, x + 1, y + 14), "#4a8a3e")
  c:part(c:ellipse(x - 5, y + 9, 4, 2), GV.ramp("#7ab55c"), { flat = true, gloss = false })
  c:part(c:ellipse(x + 6, y + 6, 4, 2), GV.ramp("#7ab55c"), { flat = true, gloss = false })
  c:part(c:ellipse(x, y, r, r), GV.ramp("#e46a9b"), { cres = 3, deep = 5, gloss = false })
  c:part(c:ellipse(x, y, r - 3, r - 3), GV.ramp("#f6b8cf"), { cres = 2, deep = 3, gloss = false, outline = false })
  c:part(c:ellipse(x, y + 1, r - 5, r - 5), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false })
  for dx = -(r - 2), r - 2, 3 do c:px(x + dx, y - r + 1, "#e46a9b") end
end
protea(26, 100, 10); protea(214, 98, 8); protea(166, 108, 6)
for _, x in ipairs({ 52, 66, 196, 232 }) do
  c:fill(c:rect(x, 108, x + 1, 120), "#4a8a3e")
  c:part(c:poly({ {x - 3, 108}, {x + 4, 108}, {x + 1, 98} }), GV.ramp("#f08a24"), { flat = true, gloss = false })
end

-- the rock hyrax (dassie), sitting on the trail
local DX, DY = 96, 114
local D = GV.ramp("#9a6b3f", { gloss = "#d9a660", shade = "#7a4a1f", deep = "#4a2c1a" })
c:part(c:ellipse(DX, DY, 15, 11), D, { cres = 5, deep = 8 })
c:part(c:ellipse(DX, DY + 3, 8, 7):clip(c:rect(0, DY + 1, W, H)), GV.ramp("#d8c8a0", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false })
for _, dx in ipairs({ -9, 5 }) do c:part(c:ellipse(DX + dx + 2, DY + 10, 4, 3), D, { cres = 2, deep = 3, gloss = false }) end
-- head (big, blunt)
c:part(c:ellipse(DX - 2, DY - 13, 12, 9), D, { cres = 4, deep = 7 })
for _, dx in ipairs({ -10, 7 }) do
  c:part(c:ellipse(DX + dx, DY - 21, 3, 3), D, { cres = 1, deep = 2, gloss = false })
  c:px(DX + dx, DY - 21, "#4a2c1a")
end
c:part(c:ellipse(DX - 2, DY - 9, 6, 4), GV.ramp("#d8c8a0", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false })
c:fill(c:rect(DX - 3, DY - 11, DX - 1, DY - 10), "#2a1a10")
c:px(DX - 4, DY - 7, "#2a1a10"); c:px(DX - 3, DY - 6, "#2a1a10"); c:px(DX - 2, DY - 6, "#2a1a10"); c:px(DX - 1, DY - 6, "#2a1a10"); c:px(DX, DY - 7, "#2a1a10")
c:eye(DX - 11, DY - 18); c:eye(DX + 3, DY - 18)
c:ground(DX, DY + 13, 16, 2)

-- a few drifting embers in front
for _, p in ipairs({ {30,60},{150,40},{220,50},{176,80},{70,90},{44,84} }) do c:px(p[1], p[2], "#f08a24"); c:px(p[1] + 1, p[2] - 1, "#fbe0a8") end

L.finish(c, SLUG)
