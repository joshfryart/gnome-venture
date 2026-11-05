-- stage-wetland v3: clear-day marsh base backdrop (no weather painted in)
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H, INK, mix = X.hash, GX.INK, GX.mix
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "stage-wetland" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local R6 = GX.ramp6
local GRN1 = { hi = "#c8f070", base = "#6cc050", shade = "#3a9048", deep = "#1f5a44" }
local GRN2 = { hi = "#a0dc60", base = "#48a050", shade = "#2e7648", deep = "#1c4a40" }
local WILL = { hi = "#d4f080", base = "#9cd060", shade = "#5aa048", deep = "#2e7048" }
local BARK = { hi = "#c8a46a", base = "#8a6444", shade = "#5e4238", deep = "#3a2832" }
local GRASS = { hi = "#d0f070", base = "#92d048", shade = "#58a840", deep = "#2a7a44" }
local MUD = { hi = "#c8a46a", base = "#9a7248", shade = "#6e4e3a", deep = "#46303a" }
local HERON = { hi = "#ffffff", base = "#e8eef0", shade = "#b4c0cc", deep = "#7a8aa0" }
HERON.hi = "#f8fcfc"
local FAR = "#8cc0a0"

-- sky (plain clear gradient) + small sun
GX.bands(c, 0, 125, { "#7cc4ee", "#98d4f4", "#b4e4f6", "#cdf0f4", "#e4f6d8", "#f4f4c0" }, 3, .2)
local sun = mk(); E(sun, 396, 36, 13, 12); sun = GX.rough(sun, 5, 1)
c:fillMask(sun, "#fff4b8"); local s2 = mk(); E(s2, 396, 36, 8, 7); c:fillMask(s2, "#fffbe0")

-- far treeline
for _, t in ipairs{ {10,108,34,10},{70,106,36,12},{130,110,34,9},{190,106,38,12},{255,109,36,10},{320,106,38,12},{385,110,36,9},{450,106,36,12} } do
  GX.foliage(c, t[1], t[2], t[3], t[4], { hi = mix(FAR, "#e4f6d8", .35), base = FAR, shade = mix(FAR, "#2a6a5a", .3), deep = mix(FAR, "#2a5a50", .5) }, 200 + t[1])
end
GX.ground(c, function(x) return 120 + floor(3 * sin(x / 31) + 1.5 * sin(x / 9)) end, { hi = "#c0e888", base = "#9cd070", shade = "#78b060", deep = "#5a9060" }, 5, { top = .75, fall = .3, tex = .3 })

-- pond
local function top(x) return 128 + floor(2 * sin(x / 21) + 1.2 * sin(x / 6)) end
local function bot(x) return 176 + floor(3 * sin(x / 27 + 1) + 2 * sin(x / 8)) end
local pond = mk()
for x = 0, 479 do for y = top(x), bot(x) do pond:set(x, y) end end
pond = GX.rough(pond, 31, 1)
local WA = { "#4a8cba", "#5aa8cc", "#78c4d8", "#9ad8e0", "#bfe8e0", "#fff4c8" }
pond:each(function(x, y)
  local t = (y - top(x)) / 48
  local v = .12 + t * .55 + (GX.vn(x * .35, y * 1.5, 4, 9) - .5) * .3
  if y < top(x) + 4 then v = v + .25 end
  c:px(x, y, WA[max(1, min(5, 1 + floor(max(0, min(1, v)) * 5)))])
end)
for i = 0, 90 do   -- ripples
  local x, y = floor(H(i, 71, 1) * 470), 132 + floor(H(i, 73, 1) * 42)
  if pond:has(x, y) and pond:has(x + 7, y) then for k = 0, 3 + i % 5 do c:px(x + k, y, (i % 2 == 0) and "#e8fbe8" or "#3e7aa8") end end
end
-- mud shore rim
local shr = pond:copy():grow(2); shr:cut(pond)
shr:each(function(x, y) if y > 150 then c:px(x, y, R6(MUD)[2 + floor(GX.vn(x, y, 3, 8) * 3)]) end end)

-- bank ground
GX.ground(c, function(x) return bot(x) + 1 end, GRASS, 7, { top = .86, fall = .6, tex = .32, sc = 8 })
for x = 0, 479 do for y = bot(x) + 1, bot(x) + 3 do   -- wet bank edge
  if GX.vn(x, y, 3, 12) > .35 then c:px(x, y, MUD.base) end end
  c:px(x, bot(x) + 1, MUD.shade)
end

-- lily pads
local pads = { {70,152,10,3},{120,160,9,3},{165,146,8,2},{300,150,11,3},{350,160,9,3},{255,168,8,2},{36,166,8,2},{205,164,9,3} }
for i, p in ipairs(pads) do
  local m = mk(); E(m, p[1], p[2], p[3], p[4]); m = GX.rough(m, 50 + i, 1)
  for k = 1, p[3] do m:cut(c:rect(p[1] + k, p[2], p[1] + k, p[2])) end
  GX.lit(c, m, R6(i % 2 == 0 and GRN1 or GRN2), { R = 3, tex = .35, sc = 2, seed = i, rimlight = true })
