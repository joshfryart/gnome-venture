-- gather scene-forest, Hearth Pop v3 PILOT. 480x270 native (scale 1). Single pass.
-- Satchel back comes from satchel.lua (shared by every scene); satchel-front.png overlays it.
-- Quirk: a hollow in the log with two gold eyes watching.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local NAME = app.params.name or "scene-forest"
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = NAME }
local INK = P.ink
local floor, sin, cos, abs, min, max = math.floor, math.sin, math.cos, math.abs, math.min, math.max
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry or rx) end
local function R(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
local function fm(m, h) c:fillMask(m, h) return m end
local function px(x, y, h) c:px(x, y, h) end
local function hash(a, b) return ((a * 73856093) ~ (b * 19349663) ~ (a * b * 83492791)) % 1000 end
local function rim(m, h) return c:rim(m, h or INK) end

local LEAF1 = { hi = "#b4dc6e", base = "#5fae52", shade = "#3f8a4a", deep = "#24544a" }
local LEAF2 = { hi = "#8fcf6a", base = "#46955a", shade = "#2f6e52", deep = "#1f4a46" }
local BARK = { hi = "#a8704a", base = "#7a4a34", shade = "#5a3430", deep = "#3a2229" }
local REDL = { hi = "#ff8a5c", base = "#e8493b", shade = "#b52e3f", deep = "#6e2038" }
local ORGL = { hi = "#ffb85c", base = "#f0882e", shade = "#c95a26", deep = "#7a3423" }
local GOLDL = { hi = "#ffe38a", base = "#f0b43a", shade = "#d0802a", deep = "#8f4a1f" }
local CAP = { hi = "#ff8a5c", base = "#e8493b", shade = "#b52e3f", deep = "#6e2038" }

-- shape then ramp lighting: base, lit upper-left edge, shade lower-right edge, optional deep underside
local function form(m, Rm, o)
  o = o or {}
  fm(m, Rm.base)
  local lt, sh, dp = {}, {}, {}
  m:each(function(x, y)
    if not m:has(x - 2, y - 2) then lt[#lt + 1] = { x, y } end
    if not m:has(x + 2, y + 2) then sh[#sh + 1] = { x, y } end
    if o.deep and not m:has(x, y + 1) then dp[#dp + 1] = { x, y } end
  end)
  for _, p in ipairs(lt) do px(p[1], p[2], Rm.hi) end
  for _, p in ipairs(sh) do px(p[1], p[2], Rm.shade) end
  for _, p in ipairs(dp) do px(p[1], p[2], Rm.deep) end
  return m
end

---------------------------------------------------------------- far: hazy light, far trunks, shafts
c:stripes(0, 150, { "#ffd8a8", "#ffc090", "#f0a89a", "#d896a8", "#b88ab8", "#9a80b0" }, { 2, 3, 3, 3, 3, 3 })
for i = 0, 6 do   -- warm light shafts
  local x = 40 + i * 62
  c:fillMask(c:poly{ { x, 0 }, { x + 22, 0 }, { x + 70, 150 }, { x + 36, 150 } }:clip(R(0, 0, 479, 150)), "#ffdca0")
end
for _, t in ipairs{ { 28, 22 }, { 150, 16 }, { 250, 20 }, { 340, 14 }, { 420, 18 } } do   -- far trunks, violet haze
  fm(R(t[1], 30, t[1] + t[2] - 1, 150), "#9a7aa8")
  fm(R(t[1] + t[2] - 5, 30, t[1] + t[2] - 1, 150), "#86689a")
end
c:terrain(function(x) return 128 + floor(5 * sin(x / 31)) end, "#a8a860", 160, 0, 479)
c:terrain(function(x) return 140 + floor(4 * sin(x / 23 + 2)) end, "#b4c458", 270, 0, 479)
c:terrain(function(x) return 214 + floor(5 * sin(x / 37 + 1)) end, "#7aa84a", 270, 0, 479)
c:terrain(function(x) return 246 + floor(3 * sin(x / 19)) end, "#3a7a4a", 270, 0, 479)
for i = 0, 340 do   -- grass flecks
  local x, y = hash(i, 7) % 480, 146 + hash(i, 11) % 120
  px(x, y, y > 214 and "#4a9050" or "#d4dc70"); px(x, y - 1, y > 214 and "#4a9050" or "#d4dc70")
end

---------------------------------------------------------------- canopy: clustered lobes, each with its own light and shade, hanging leaf scallops
for _, g in ipairs{ { 110, 44, 12, 8 }, { 300, 48, 14, 8 }, { 420, 48, 10, 6 } } do fm(E(g[1], g[2], g[3], g[4]), "#ffd0a0"); px(g[1] - 3, g[2] - 2, "#fff4d6"); px(g[1] - 2, g[2] - 2, "#fff4d6") end
local clusters = { { 40, 14, 52, 24, ORGL, 1 }, { 110, 6, 46, 20, REDL, 2 }, { 170, 18, 46, 22, GOLDL, 3 }, { 236, 6, 48, 22, ORGL, 4 }, { 300, 18, 50, 24, REDL, 5 },
  { 362, 6, 46, 20, GOLDL, 6 }, { 424, 16, 50, 24, ORGL, 7 }, { 474, 6, 34, 20, REDL, 8 }, { 14, 40, 32, 14, GOLDL, 9 }, { 250, 40, 34, 12, LEAF1, 10 }, { 372, 42, 34, 12, GOLDL, 11 }, { 70, 42, 26, 10, LEAF2, 12 } }
local lobesAll = {}
for _, g in ipairs(clusters) do
  local cx, cy, rw, rh, ramp, seed = g[1], g[2], g[3], g[4], g[5], g[6]
  fm(E(cx, cy + rh + 10, rw - 6, 10), "#a888b4")   -- cool shade the canopy throws below
  local n = 8
  for i = 1, n do
    local t = (i - 1) / (n - 1)
    local lx = cx - rw + floor(2 * rw * t) + (hash(seed, i) % 9 - 4)
    local ly = cy + floor(abs(t - .5) * rh * .6) + (hash(seed, i + 9) % 7 - 3)
    local lr = floor(rh * .55) + hash(seed, i + 3) % 5
    lobesAll[#lobesAll + 1] = { lx, ly, lr + 6, lr + 1, ramp }
    if i % 2 == 0 then lobesAll[#lobesAll + 1] = { lx + 3, ly + lr, 6, 5, ramp } end   -- hanging scallop
  end
  lobesAll[#lobesAll + 1] = { cx, cy + 4, rw - 4, rh - 4, ramp }
end
for _, l in ipairs(lobesAll) do rim(E(l[1], l[2], l[3], l[4]), INK) end
for _, l in ipairs(lobesAll) do
  local m = E(l[1], l[2], l[3], l[4]); form(m, l[5], { deep = true })
  m:each(function(x, y)
    local h = hash(x, y)
    if h % 59 == 0 and m:has(x + 1, y) then px(x, y, l[5].hi); px(x + 1, y, l[5].hi) elseif h % 83 == 1 and m:has(x + 1, y) then px(x, y, l[5].shade); px(x + 1, y, l[5].shade) end
  end)
  for k = 1, 2 do   -- vein glints
    local vx, vy = l[1] - l[3] + 6 + (k * 13 + l[1]) % max(4, l[3] * 2 - 12), l[2] - 2 + (k * 3) % 5
    if m:has(vx, vy) and m:has(vx + 4, vy + 2) then px(vx, vy, l[5].hi); px(vx + 1, vy, l[5].hi); px(vx + 2, vy + 1, l[5].shade) end
  end
end

---------------------------------------------------------------- trunks (left and right, ink rim)
local function trunk(x0, x1, y0, y1)
  local m = R(x0, y0, x1, y1)
  local w = x1 - x0
  local flare = c:poly{ { x0 - 8, y1 + 8 }, { x0 + 2, y1 - 12 }, { x1 - 2, y1 - 12 }, { x1 + 8, y1 + 8 } }
  m = m:copy():add(flare)
  rim(m, INK); rim(m:copy():grow(1), "#3a2229")
  fm(m, BARK.base)
  fm(R(x0, y0, x0 + floor(w * 0.22), y1 - 10), BARK.hi)
  fm(R(x0 + floor(w * 0.22) + 1, y0, x0 + floor(w * 0.3), y1 - 10), "#8f5a3c")
  fm(R(x1 - floor(w * 0.34), y0, x1, y1 - 10), BARK.shade)
  fm(R(x1 - floor(w * 0.12), y0, x1, y1 - 10), BARK.deep)
  fm(flare:copy():clip(R(x0 - 8, y1 - 12, x1 + 8, y1 + 8)), BARK.shade)
  for y = y0 + 6, y1 - 4, 11 do   -- bark dashes
    local x = x0 + 5 + (hash(y, x0) % max(1, x1 - x0 - 12)); fm(R(x, y, x + 1, y + 5), BARK.deep)
  end
  return m
end
trunk(76, 112, 14, 140)
trunk(166, 178, 26, 122)   -- slim mid trunk
trunk(440, 479, 0, 166)


---------------------------------------------------------------- bunting and glowing lanterns between the trunks
local FLAG = { "#e8493b", "#f5b82e", "#5fc4c8", "#f5809f", "#7cc35a" }
local function bunt(x0, y0, x1, y1, sag)
  local pts, n = {}, x1 - x0
  for i = 0, n do local t = i / n; local x = x0 + i; local y = floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t)); pts[#pts + 1] = { x, y }; px(x, y, INK); px(x, y + 1, "#5a3430") end
  for i = 7, n - 5, 12 do
    local x, y = pts[i][1], pts[i][2] + 2; local col = FLAG[1 + (i // 12) % 5]
    local fl = c:poly{ { x - 4, y }, { x + 4, y }, { x, y + 10 } }; rim(fl, INK); fm(fl, col); px(x - 2, y + 1, "#fff4d6"); px(x - 1, y + 1, "#fff4d6")
  end
  return pts
end
local function lantern(x, y)
  fm(E(x, y + 4, 9, 9), "#ffe9b0"); fm(E(x, y + 4, 6, 6), "#ffd470")   -- halo
  local l = E(x, y + 4, 3, 4); rim(l, INK); fm(l, "#f5b82e"); px(x - 1, y + 3, "#fff4d6"); px(x, y - 1, INK)
end
local p1 = bunt(112, 54, 166, 50, 8)
local p2 = bunt(178, 50, 440, 48, 26)
for _, i in ipairs{ 30, 100, 170, 230 } do local p = p2[i]; if p then lantern(p[1], p[2] + 1) end end
lantern(p1[28][1], p1[28][2] + 1)

---------------------------------------------------------------- ground richness: dapples, tree shadows, path stones, tufts
local function blocked(x, y) return (x < 156 and y > 120 and y < 200) or (x > 280 and x < 432 and y > 60 and y < 218) or (abs(x - 240) < 60 and abs(y - 214) < 20) end
for _, t in ipairs{ { 94, 172, 38, 5 }, { 172, 152, 14, 3 }, { 458, 176, 22, 5 } } do fm(E(t[1], t[2], t[3], t[4]), "#8aa84e") end   -- trunk shadows on the grass
for i = 0, 10 do local x, y = 30 + hash(i, 51) % 420, 150 + hash(i, 53) % 100; if not blocked(x, y) then fm(E(x, y, 14 + i % 4 * 3, 4), "#d8e47a"); fm(E(x - 2, y - 1, 6, 2), "#eef28e") end end   -- sun dapples
local STO = { hi = "#e8e4ee", base = "#b4b0c4", shade = "#7e7a98", deep = "#4a4868" }
for _, s2 in ipairs{ { 232, 268, 20, 6 }, { 262, 254, 16, 5 }, { 214, 246, 13, 4 }, { 246, 238, 11, 4 }, { 224, 232, 9, 3 } } do
  local m = E(s2[1], s2[2], s2[3], s2[4]); rim(m, INK); form(m, STO, { deep = true }); fm(E(s2[1] - 2, s2[2] - 1, s2[3] // 2, 1), "#7cc35a")
end
for i = 0, 40 do   -- grass tufts
  local x, y = 10 + hash(i, 61) % 460, 160 + hash(i, 63) % 108
  if not blocked(x, y) then
    local dk = y > 214 and "#2f7a44" or "#5fa840"
    px(x - 2, y, dk); px(x - 2, y - 1, dk); px(x, y, dk); px(x, y - 1, dk); px(x, y - 2, dk); px(x, y - 3, "#c4e07a"); px(x + 2, y, dk); px(x + 2, y - 1, dk)
  end
end

---------------------------------------------------------------- mossy log with hollow (left)
local log = R(10, 138, 142, 190):copy():add(E(10, 164, 2, 26))
rim(log, INK); form(log, { hi = "#c08550", base = "#9a6038", shade = "#6e3f2a", deep = "#43261f" }, { deep = true })
for y = 150, 184, 8 do fm(R(24 + hash(y, 3) % 40, y, 40 + hash(y, 5) % 70, y), "#5a3430") end   -- grain
local moss = R(12, 132, 140, 144):copy():add(E(76, 138, 66, 8))
fm(moss, P.moss.base); for x = 14, 138, 3 do px(x, 145 + hash(x, 1) % 5, P.moss.base); px(x, 138, P.moss.hi) end
for x = 14, 138, 7 do px(x, 134 + hash(x, 9) % 3, P.moss.hi) end
local ring = E(142, 164, 14, 28)   -- log end, hollow, eyes
rim(ring, INK); form(ring, { hi = "#e8b982", base = "#c08550", shade = "#9a6038", deep = "#6e3f2a" })
fm(E(143, 166, 8, 18), "#d19a62"); fm(E(143, 168, 6, 14), "#241418")
fm(R(139, 163, 140, 164), "#ffe38a"); fm(R(146, 163, 147, 164), "#ffe38a")   -- two gold eyes
local function shroom(x, y, s)   -- x,y = base of stem
  fm(R(x - 1, y - 7 * s, x + 1, y), P.cream); px(x + 1, y - 3 * s, "#e4d0aa")
  local cap = E(x, y - 8 * s, 4 * s + 2, 3 * s + 1); rim(cap, INK); form(cap, CAP)
  px(x - 2, y - 9 * s, P.cream); px(x + 2, y - 8 * s, P.cream); px(x, y - 10 * s, P.cream)
end
shroom(40, 134, 2); shroom(64, 134, 1); shroom(112, 132, 1)
fm(E(78, 190, 10, 3), "#2a6a45")   -- log contact shadow

---------------------------------------------------------------- fairy ring (centre)
local fr = E(240, 214, 52, 14)
fm(fr, "#8cd08a"); fm(E(240, 214, 44, 10), "#a8dc9a")
for a = 0, 17 do
  local t = a / 18 * 6.2832; local x, y = 240 + floor(52 * cos(t)), 214 + floor(14 * sin(t))
  fm(R(x, y - 5, x, y), P.cream); rim(E(x, y - 6, 3, 2), INK); fm(E(x, y - 6, 3, 2), P.cream); px(x + 1, y - 6, "#e4d0aa")
end

---------------------------------------------------------------- acorns, ferns, leaf scatter
local function acorn(x, y)
  local nut = E(x, y + 3, 4, 5); rim(nut, INK); form(nut, { hi = "#d19a62", base = "#b97a4a", shade = "#864c33", deep = "#51302b" })
  local cp = E(x, y - 1, 5, 3); rim(cp, INK); form(cp, { hi = "#a8704a", base = "#7a4a34", shade = "#5a3430", deep = "#3a2229" })
  fm(R(x, y - 5, x, y - 4), INK)
end
for _, a in ipairs{ { 172, 196 }, { 184, 206 }, { 62, 222 }, { 130, 244 }, { 250, 252 }, { 440, 224 }, { 326, 240 } } do acorn(a[1], a[2]) end
local function fern(x, y, dir)
  for i = 0, 6 do
    local ang = (-80 + i * 24) * dir
    local len = 30 - abs(i - 3) * 3
    local ex, ey = x + floor(len * sin(ang / 57.3)) , y - floor(len * cos(ang / 57.3))
    local mx, my = (x + ex) // 2 + dir * -3, (y + ey) // 2 - 4
    local fr = c:poly{ { x, y }, { mx - 3, my }, { ex, ey }, { mx + 3, my + 4 } }
    rim(fr, INK); fm(fr, i % 2 == 0 and LEAF1.base or LEAF2.base)
    px(mx, my, LEAF1.hi); px(mx + 1, my + 1, LEAF1.hi)
  end
end
fern(20, 264, 1); fern(444, 218, -1); fern(300, 266, -1)
for i = 0, 150 do   -- fallen leaves
  local x, y = hash(i, 31) % 480, 150 + hash(i, 37) % 120
  local col = ({ "#f5b82e", "#e8883a", "#d98322", "#c94f3a" })[1 + i % 4]
  px(x, y, col); px(x + 1, y, col); px(x, y + 1, "#8f4a1f")
end


---------------------------------------------------------------- polish: ivy, bracket fungus, robin, motes
for i = 0, 9 do   -- ivy down the right trunk
  local x, y = 446 + (i % 2) * 8 + hash(i, 71) % 4, 30 + i * 13
  local lf = c:poly{ { x, y }, { x - 5, y + 3 }, { x - 3, y + 9 }, { x + 3, y + 9 }, { x + 5, y + 3 } }
  rim(lf, INK); form(lf, LEAF1); px(x, y + 3, LEAF1.hi)
end
for i = 0, 8 do px(452 + (i % 2) * 2, 26 + i * 13, "#24544a"); px(452 + (i % 2) * 2, 27 + i * 13, "#24544a"); px(452 + (i % 2) * 2, 28 + i * 13, "#24544a") end
for _, b in ipairs{ { 100, 70 }, { 104, 100 }, { 92, 118 } } do   -- bracket fungus on the left trunk
  local br = E(b[1], b[2], 9, 4); rim(br, INK); form(br, { hi = "#ffe38a", base = "#f0b43a", shade = "#d0802a", deep = "#8f4a1f" })
  fm(R(b[1] - 7, b[2] + 2, b[1] + 7, b[2] + 3), "#fff4d6")
end
-- robin on the bunting
local rb = E(300, 50, 5, 4); rim(rb, INK); form(rb, { hi = "#ff9a6a", base = "#e8604a", shade = "#b52e3f", deep = "#6e2038" })
fm(E(301, 52, 3, 2), "#fff4d6"); fm(E(305, 47, 3, 3), "#8a6a5a"); rim(E(305, 47, 3, 3), INK); fm(E(305, 47, 3, 3), "#8a6a5a"); px(306, 46, INK); px(309, 48, "#ffd470"); px(310, 48, "#ffd470"); px(296, 53, INK); px(298, 54, INK)
for i = 0, 44 do   -- glowing pollen motes
  local x, y = 20 + hash(i, 81) % 440, 70 + hash(i, 83) % 120
  px(x, y, "#fff4d6"); if i % 5 == 0 then px(x + 1, y, "#ffe38a"); px(x, y + 1, "#ffe38a"); px(x - 1, y, "#ffe38a"); px(x, y - 1, "#ffe38a") end
end

---------------------------------------------------------------- stories: squirrel, berry bush, snail, wildflowers
local ORG = { hi = "#ffb85c", base = "#f0882e", shade = "#c95a26", deep = "#7a3423" }
local function squirrel(x, y)   -- sits on the log
  local tail = c:poly{ { x - 6, y }, { x - 12, y - 8 }, { x - 11, y - 18 }, { x - 5, y - 20 }, { x - 3, y - 12 }, { x - 3, y - 2 } }
  rim(tail, INK); form(tail, ORG)
  local body = E(x + 2, y - 4, 6, 8); rim(body, INK); form(body, ORG)
  fm(E(x + 4, y - 3, 3, 5), P.cream)
  local head = E(x + 5, y - 14, 5, 4); rim(head, INK); form(head, ORG)
  px(x + 4, y - 18, ORG.deep); px(x + 8, y - 18, ORG.deep); px(x + 3, y - 14, INK); px(x + 8, y - 13, INK)
  fm(E(x + 3, y + 3, 3, 2), ORG.shade)
end
squirrel(100, 136)
local function bush(x, y)
  for _, p in ipairs{ { -14, 0, 14, 9 }, { 8, -2, 16, 10 }, { -2, -10, 14, 10 } } do
    local m = E(x + p[1], y + p[2], p[3], p[4]); rim(m, INK); form(m, LEAF2, { deep = true })
  end
  for i = 0, 11 do local bx, by = x - 20 + hash(i, 5) % 40, y - 14 + hash(i, 9) % 20
    fm(E(bx, by, 2, 2), "#e8493b"); px(bx - 1, by - 1, "#ff8a5c") end
end
bush(396, 232)
local function snail(x, y)
  local sh = E(x, y - 5, 5, 5); rim(sh, INK); form(sh, { hi = "#ffd4a0", base = "#e8a060", shade = "#b86a3a", deep = "#6e3f2a" }); px(x, y - 5, "#b86a3a")
  fm(R(x - 8, y - 1, x + 6, y), "#c8b490"); rim(R(x - 8, y - 1, x + 6, y), INK); px(x + 7, y - 4, INK); px(x + 6, y - 6, "#c8b490")
end
snail(210, 250)
for i = 0, 26 do   -- wildflowers
  local x, y = 20 + hash(i, 41) % 440, 152 + hash(i, 43) % 112
  local col = ({ "#ff9fc0", P.cream, "#ffe38a", "#c9b2f0" })[1 + i % 4]
  px(x, y - 1, col); px(x - 1, y, col); px(x + 1, y, col); px(x, y + 1, col); px(x, y, "#f5b82e"); px(x, y + 2, "#3f9150")
end

---------------------------------------------------------------- satchel back (shared)
dofile(d .. "/satchel.lua").back(c)

c:save{ aseprite = d .. "/out/" .. NAME .. ".aseprite", png = d .. "/out/" .. NAME .. ".png", scale = 1 }
