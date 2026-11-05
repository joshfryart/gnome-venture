local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local H = X.hash
local INK = GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "island" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end

local SAND = { hi = "#fff8dc", base = "#f8dca2", shade = "#e0b47a", deep = "#b98860" }
local PALM = { hi = "#c4f060", base = "#58b840", shade = "#2e8a48", deep = "#175040" }
local PALM2 = { hi = "#a8e458", base = "#3ea044", shade = "#237048", deep = "#143e3c" }
local BARK = { hi = "#d8a070", base = "#a8683c", shade = "#7a4634", deep = "#47292c" }
local GRASS = { hi = "#d8f070", base = "#8cc848", shade = "#4e9a40", deep = "#2a6a42" }
local COCO = { hi = "#b88050", base = "#7a4a30", shade = "#52302c", deep = "#33201f" }
local WET = "#d8b480"

---------------------------------------------------------------- sky
local sky = { "#7fd8f8", "#97e0f8", "#b4eafa", "#d0f2f8", "#e6f8ee", "#fff4d0" }
GX.bands(c, 0, 100, sky, 3, .2)
local sun = mk(); E(sun, 250, 84, 30, 18); c:fillMask(sun, "#fff0b8"); local s2 = mk(); E(s2, 250, 86, 18, 10); c:fillMask(s2, "#fffbe4")
-- fat cloud
local CL = { hi = "#ffffff", base = "#fff6ea", shade = "#f4d8d0", deep = "#d8b0c0" }
local cm = mk()
for _, b in ipairs{ {150,40,16,10}, {172,34,18,13}, {196,38,17,11}, {216,44,13,8}, {132,46,12,7}, {176,46,36,8} } do E(cm, b[1], b[2], b[3], b[4]) end
cm = GX.rough(cm, 4, 1)
GX.lit(c, cm, GX.ramp6(CL), { R = 9, tex = .45, sc = 4, seed = 8, ink = false, amb = .35 })
local cm2 = mk(); E(cm2, 330, 26, 20, 6); E(cm2, 316, 28, 10, 5); E(cm2, 350, 29, 12, 4); cm2 = GX.rough(cm2, 9, 1)
GX.lit(c, cm2, GX.ramp6(CL), { R = 5, tex = .4, sc = 4, seed = 2, ink = false, amb = .35 })
for _, g in ipairs{ {20,70},{40,64},{260,52},{440,70} } do local b = mk(); E(b, g[1], g[2], 14, 3); b = GX.rough(b, g[1], 1); c:fillMask(b, "#e6f8ee") end

---------------------------------------------------------------- sea
local sea = { "#7be8f0", "#58dcec", "#34c8e8", "#22b0dc", "#26c4d4", "#3ad8c8", "#62e8c8", "#98f0cc" }
GX.bands(c, 100, 154, sea, 5, .26)
-- far islet
local isl = mk()
for x = 186, 262 do local u = (x - 224) / 38; local h = floor(11 * max(0, 1 - u * u) ^ .8 + (GX.vn(x, 0, 6, 3) - .5) * 3); for y = 100 - h, 100 do isl:set(x, y) end end
GX.lit(c, isl, GX.ramp6({ hi = "#b8e8a8", base = "#68c0a0", shade = "#3c9494", deep = "#287080" }), { R = 8, tex = .5, sc = 3, seed = 3, ink = false })
for _, p in ipairs{ {212,0},{232,-1},{244,2} } do
  local px, py = p[1], 100 - 11 + p[2]
  for k = 0, 5 do c:px(px, py - k, "#287080") end
  c:fillMask(c:rect(px - 4, py - 7, px + 4, py - 6), "#3c9494"); c:px(px - 5, py - 5, "#3c9494"); c:px(px + 5, py - 5, "#3c9494"); c:fillMask(c:rect(px - 2, py - 8, px + 2, py - 8), "#68c0a0")
end
-- sparkle glints
local function inSat(x, y) return x > 280 and x < 440 and y > 56 and y < 220 end
for i = 0, 70 do
  local x, y = floor(H(i, 11, 1) * 478), 102 + floor(H(i, 12, 1) ^ 1.3 * 46)
  if not inSat(x, y) or i % 4 == 0 then
    local l = 1 + floor(H(i, 13, 1) * 3)
    for k = 0, l do c:px(x + k, y, "#ffffff") end
    if i % 3 == 0 then c:px(x + 1, y - 1, "#e8ffff"); c:px(x + 1, y + 1, "#e8ffff") end
  end
