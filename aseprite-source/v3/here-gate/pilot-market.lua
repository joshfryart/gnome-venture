-- pilot-market.lua : PARAMETRIC stop scene "MARKET HAMLET" (gate view, one-point perspective, VP ~ (240,112)).
-- One composition, many looks.  --script-param pal=<name>  (default grassland_maplewold)
--   /tmp/aseq/squashfs-root/AppRun -b --script-param out=<dir>/ --script-param pal=desert_adobe --script pilot-market.lua
-- Geometry (SPOTS / STAND / road) is look-independent; everything colour / flora / roof is read from PALETTES[pal].
-- To add a look: copy one PALETTES entry, change the ramps + flora ("maple"|"palm") + roofStyle ("gable"|"flat")
-- + wallStyle ("timber"|"adobe") + roofTex ("thatch"|"shingle") + skyStyle ("clouds"|"haze") + hillStyle ("hills"|"dunes").
local ROOT = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(ROOT .. "/v3/lib/hp.lua")
local OUT = app.params.out or (ROOT .. "/v3/here-gate/")
local PALNAME = app.params.pal or "grassland_maplewold"

local function rp(s) -- "hi base shade deep edge"
  local t = {} for h in s:gmatch("#%x+") do t[#t+1] = h end
  return { hi = t[1], base = t[2], shade = t[3], deep = t[4], edge = t[5] or t[4] }
end

---------------------------------------------------------------- PALETTES (per-look roles)
local PALETTES = {
  grassland_maplewold = {
    sky = { "#eaa774", "#f1bd84", "#f6d39b", "#f9e4b6" }, skyStyle = "clouds",
    cloud = { top = "#fdf1d6", under = "#f3cfa2" },
    hillFar = "#e6c08e", hillMid = "#d4a466", hillMidShade = "#c08c52", hillStyle = "hills",
    farTree = rp("#f4b884 #e39a64 #cc7c56 #b0664c #8e5444"),
    ground = rp("#ecc977 #d9ab55 #bd8a40 #946634 #6a4428"), groundFar = "#e8c584",
    road = rp("#e4d8c4 #cbbaa2 #ab9881 #86746a #5a4c4a"), slabRatio = 1.06, slabK = 15,
    stone = rp("#e4ddd2 #bab2a6 #908890 #686078 #433b52"),
    plaster = rp("#fff4dc #f0e0bf #d3bd9b #a89080 #6a5458"),
    wall2 = rp("#d6e4c2 #aac89a #85a37e #607f68 #3e5650"),
    timber = rp("#b07a50 #885636 #663e2a #4a2b22 #2e1a1c"),
    roof = rp("#f6d070 #e0a948 #ba8136 #8c5a2a #5c3a20"),
    roof2 = rp("#e88660 #c95c3e #a24034 #742e2e #4a1c26"),
    awnA = rp("#f08a7a #d9524a #b03a3c #822a36 #521a28"),
    awnB = rp("#fff6e0 #f6e6c4 #dcc7a0 #b09c84 #6e5c58"),
    accent = rp("#86d0bc #4fa494 #3a7c76 #2b5a5c #1c3a44"),
    foliage = rp("#ffc457 #f08c32 #cc5c2a #983c26 #5e2420"),
    foliage2 = rp("#f69064 #d9533a #ac3a32 #7a282c #4a1824"),
    leaf = rp("#c4d878 #93b552 #6a903e #4a6a36 #2e4428"),
    water = rp("#cdeef0 #8fcfd8 #5ea4bc #43769c #2e4a72"),
    glow = rp("#fff6c0 #ffd870 #f6aa42 #d27a30 #8a4a24"),
    soil = rp("#a87a58 #855a40 #66422f #4a2e24 #2e1a18"),
    board = rp("#e8bc88 #c99462 #a6744c #7c553c #4e3428"),
    produce = rp("#ffb04a #f07c22 #c85a1e #943e1c #5e2618"),
    shadow = "#a07068", shadowRoad = "#958590",
    flora = "maple", roofStyle = "gable", wallStyle = "timber", roofTex = "thatch", wellRoof = "roof2",
  },
  desert_adobe = {
    sky = { "#d2b48e", "#e0c59a", "#ebd3a8", "#f4e2bc" }, skyStyle = "haze",
    cloud = { top = "#f8ead0", under = "#ead3aa" },
    hillFar = "#ecd0a4", hillMid = "#e6bc84", hillMidShade = "#d2a06c", hillStyle = "dunes",
    farTree = rp("#c8c892 #a9a874 #8c8a62 #706e52 #52503e"),
    ground = rp("#f6dca4 #eac287 #d1a068 #ad7c50 #7a5238"), groundFar = "#f0d6a6",
    road = rp("#f2dcb8 #dabb90 #bb9a74 #96785f #634c44"), slabRatio = 1.085, slabK = 9,
    stone = rp("#f4d8b0 #dcae80 #b98762 #8c6050 #5c3c3c"),
    plaster = rp("#fffbf2 #f3ecdf #d6cbc2 #aa9ea6 #645870"),
    wall2 = rp("#f2a678 #d6784c #b0583e #823e38 #522630"),
    timber = rp("#c09060 #946a42 #714e32 #523828 #33221c"),
    roof = rp("#f6d886 #e0b456 #bc8c3c #8e622c #5a3c1e"),
    roof2 = rp("#8ec4ee #4f8fd0 #3a6aa8 #2c4c80 #1c3054"),
    awnA = rp("#86bcf0 #3c7cc8 #2e5c9c #234276 #162a4e"),
    awnB = rp("#ffdc80 #f4b42e #d68a20 #a0601e #603a18"),
    accent = rp("#8ae0d4 #3eb4a8 #2e8a88 #23646a #163e48"),
    foliage = rp("#c0d878 #84ae4a #5e8a40 #406438 #263e28"),
    foliage2 = rp("#f48cc4 #d6509c #aa387e #7a2a64 #4a1a40"),
    leaf = rp("#acd49e #6caa7a #4e8662 #36624e #203e36"),
    water = rp("#c8f2ec #7cd6d0 #48aab8 #357c9a #24506e"),
    glow = rp("#fff8c8 #ffdc6c #f8aa3a #d6782a #8c4620"),
    soil = rp("#c89a6c #a4744c #805638 #5c3c2c #3c261e"),
    board = rp("#f0d4a2 #d6b07a #b48c5c #8a6646 #5a4030"),
    produce = rp("#ff9a5a #e8602c #bc4424 #8a301e #5a1e18"),
    shadow = "#b4807a", shadowRoad = "#a8909a",
    flora = "palm", roofStyle = "flat", wallStyle = "adobe", roofTex = "palm", wellRoof = "roof2",
  },
}
local L = PALETTES[PALNAME] or error("unknown pal " .. tostring(PALNAME))

---------------------------------------------------------------- GEOMETRY (same for every look)
local W, H, HZ, VX = 480, 270, 112, 240
local SPOTS = {
  { k = "cottages", name = "Cottages",     box = { 16, 64, 78, 134 } },
  { k = "seed",     name = "Seed Swap",    box = { 16, 146, 78, 212 } },
  { k = "well",     name = "Wishing Well", box = { 90, 92, 196, 210 } },
  { k = "pond",     name = "Fishing Pond", box = { 16, 226, 108, 264 } },
  { k = "table",    name = "Long Table",   box = { 120, 222, 188, 264 } },
  { k = "trail",    name = "Wild Trail",   box = { 208, 54, 272, 124 } },
  { k = "notice",   name = "Notice Board", box = { 284, 46, 342, 136 } },
  { k = "rest",     name = "Rest House",   box = { 354, 62, 462, 136 } },
  { k = "stall",    name = "Trader Stall", box = { 290, 150, 410, 226 } },
  { k = "forage",   name = "Forage Patch", box = { 296, 238, 376, 264 } },
}
local STAND = { { x = 216, y = 256 }, { x = 264, y = 256 }, { x = 222, y = 222 }, { x = 258, y = 222 },
                { x = 230, y = 186 }, { x = 250, y = 158 } }
local ROAD_TOP = 124
local function xl(y) return 234 - (y - ROAD_TOP) * 0.3 end
local function xr(y) return 246 + (y - ROAD_TOP) * 0.3 end

---------------------------------------------------------------- helpers
local c = HP.canvas{ w = W, h = H, scale = 1, name = "pilot-market-" .. PALNAME }
local floor, sin, abs = math.floor, math.sin, math.abs
local function hash(a, b, s)
  local n = (a * 374761393 + b * 668265263 + (s or 0) * 1442695041) & 0x7fffffff
  n = ((n ~ (n >> 13)) * 1274126177) & 0x7fffffff
  return (n % 10007) / 10007
end
local function px(x, y, h) c:put(x, y, h) end
local function rect(a, b, cc, d) return c:rect(a, b, cc, d) end
local function poly(t) return c:poly(t) end
local function fill(m, h) c:fillMask(m, h) return m end
local function part(m, r, o) return c:part(m, r, o) end
local function hline(x0, x1, y, h) for x = x0, x1 do px(x, y, h) end end
local function vline(x, y0, y1, h) for y = y0, y1 do px(x, y, h) end end
local function union(...) local m = HP.mask() for _, a in ipairs({ ... }) do m:add(a) end return m end
local function rimOf(m, r) c:rim(m, r.edge) end
local roadM

local function shadow(x0, x1, yb, dx, dy) -- light upper-left: shadow falls lower-right
  local m = poly{ { x0, yb - 2 }, { x1, yb - 2 }, { x1 + dx, yb + dy }, { x0 + dx, yb + dy } }
  m:each(function(x, y) px(x, y, (roadM and roadM:has(x, y)) and L.shadowRoad or L.shadow) end)
end
local function courses(m, y0, rowH, bw, r, seed)
  m:each(function(x, y)
    local row = (y - y0) // rowH
    local off = (row % 2) * (bw // 2) + (seed or 0)
    local ry, rx = (y - y0) % rowH, (x + off) % bw
    if ry == 0 or rx == 0 then px(x, y, r.deep)
    elseif ry == 1 and rx == 1 then px(x, y, r.hi)
    elseif ry == rowH - 1 and hash(x // bw, row, 7) < .5 then px(x, y, r.shade) end
  end)
end
local function hrows(m, y0, step, h) m:each(function(x, y) if (y - y0) % step == 0 then px(x, y, h) end end) end
local function speckle(m, r, dens, seed)
  m:each(function(x, y)
    local v = hash(x, y, seed or 3)
    if v < dens then px(x, y, r.hi) elseif v > 1 - dens then px(x, y, r.deep) end
  end)
end

local function window(x0, y0, x1, y1, fr, arched)
  local f = arched and c:rrect(x0 - 1, y0 - 1, x1 + 1, y1 + 4, 3):clip(rect(x0 - 1, y0 - 1, x1 + 1, y1 + 1)) or rect(x0 - 1, y0 - 1, x1 + 1, y1 + 1)
  fill(f, fr.deep)
  local g = f:shrink(1)
  fill(g, L.glow.base)
  g:each(function(x, y) if not g:has(x + 1, y + 1) then px(x, y, L.glow.shade) end end)
  px(x0 + 1, y0 + 1, L.glow.hi) px(x0 + 2, y0 + 1, L.glow.hi)
  vline((x0 + x1) // 2, y0, y1, fr.base)
  if y1 - y0 > 5 then hline(x0, x1, (y0 + y1) // 2, fr.base) end
  hline(x0 - 2, x1 + 2, y1 + 2, fr.hi) hline(x0 - 2, x1 + 2, y1 + 3, fr.deep)
  if arched and L.wallStyle == "adobe" then -- shutters
    fill(rect(x0 - 4, y0, x0 - 2, y1), L.awnA.base) vline(x0 - 4, y0, y1, L.awnA.hi)
    fill(rect(x1 + 2, y0, x1 + 4, y1), L.awnA.shade)
  end
end
local function door(x0, y0, x1, y1, r, arched)
  local m = arched and c:rrect(x0, y0, x1, y1 + 6, 4):clip(rect(x0, y0, x1, y1)) or rect(x0, y0, x1, y1)
  part(m, r, { inner = false })
  c:edgeIn(m, r.edge)
  for x = x0 + 3, x1 - 2, 3 do vline(x, y0 + 3, y1 - 1, r.shade) end
  px(x1 - 2, (y0 + y1) // 2 + 2, L.glow.hi)
  return m
end

-- lumpy crown (irregular polygon, never a circle) with leaf speckle
local function crown(cx, cy, rx, ry, r, seed)
  local pts, n = {}, 16
  for i = 0, n - 1 do
    local a = i / n * 2 * math.pi
    local k = .78 + .34 * hash(i, seed, 11)
    pts[#pts + 1] = { cx + math.cos(a) * rx * k, cy + sin(a) * ry * k }
  end
  local m = poly(pts)
  rimOf(m, r)
  part(m, r)
  m:each(function(x, y)
    local v = hash(x, y, seed)
    local ul = (x - cx) / rx + (y - cy) / ry < -.2
    if v < .10 then px(x, y, ul and r.hi or r.base)
    elseif v > .88 then px(x, y, ul and r.base or r.deep) end
  end)
  return m
end
local function maple(x, yb, h, r, seed, far)
  local tr = far and L.farTree or L.timber
  local t = rect(x - 2, yb - h // 2, x + 1, yb)
  if not far then rimOf(t, tr) end
  part(t, tr, { nopop = true })
  crown(x, yb - h * .62, h * .45, h * .36, far and L.farTree or r, seed)
end
local function palm(x, yb, h, lean, seed, far)
  local tr = far and L.farTree or L.timber
  local fr = far and L.farTree or L.foliage
  local top = { x + lean, yb - h }
  local trunk = c:line({ { x, yb }, { x + lean * .35, yb - h * .5 }, top }, far and 2 or 3)
  if not far then rimOf(trunk, tr) end
  part(trunk, tr, { nopop = true, noshade = true })
  trunk:each(function(xx, y) if (y + seed) % 3 == 0 then px(xx, y, tr.deep) end end)
  local fronds = HP.mask()
  local s = far and .5 or 1
  for i = 0, 6 do
    local a = -math.pi + i / 6 * math.pi
    local len = (16 + 6 * hash(i, seed, 2)) * s
    local ex, ey = top[1] + math.cos(a) * len, top[2] + sin(a) * len * .5
    local mx, my = (top[1] + ex) / 2, (top[2] + ey) / 2 - 3 * s
    fronds:add(c:line({ top, { mx, my }, { ex, ey + 6 * s } }, far and 1 or 2))
  end
  if not far then rimOf(fronds, fr) end
  part(fronds, fr, { nopop = true })
  if not far then fill(rect(top[1] - 1, top[2], top[1] + 1, top[2] + 2), L.timber.deep) end
end
local function cactus(x, yb, h, seed)
  local r = L.leaf
  local m = c:rrect(x - 3, yb - h, x + 3, yb, 3)
  m:add(c:rrect(x - 10, yb - h * .7, x - 6, yb - h * .35, 2)):add(rect(x - 8, yb - h * .42, x - 3, yb - h * .35))
  m:add(c:rrect(x + 6, yb - h * .82, x + 10, yb - h * .5, 2)):add(rect(x + 3, yb - h * .56, x + 8, yb - h * .5))
  rimOf(m, r) part(m, r)
  m:each(function(xx, y) if xx == x and (y % 2 == 0) then px(xx, y, r.shade) end end)
  px(x, yb - h + 1, L.foliage2.base) px(x + 1, yb - h + 1, L.foliage2.hi)
end
local function flora(x, yb, h, seed, far)
  if L.flora == "maple" then maple(x, yb, h, seed % 2 == 0 and L.foliage or L.foliage2, seed, far)
  else
    if seed % 3 == 2 and not far then cactus(x, yb, floor(h * .6), seed) else palm(x, yb, h, (seed % 2 == 0) and 4 or -4, seed, far) end
  end
end

---------------------------------------------------------------- generic building (gable/thatch vs flat parapet)
local function building(o)
  local x0, x1, yb, wh, rh, wr = o.x0, o.x1, o.yb, o.wh, o.rh, o.wall
  local top, cx = yb - wh, (x0 + x1) // 2
  local wallM = (L.wallStyle == "adobe") and c:rrect(x0, top, x1, yb, 2):add(rect(x0, top + 4, x1, yb)) or rect(x0, top, x1, yb)
  local roofM, gableM, chim
  local rr = o.roof or L.roof
  if L.roofStyle == "gable" then
    roofM = poly{ { x0 - 3, top + 3 }, { cx, top - rh }, { x1 + 3, top + 3 } }
    roofM:add(rect(x0 - 3, top, x1 + 3, top + 3))
    gableM = poly{ { x0 + 5, top }, { cx, top - rh + 8 }, { x1 - 5, top } }
    roofM:cut(gableM)
    if o.chimney then chim = rect(x1 - 12, top - rh + 2, x1 - 7, top - rh // 2) end
  else
    local q = (x1 - x0) // 4
    roofM = rect(x0 - 1, top - 4, x1 + 1, top + 1)
    roofM:add(rect(cx - q, top - 4 - rh // 2, cx + q, top))
    roofM:add(rect(cx - q // 2, top - 4 - rh, cx + q // 2, top))
  end
  local sil = union(wallM, roofM)
  if gableM then sil:add(gableM) end
  if chim then sil:add(chim) end
  shadow(x0 + 2, x1, yb, 10, 5)
  rimOf(sil, wr)
  if chim then part(chim, L.stone) courses(chim, top - rh + 2, 4, 6, L.stone) end
  part(wallM, wr)
  if L.roofStyle == "gable" then
    part(gableM, wr, { nopop = true })
    part(roofM, rr, { sep = true })
    if L.roofTex == "thatch" then
      roofM:each(function(x, y)
        if (y + (x // 5) % 2) % 3 == 0 then px(x, y, rr.shade) elseif hash(x, y, 5) < .07 then px(x, y, rr.hi) end
      end)
    else
      courses(roofM, top - rh, 3, 5, rr)
    end
    c:line({ { x0 - 2, top + 2 }, { cx, top - rh + 1 } }, 1):each(function(x, y) if roofM:has(x, y) then px(x, y, rr.hi) end end)
    hline(x0 - 3, x1 + 3, top + 3, rr.deep)
    -- gable: timber king post + attic window
    vline(cx, top - rh + 10, top - 1, L.timber.base)
    if rh >= 18 then window(cx - 3, top - rh // 2 + 1, cx + 2, top - rh // 2 + 5, L.timber) end
  else
    roofM:each(function(x, y) if not roofM:has(x, y - 1) then px(x, y, wr.hi) end end)
    -- vigas (beam ends)
    for x = x0 + 4, x1 - 4, 8 do fill(rect(x, top + 3, x + 2, top + 4), L.timber.base) px(x, top + 3, L.timber.hi) hline(x, x + 2, top + 5, wr.shade) end
  end
  if L.wallStyle == "timber" then
    local beams = union(rect(x0, top, x1, top + 1), rect(x0, yb - 2, x1, yb), rect(x0, top, x0 + 1, yb), rect(x1 - 1, top, x1, yb))
    local mid = top + floor(wh * .45)
    beams:add(rect(x0, mid, x1, mid + 1))
    for x = x0 + 12, x1 - 10, 14 do beams:add(rect(x, top, x + 1, yb)) end
    beams:add(c:line({ { x0 + 2, mid - 1 }, { x0 + 10, top + 2 } }, 1)):add(c:line({ { x1 - 2, mid - 1 }, { x1 - 10, top + 2 } }, 1))
    part(beams, L.timber, { nopop = true, noshade = true })
  else
    hline(x0, x1, yb - 3, L.accent.base) hline(x0, x1, yb - 2, L.accent.shade)
    for i = 1, 6 do local hx, hy = x0 + 3 + floor(hash(i, x0, 9) * (x1 - x0 - 6)), top + 6 + floor(hash(i, yb, 9) * (wh - 12)); px(hx, hy, wr.shade) px(hx + 1, hy, wr.shade) end
  end
  return top, cx
end

---------------------------------------------------------------- BACKGROUND
c:stripes(0, HZ, L.sky, { 3, 3, 3, 2 })
if L.skyStyle == "clouds" then
  for _, cl in ipairs({ { 120, 44, 40 }, { 300, 30, 52 }, { 400, 66, 30 }, { 40, 80, 26 } }) do
    local x, y, w = cl[1], cl[2], cl[3]
    local m = c:rrect(x, y - 6, x + w, y, 3):add(c:rrect(x + w // 5, y - 12, x + w * 3 // 4, y - 4, 4)):add(c:rrect(x + w // 2, y - 15, x + w * 3 // 4 + 4, y - 8, 3))
    fill(m, L.cloud.top) hline(x + 2, x + w - 2, y, L.cloud.under)
  end
else
  for i, s in ipairs({ { 30, 40, 130 }, { 200, 28, 170 }, { 330, 54, 120 }, { 80, 70, 90 }, { 380, 84, 80 } }) do
    hline(s[1], s[1] + s[3], s[2], L.cloud.top) hline(s[1] + 10, s[1] + s[3] - 14, s[2] + 1, L.cloud.under)
  end
end
-- far hills / mesas
local function fFar(x)
  if L.hillStyle == "dunes" then
    local m = HZ - 8
    if x > 30 and x < 130 then m = HZ - 26 + (x < 40 and (40 - x) * 1.8 or 0) + (x > 118 and (x - 118) * 1.6 or 0) end
    if x > 330 and x < 410 then m = math.min(m, HZ - 20 + (x < 342 and (342 - x) * 1.4 or 0) + (x > 398 and (x - 398) * 1.4 or 0)) end
    return m + 2 * sin(x / 9)
  end
  return HZ - 16 + 6 * sin(x / 37) + 4 * sin(x / 13 + 1)
end
local function fMid(x) return HZ - 6 + 4 * sin(x / 29 + 2) + 3 * sin(x / 11) end
c:terrain(fFar, L.hillFar, HZ)
if L.hillStyle == "dunes" then
  for x = 0, W - 1 do local y = floor(fFar(x) + .5) if fFar(x) - fFar(x - 1) > .6 then vline(x, y, math.min(HZ, y + 3), L.hillMidShade) end end
end
for i, tx in ipairs({ 24, 52, 196, 290, 318, 352, 440 }) do flora(tx, floor(fMid(tx)) + 2, 22, i, true) end
local midM = c:terrain(fMid, L.hillMid, HZ)
midM:each(function(x, y)
  local d = fMid(x + 1) - fMid(x - 1)
  if L.hillStyle == "dunes" and d > 0 and y < fMid(x) + 3 then px(x, y, L.hillMidShade)
  elseif L.hillStyle == "hills" and (x + y * 3) % 23 == 0 then px(x, y, L.hillMidShade) end
end)
-- ground
c:stripes(HZ + 1, H - 1, { L.groundFar, L.ground.hi, L.ground.base, L.ground.base }, { 1, 2, 4, 6 })
for y = HZ + 1, H - 1 do
  local d = y - HZ + 2
  for x = 0, W - 1 do
    if L.hillStyle == "hills" then
      local u = (x - VX) / d * 7
      if y < 168 and abs(u - floor(u + .5)) < .06 + 1.2 / d then px(x, y, L.ground.shade)
      elseif hash(x, y, 1) < .02 + y / 9000 then px(x, y, L.ground.shade) px(x, y - 1, L.ground.hi) end
    else
      local w = (y * 7 + floor(4 * sin(x / (8 + d * .2) + y))) % (6 + d // 10)
      if w == 0 then px(x, y, L.ground.shade) elseif w == 1 and hash(x, y, 4) < .5 then px(x, y, L.ground.hi) end
    end
  end
end
-- road (one-point perspective slabs)
roadM = poly{ { xl(ROAD_TOP), ROAD_TOP }, { xr(ROAD_TOP), ROAD_TOP }, { xr(H + 2), H + 2 }, { xl(H + 2), H + 2 } }
local function cell(x, y)
  local d = y - HZ + 6
  local row = floor(math.log(d) / math.log(L.slabRatio))
  local u = (x - VX) / d * L.slabK + (row % 2) * .5
  return row, floor(u)
end
roadM:each(function(x, y)
  local r1, u1 = cell(x, y)
  local r2, u2 = cell(x - 1, y)
  local r3, u3 = cell(x, y - 1)
  local h
  if r1 ~= r3 or u1 ~= u2 then h = L.road.deep
  else
    local v = hash(r1, u1, 21)
    h = v < .18 and L.road.hi or (v > .8 and L.road.shade or L.road.base)
    local r4, u4 = cell(x - 1, y - 1)
    if (r4 ~= r1 or u4 ~= u1) and cell(x - 2, y) == r1 then h = L.road.hi end
  end
  px(x, y, h)
end)
for y = ROAD_TOP, H - 1 do
  px(floor(xl(y)), y, L.road.edge) px(floor(xl(y)) - 1, y, L.ground.deep)
  px(floor(xr(y) + .99), y, L.road.edge) px(floor(xr(y) + .99) + 1, y, L.ground.deep)
end

---------------------------------------------------------------- QUIRKS on far hills (behind the well)
local function scarecrow()
  local t = L.timber
  local post = rect(108, 72, 109, 98):add(rect(100, 80, 117, 81))
  local shirt = poly{ { 103, 79 }, { 114, 79 }, { 116, 90 }, { 101, 90 } }
  local head = c:rrect(105, 70, 112, 78, 2)
  local hat = poly{ { 103, 66 }, { 114, 66 }, { 113, 70 }, { 104, 70 } }
  local spout = c:line({ { 114, 68 }, { 118, 65 } }, 1)
  local lid = rect(107, 63, 110, 65)
  local sil = union(post, shirt, head, hat, spout, lid)
  rimOf(sil, L.awnA)
  part(post, t, { nopop = true }) part(shirt, L.accent) hrows(shirt, 82, 3, L.accent.shade)
  part(head, L.awnB) px(107, 73, t.deep) px(110, 73, t.deep) hline(107, 110, 76, t.shade)
  part(hat, L.roof2) part(lid, L.roof2) fill(spout, L.roof2.shade)
  px(102, 69, L.roof2.deep) px(101, 68, L.roof2.deep) -- handle
end
local function beanBarrow()
  local t = L.timber
  local tray = poly{ { 160, 86 }, { 184, 86 }, { 180, 94 }, { 163, 94 } }
  local handles = c:line({ { 160, 88 }, { 152, 92 } }, 1):add(c:line({ { 166, 94 }, { 164, 98 } }, 1))
  local wheel = poly{ { 180, 92 }, { 186, 92 }, { 188, 95 }, { 186, 98 }, { 180, 98 }, { 178, 95 } }
  local pump = poly{ { 165, 78 }, { 170, 74 }, { 178, 74 }, { 182, 78 }, { 182, 86 }, { 165, 86 } }
  local stalk = c:line({ { 173, 74 }, { 170, 64 }, { 176, 54 }, { 171, 44 }, { 175, 36 } }, 2)
  local leaves = HP.mask()
  for i, p in ipairs({ { 170, 63, -1 }, { 176, 55, 1 }, { 171, 46, -1 }, { 175, 38, 1 } }) do
    leaves:add(poly{ { p[1], p[2] }, { p[1] + p[3] * 7, p[2] - 3 }, { p[1] + p[3] * 9, p[2] + 1 }, { p[1] + p[3] * 3, p[2] + 2 } })
  end
  local sil = union(tray, handles, wheel, pump, stalk, leaves)
  rimOf(sil, L.leaf)
  part(handles, t, { nopop = true }) part(tray, t) part(wheel, L.stone, { nopop = true })
  part(pump, L.produce) vline(170, 76, 85, L.produce.shade) vline(176, 76, 85, L.produce.shade)
  part(stalk, L.leaf, { nopop = true }) part(leaves, L.leaf, { sep = true })
end

---------------------------------------------------------------- OBJECTS
local function drawTrail() -- Wild Trail archway at the road's end (208,54,272,124)
  -- path continuing inside, deep woods
  local opening = poly{ { 222, 124 }, { 222, 76 }, { 230, 68 }, { 250, 68 }, { 258, 76 }, { 258, 124 } }
  local fr = L.foliage
  fill(opening, L.leaf.deep)
  opening:each(function(x, y) if hash(x, y, 31) < .25 then px(x, y, L.leaf.shade) end end)
  fill(poly{ { 236, 124 }, { 244, 124 }, { 241, 92 }, { 239, 92 } }, L.road.shade)
  for i = 0, 3 do local y = 98 + i * 7 hline(239 - i, 241 + i, y, L.road.deep) end
  fill(rect(224, 86, 228, 124), L.leaf.edge) fill(rect(252, 82, 256, 124), L.leaf.edge)
  local pL, pR = rect(210, 74, 220, 124), rect(260, 74, 270, 124)
  local lintel = poly{ { 208, 80 }, { 208, 70 }, { 216, 60 }, { 228, 55 }, { 252, 55 }, { 264, 60 }, { 272, 70 }, { 272, 80 }, { 260, 80 }, { 258, 74 }, { 250, 67 }, { 230, 67 }, { 222, 74 }, { 220, 80 } }
  shadow(212, 270, 124, 8, 4)
  local sil = union(pL, pR, lintel)
  rimOf(sil, L.leaf)
  local pillarR = (L.flora == "palm") and L.timber or L.stone
  part(pL, pillarR) part(pR, pillarR)
  if L.flora == "palm" then
    pL:add(pR):each(function(x, y) if y % 4 == 0 then px(x, y, pillarR.deep) elseif y % 4 == 1 then px(x, y, pillarR.hi) end end)
  else courses(union(pL, pR), 74, 6, 6, pillarR) end
  part(lintel, L.leaf)
  lintel:each(function(x, y) local v = hash(x, y, 33) if v < .14 then px(x, y, L.leaf.hi) elseif v > .86 then px(x, y, L.leaf.deep) end end)
  -- leaf clumps / fronds on the lintel
  for i, p in ipairs({ { 214, 66 }, { 230, 58 }, { 246, 57 }, { 262, 63 }, { 216, 78 }, { 266, 78 } }) do
    local cm = poly{ { p[1] - 5, p[2] }, { p[1] - 2, p[2] - 4 }, { p[1] + 3, p[2] - 4 }, { p[1] + 6, p[2] }, { p[1] + 3, p[2] + 4 }, { p[1] - 2, p[2] + 4 } }
    local rr = (i % 2 == 0) and L.foliage2 or fr
    rimOf(cm, rr) part(cm, rr)
  end
  -- trail marker + hanging lantern
  fill(c:line({ { 240, 67 }, { 240, 72 } }, 1), L.timber.deep)
  local lan = rect(237, 73, 243, 80)
  rimOf(lan, L.timber) fill(lan, L.glow.base) px(238, 74, L.glow.hi) vline(243, 74, 80, L.glow.shade) hline(237, 243, 73, L.timber.base)
  local mk = rect(262, 104, 267, 110) rimOf(mk, L.awnA) part(mk, L.awnA)
end

local function drawCottages() -- (16,64,78,134)
  building{ x0 = 19, x1 = 45, yb = 134, wh = 32, rh = 22, wall = L.plaster }
  window(24, 110, 30, 116, L.timber) door(34, 118, 41, 133, L.accent, L.wallStyle == "adobe")
  local top = building{ x0 = 52, x1 = 75, yb = 134, wh = 40, rh = 26, wall = L.wall2, chimney = L.roofStyle == "gable", roof = L.roofStyle == "gable" and L.roof2 or nil }
  window(57, 100, 63, 106, L.timber, L.wallStyle == "adobe") window(57, 116, 62, 122, L.timber)
  door(66, 116, 72, 133, L.timber, L.wallStyle == "adobe")
  -- flower pot / pot plant at the door
  local pot = rect(47, 128, 50, 133) rimOf(pot, L.wall2) part(pot, L.awnA, { nopop = true })
  px(48, 127, L.foliage2.base) px(49, 126, L.leaf.base)
end

local function drawSeed() -- Seed Swap shop front (16,146,78,212)
  local top, cx = building{ x0 = 19, x1 = 75, yb = 212, wh = 42, rh = 16, wall = L.wallStyle == "timber" and L.wall2 or L.plaster }
  -- sprout finial
  local sp = c:line({ { cx, top - 19 + (L.roofStyle == "gable" and 2 or 0) }, { cx, top - 14 } }, 1)
  local lf = poly{ { cx, top - 19 }, { cx - 5, top - 22 }, { cx - 6, top - 19 } }:add(poly{ { cx, top - 19 }, { cx + 5, top - 23 }, { cx + 6, top - 20 } })
  rimOf(union(sp, lf), L.leaf) part(sp, L.leaf, { nopop = true }) part(lf, L.leaf)
  -- shop window full of seed packets
  local win = rect(24, 184, 70, 198)
  fill(rect(23, 183, 71, 199), L.timber.deep) fill(win, L.glow.shade)
  for i = 0, 7 do
    local x = 25 + i * 6
    local rr = ({ L.awnA, L.awnB, L.accent, L.produce, L.leaf, L.foliage2, L.roof, L.wall2 })[i + 1]
    local pk = rect(x, 186 + (i % 2), x + 4, 192 + (i % 2)) part(pk, rr, { nopop = true }) px(x + 1, 187 + (i % 2), rr.hi)
    hline(x, x + 4, 189 + (i % 2), rr.deep)
  end
  hline(24, 70, 193, L.timber.base)
  for i = 0, 4 do local x = 26 + i * 9 local jar = rect(x, 194, x + 5, 198) fill(jar, L.water.hi) hline(x, x + 5, 194, L.timber.base) fill(rect(x + 1, 196, x + 4, 198), (i % 2 == 0) and L.produce.shade or L.soil.base) end
  -- striped awning
  local aw = poly{ { 18, 182 }, { 22, 174 }, { 72, 174 }, { 76, 182 } }
  for x = 18, 76, 4 do aw:add(poly{ { x, 182 }, { x + 4, 182 }, { x + 2, 185 } }) end
  aw:clip(rect(17, 170, 77, 186))
  rimOf(aw, L.awnA)
  aw:each(function(x, y) px(x, y, ((x - 18) // 4) % 2 == 0 and L.awnA.base or L.awnB.base) end)
  hline(22, 72, 174, L.awnB.hi) hline(18, 76, 182, L.awnA.shade)
  -- crate stand + door
  door(26, 200, 32, 211, L.timber)
  local crate = rect(52, 202, 70, 211) rimOf(crate, L.timber) part(crate, L.timber) hline(52, 70, 206, L.timber.deep)
  for i = 0, 3 do local sx = 54 + i * 4 px(sx, 201, L.leaf.base) px(sx + 1, 200, L.leaf.hi) px(sx, 200, L.leaf.shade) end
end

local function drawWell() -- giant Wishing Well (90,92,196,210)
  local S, T, RR = L.stone, L.timber, L[L.wellRoof]
  local roofOuter = poly{ { 143, 92 }, { 196, 120 }, { 196, 126 }, { 90, 126 }, { 90, 120 } }
  local gable = poly{ { 143, 104 }, { 178, 121 }, { 108, 121 } }
  local roofM = roofOuter:copy():cut(gable)
  local postL, postR = rect(103, 126, 110, 156), rect(176, 126, 183, 156)
  local lipTop = poly{ { 98, 147 }, { 188, 147 }, { 194, 156 }, { 92, 156 } }
  local lipFront = rect(92, 156, 194, 165)
  local drum = poly{ { 97, 165 }, { 189, 165 }, { 191, 168 }, { 191, 204 }, { 187, 208 }, { 99, 208 }, { 95, 204 }, { 95, 168 } }
  local axle = rect(110, 130, 176, 133)
  local crank = rect(184, 130, 190, 133):add(rect(188, 133, 191, 143))
  local rope = rect(142, 134, 143, 140)
  local bucket = poly{ { 134, 141 }, { 152, 141 }, { 150, 153 }, { 136, 153 } }
  shadow(100, 192, 208, 14, 6)
  local sil = union(roofOuter, postL, postR, lipTop, lipFront, drum, crank, axle, bucket)
  rimOf(sil, S)
  part(drum, S) courses(drum, 165, 7, 13, S)
  part(lipFront, S, { sep = true }) courses(lipFront, 156, 10, 17, S, 5)
  part(lipTop, S, { sep = true })
  local opening = poly{ { 106, 149 }, { 180, 149 }, { 184, 154 }, { 102, 154 } }
  fill(opening, L.water.deep) hline(110, 178, 149, S.edge) hline(118, 128, 152, L.water.shade) hline(156, 170, 151, L.water.shade)
  px(165, 152, L.glow.hi) px(166, 152, L.glow.base)
  part(postL, T) part(postR, T)
  postL:add(postR):each(function(x, y) if (x == 105 or x == 178) and y % 5 ~= 0 then px(x, y, T.shade) end end)
  part(axle, T, { nopop = true }) hline(110, 176, 130, T.hi)
  for x = 136, 150, 3 do vline(x, 131, 133, L.board.base) end -- coiled rope on the axle
  fill(rope, L.board.base) part(crank, T, { nopop = true }) fill(rect(188, 140, 191, 143), L.accent.base)
  part(bucket, T) hline(135, 151, 144, S.deep) hline(136, 150, 150, S.deep) fill(c:line({ { 135, 141 }, { 143, 137 }, { 151, 141 } }, 1), S.deep)
  part(roofM, RR, { sep = true }) courses(roofM, 92, 4, 6, RR)
  c:line({ { 91, 120 }, { 143, 93 } }, 1):each(function(x, y) if roofM:has(x, y) then px(x, y, RR.hi) end end)
  hline(90, 196, 126, RR.edge) hline(91, 195, 125, RR.deep)
  local gR = (L.wallStyle == "timber") and L.plaster or L.accent
  part(gable, gR, { nopop = true })
  vline(143, 106, 121, T.base) c:line({ { 143, 112 }, { 130, 120 } }, 1):each(function(x, y) px(x, y, T.base) end)
  c:line({ { 143, 112 }, { 156, 120 } }, 1):each(function(x, y) px(x, y, T.base) end)
  local fin = rect(141, 88, 145, 92) rimOf(fin, L.awnB) part(fin, L.awnB, { nopop = true }) px(142, 89, L.awnB.hi)
  if L.wallStyle == "adobe" then -- tile band
    for x = 93, 193 do for y = 158, 162 do px(x, y, (((x - 93) // 5 + (y - 158) // 3) % 2 == 0) and L.accent.base or L.awnB.base) end end
    hline(93, 193, 157, S.deep) hline(93, 193, 163, S.deep)
  else -- ivy on the drum
    for i = 0, 14 do local x, y = 97 + floor(hash(i, 1, 41) * 20), 166 + floor(hash(i, 2, 41) * 40) px(x, y, L.leaf.base) px(x + 1, y, L.leaf.hi) px(x, y + 1, L.leaf.deep) end
  end
  c:sparkle(176, 160)
end

local function drawPond() -- Fishing Pond (16,226,108,264)
  local bank = poly{ { 18, 238 }, { 32, 228 }, { 72, 226 }, { 100, 232 }, { 108, 246 }, { 100, 260 }, { 60, 264 }, { 26, 262 }, { 16, 252 } }
  local water = bank:shrink(3)
  shadow(24, 104, 262, 6, 3)
  rimOf(bank, L.water)
  fill(bank, L.soil.base)
  bank:edge():each(function(x, y) px(x, y, (hash(x, y, 51) < .5) and L.stone.base or L.stone.hi) end)
  part(water, L.water, { nopop = true })
  water:each(function(x, y) if not water:has(x, y - 2) then px(x, y, L.water.deep) end end)
  for i, s in ipairs({ { 30, 244, 12 }, { 48, 252, 16 }, { 36, 256, 8 }, { 62, 240, 10 } }) do hline(s[1], s[1] + s[3], s[2], L.water.hi) end
  -- lily pads / floating leaves (wedge cut, not round)
  for i, p in ipairs({ { 40, 236 }, { 54, 246 }, { 28, 250 } }) do
    local pad = poly{ { p[1] - 4, p[2] }, { p[1], p[2] - 2 }, { p[1] + 4, p[2] }, { p[1], p[2] + 2 } }
    fill(pad, L.leaf.base) px(p[1] - 3, p[2], L.leaf.hi) px(p[1] + 1, p[2] + 1, L.leaf.deep)
  end
  px(41, 234, L.foliage2.hi) px(42, 234, L.foliage2.base)
  -- jetty
  local jet = poly{ { 70, 240 }, { 104, 240 }, { 106, 250 }, { 72, 250 } }
  local legs = rect(74, 250, 76, 257):add(rect(100, 250, 102, 256)):add(rect(86, 250, 88, 256))
  rimOf(union(jet, legs), L.timber)
  part(legs, L.timber, { nopop = true })
  part(jet, L.board)
  jet:each(function(x, y) if (x - y // 3) % 5 == 0 then px(x, y, L.board.deep) end end)
  hline(72, 105, 250, L.timber.deep)
  -- rod leaning on a post with line + bobber-square
  fill(c:line({ { 98, 240 }, { 80, 222 }, { 66, 220 } }, 1), L.timber.deep)
  vline(66, 221, 236, L.awnB.shade) fill(rect(65, 236, 67, 238), L.awnA.base)
  -- reeds / bank plants
  for i = 0, 6 do local x = 20 + i * 4 local h = 5 + floor(hash(i, 9, 52) * 7)
    vline(x, 252 - h, 252, L.flora == "palm" and L.leaf.shade or L.roof.deep) px(x, 252 - h, L.flora == "palm" and L.leaf.hi or L.timber.base) end
  -- bucket of bait-less pebbles + tackle box
  local box = rect(90, 233, 99, 239) rimOf(box, L.accent) part(box, L.accent) hline(90, 99, 235, L.accent.deep)
end

local function drawTable() -- Long Table pavilion (120,222,188,264)
  local can = poly{ { 120, 233 }, { 128, 222 }, { 180, 222 }, { 188, 233 } }
  for x = 120, 186, 4 do can:add(poly{ { x, 233 }, { x + 4, 233 }, { x + 2, 236 } }) end
  can:clip(rect(120, 222, 188, 236))
  local posts = rect(123, 236, 125, 262):add(rect(183, 236, 185, 262))
  local top = poly{ { 131, 243 }, { 177, 243 }, { 181, 249 }, { 127, 249 } }
  local cloth = rect(127, 249, 181, 254)
  local legs = rect(129, 255, 131, 261):add(rect(177, 255, 179, 261))
  local bench = rect(126, 258, 182, 260)
  shadow(124, 186, 262, 8, 3)
  rimOf(union(can, posts, top, cloth, legs, bench), L.awnA)
  part(posts, L.timber, { nopop = true })
  can:each(function(x, y) px(x, y, ((x - 120) // 4) % 2 == 0 and L.awnB.base or L.awnA.base) end)
  hline(128, 180, 222, L.awnB.hi) hline(120, 188, 233, L.awnA.deep)
  part(legs, L.timber, { nopop = true })
  part(top, L.awnB) part(cloth, L.accent, { nopop = true })
  for x = 127, 181, 3 do px(x, 254, L.accent.hi) end
  part(bench, L.timber, { nopop = true })
  -- feast: teapot, pie, jug, plates
  local tp = poly{ { 136, 239 }, { 144, 239 }, { 145, 245 }, { 135, 245 } }
  rimOf(tp, L.roof2) part(tp, L.roof2) fill(c:line({ { 145, 241 }, { 148, 238 } }, 1), L.roof2.deep) px(139, 238, L.roof2.deep) px(140, 238, L.roof2.deep)
  local pie = poly{ { 152, 243 }, { 162, 243 }, { 164, 246 }, { 150, 246 } } rimOf(pie, L.produce) part(pie, L.produce, { nopop = true })
  hline(153, 161, 244, L.roof.hi)
  local jug = rect(168, 239, 172, 245) rimOf(jug, L.water) part(jug, L.water)
  for x = 131, 175, 11 do hline(x, x + 3, 247, L.plaster.hi) end
  -- lanterns under the canopy
  for _, lx in ipairs({ 140, 168 }) do vline(lx, 236, 237, L.timber.deep) local l = rect(lx - 1, 238, lx + 1, 240) fill(l, L.glow.base) px(lx - 1, 238, L.glow.hi) end
end

local function drawNotice() -- towering Notice Board (284,46,342,136)
  local T = L.timber
  local roof = poly{ { 284, 59 }, { 313, 46 }, { 342, 59 }, { 342, 62 }, { 284, 62 } }
  local posts = rect(289, 62, 294, 136):add(rect(332, 62, 337, 136))
  local board = rect(287, 65, 339, 114)
  local bar = rect(286, 120, 340, 123)
  shadow(290, 338, 136, 10, 5)
  rimOf(union(roof, posts, board, bar), T)
  part(posts, T)
  part(board, L.board, { band = 2 })
  board:each(function(x, y) if hash(x, y, 61) < .06 then px(x, y, L.board.deep) end end)
  hline(287, 339, 65, T.base) hline(287, 339, 114, T.base) vline(287, 65, 114, T.base) vline(339, 65, 114, T.base)
  part(bar, T, { nopop = true })
  part(roof, L[L.wellRoof]) courses(roof, 46, 3, 5, L[L.wellRoof])
  -- pinned notes (blank, no text) + a pinned map scrap + ribbon
  local notes = { { 291, 69, 302, 82, L.awnB }, { 306, 70, 320, 80, L.plaster }, { 324, 68, 335, 84, L.awnB },
                  { 292, 87, 305, 100, L.accent }, { 309, 85, 321, 104, L.plaster }, { 325, 89, 335, 99, L.roof },
                  { 296, 103, 306, 111, L.awnA }, { 323, 102, 334, 111, L.plaster } }
  for i, n in ipairs(notes) do
    local m = rect(n[1], n[2], n[3], n[4])
    part(m, n[5], { nopop = true })
    c:edgeIn(m, n[5].deep)
    for y = n[2] + 3, n[4] - 2, 3 do hline(n[1] + 2, n[3] - 2 - (y % 4), y, n[5].shade) end
    px((n[1] + n[3]) // 2, n[2] + 1, L.awnA.base)
  end
  fill(c:line({ { 311, 90 }, { 316, 96 }, { 312, 100 } }, 1), L.awnA.base) -- route line on the map
  -- hanging lantern on the right post
  hline(337, 340, 70, T.deep) vline(340, 70, 72, T.deep)
  local lan = rect(338, 73, 342, 79) rimOf(lan, T) fill(lan, L.glow.base) px(339, 74, L.glow.hi) vline(342, 74, 79, L.glow.shade)
  -- paste bucket
  local b = poly{ { 300, 128 }, { 308, 128 }, { 307, 135 }, { 301, 135 } } rimOf(b, L.accent) part(b, L.accent, { nopop = true })
  vline(305, 122, 128, T.hi)
end

local function drawRest() -- Rest House front with bench, quilt, teapot (354,62,462,136)
  local top, cx = building{ x0 = 360, x1 = 456, yb = 136, wh = 46, rh = 26, wall = L.plaster, chimney = L.roofStyle == "gable" }
  -- porch roof
  local porch = poly{ { 356, 106 }, { 460, 106 }, { 462, 111 }, { 354, 111 } }
  rimOf(porch, L.awnA)
  porch:each(function(x, y) px(x, y, (((x - 356) // 6) % 2 == 0) and L.awnA.base or L.awnB.base) end)
  hline(356, 460, 106, L.awnB.hi) hline(354, 462, 111, L.awnA.deep)
  fill(rect(360, 112, 361, 134), L.timber.base) fill(rect(455, 112, 456, 134), L.timber.base)
  window(366, 96, 378, 102, L.timber, L.wallStyle == "adobe") window(438, 96, 450, 102, L.timber, L.wallStyle == "adobe")
  window(366, 115, 376, 120, L.timber) window(440, 115, 450, 120, L.timber)
  door(400, 112, 416, 135, L.wallStyle == "adobe" and L.awnA or L.timber, L.wallStyle == "adobe")
  -- door lantern
  local lan = rect(420, 114, 423, 119) rimOf(lan, L.timber) fill(lan, L.glow.base) px(420, 114, L.glow.hi)
  -- bench with quilt
  local bench = rect(364, 127, 396, 129):add(rect(365, 130, 367, 135)):add(rect(393, 130, 395, 135)):add(rect(364, 122, 366, 127))
  local quilt = rect(370, 123, 390, 133)
  shadow(366, 396, 135, 5, 2)
  rimOf(union(bench, quilt), L.timber)
  part(bench, L.timber, { nopop = true })
  local qc = { L.awnA.base, L.awnB.base, L.accent.base, L.roof.base }
  quilt:each(function(x, y) px(x, y, qc[((x - 370) // 5 + (y - 123) // 4) % 4 + 1]) end)
  for x = 370, 390, 5 do vline(x, 123, 133, L.awnB.deep) end
  hline(370, 390, 133, L.awnA.deep)
  -- tea table + teapot (angular, not round)
  local tbl = rect(424, 127, 444, 129):add(rect(426, 130, 427, 135)):add(rect(441, 130, 442, 135))
  local pot = poly{ { 429, 120 }, { 438, 120 }, { 440, 126 }, { 427, 126 } }
  local lid = rect(432, 118, 435, 119)
  rimOf(union(tbl, pot, lid), L.timber)
  part(tbl, L.timber, { nopop = true }) part(pot, L.accent) part(lid, L.accent, { nopop = true })
  fill(c:line({ { 440, 122 }, { 443, 119 } }, 1), L.accent.deep) px(426, 122, L.accent.deep) px(425, 123, L.accent.deep)
  hline(429, 438, 123, L.awnB.base)
  local cup = rect(436, 125, 437, 126) -- tiny cup
  fill(rect(441, 125, 443, 126), L.plaster.hi)
  -- flower boxes under top windows
  for _, x in ipairs({ 365, 437 }) do for i = 0, 14, 2 do px(x + i, 104, (i % 4 == 0) and L.foliage2.base or L.leaf.base) end end
end

local function drawStall() -- huge Trader Stall (290,150,410,226)
  local T = L.timber
  local aw = poly{ { 290, 174 }, { 298, 152 }, { 402, 152 }, { 410, 174 } }
  for x = 290, 406, 8 do aw:add(poly{ { x, 174 }, { x + 8, 174 }, { x + 4, 179 } }) end
  aw:clip(rect(290, 150, 410, 179))
  local sign = rect(332, 150, 368, 156)
  local posts = rect(295, 178, 299, 224):add(rect(401, 178, 405, 224))
  local back = rect(300, 179, 400, 195)
  local ctop = poly{ { 299, 194 }, { 401, 194 }, { 404, 199 }, { 296, 199 } }
  local cfront = rect(296, 199, 404, 220)
  local legs = rect(300, 221, 304, 225):add(rect(396, 221, 400, 225))
  shadow(296, 406, 224, 14, 5)
  rimOf(union(aw, posts, back, ctop, cfront, legs), T)
  part(posts, T)
  fill(back, T.deep) hrows(rect(301, 180, 399, 194), 186, 7, T.base)
  -- shelf goods behind
  for i = 0, 11 do local x = 303 + i * 8 local rr = ({ L.produce, L.water, L.awnB, L.leaf })[i % 4 + 1]
    local j = rect(x, 181 + (i % 2), x + 4, 185) fill(j, rr.base) px(x, 181 + (i % 2), rr.hi) vline(x + 4, 182, 185, rr.shade)
    local j2 = rect(x + 2, 188, x + 5, 192) fill(j2, (rr == L.water) and L.foliage2.base or rr.shade) px(x + 2, 188, rr.hi) end
  -- awning stripes
  aw:each(function(x, y)
    local k = ((x - VX) * 40 // (y - 100 + 40)) -- stripes converge toward the vanishing point
    px(x, y, (floor(x / 8) % 2 == 0) and L.awnA.base or L.awnB.base)
  end)
  aw:each(function(x, y) if not aw:has(x + 1, y + 1) then px(x, y, ((floor(x / 8) % 2 == 0) and L.awnA or L.awnB).shade) end end)
  hline(298, 402, 152, L.awnB.hi) hline(291, 409, 174, L.awnA.deep)
  part(sign, T) hline(334, 366, 153, T.deep)
  for i = 0, 4 do local x = 338 + i * 6 fill(rect(x, 152, x + 2, 154), ({ L.produce, L.leaf, L.awnB, L.water, L.foliage2 })[i + 1].base) end
  -- counter
  part(cfront, T, { band = 2 }) for x = 296, 404, 9 do vline(x, 200, 220, T.deep) end hline(296, 404, 209, T.shade)
  part(ctop, L.board) part(legs, T, { nopop = true })
  -- goods on the counter: crates heaped with produce, spice/grain mounds, bolts of cloth
  local function heap(x0, x1, yb, rr)
    local m = poly{ { x0, yb }, { x0 + 2, yb - 5 }, { (x0 + x1) // 2, yb - 8 }, { x1 - 2, yb - 5 }, { x1, yb } }
    rimOf(m, rr) part(m, rr, { sep = true })
    m:each(function(x, y) if hash(x, y, x0) < .16 then px(x, y, rr.hi) elseif hash(x, y, x0 + 1) < .12 then px(x, y, rr.deep) end end)
  end
  heap(302, 322, 195, L.produce)
  heap(326, 344, 195, L.flora == "palm" and L.awnB or L.foliage2)
  heap(374, 396, 195, L.flora == "palm" and L.wall2 or L.leaf)
  local bolt = rect(350, 186, 368, 195) rimOf(bolt, L.accent) part(bolt, L.accent) for x = 352, 366, 4 do vline(x, 187, 194, L.accent.deep) end
  -- crates in front
  for i, x in ipairs({ 310, 360 }) do
    local cr = rect(x, 210, x + 24, 222) rimOf(cr, T) part(cr, L.board) hline(x, x + 24, 216, L.board.deep) vline(x + 12, 210, 222, L.board.deep)
  end
  -- hanging lanterns and strings of chilies
  for _, lx in ipairs({ 312, 388 }) do vline(lx, 179, 182, T.edge) local l = rect(lx - 2, 183, lx + 2, 189) rimOf(l, T) fill(l, L.glow.base) px(lx - 2, 183, L.glow.hi) vline(lx + 2, 184, 189, L.glow.shade) end
  for y = 180, 190, 2 do px(346, y, L.awnA.base) px(347, y + 1, L.awnA.shade) end
end

local function drawForage() -- Forage Patch raised bed (296,238,376,264)
  local T = L.timber
  local soil = poly{ { 304, 247 }, { 368, 247 }, { 374, 254 }, { 298, 254 } }
  local front = rect(298, 254, 374, 262)
  local back = rect(304, 245, 368, 247)
  shadow(300, 374, 262, 8, 2)
  rimOf(union(soil, front, back), T)
  part(back, T, { nopop = true })
  fill(soil, L.soil.base) soil:each(function(x, y) if hash(x, y, 71) < .2 then px(x, y, L.soil.deep) elseif hash(x, y, 72) < .1 then px(x, y, L.soil.hi) end end)
  part(front, T) hline(298, 374, 258, T.deep) for x = 298, 374, 19 do vline(x, 254, 262, T.deep) end
  -- plants
  local P = HP.mask()
  if L.flora == "maple" then
    for i, x in ipairs({ 308, 330, 352 }) do -- mushrooms (trapezoid caps + dots)
      local cap = poly{ { x - 5, 247 }, { x - 3, 243 }, { x + 3, 243 }, { x + 5, 247 } }
      local st = rect(x - 1, 248, x + 1, 251)
      rimOf(union(cap, st), L.awnA) part(st, L.awnB, { nopop = true }) part(cap, L.awnA)
      px(x - 2, 244, L.awnB.hi) px(x + 2, 245, L.awnB.hi)
    end
    for i, x in ipairs({ 319, 341, 363 }) do -- fern / berry bush
      local b = poly{ { x - 6, 251 }, { x - 4, 242 }, { x, 238 }, { x + 4, 242 }, { x + 6, 251 } }
      rimOf(b, L.leaf) part(b, L.leaf)
      b:each(function(xx, y) if hash(xx, y, 73) < .1 then px(xx, y, L.foliage2.base) px(xx, y - 1, L.foliage2.hi) end end)
    end
  else
    for i, x in ipairs({ 310, 342 }) do -- aloe rosettes (spiky)
      local m = HP.mask()
      for j = -3, 3 do m:add(c:line({ { x, 251 }, { x + j * 2, 240 + abs(j) } }, 1)) end
      rimOf(m, L.leaf) part(m, L.leaf, { nopop = true })
    end
    for i, x in ipairs({ 326, 358 }) do -- prickly-pear pads
      local m = c:rrect(x - 4, 243, x + 2, 251, 2):add(c:rrect(x + 1, 238, x + 6, 245, 2))
      rimOf(m, L.leaf) part(m, L.leaf, { sep = true }) px(x + 3, 237, L.foliage2.base) px(x - 1, 242, L.foliage2.base)
    end
    for i, x in ipairs({ 318, 368 }) do px(x, 246, L.produce.base) px(x, 247, L.produce.shade) px(x + 1, 245, L.leaf.base) end
  end
  -- trowel stuck in the soil
  fill(rect(371, 238, 372, 246), T.base) local bl = poly{ { 369, 246 }, { 374, 246 }, { 372, 251 } } fill(bl, L.stone.base) px(370, 246, L.stone.hi)
end

local function snailMailbox() -- quirk at the well side (198..222,126..146)
  local post = rect(208, 136, 209, 146)
  local shell = c:rrect(203, 124, 216, 135, 4)
  local foot = rect(198, 133, 220, 136):add(rect(198, 129, 201, 133))
  local stalks = rect(198, 125, 198, 128):add(rect(201, 125, 201, 128))
  rimOf(union(post, shell, foot, stalks), L.roof2)
  part(post, L.timber, { nopop = true })
  part(foot, L.leaf, { nopop = true })
  fill(stalks, L.leaf.shade)
  part(shell, L.roof2)
  fill(c:line({ { 209, 129 }, { 212, 129 }, { 212, 132 }, { 207, 132 }, { 207, 127 }, { 214, 127 } }, 1), L.roof2.deep)
  hline(204, 215, 134, L.awnB.base) -- letter slot
  local flag = rect(217, 126, 219, 129) fill(flag, L.awnA.base)
end
local function haystack() -- haystack with a little door (424,180,462,224)
  local m = poly{ { 424, 224 }, { 426, 204 }, { 432, 190 }, { 443, 182 }, { 454, 190 }, { 460, 204 }, { 462, 224 } }
  shadow(426, 462, 224, 8, 3)
  rimOf(m, L.roof) part(m, L.roof)
  m:each(function(x, y) if (y + (x // 4) % 3) % 4 == 0 then px(x, y, L.roof.shade) elseif hash(x, y, 81) < .06 then px(x, y, L.roof.hi) end end)
  door(438, 208, 447, 224, L.accent, true)
  window(451, 200, 454, 203, L.timber)
end
local function signBothWays() -- (430,146,458,174)
  local post = rect(442, 152, 445, 176)
  local b1 = poly{ { 430, 155 }, { 434, 151 }, { 454, 151 }, { 458, 155 }, { 454, 159 }, { 434, 159 } } -- double-headed
  local b2 = poly{ { 432, 165 }, { 436, 162 }, { 452, 162 }, { 456, 165 }, { 452, 168 }, { 436, 168 } }
  rimOf(union(post, b1, b2), L.timber)
  part(post, L.timber, { nopop = true })
  part(b1, L.board) part(b2, L.awnB)
  hline(436, 452, 155, L.board.deep) hline(438, 450, 165, L.awnB.deep)
end

---------------------------------------------------------------- compose back -> front
scarecrow()
beanBarrow()
-- far flora between far buildings
flora(200, 104, 30, 4)
flora(350, 108, 34, 3)
drawTrail()
drawCottages()
drawNotice()
drawRest()
snailMailbox()
signBothWays()
drawWell()
drawSeed()
drawStall()
haystack()
drawTable()
drawPond()
drawForage()

---------------------------------------------------------------- GATE FRAME (timber beam, stone posts, lanterns, bunting)
local G = L.stone
local corner = L.flora == "maple" and L.foliage or L.foliage
-- overhanging foliage at the top corners
if L.flora == "maple" then
  crown(56, 18, 34, 12, L.foliage, 91) crown(110, 14, 22, 8, L.foliage2, 92)
  crown(428, 18, 34, 12, L.foliage2, 93) crown(378, 14, 20, 8, L.foliage, 94)
else
  for _, f in ipairs({ { 20, 14, 1 }, { 460, 14, -1 } }) do
    local m = HP.mask()
    for i = 0, 4 do m:add(c:line({ { f[1], f[2] }, { f[1] + f[3] * (14 + i * 9), f[2] + 6 + i * 2 }, { f[1] + f[3] * (22 + i * 12), f[2] + 16 + i * 4 } }, 2)) end
    rimOf(m, L.foliage) part(m, L.foliage, { nopop = true })
  end
end
local beam = rect(0, 0, W - 1, 12)
local postL, postR = rect(0, 0, 15, 222), rect(W - 16, 0, W - 1, 222)
local plL, plR = rect(0, 218, 18, 228), rect(W - 19, 218, W - 1, 228)
local brL = poly{ { 16, 13 }, { 34, 13 }, { 16, 31 } }
local brR = poly{ { W - 17, 13 }, { W - 35, 13 }, { W - 17, 31 } }
rimOf(union(beam, postL, postR, plL, plR, brL, brR), L.timber)
part(postL, G) part(postR, G)
courses(union(postL, postR), 0, 9, 16, G)
part(plL, G, { sep = true }) part(plR, G, { sep = true }) hline(0, 18, 218, G.hi) hline(W - 19, W - 1, 218, G.hi)
part(brL, L.timber, { nopop = true }) part(brR, L.timber, { nopop = true })
part(beam, L.timber, { band = 2 })
beam:each(function(x, y) if y > 1 and y < 11 and hash(x // 7, y, 95) < .12 then px(x, y, L.timber.shade) end end)
hline(0, W - 1, 1, L.timber.hi)
for x = 30, W - 30, 60 do fill(rect(x, 4, x + 2, 6), L.timber.deep) px(x, 4, L.timber.hi) end
-- bunting
local function by(x) local t = (x - VX) / 224 return 15 + 16 * (1 - t * t) end
for x = 16, W - 17 do px(x, floor(by(x)), L.timber.deep) end
local cols = { L.awnA, L.awnB, L.accent, L.roof }
local i = 0
for x = 20, W - 28, 12 do
  i = i + 1
  local y = floor(by(x + 4))
  local tri = poly{ { x, y }, { x + 8, y }, { x + 4, y + 7 } }
  local r = cols[i % 4 + 1]
  fill(tri, r.base) hline(x, x + 8, y, r.hi)
  tri:each(function(xx, yy) if not tri:has(xx + 1, yy) then px(xx, yy, r.deep) end end)
end
-- lanterns hanging from the beam
for _, lx in ipairs({ 34, W - 35 }) do
  vline(lx, 13, 19, L.timber.edge)
  local cap = rect(lx - 5, 20, lx + 5, 22)
  local body = rect(lx - 4, 23, lx + 4, 33)
  local base = rect(lx - 5, 34, lx + 5, 35)
  rimOf(union(cap, body, base), L.timber)
  part(cap, L.timber, { nopop = true }) part(base, L.timber, { nopop = true })
  fill(body, L.glow.base) vline(lx - 4, 23, 33, L.timber.base) vline(lx + 4, 23, 33, L.timber.base)
  fill(rect(lx - 3, 24, lx - 1, 32), L.glow.hi) vline(lx + 3, 24, 33, L.glow.shade) vline(lx, 23, 33, L.timber.deep)
  for yy = 37, 41 do px(lx, yy, L.glow.shade) end -- warm drip of light
end

-- keep the compass corner calm: plain ground re-laid
for y = 230, H - 1 do for x = 380, W - 1 do
  local v = hash(x, y, 99)
  px(x, y, v < .04 and L.ground.shade or L.ground.base)
end end

c:finish{ outline = false }
HP.assertClean(c)
local base = OUT .. "pilot-market-" .. PALNAME
c:save{ aseprite = base .. ".aseprite", png = base .. ".png", scale = 1 }

-- layout (geometry is look-independent)
local parts = {}
for _, s in ipairs(SPOTS) do
  local b = s.box
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s.k, s.name, (b[1] + b[3]) // 2, b[4], b[1], b[2], b[3], b[4])
end
local st = {}
for _, p in ipairs(STAND) do st[#st + 1] = string.format('{"x":%d,"y":%d}', p.x, p.y) end
local f = io.open(OUT .. "pilot-market.layout.json", "w")
f:write(string.format('{"w":%d,"h":%d,"horizon":%d,"view":"gate","spots":[%s],"stand":[%s],"compass_clear":[380,230,480,270]}\n',
  W, H, HZ, table.concat(parts, ","), table.concat(st, ",")))
f:close()
print("saved " .. base)
