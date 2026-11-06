-- stage-island v3: clear-day tropical beach base backdrop
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local H, INK = X.hash, GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "stage-island" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local R6 = GX.ramp6
local SAND = { hi = "#fff8dc", base = "#f8dca2", shade = "#e0b47a", deep = "#b98860" }
local PALM = { hi = "#c4f060", base = "#58b840", shade = "#2e8a48", deep = "#175040" }
local PALM2 = { hi = "#a8e458", base = "#3ea044", shade = "#237048", deep = "#143e3c" }
local BARK = { hi = "#d8a070", base = "#a8683c", shade = "#7a4634", deep = "#47292c" }
local GRASS = { hi = "#d8f070", base = "#8cc848", shade = "#4e9a40", deep = "#2a6a42" }
local COCO = { hi = "#b88050", base = "#7a4a30", shade = "#52302c", deep = "#33201f" }
local WET = "#d8b480"

-- sky (clear)
GX.bands(c, 0, 92, { "#7fd8f8", "#97e0f8", "#b4eafa", "#d0f2f8", "#e6f8ee", "#fff4d0" }, 3, .2)
-- sea / lagoon
local sea = { "#7be8f0", "#58dcec", "#4ccfe4", "#52d4d8", "#6adcd0", "#86e8d0", "#a8f0d4", "#c4f6dc" }
GX.bands(c, 92, 156, sea, 5, .26)
for i = 0, 70 do
  local x, y = floor(H(i, 11, 1) * 478), 96 + floor(H(i, 12, 1) ^ 1.2 * 56)
  local l = 2 + floor(H(i, 13, 1) * 4)
  for k = 0, l do c:px(x + k, y, y > 130 and "#e8ffff" or "#ffffff") end
end
for i = 0, 40 do local x, y = floor(H(i, 21, 1) * 470), 98 + floor(H(i, 22, 1) * 50); c:fillMask(c:rect(x, y, x + 3 + i % 4, y), "#34b8dc") end
-- far green island with a small peak
local isl = mk()
for x = 192, 300 do
  local u = (x - 236) / 50; local h = floor(26 * max(0, 1 - abs(u) ^ 1.5) ^ .9 + (GX.vn(x, 0, 6, 3) - .5) * 3)
  for y = 92 - h, 92 do isl:set(x, y) end
end
isl = GX.rough(isl, 3, 1)
GX.lit(c, isl, R6({ hi = "#b8e8a8", base = "#68b890", shade = "#3c9494", deep = "#287080" }), { R = 16, tex = .5, sc = 3, seed = 3, ink = false })
for _, p in ipairs{ {206,0},{214,1} } do local m = mk(); E(m, p[1], 88 + p[2], 4, 4); GX.lit(c, m, R6({ hi = "#68b890", base = "#3c9494", shade = "#287080", deep = "#1c5068" }), { R = 3, tex = .2, seed = p[1], ink = false }) end
-- sailboat
local function sailboat(x, y)
  local sail = c:poly{ { x, y - 24 }, { x, y - 2 }, { x - 12, y - 2 } }
  GX.lit(c, sail, R6({ hi = "#fffaf0", base = "#f4ead8", shade = "#d0c0c0", deep = "#9a8aa0" }), { R = 8, tex = .2, seed = x, ink = false })
  local jib = c:poly{ { x + 2, y - 18 }, { x + 2, y - 2 }, { x + 11, y - 2 } }
  GX.lit(c, jib, R6({ hi = "#ffb0c8", base = "#ee6aa0", shade = "#c04888", deep = "#80285a" }), { R = 6, tex = .2, seed = x + 1, ink = false })
  local hull = c:poly{ { x - 14, y - 1 }, { x + 14, y - 1 }, { x + 10, y + 3 }, { x - 10, y + 3 } }
  GX.lit(c, hull, R6(BARK), { R = 3, tex = .2, seed = x + 2, rimlight = true })
  for k = -10, 10 do if H(k, x, 4) > .4 then c:px(x + k, y + 4, "#e8fff8") end end
end
sailboat(110, 112)

-- beach
local function yfn(x) return 154 + floor(3 * sin(x / 41) + 2 * sin(x / 13 + 1)) end
GX.ground(c, yfn, SAND, 7, { top = .84, fall = .52, tex = .32, sc = 8 })
for x = 0, 479 do
  local y0 = yfn(x)
  for k = 1, 5 do c:px(x, y0 + k, k < 3 and "#c8a070" or WET) end
  if GX.vn(x, 3, 5, 9) > .45 then c:px(x, y0 + 6, WET) end
  c:px(x, y0 - 1, "#ffffff"); c:px(x, y0, "#ffffff")
  if GX.vn(x, 7, 4, 2) > .5 then c:px(x, y0 - 2, "#d8fff8"); c:px(x, y0 - 3, "#9af4ec") end
end
for i = 0, 22 do local x, y = floor(H(i, 31, 1) * 470), 142 + floor(H(i, 32, 1) * 10); c:fillMask(c:rect(x, y, x + 5 + i % 5, y), "#d0fff4") end
for i = 0, 26 do
  local x, y = 10 + floor(H(i, 51, 1) * 460), 172 + floor(H(i, 53, 1) * 94)
  local m = mk(); E(m, x, y, 10 + i % 4 * 3, 2); m = GX.rough(m, i, 1); c:fillMask(m, i % 2 == 0 and "#fff4cc" or "#e8c08a")