end
for i = 0, 40 do local x, y = floor(H(i, 21, 1) * 470), 104 + floor(H(i, 22, 1) * 46); c:fillMask(c:rect(x, y, x + 3 + i % 4, y), "#1ea0d4") end

---------------------------------------------------------------- sand ground + tide line
local function yfn(x) return 150 + floor(4 * sin(x / 41) + 2 * sin(x / 13 + 1)) end
GX.ground(c, yfn, SAND, 7, { top = .84, fall = .52, tex = .32, sc = 8 })
for x = 0, 479 do
  local y0 = yfn(x)
  for k = 1, 5 do c:px(x, y0 + k, k < 3 and "#c8a070" or WET) end
  if GX.vn(x, 3, 5, 9) > .45 then c:px(x, y0 + 6, WET) end
  c:px(x, y0 - 1, "#ffffff"); c:px(x, y0, "#ffffff")
  if GX.vn(x, 7, 4, 2) > .5 then c:px(x, y0 - 2, "#d8fff8"); c:px(x, y0 - 3, "#9af4ec") end
end
for i = 0, 22 do   -- shallow foam dashes
  local x, y = floor(H(i, 31, 1) * 470), 138 + floor(H(i, 32, 1) * 10)
  c:fillMask(c:rect(x, y, x + 5 + i % 5, y), "#d0fff4")
end
-- drier sand dapples (lighter patches) and a few ripples
local function blocked(x, y) return (x < 156 and y > 150 and y < 204) or (x > 276 and x < 440 and y > 60 and y < 222) or (x > 380 and y > 222) end
for i = 0, 26 do
  local x, y = 10 + floor(H(i, 51, 1) * 460), 168 + floor(H(i, 53, 1) * 98)
  if not blocked(x, y) then local m = mk(); E(m, x, y, 10 + i % 4 * 3, 2); m = GX.rough(m, i, 1); c:fillMask(m, i % 2 == 0 and "#fff4cc" or "#e8c08a") end
end
for i = 0, 60 do   -- grains
  local x, y = floor(H(i, 71, 1) * 480), 160 + floor(H(i, 73, 1) * 108)
  if not blocked(x, y) then c:px(x, y, i % 2 == 0 and "#c89a68" or "#fffbe8") end
end

---------------------------------------------------------------- palms
local function bez(p0, p1, p2, t) local u = 1 - t; return u*u*p0[1] + 2*u*t*p1[1] + t*t*p2[1], u*u*p0[2] + 2*u*t*p1[2] + t*t*p2[2] end
local function palmTrunk(p0, p1, p2, r0, r1, seed)
  local m = mk()
  for i = 0, 70 do local x, y = bez(p0, p1, p2, i / 70); E(m, floor(x), floor(y), floor(r0 + (r1 - r0) * i / 70 + .5)) end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, GX.ramp6(BARK), { R = 4, tex = .35, sc = 2.4, seed = seed, rimlight = true,
    fn = function(x, y) return (floor(y / 3) % 2) * .13 - .06 end })
