-- wonder-cedar-sanctuary.lua : ancient cedars, so quiet. A cushion on a mossy stone circle, a seed drifting down. Misty morning.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local FLAT = { gloss = false, rim = false, bounce = false, outline = false }
local MIST = { "#9cc0cc", "#aecdd4", "#bfd9dc", "#cfe4e2", "#dcece4", "#e8f2e4" }
c:bands(c:rect(0, 0, W - 1, 100), MIST, { dir = "v" })
-- pale sun glow top-left (hard rings)
c:fill(c:ellipse(46, 20, 14, 14), "#e8f2e4"); c:fill(c:ellipse(46, 20, 9, 9), "#f6f4da"); c:fill(c:ellipse(46, 20, 5, 5), "#fff1c8")
-- snowy peaks
c:part(c:poly({ {0,78},{0,62},{22,46},{34,56},{58,36},{80,58},{108,44},{132,60},{160,38},{186,56},{212,42},{240,58},{240,78} }), GV.ramp("#8aa0c8", { shade = "#6f86b4", deep = "#56699a" }), { gloss = false, rim = false, bounce = false, outline = false, cres = 6, deep = 10 })
for _, p in ipairs({ { {22,46},{16,54},{22,52},{26,56},{30,52},{34,56} }, { {58,36},{50,48},{56,45},{60,50},{66,45},{72,50},{80,58} }, { {108,44},{102,52},{108,50},{112,54},{118,50},{122,54} }, { {160,38},{152,50},{158,47},{162,52},{168,47},{176,52},{186,56} }, { {212,42},{205,52},{211,50},{216,54},{222,50},{226,54} } }) do
  c:fill(c:poly({ p[1], p[2], p[3], p[4], p[5], p[6], p[7] or p[6] }), "#f6f4ee")
end
-- mist bands across the base of the peaks
for _, m in ipairs({ {30,70,50,3},{150,66,60,3},{200,76,40,2},{96,74,44,2} }) do c:fill(c:ellipse(m[1], m[2], m[3], m[4]), "#dcece4") end
-- far dark forest line
c:part(c:poly({ {0,100},{0,76},{14,70},{28,78},{44,68},{60,78},{82,70},{100,80},{122,70},{140,80},{160,72},{184,80},{204,70},{222,78},{240,72},{240,100} }), GV.ramp("#5a8a78", { shade = "#487868", deep = "#386058" }), { gloss = false, rim = false, bounce = false, outline = false, cres = 4 })
-- ground
c:part(L.below(c, function(x) return 92 + 2 * math.sin(x / 19) end), GV.ramp("#7ab55c", { shade = "#5e9a48", deep = "#3a6a34" }), { cres = 6, deep = 9, gloss = false })
-- path of pale earth leading in
c:part(c:poly({ {96,135},{104,108},{134,108},{150,135} }), GV.ramp("#c9a96e"), { gloss = false, rim = false, outline = false, cres = 4 })

-- cedar: trunk, flat layered tiers
local function cedar(cx, base, hgt, rx0, trunkw)
  local TR = GV.ramp("#8a5a3a", { shade = "#6a4028", deep = "#4a2c1a" })
  c:part(c:poly({ {cx - trunkw, base}, {cx - trunkw * 0.5, base - hgt + 8}, {cx + trunkw * 0.5, base - hgt + 8}, {cx + trunkw, base} }), TR, { cres = 4, deep = 6, gloss = false })
  local n = 5
  for i = 1, n do
    local t = (i - 1) / (n - 1)
    local y = base - hgt + 8 + i * (hgt - 26) / n
    local rx = rx0 * (0.35 + 0.65 * t)
    local lobe = c:ellipse(cx, y, rx, 6)
    lobe:add(c:ellipse(cx - rx * 0.55, y + 1, rx * 0.5, 5)); lobe:add(c:ellipse(cx + rx * 0.55, y + 1, rx * 0.5, 5))
    c:part(lobe, GV.ramp((i % 2 == 0) and "#3f8a62" or "#4a9a6a", { shade = "#2f7258", deep = "#1f4a40" }), { cres = 3, deep = 5, gloss = false })
    -- tiny stitch-like needle marks
    for k = -2, 2 do c:px(cx + k * math.floor(rx / 3), y - 1, "#7ac08a") end
  end
  c:part(c:ellipse(cx, base - hgt + 2, math.max(rx0 * 0.3, 3), 4), GV.ramp("#4a9a6a", { shade = "#2f7258", deep = "#1f4a40" }), { cres = 2, deep = 3, gloss = false })
  -- cones
  c:px(cx - 3, base - hgt + 12, "#b07a45"); c:px(cx + rx0 * 0.3, base - hgt + 22, "#b07a45")