end
for i = 0, 70 do local x, y = floor(H(i, 71, 1) * 480), 166 + floor(H(i, 73, 1) * 102); c:px(x, y, i % 2 == 0 and "#c89a68" or "#fffbe8") end

-- palms
local function bez(p0, p1, p2, t) local u = 1 - t; return u*u*p0[1] + 2*u*t*p1[1] + t*t*p2[1], u*u*p0[2] + 2*u*t*p1[2] + t*t*p2[2] end
local function palmTrunk(p0, p1, p2, r0, r1, seed)
  local m = mk()
  for i = 0, 80 do local x, y = bez(p0, p1, p2, i / 80); E(m, floor(x), floor(y), floor(r0 + (r1 - r0) * i / 80 + .5)) end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, R6(BARK), { R = 4, tex = .35, sc = 2.4, seed = seed, rimlight = true, fn = function(x, y) return (floor(y / 3) % 2) * .13 - .06 end })
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
  GX.lit(c, m, R6(R), { R = 3, tex = .35, sc = 2, seed = seed, rimlight = true, amb = .3 })
  for i = 2, #mid - 3 do c:px(mid[i][1], mid[i][2], R.deep) end
end
local function crown(cx, cy, angs, L, droop, seed)
  for i, a in ipairs(angs) do frond(cx, cy, a, L - (i % 2) * 5, droop, (i % 2 == 0) and PALM or PALM2, seed + i) end
end
local function nuts(ps) for _, p in ipairs(ps) do local m = mk(); E(m, p[1], p[2], 3); GX.lit(c, m, R6(COCO), { R = 3, tex = .1, seed = p[1], rimlight = true }) end end
palmTrunk({12,236}, {14,120}, {48,48}, 6, 4, 31)
crown(48, 46, {165, 140, 105, 65, 30, 5, 200}, 46, 20, 40)
nuts{ {44,52},{51,53},{47,56} }
palmTrunk({472,236}, {466,130}, {430,56}, 6, 4, 33)
crown(430, 54, {178, 150, 118, 80, 40, 12, -10}, 44, 18, 60)
nuts{ {426,59},{433,60},{429,63} }

-- shells, starfish, coconuts (sparse, low)
local function shell(x, y, col)
  local m = mk(); E(m, x, y, 4, 3); m:cut(c:rect(x - 6, y + 2, x + 6, y + 6))
  GX.lit(c, m, R6({ hi = "#ffffff", base = col, shade = GX.mix(col, "#a06070", .45), deep = GX.mix(col, "#5a3050", .6) }), { R = 3, tex = 0, seed = x, rimlight = true })
  for k = -2, 2, 2 do c:px(x + k, y - 1, GX.mix(col, "#a06070", .5)) end
end
shell(150, 192, "#ffc8c0"); shell(332, 238, "#fff0e0"); shell(250, 206, "#ffd8a0"); shell(410, 258, "#e8d8f8")
local function star(x, y, base)
  local pts = {}
  for k = 0, 9 do local r = (k % 2 == 0) and 9 or 4; local a = -pi / 2 + k * pi / 5; pts[#pts + 1] = { x + floor(r * cos(a) + .5), y + floor(r * sin(a) + .5) } end
  local m = c:poly(pts)
  GX.lit(c, m, R6(base), { R = 6, tex = .3, sc = 2, seed = 5, rimlight = true })
  m:each(function(px, py) if H(px, py, 9) < .07 then c:px(px, py, "#ffe8b0") end end)
end
star(98, 246, { hi = "#ffc48a", base = "#f0642e", shade = "#c4402e", deep = "#6e2038" })
star(382, 226, { hi = "#ffa8d0", base = "#e8589c", shade = "#b83878", deep = "#6e2048" })
for _, p in ipairs{ {60,252},{68,255} } do local m = mk(); E(m, p[1], p[2], 5, 4); GX.lit(c, m, R6(COCO), { R = 3, tex = .15, seed = p[1], rimlight = true }); c:px(p[1] - 1, p[2] - 1, COCO.hi) end
for _, p in ipairs{ {30,244},{140,236},{300,250},{440,246},{200,226},{450,200} } do GX.tuft(c, p[1], p[2], GRASS) end
-- quirk: a tiny hermit crab
local function crab(x, y)
  local CR = { hi = "#ff9a70", base = "#f06040", shade = "#c03c3c", deep = "#6e2038" }
  for _, dx in ipairs{ -2, 1, 4 } do c:px(x + dx, y, INK) end
  local bd = mk(); E(bd, x + 3, y - 2, 4, 2); GX.lit(c, bd, R6(CR), { R = 3, tex = 0, rimlight = true })
  local sm = mk(); E(sm, x - 3, y - 5, 5, 4); sm = GX.rough(sm, 14, 1)
  GX.lit(c, sm, R6({ hi = "#ffffff", base = "#f4d4e0", shade = "#c898b0", deep = "#7a4a68" }), { R = 5, tex = .15, seed = 3, rimlight = true })
  c:px(x + 6, y - 5, INK); c:px(x + 8, y - 5, INK)
end
crab(200, 242)

c:save{ aseprite = d.."/out/stage-island.aseprite", png = d.."/out/stage-island.png", scale = 1 }