end
local function frond(cx, cy, adeg, L, droop, R, seed)
  local m, mid = mk(), {}
  local ca, sa = cos(adeg / 57.3), -sin(adeg / 57.3)
  local steps = floor(L)
  for i = 0, steps do
    local t = i / steps
    local x, y = floor(cx + ca * L * t), floor(cy + sa * L * t + droop * t * t)
    local w = floor(5.5 * sin(pi * min(1, t * 1.15)) ^ .75 * (.6 + .4 * (i % 3 == 0 and 1 or .35)) + .5)
    for k = -w, w do m:set(x, y + k) end
    mid[#mid + 1] = { x, y }
  end
  GX.lit(c, m, GX.ramp6(R), { R = 3, tex = .35, sc = 2, seed = seed, rimlight = true, amb = .3 })
  for i = 2, #mid - 3 do c:px(mid[i][1], mid[i][2], R.deep) end
end
local function crown(cx, cy, angs, L, droop, seed, back)
  for i, a in ipairs(angs) do frond(cx, cy, a, L - (i % 2) * 5, droop, (i % 2 == 0) and PALM or PALM2, seed + i) end
end
-- left palm (behind canoe)
palmTrunk({22,172}, {28,96}, {66,36}, 5, 3, 31)
crown(66, 36, {165, 135, 100, 62, 30, 5, 200}, 40, 18, 40)
for _, p in ipairs{ {62,41},{69,42},{65,45} } do local m = mk(); E(m, p[1], p[2], 3); GX.lit(c, m, GX.ramp6(COCO), { R = 3, tex = .1, seed = p[1], rimlight = true }) end
-- right palm
palmTrunk({470,182}, {464,100}, {446,44}, 5, 3, 33)
crown(446, 42, {178, 150, 118, 80, 40, 12}, 36, 16, 60)
for _, p in ipairs{ {442,47},{449,48},{445,51} } do local m = mk(); E(m, p[1], p[2], 3); GX.lit(c, m, GX.ramp6(COCO), { R = 3, tex = .1, seed = p[1], rimlight = true }) end

---------------------------------------------------------------- hero: upturned canoe
local sh = mk(); E(sh, 84, 200, 72, 5); sh = GX.rough(sh, 5, 1); c:fillMask(sh, "#c89a68")
local cx, hw, base, hh = 84, 68, 198, 38
local function topy(x) local u = abs(x - cx) / hw; return base - floor(hh * max(0, 1 - u ^ 2.3) ^ .7 + (GX.vn(x, 0, 9, 4) - .5) * 1.5) end
local cn = mk()
for x = cx - hw, cx + hw do for y = topy(x), base do cn:set(x, y) end end
cn = GX.rough(cn, 6, 1)
local CANOE = { hi = "#f0b868", base = "#d08a48", shade = "#a05c38", deep = "#5e3430" }
GX.lit(c, cn, GX.ramp6(CANOE), { R = 20, tex = .3, sc = 2, seed = 7, rimlight = true, h = 1,
  fn = function(x, y) local t = topy(x); local k = (y - t); return ((floor(k / 5)) % 2) * .1 - .05 + (y > base - 4 and -.25 or 0) end })
for x = cx - hw, cx + hw do   -- ridge keel highlight line and plank seams
  local t = topy(x); if cn:has(x, t + 2) then c:px(x, t + 2, "#ffe0a0") end
  for _, k in ipairs{ 9, 19, 29 } do if cn:has(x, t + k) and (x % 3 ~= 0) then c:px(x, t + k, "#8a4c36") end end
end
for _, rx in ipairs{ 56, 88, 118 } do   -- rope lashings
  for y = topy(rx), base - 4 do if cn:has(rx, y) then c:px(rx, y, "#f5e8c0"); c:px(rx + 1, y, "#d8c090"); c:px(rx + 2, y, INK) end end
end
c:px(cx - hw + 1, topy(cx - hw + 2) - 1, INK)
-- paddle leaning on the hull
local pd = c:poly{ {136,150},{140,150},{142,160},{150,162},{150,172},{146,176},{142,186},{138,186},{138,164},{136,160} }
GX.lit(c, pd, GX.ramp6({ hi = "#ffe0a0", base = "#e8b060", shade = "#b87c44", deep = "#6a4030" }), { R = 3, tex = .2, seed = 5, rimlight = true })
-- coconuts on the sand
for _, p in ipairs{ {22,205},{30,208},{157,198} } do local m = mk(); E(m, p[1], p[2], 4, 3); GX.lit(c, m, GX.ramp6(COCO), { R = 3, tex = .15, seed = p[1], rimlight = true }); c:px(p[1] - 1, p[2] - 1, COCO.hi) end

---------------------------------------------------------------- beach grass tufts
for i = 0, 40 do
  local x, y = 8 + floor(H(i, 61, 1) * 464), 162 + floor(H(i, 63, 1) * 106)
  if not blocked(x, y) and (y < 235 or x < 270) then GX.tuft(c, x, y, y > 230 and { hi = GRASS.base, base = GRASS.shade, shade = GRASS.deep } or GRASS) end
end
for _, p in ipairs{ {160,206},{168,203},{176,208},{452,212},{460,208},{468,214} } do GX.tuft(c, p[1], p[2], GRASS) end

---------------------------------------------------------------- shells, starfish, driftwood
local function shell(x, y, col, flip)
  local m = mk(); E(m, x, y, 4, 3); m:cut(c:rect(x - 6, y + 2, x + 6, y + 6))
  GX.lit(c, m, GX.ramp6({ hi = "#ffffff", base = col, shade = GX.mix(col, "#a06070", .45), deep = GX.mix(col, "#5a3050", .6) }), { R = 3, tex = 0, seed = x, rimlight = true })
  for k = -2, 2, 2 do c:px(x + k, y - 1, GX.mix(col, "#a06070", .5)); c:px(x + k, y, GX.mix(col, "#a06070", .5)) end
end
shell(196, 168, "#ffc8c0"); shell(244, 172, "#fff0e0"); shell(328, 170, "#ffd8a0"); shell(408, 164, "#ffc8c0"); shell(128, 220, "#fff0e0"); shell(470, 160, "#e8d8f8")
local function star(x, y)
  local pts = {}
  for k = 0, 9 do local r = (k % 2 == 0) and 10 or 4; local a = -pi / 2 + k * pi / 5; pts[#pts + 1] = { x + floor(r * cos(a) + .5), y + floor(r * sin(a) + .5) } end
  local m = c:poly(pts)
  GX.lit(c, m, GX.ramp6({ hi = "#ffc48a", base = "#f0642e", shade = "#c4402e", deep = "#6e2038" }), { R = 6, tex = .3, sc = 2, seed = 5, rimlight = true })
  m:each(function(px, py) if H(px, py, 9) < .07 then c:px(px, py, "#ffe8b0") end end)
  for k = 0, 4 do local a = -pi / 2 + k * 2 * pi / 5; c:px(x + floor(5 * cos(a) + .5), y + floor(5 * sin(a) + .5), "#ffe8b0") end
end
star(268, 164)
-- driftwood stick
local dw = c:poly{ {196,248},{222,244},{240,246},{238,249},{212,252},{196,251} }
GX.lit(c, dw, GX.ramp6({ hi = "#e8d8c0", base = "#b8a088", shade = "#8a7260", deep = "#54443f" }), { R = 3, tex = .3, seed = 4, rimlight = true })

---------------------------------------------------------------- quirk: hermit crab with a shell
local function crab(x, y)
  local CR = { hi = "#ff9a70", base = "#f06040", shade = "#c03c3c", deep = "#6e2038" }
  -- legs
  for _, dx in ipairs{ -6, -3, 0, 3 } do c:px(x + dx, y, INK); c:px(x + dx, y + 1, INK) end
  -- claws and eyes
  local cl = mk(); E(cl, x + 11, y - 4, 3, 2); GX.lit(c, cl, GX.ramp6(CR), { R = 2, tex = 0, rimlight = true })
  c:px(x + 9, y - 2, CR.base); c:px(x + 8, y - 1, CR.shade)
  local bd = mk(); E(bd, x + 6, y - 1, 4, 3); GX.lit(c, bd, GX.ramp6(CR), { R = 3, tex = 0, rimlight = true })
  c:px(x + 7, y - 6, INK); c:px(x + 9, y - 6, INK); c:px(x + 7, y - 5, CR.base); c:px(x + 9, y - 5, CR.base)
  c:px(x + 7, y - 7, "#ffffff"); c:px(x + 9, y - 7, "#ffffff")
  -- spiral shell
  local sm = mk(); E(sm, x - 3, y - 6, 7, 6); sm = GX.rough(sm, 14, 1)
  GX.lit(c, sm, GX.ramp6({ hi = "#ffffff", base = "#f4d4e0", shade = "#c898b0", deep = "#7a4a68" }), { R = 6, tex = .15, seed = 3, rimlight = true,
    fn = function(px, py) local dd = sqrt((px - x + 3) ^ 2 + (py - y + 6) ^ 2); return (floor(dd * 1.4) % 2) * .16 - .08 end })
  c:px(x - 4, y - 7, "#a86088"); c:px(x - 3, y - 6, "#a86088")
  -- tiny bubble thought: a heart
  c:px(x + 2, y - 15, "#ff6a88"); c:px(x + 4, y - 15, "#ff6a88"); c:fillMask(c:rect(x + 2, y - 14, x + 4, y - 14), "#ff6a88"); c:px(x + 3, y - 13, "#ff6a88")
end
crab(216, 226)
-- crab tracks
for k = 1, 7 do c:px(196 - k * 3, 229 + k % 2, "#c89a68"); c:px(196 - k * 3, 231 - k % 2, "#c89a68") end

---------------------------------------------------------------- satchel contact shadow (nosat branch)
local shd = mk(); GX.disc(shd, 357, 213, 74, 5); c:fillMask(shd, "#c89a68")

c:save{ aseprite = d.."/../out/scene-island.aseprite", png = d.."/../out/scene-island.png", scale = 1 }