end
local function lily(x, y, col)
  for k = -4, 4, 2 do c:px(x + k, y, mix(col, "#b04a80", .5)); c:px(x + k, y - 1, col); c:px(x + k // 2, y - 2, "#ffffff") end
  c:px(x - 2, y - 3, col); c:px(x + 2, y - 3, col); c:px(x, y - 3, "#ffffff"); c:px(x, y - 4, "#ffffff")
  c:px(x - 1, y - 1, "#ffe38a"); c:px(x, y - 1, "#ffd040"); c:px(x + 1, y - 1, "#ffe38a")
end
lily(300, 148, "#ff9fc0"); lily(121, 158, "#fff4f8"); lily(70, 150, "#ff9fc0")
-- quirk: a tiny frog on a pad
do
  local FR = { hi = "#e8ff88", base = "#7cd040", shade = "#3e9a40", deep = "#1f5a44" }
  local fm = mk(); E(fm, 352, 157, 4, 2); fm = GX.rough(fm, 61, 1)
  GX.lit(c, fm, R6(FR), { R = 2, tex = .2, seed = 5, rimlight = true })
  c:px(350, 154, "#ffffff"); c:px(354, 154, "#ffffff"); c:px(350, 155, INK); c:px(354, 155, INK)
end
for i = 0, 150 do   -- duckweed
  local x, y = floor(H(i, 81, 1) * 480), 130 + floor(H(i, 83, 1) * 46)
  if pond:has(x, y) and GX.vn(x, y, 12, 14) > .55 then c:px(x, y, "#9ae060"); c:px(x + 1, y, "#6cc050") end
end

-- weeping willow (left edge)
local tr = GX.trunk(c, 24, 38, 60, 178, BARK, 17, { moss = GRN2 })
local fol = { {30,40,52,30,WILL,301},{70,52,44,26,WILL,302},{18,70,36,22,GRN1,303},{82,76,28,16,WILL,304},{40,86,44,14,GRN1,305} }
for _, f in ipairs(fol) do GX.foliage(c, f[1], f[2], f[3], f[4], f[5], f[6]) end
for x = 0, 112, 2 do   -- hanging fronds
  local y0 = 80 + floor(8 * sin(x / 11)) - floor(max(0, x - 70) * .5)
  local len = 28 + floor(H(x, 4, 1) * 40) - floor(max(0, x - 70) * .6)
  for k = 0, max(6, len) do
    local xx = x + floor(sin(k / 8 + x) * 1.2)
    local col = (k < 3) and WILL.shade or (H(k, x, 2) < .3 and WILL.hi or WILL.base)
    if k > len - 3 then col = WILL.shade end
    c:px(xx, y0 + k, col); if k % 6 == 0 then c:px(xx + 1, y0 + k, WILL.hi) end
  end
end

-- reeds and cattails (right)
local function reed(x, yb, h, lean, seed, cat)
  local pts = {}
  for k = 0, h do
    local xx = x + floor(lean * (k / h) ^ 2 * 8) + floor(sin(k / 14 + seed) * 1.2)
    pts[k] = { xx, yb - k }
    c:px(xx, yb - k, INK); c:px(xx + 1, yb - k, k < h * .25 and GRN2.deep or (H(k, seed, 3) < .25 and GRN1.hi or GRN1.base)); c:px(xx + 2, yb - k, GRN1.hi)
  end
  if cat then
    local tp = pts[h - 6]
    c:fillMask(c:rect(tp[1] - 1, tp[2] - 8, tp[1] + 3, tp[2]), INK)
    c:fillMask(c:rect(tp[1], tp[2] - 7, tp[1] + 2, tp[2] - 1), "#7a4a34")
    c:px(tp[1], tp[2] - 7, "#b97a4a"); c:px(tp[1], tp[2] - 5, "#b97a4a"); c:px(tp[1] + 2, tp[2] - 3, "#4a2a2c")
    c:px(tp[1] + 1, tp[2] - 9, "#c8b080"); c:px(tp[1] + 1, tp[2] - 10, "#c8b080")
  end
end
local function clump(x0, x1, yb, hmin, hmax, lean, seed)
  for x = x0, x1, 3 do
    reed(x, yb + floor(H(x, seed, 2) * 5), hmin + floor(H(x, seed, 1) * (hmax - hmin)), lean * (.5 + H(x, seed, 4)), x + seed, H(x, seed, 5) < .35)
  end
end
clump(392, 479, 172, 40, 86, -0.5, 13)
clump(430, 479, 178, 24, 54, -0.9, 14)
clump(270, 292, 172, 22, 40, -0.4, 15)
clump(36, 50, 174, 18, 30, 0.5, 16)

-- white heron wading (hero)
do
  local hx, hy = 232, 168   -- feet y
  c:fillMask(c:rect(hx - 9, hy + 1, hx + 9, hy + 1), "#3e7aa8")   -- ripple ring
  for _, lx in ipairs{ hx - 3, hx + 3 } do
    c:fillMask(c:rect(lx - 1, hy - 28, lx + 1, hy), INK); c:fillMask(c:rect(lx, hy - 28, lx, hy), "#6a7a84")
    c:px(lx - 1, hy, INK); c:px(lx + 2, hy, INK)
  end
  local body = mk(); E(body, hx, hy - 38, 12, 9)
  for i = 0, 14 do body:set(hx + 10 + i, hy - 40 + floor(i * .3)) ; body:set(hx + 10 + i, hy - 41 + floor(i * .3)) end -- tail
  body = GX.rough(body, 91, 1)
  GX.lit(c, body, R6(HERON), { R = 8, tex = .3, sc = 3, seed = 91, rimlight = true, amb = .24 })
  local wing = mk(); E(wing, hx + 2, hy - 38, 8, 5); wing = GX.rough(wing, 92, 1)
  GX.lit(c, wing, R6({ hi = "#e8eef0", base = "#b4c0cc", shade = "#8a9ab0", deep = "#5a6a84" }), { R = 4, tex = .3, seed = 93, rimlight = true })
  local neck = mk()
  for y = hy - 66, hy - 42 do local w = 2; local xo = floor(-sin((y - hy) / 7) * 3) - 9; for x = hx + xo - w, hx + xo + w do neck:set(x, y) end end
  neck = GX.rough(neck, 94, 1)
  GX.lit(c, neck, R6(HERON), { R = 3, tex = .2, seed = 95, rimlight = true })
  local hd = mk(); E(hd, hx - 9, hy - 69, 4, 3)
  GX.lit(c, hd, R6(HERON), { R = 3, tex = .1, seed = 96, rimlight = true })
  for k = 0, 11 do c:px(hx - 14 - k, hy - 69 + floor(k * .1), INK); c:px(hx - 14 - k, hy - 69 + (k > 0 and 0 or 0), "#e8a030") end
  c:px(hx - 7, hy - 70, INK)
  for k = 0, 5 do c:px(hx - 6 + k, hy - 74 + k // 3, HERON.deep) end  -- crest plume
end

-- fallen log (bottom-right, small and off the main walking line)
do
  local lg = mk()
  for x = 372, 448 do for y = 246 + floor((x - 372) * .02), 260 + floor((x - 372) * .02) do lg:set(x, y) end end
  lg = GX.rough(lg, 99, 1)
  GX.lit(c, lg, R6(BARK), { R = 7, tex = .5, sc = 2.5, seed = 99, rimlight = true,
    fn = function(x, y) return (GX.vn(x * .12, y * 2, 2, 5) - .5) * .3 end })
  local en = mk(); E(en, 372, 253, 4, 7); GX.lit(c, en, R6({ hi = "#f0d8a0", base = "#d8b078", shade = "#b08458", deep = "#6e4e3a" }), { R = 4, tex = .2, seed = 9, rimlight = true })
  c:px(371, 253, BARK.shade); c:px(372, 253, BARK.shade)
  for x = 390, 430, 10 do c:px(x, 249, GRN1.base); c:px(x + 1, 249, GRN1.hi); c:px(x + 2, 250, GRN1.base) end
  c:fillMask(c:rect(380, 262, 442, 262), "#4a8a40")
end

-- calm bank details (sparse, y>182)
for i = 0, 40 do
  local x, y = 12 + floor(H(i, 61, 1) * 456), 186 + floor(H(i, 63, 1) * 78)
  if not (x > 366 and x < 454 and y > 240) then GX.tuft(c, x, y, y > 230 and { hi = GRASS.base, base = GRASS.shade, shade = GRASS.deep, deep = GRASS.deep } or GRASS) end
end
for i = 0, 9 do GX.flower(c, 20 + floor(H(i, 41, 1) * 440), 190 + floor(H(i, 43, 1) * 60), ({ "#ff9fc0", "#fff4d6", "#ffe38a", "#c9b2f0" })[1 + i % 4]) end
local STO = { hi = "#e8e4d0", base = "#b4b09c", shade = "#7e7a68", deep = "#4a4850" }
for si, s in ipairs{ {140,214,6,3},{290,236,7,3},{60,250,6,2} } do
  local m = mk(); E(m, s[1], s[2], s[3], s[4]); m = GX.rough(m, si + 120, 1)
  GX.lit(c, m, R6(STO), { R = 3, tex = .3, sc = 3, seed = si, rimlight = true })
end

c:save{ aseprite = d.."/out/stage-wetland.aseprite", png = d.."/out/stage-wetland.png", scale = 1 }