end
-- mid-distance small cedars
cedar(104, 96, 40, 18, 3); cedar(140, 98, 44, 20, 3); cedar(222, 98, 40, 18, 3)
-- the two great cedars
cedar(46, 118, 96, 44, 8)
cedar(196, 118, 96, 44, 8)
-- owl on a branch of the left cedar (a little sleepy)
c:part(c:rect(58, 52, 74, 53), GV.ramp("#6a4028"), { flat = true, gloss = false })
c:part(c:ellipse(66, 46, 5, 6), GV.ramp("#b07a45"), { cres = 3, deep = 4, gloss = false })
c:part(c:ellipse(66, 40, 5, 4), GV.ramp("#b07a45"), { cres = 2, deep = 3, gloss = false })
c:fill(c:rect(62, 35, 63, 36), "#8a5a3a"); c:fill(c:rect(69, 35, 70, 36), "#8a5a3a")
c:eye(61, 38, true); c:eye(67, 38, true)
c:px(66, 41, "#e8a317"); c:fill(c:rect(63, 46, 69, 46), "#d9a660"); c:fill(c:rect(64, 48, 68, 48), "#d9a660")

-- the sanctuary: moss stone circle and a felt meditation cushion, in a pool of light
local cx, cy = 118, 114
c:part(c:ellipse(cx, cy + 4, 26, 8), GV.ramp("#a8a8a0", { shade = "#808890", deep = "#5b6470", rim = "#d0ccc0" }), { cres = 4, deep = 6, gloss = false })
c:part(c:ellipse(cx, cy + 3, 20, 5.5), GV.ramp("#7ab55c", { shade = "#5e9a48", deep = "#3a6a34" }), { flat = true, gloss = false, outline = false })
-- light shaft pool (lighter patch, hard edge)
c:fill(c:ellipse(cx - 2, cy + 3, 15, 3.5), "#c8d77a")
c:fill(c:ellipse(cx - 2, cy + 3, 9, 2), "#e8eca0")
-- cushion
c:part(c:ellipse(cx, cy - 1, 11, 6), GV.ramp("#b8452f", { shade = "#8a2f2a", deep = "#5a1a22", rim = "#e07a4a" }), { cres = 3, deep = 5 })
c:part(c:ellipse(cx, cy - 3, 9, 3.5), GV.ramp("#d6322b"), { cres = 2, deep = 3, gloss = false })
c:button(cx - 2, cy - 5)
c:seam({ {cx - 9, cy}, {cx + 9, cy} }, { on = 2, off = 1 })
-- a seed drifting down, glowing, with motes
c:part(c:ellipse(cx - 3, 92, 2, 3), GV.ramp("#e8a317"), { flat = true, gloss = false })
c:px(cx - 4, 91, "#fff1c8"); c:px(cx - 3, 97, "#f5cf6a")
c:fill(c:rect(cx - 3, 87, cx - 3, 89), "#f5cf6a")
for _, m in ipairs({ {96,96},{100,86},{114,78},{130,90},{108,104},{124,100},{90,108},{140,104} }) do c:px(m[1], m[2], "#fff1c8") end
-- ferns, mushrooms, and stones in the foreground
local function fern(x, y)
  for i = -3, 3 do c:fill(c:rect(x + i * 2, y - 6 + math.abs(i), x + i * 2 + 1, y), (i % 2 == 0) and "#4a8a3e" or "#6a9a3a") end
  c:px(x, y - 7, "#a4b86a")
end
fern(22, 128); fern(224, 126); fern(78, 130); fern(168, 129)
for _, m in ipairs({ {90,122},{150,124},{36,116} }) do
  c:part(c:ellipse(m[1], m[2], 3, 2), GV.ramp("#d6322b"), { flat = true, gloss = false })
  c:px(m[1] - 1, m[2] - 1, "#f2e4c0"); c:fill(c:rect(m[1], m[2] + 1, m[1], m[2] + 3), "#f2e4c0")
end
for _, p in ipairs({ {60,126,4,2},{180,124,5,2},{130,129,3,1} }) do c:part(c:ellipse(p[1], p[2], p[3], p[4]), GV.ramp("#8b8f96"), { flat = true, gloss = false }) end
-- a little bird in the air
for _, g in ipairs({ {150,30},{160,26} }) do c:px(g[1], g[2], "#56699a"); c:px(g[1]+1, g[2]+1, "#56699a"); c:px(g[1]+2, g[2], "#56699a") end
L.finish(c, "wonder-cedar-sanctuary")
