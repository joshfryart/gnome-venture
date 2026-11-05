-- here-stop-herb: Herb garden rest stop, GATE VIEW, hero scale, 480x270 native.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app and app.params and app.params.out) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/places/"
if OUT:sub(-1) ~= "/" then OUT = OUT .. "/" end
local NAME = "here-stop-herb"
local W, H = 480, 270
local VX, VY = 240, 112
local HOR = 104
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, max, min, abs, sin, cos = math.floor, math.max, math.min, math.abs, math.sin, math.cos

---------------------------------------------------------------- helpers
local function P(x, y, col) x, y = floor(x), floor(y) if x >= 0 and y >= 0 and x < W and y < H then c:put(x, y, col) end end
local function R(x0, y0, x1, y1, col) for y = floor(y0), floor(y1) do for x = floor(x0), floor(x1) do P(x, y, col) end end end
local function hs(x, y, s)
  local n = (x * 374761393 + y * 668265263 + (s or 0) * 982451653) & 0x7fffffff
  n = ((n ~ (n >> 13)) * 1274126177) & 0x7fffffff
  n = n ~ (n >> 16)
  return (n % 10007) / 10007
end
local function hx(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
local function rgb(r, g, b)
  local function cl(v) return max(6, min(250, floor(v + .5))) end
  return string.format("#%02x%02x%02x", cl(r), cl(g), cl(b))
end
-- cool-violet shade of what is already there
local function shadeAt(x, y, k)
  local h = c:get(x, y) if not h then return end
  local r, g, b = hx(h)
  P(x, y, rgb(r * k + (1 - k) * 60, g * k + (1 - k) * 40, b * k + (1 - k) * 110))
end
local function glowAt(x, y, k)
  local h = c:get(x, y) if not h then return end
  local r, g, b = hx(h)
  P(x, y, rgb(r + (255 - r) * k, g + (215 - g) * k * .9, b + (120 - b) * k * .5))
end
local function M(m, col) c:fillMask(m, col) end
local function poly(p) return c:poly(p) end
local function rect(a, b, cc, d) return c:rect(a, b, cc, d) end
local function ell(a, b, cc, d) return c:ellipse(a, b, cc, d) end
local function line(p, w) return c:line(p, w) end
-- textured fill: base + darker/lighter flecks
local function tex(m, base, dk, lt, s, dens)
  dens = dens or .18
  m:each(function(x, y)
    local v = hs(x, y, s)
    if v < dens * .5 then P(x, y, dk) elseif v > 1 - dens * .5 then P(x, y, lt) else P(x, y, base) end
  end)
end
-- soft ground shadow ellipse (2-tone, cool)
local function gshadow(cx, cy, rx, ry)
  ell(cx, cy, rx, ry):each(function(x, y) shadeAt(x, y, .78) end)
  ell(cx + 2, cy, floor(rx * .7), max(1, floor(ry * .6))):each(function(x, y) shadeAt(x, y, .88) end)
end
-- recede a point toward the vanishing point
local function rec(p, f) return { p[1] + (VX - p[1]) * f, p[2] + (VY - p[2]) * f } end
local function pathL(y) return VX - 8 - 72 * (y - VY) / 158 end
local function pathR(y) return VX + 8 + 82 * (y - VY) / 158 end

---------------------------------------------------------------- sky (late morning)
c:stripes(0, HOR, { "#86b8dc", "#98c6e2", "#acd3e6", "#c2dee6", "#d8e8e0", "#ecefcf" }, { 3, 3, 3, 3, 2, 2 })
for _, cl in ipairs({ { 70, 42, 46 }, { 150, 26, 34 }, { 300, 36, 52 }, { 392, 52, 40 }, { 220, 60, 28 } }) do
  local m = c:cloud(cl[1], cl[2], cl[3], "#f6f0e2", "#d4d8e6")
  for xx = cl[1] + 2, cl[1] + cl[3] - 3 do if m:has(xx, cl[2] - 1) then P(xx, cl[2] - 1, "#e6e4e4") end end
end
-- far lavender-blue hills
c:terrain(function(x) return 80 + 6 * sin(x / 37) + 4 * sin(x / 13 + 1) end, "#a3afd4", HOR)
c:terrain(function(x) return 84 + 6 * sin(x / 37) + 4 * sin(x / 13 + 1) end, "#97a3cc", HOR)
-- mid green hills with lavender field stripes
local mid = c:terrain(function(x) return 90 + 5 * sin(x / 52 + 2) + 3 * sin(x / 19) end, "#9cc070", HOR)
mid:each(function(x, y)
  if y > 92 and ((x + y * 3) // 7) % 3 == 0 and x > 250 and x < 420 then P(x, y, "#a48ccc") end
  if y > 92 and ((x - y * 2) // 6) % 3 == 0 and x < 200 and x > 30 then P(x, y, "#c8cc6a") end
end)
-- trees on mid hills (lumpy, not round)
for _, t in ipairs({ { 120, 92 }, { 132, 94 }, { 356, 90 }, { 372, 92 }, { 440, 91 }, { 30, 94 } }) do
  local m = ell(t[1], t[2] - 4, 6, 5):add(ell(t[1] + 3, t[2] - 7, 4, 4))
  c:rim(m, "#4a6a48")
  tex(m, "#6e9a5a", "#5a8450", "#86b066", t[1], .3)
  R(t[1], t[2], t[1] + 1, t[2] + 2, "#6a4a3a")
end

---------------------------------------------------------------- ground
local ground = rect(0, HOR, W - 1, H - 1)
ground:each(function(x, y)
  local v = hs(x, y, 7)
  local col = "#98c25c"
  if y < 120 then col = "#a2c662" end
  if v < .07 then col = "#86b04e" elseif v > .94 then col = "#b2d26e" end
  P(x, y, col)
end)
-- grass tufts, bigger nearer
for i = 1, 520 do
  local x = floor(hs(i, 1, 3) * W)
  local y = HOR + 4 + floor(hs(i, 2, 3) ^ .7 * (H - HOR - 6))
  local s = 1 + floor((y - HOR) / 60)
  P(x, y, "#6e9a42") P(x - s, y - s, "#7aa848") P(x + s, y - s, "#7aa848") P(x, y - s - 1, "#8ab452")
  if hs(i, 9, 3) > .93 then P(x, y - s - 2, (i % 2 == 0) and "#f2e6a8" or "#e8a0c0") end
end

-- horizon cottage hedge (bumpy, with flowers)
local hedge = c:terrain(function(x) return 96 + 2 * sin(x / 5) + 2 * sin(x / 11 + 3) end, nil, HOR + 4)
c:rim(hedge, "#3e6034")
hedge:each(function(x, y)
  local v = hs(x, y, 11)
  local col = "#5e8a44"
  if y < 100 then col = "#74a050" end
  if y > HOR + 1 then col = "#4e7a3c" end
  if v < .12 then col = "#4a7238" elseif v > .9 then col = "#86b45c" end
  if v > .985 then col = (x % 3 == 0) and "#f0a0c0" or "#f6e8c0" end
  P(x, y, col)
end)

-- path: flagstones narrowing to the vanishing point
local path = HP.mask()
for y = HOR + 2, H - 1 do
  local yy = max(y, VY)
  local l, r = pathL(yy), pathR(yy)
  if y < VY then l, r = VX - 8 + (VY - y) * .4, VX + 8 - (VY - y) * .4 end
  for x = floor(l), floor(r) do path:set(x, y) end
end
c:rim(path, "#7e9a4a")
M(path, "#9a8466")
do
  local rows, y = {}, HOR + 2
  while y < H do
    local hgt = max(2, floor((y - HOR) * .085 + .5))
    rows[#rows + 1] = { y, y + hgt - 1 }
    y = y + hgt
  end
  for i, rw in ipairs(rows) do
    local hgt = rw[2] - rw[1] + 1
    local yy = max(rw[1], VY)
    local l, r = pathL(yy), pathR(yy)
    if rw[1] < VY then l, r = VX - 8, VX + 8 end
    local sw = max(4, floor(hgt * 2.3))
    local x = l - ((i % 2) * floor(sw / 2))
    local k = 0
    while x < r + 2 do
      k = k + 1
      local v = hs(i, k, 21)
      local base = (v < .3) and "#c9b48e" or (v < .6) and "#d6c29c" or (v < .85) and "#cdb08a" or "#bfb0a0"
      local x0, x1 = floor(x) + 1, floor(x + sw) - 1
      for py = rw[1] + 1, rw[2] do for px = x0, x1 do
        if path:has(px, py) then
          local col = base
          if py == rw[1] + 1 and hgt > 2 then col = "#e6d6b2" end
          if px == x0 and hgt > 2 then col = "#ded0aa" end
          if py == rw[2] and hgt > 3 then col = "#b09a78" end
          if hgt > 4 and hs(px, py, 5) > .93 then col = "#b8a482" end
          P(px, py, col)
        end
      end end
      x = x + sw
    end
  end
end
-- warm sun pool on the path
path:each(function(x, y) if y > 150 and y < 200 and (x - 2 * y) % 97 < 30 and hs(x, y, 4) > .55 then glowAt(x, y, .12) end end)

---------------------------------------------------------------- building helper
-- gable building facing viewer; side face recedes toward the VP.
-- o = {x0,x1,yb,h,rh(roof h),f(recede), wall={dk,base,lt,deep}, roof={dk,base,lt,deep}, ink}
local function building(o)
  local x0, x1, yb, h, rh, f = o.x0, o.x1, o.yb, o.h, o.rh, o.f or .1
  local yt = yb - h
  local cx = (x0 + x1) / 2
  local apex = { cx, yt - rh }
  local leftSide = (x1 < VX) -- building on the left: right side visible
  local eE = leftSide and { x1 + 3, yt + 2 } or { x0 - 3, yt + 2 }
  local bE = leftSide and { x1, yb } or { x0, yb }
  local tE = leftSide and { x1, yt } or { x0, yt }
  local sideWall = poly{ bE, tE, rec(tE, f), rec(bE, f) }
  local roofSide = poly{ apex, eE, rec(eE, f), rec(apex, f) }
  local front = rect(x0, yt, x1, yb)
  local gable = poly{ { x0, yt + 1 }, { cx, apex[2] + 4 }, { x1 + 1, yt + 1 } }
  local roofEdge = line({ { x0 - 4, yt + 3 }, apex, { x1 + 4, yt + 3 } }, 5)
  local all = sideWall:copy():add(roofSide):add(front):add(gable):add(roofEdge)
  gshadow(leftSide and x1 + 4 or x0 - 4, yb + 1, floor((x1 - x0) / 2 + 10), 4)
  c:rim(all, o.ink)
  -- side wall (shade)
  tex(sideWall, o.wall.deep, o.wall.dk, o.wall.deep, x0 + 3, .2)
  -- roof side plane (thatch/tile rows going back)
  roofSide:each(function(x, y)
    local v = hs(x, y, x0)
    local col = o.roof.base
    if (y + floor(x * .2)) % 4 == 0 then col = o.roof.dk end
    if v > .9 then col = o.roof.lt end
    P(x, y, col)
  end)
  -- front wall
  front:add(gable)
  front:each(function(x, y)
    local col = o.wall.base
    local v = hs(x, y, x0 + 1)
    if o.timber and ((x - x0) % 14 == 0 or y == yt + floor(h / 2)) then col = o.timber
    elseif o.stone then
      local row = (y - yt) // 5
      local bx = (x - x0 + (row % 2) * 4) % 9
      if bx == 0 or (y - yt) % 5 == 0 then col = o.wall.dk elseif v > .85 then col = o.wall.lt end
    else
      if v < .08 then col = o.wall.dk elseif v > .9 then col = o.wall.lt end
    end
    if x <= x0 + 1 then col = o.wall.lt end
    if y >= yb - 1 then col = o.wall.dk end
    P(x, y, col)
  end)
  -- under-eave shade
  for y = yt + 1, yt + 3 do for x = x0, x1 do shadeAt(x, y, .8) end end
  gable:each(function(x, y) if y > apex[2] + 4 and y < yt + 1 then shadeAt(x, y, .88) end end)
  -- roof edge (barge band) with lit left slope
  roofEdge:each(function(x, y)
    local col = (x < cx) and o.roof.lt or o.roof.base
    if hs(x, y, 3) > .8 then col = o.roof.dk end
    P(x, y, col)
  end)
  line({ { x0 - 4, yt + 5 }, { cx, apex[2] + 2 }, { x1 + 4, yt + 5 } }, 1):each(function(x, y) P(x, y, o.roof.dk) end)
  return { yt = yt, apex = apex, cx = cx }
end
local function window(x0, y0, w, h, frame, ink, lit)
  local m = rect(x0, y0, x0 + w - 1, y0 + h - 1)
  c:rim(m, ink)
  M(m, frame)
  local g = rect(x0 + 1, y0 + 1, x0 + w - 2, y0 + h - 2)
  g:each(function(x, y)
    local col = lit and "#f6cc6a" or "#9ccadc"
    if (y - y0) < h / 2 and lit then col = "#fbe29a" end
    if not lit and (x - y) % 7 == 0 then col = "#d6eeee" end
    P(x, y, col)
  end)
  R(x0 + floor(w / 2), y0 + 1, x0 + floor(w / 2), y0 + h - 2, frame)
  R(x0 + 1, y0 + floor(h / 2), x0 + w - 2, y0 + floor(h / 2), frame)
  R(x0 - 1, y0 + h, x0 + w, y0 + h + 1, "#c9a070") -- sill
  P(x0 - 1, y0 + h + 1, "#8a6040")
end
local function door(x0, y0, w, h, col, dk, ink)
  local m = rect(x0, y0, x0 + w - 1, y0 + h - 1)
  c:rim(m, ink)
  m:each(function(x, y)
    local cc = col
    if (x - x0) % 4 == 3 then cc = dk end
    if y == y0 or y == y0 + 1 then cc = dk end
    P(x, y, cc)
  end)
  R(x0 + w - 3, y0 + floor(h / 2), x0 + w - 2, y0 + floor(h / 2), "#f0c060")
end
-- small icon sign board on a post / bracket
local function signBoard(x0, y0, w, h, bg, ink)
  local m = rect(x0, y0, x0 + w - 1, y0 + h - 1)
  c:rim(m, ink)
  M(m, bg)
  R(x0, y0, x0 + w - 1, y0, "#f2dcb0")
  R(x0, y0 + h - 1, x0 + w - 1, y0 + h - 1, "#8a5a3c")
  return m
end

---------------------------------------------------------------- HOMES (left far)
local woodInk = "#3e2620"
-- cottage 1: thatched, cream timber
local b1 = building{ x0 = 26, x1 = 80, yb = 128, h = 32, rh = 30, f = .1, ink = "#4a3438",
  wall = { dk = "#b49c84", base = "#e2d0aa", lt = "#f2e4c4", deep = "#9a8494" }, timber = "#7a5038",
  roof = { dk = "#9a7034", base = "#c69a4c", lt = "#e6c26a", deep = "#7a5430" } }
window(33, 106, 12, 10, "#7a5038", woodInk, true)
door(55, 108, 11, 20, "#5a8a9a", "#46707e", "#2e3e4a")
window(70, 107, 8, 9, "#7a5038", woodInk, false)
-- chimney with smoke puffs
do
  local ch = rect(36, 68, 43, 84)
  c:rim(ch, "#4a3438")
  ch:each(function(x, y) P(x, y, ((x + (y // 3) * 2) % 5 == 0 or y % 3 == 0) and "#8a5a4a" or "#b06a50") end)
  R(35, 67, 44, 68, "#6a4a40")
  for i, p in ipairs({ { 40, 60, 4 }, { 45, 52, 5 }, { 52, 44, 6 } }) do
    local m = ell(p[1], p[2], p[3], p[3] - 1)
    M(m, (i % 2 == 0) and "#e6e8ec" or "#d8dce6")
    R(p[1] - 1, p[2] - p[3] + 2, p[1], p[2] - p[3] + 2, "#f4f2ee")
  end
end
-- climbing roses on cottage 1 front
for i = 0, 26 do
  local x, y = 27 + floor(hs(i, 1, 44) * 6), 96 + i
  P(x, y, "#4e8a3c") if i % 4 == 0 then P(x + 1, y, "#e85a78") P(x + 1, y - 1, "#f48aa0") end
end
-- homes icon sign: a little house-shaped board on a bracket
do
  R(82, 99, 92, 100, woodInk)
  R(90, 101, 90, 103, "#8a6040")
  local m = poly{ { 84, 110 }, { 84, 106 }, { 90, 102 }, { 96, 106 }, { 96, 110 } }
  c:rim(m, woodInk) M(m, "#f2dcb0")
  R(89, 107, 91, 110, "#c05a3a")
end
-- cottage 2: small red-tiled hut, stone
local b2 = building{ x0 = 108, x1 = 146, yb = 124, h = 24, rh = 22, f = .08, ink = "#3e3048",
  wall = { dk = "#8a8494", base = "#b8b2bc", lt = "#d8d2d4", deep = "#7a7090" }, stone = true,
  roof = { dk = "#8e3a3a", base = "#c0563e", lt = "#e27a52", deep = "#6a2a34" } }
window(114, 106, 9, 8, "#6b4232", woodInk, true)
door(129, 108, 10, 16, "#a8744a", "#8a5a3c", woodInk)
-- boot planter quirk by the hut door
do
  local m = poly{ { 140, 124 }, { 140, 116 }, { 145, 116 }, { 145, 121 }, { 151, 121 }, { 151, 124 } }
  c:rim(m, "#2e2a3a") M(m, "#5a4a3a") R(140, 116, 145, 116, "#7a6450") R(146, 121, 151, 121, "#7a6450")
  for i = 0, 4 do P(141 + i, 115 - (i % 2), "#5aa040") P(141 + i, 114 - (i % 3), "#78c050") end
  P(143, 112, "#f0c040") P(141, 113, "#e85a78")
end
-- picket fence piece between homes
for x = 96, 104, 3 do R(x, 116, x + 1, 127, "#ece2cc") P(x, 116, "#c8bca8") R(x + 1, 118, x + 1, 127, "#b8ac9a") end
R(95, 120, 105, 120, "#c8bca8")

---------------------------------------------------------------- copper still (prop, left mid)
do
  gshadow(190, 152, 22, 4)
  local fire = rect(174, 132, 204, 151)
  local pot = ell(189, 118, 14, 15):add(rect(184, 98, 194, 104))
  local neck = line({ { 194, 99 }, { 202, 95 }, { 208, 98 }, { 211, 108 } }, 3)
  local barrel = rect(204, 110, 216, 140)
  local all = fire:copy():add(pot):add(neck):add(barrel)
  c:rim(all, "#3a2224")
  -- brick firebox
  fire:each(function(x, y)
    local row = (y - 132) // 4
    local col = ((x - 174 + (row % 2) * 3) % 7 == 0 or (y - 132) % 4 == 0) and "#7a4a44" or "#b8664a"
    if hs(x, y, 9) > .9 then col = "#cc7a58" end
    P(x, y, col)
  end)
  local mouth = rect(182, 140, 196, 150)
  M(mouth, "#3a2224")
  rect(183, 143, 195, 150):each(function(x, y)
    local v = hs(x, y, 2)
    P(x, y, (y > 147) and "#f8d060" or (v > .5 and "#f08a30" or "#e05a2a"))
  end)
  -- copper pot, lit from upper left
  local cu = { "#4a2620", "#7a3a28", "#b0583a", "#d87e4a", "#f0aa6a", "#fbd8a0" }
  pot:each(function(x, y)
    local d = ((x - 183) ^ 2 + (y - 110) ^ 2) ^ .5
    local i = 6 - min(5, floor(d / 4.2))
    if i < 2 then i = 2 end
    if (y - 104) % 6 == 0 and y > 104 then i = max(2, i - 1) end
    P(x, y, cu[i])
  end)
  M(c:rect(181, 107, 182, 109), "#fdeacc")
  -- rivets band
  for x = 177, 201, 4 do P(x, 124, "#7a3a28") end
  neck:each(function(x, y) P(x, y, (y < 98) and "#f0aa6a" or "#b0583a") end)
  -- coil barrel (wood, hooped)
  barrel:each(function(x, y)
    local col = ((x - 204) % 4 == 0) and "#6b4232" or "#a8744a"
    if x == 205 then col = "#c9955e" end
    if y == 116 or y == 117 or y == 132 or y == 133 then col = "#5a5468" end
    P(x, y, col)
  end)
  R(217, 136, 219, 137, "#b0583a") P(219, 138, "#9ccadc") -- tap + drip
  -- quirk: a teapot used as the still's hat
  local tp = ell(189, 93, 6, 4):add(rect(186, 87, 192, 89))
  local spout = line({ { 195, 93 }, { 199, 89 } }, 2)
  c:rim(tp:copy():add(spout), "#3a2a4a")
  M(tp, "#7aa0d8") R(184, 91, 186, 92, "#a8c4ec") M(spout, "#5a80b8")
  R(188, 85, 190, 86, "#f0c060")
  for x = 185, 193, 2 do P(x, 95, "#f2ecf6") end
end

---------------------------------------------------------------- GLASSHOUSE (right far, prop)
do
  local x0, x1, yb, h, rh = 274, 364, 114, 30, 22
  local yt = yb - h
  local cx = (x0 + x1) / 2
  gshadow(cx - 8, yb + 1, 52, 4)
  local side = poly{ { x0, yb }, { x0, yt }, rec({ x0, yt }, .12), rec({ x0, yb }, .12) }
  local roofS = poly{ { cx, yt - rh }, { x0 - 2, yt + 1 }, rec({ x0 - 2, yt + 1 }, .12), rec({ cx, yt - rh }, .12) }
  local front = rect(x0, yt, x1, yb):add(poly{ { x0, yt + 1 }, { cx, yt - rh }, { x1 + 1, yt + 1 } })
  local base = rect(x0, yb - 6, x1, yb)
  local all = side:copy():add(roofS):add(front)
  c:rim(all, "#2e4a44")
  local frame, frameLt = "#4e7a66", "#7eaa8a"
  local function glass(m, s, dim)
    m:each(function(x, y)
      local col = dim and "#86b8c0" or "#a8dad4"
      local v = (x + y * .6)
      if v % 23 < 3 then col = dim and "#b6dcd8" or "#e2f4ec" end
      if y > yb - 16 and y < yb - 6 then
        local hh = hs(x // 3, 0, s) * 8
        if y > yb - 8 - hh then col = (hs(x, y, s) > .8) and "#d84a4a" or ((x // 3) % 2 == 0 and "#5a9a48" or "#78b858") end
      end
      P(x, y, col)
    end)
  end
  glass(side, 3, true)
  glass(roofS, 4, true)
  glass(front, 5, false)
  -- frames
  for x = x0, x1, 10 do front:each(function(px, py) if px == x then P(px, py, frame) end end) end
  for y = yt, yb, 8 do front:each(function(px, py) if py == y then P(px, py, frame) end end) end
  line({ { x0 - 2, yt + 1 }, { cx, yt - rh }, { x1 + 2, yt + 1 } }, 2):each(function(x, y) P(x, y, (x < cx) and frameLt or frame) end)
  side:edge():each(function(x, y) P(x, y, frame) end)
  roofS:edge():each(function(x, y) P(x, y, frame) end)
  -- brick plinth
  base:each(function(x, y) P(x, y, ((x + (y % 2) * 2) % 5 == 0 or y == yb - 6) and "#7a4a44" or "#b8664a") end)
  -- door
  door(cx - 6, yb - 20, 12, 14, "#4e7a66", "#3e6656", "#2e4a44")
  R(cx - 4, yb - 18, cx + 3, yb - 12, "#c6ecdc")
  -- quirk: leaf-shaped weathervane
  R(cx, yt - rh - 12, cx, yt - rh - 1, "#3a3a4a")
  local leaf = poly{ { cx - 9, yt - rh - 8 }, { cx - 3, yt - rh - 12 }, { cx + 5, yt - rh - 10 }, { cx - 3, yt - rh - 6 } }
  c:rim(leaf, "#2e4a2a") M(leaf, "#78c050") R(cx - 7, yt - rh - 9, cx + 3, yt - rh - 9, "#4e8a3c")
  P(cx - 5, yt - rh - 11, "#b8e880")
end

---------------------------------------------------------------- WILD TRAIL (right edge, hedge arch)
do
  local hedgeM = rect(396, 100, 466, 176):cut(poly{ { 412, 177 }, { 412, 134 }, { 420, 120 }, { 434, 115 }, { 448, 120 }, { 456, 134 }, { 456, 177 } })
  gshadow(430, 177, 40, 4)
  local outer = HP.mask()
  hedgeM:each(function(x, y)
    if y > 100 + 4 * sin(x / 6) + 3 then outer:set(x, y) end
  end)
  c:rim(outer, "#2e4a2e")
  outer:each(function(x, y)
    local v = hs(x, y, 31)
    local col = "#4e8040"
    if ((x // 5) + (y // 4)) % 3 == 0 then col = "#5e9048" end
    if x < 404 or y < 112 then col = "#6ea050" end
    if v < .15 then col = "#3e6a36" elseif v > .9 then col = "#7cb05a" end
    P(x, y, col)
  end)
  -- dark wild path beyond the arch, with far pines
  local gap = poly{ { 413, 177 }, { 413, 134 }, { 420, 121 }, { 434, 116 }, { 448, 121 }, { 455, 134 }, { 455, 177 } }
  gap:each(function(x, y)
    local col = (y < 150) and "#3e5a5a" or "#4a6a48"
    if y > 150 and abs(x - (440 + (y - 150) * -.4)) < (y - 145) * .45 then col = "#b0946a" end
    P(x, y, col)
  end)
  for _, t in ipairs({ { 420, 148 }, { 446, 146 }, { 433, 140 } }) do
    poly{ { t[1] - 6, t[2] }, { t[1], t[2] - 18 }, { t[1] + 6, t[2] } }:each(function(x, y) P(x, y, (x < t[1]) and "#2e6a4e" or "#24544a") end)
    R(t[1], t[2], t[1], t[2] + 3, "#4a3030")
  end
  -- willow arch band over the opening
  local arch = line({ { 410, 176 }, { 410, 134 }, { 418, 119 }, { 434, 113 }, { 450, 119 }, { 458, 134 }, { 458, 176 } }, 4)
  c:rim(arch, "#3e2620")
  arch:each(function(x, y) P(x, y, ((x + y) % 4 < 2) and "#b08048" or "#8a6038") end)
  for i, p in ipairs({ { 412, 130 }, { 424, 116 }, { 444, 116 }, { 456, 128 } }) do
    P(p[1], p[2], (i % 2 == 0) and "#f6e8c0" or "#f0a0c0") P(p[1] + 1, p[2] - 1, "#f8d060")
  end
  -- signpost: arrow pointing right with a pine icon
  local post = rect(399, 138, 402, 178)
  c:rim(post, woodInk) M(post, "#8a5a3c") R(399, 138, 399, 178, "#a8744a")
  local arrow = poly{ { 390, 140 }, { 410, 140 }, { 416, 146 }, { 410, 152 }, { 390, 152 } }
  c:rim(arrow, woodInk) M(arrow, "#d6b070") R(390, 140, 409, 140, "#f0d49a") R(391, 151, 410, 151, "#a8804a")
  poly{ { 396, 150 }, { 400, 142 }, { 404, 150 } }:each(function(x, y) P(x, y, "#2e6a4e") end)
  P(400, 151, "#4a3030")
end

---------------------------------------------------------------- STOP: signpost + stamp post + notice board
do
  gshadow(316, 179, 32, 4)
  local post = rect(288, 124, 292, 178)
  local arms = poly{ { 278, 128 }, { 300, 128 }, { 304, 132 }, { 300, 136 }, { 278, 136 } }
    :add(poly{ { 302, 140 }, { 280, 140 }, { 276, 144 }, { 280, 148 }, { 302, 148 } })
  local stamp = rect(284, 154, 296, 166)
  local board = rect(304, 134, 344, 162)
  local roof = poly{ { 300, 134 }, { 324, 124 }, { 348, 134 } }
  local legs = rect(307, 162, 310, 178):add(rect(338, 162, 341, 178))
  local all = post:copy():add(arms):add(stamp):add(board):add(roof):add(legs)
  c:rim(all, "#3a2224")
  M(post, "#8a5a3c") R(288, 124, 288, 178, "#b08050")
  R(287, 121, 293, 123, "#6a4232") -- cap
  arms:each(function(x, y) P(x, y, ((y == 128) or (y == 140)) and "#f6dc9a" or "#e2b858") end)
  R(282, 131, 296, 132, "#c08a3a") R(283, 143, 298, 144, "#c08a3a")
  -- stamp box (red) with a stamp icon
  stamp:each(function(x, y) P(x, y, (x == 284 or y == 154) and "#e2725a" or "#c0443a") end)
  R(288, 156, 292, 158, "#f6dcb0") R(289, 159, 291, 160, "#f6dcb0") R(287, 161, 293, 163, "#f6dcb0")
  -- notice board: cork with pinned papers
  legs:each(function(x, y) P(x, y, "#6b4232") end)
  roof:each(function(x, y) P(x, y, (x < 324) and "#e27a52" or "#c0563e") end)
  line({ { 300, 134 }, { 324, 124 }, { 348, 134 } }, 1):each(function(x, y) P(x, y, "#8e3a3a") end)
  board:each(function(x, y)
    local col = "#c48a50"
    if x <= 305 or x >= 343 or y <= 135 or y >= 161 then col = "#7a5038" end
    if col == "#c48a50" and hs(x, y, 13) > .85 then col = "#b07a44" end
    P(x, y, col)
  end)
  for _, pp in ipairs({ { 308, 138, 10, 9, "#f4ecd8" }, { 321, 137, 9, 12, "#bde0f0" }, { 332, 139, 8, 8, "#f6d8e0" },
                        { 310, 150, 9, 8, "#f2e8a8" }, { 323, 152, 14, 7, "#d6eecc" } }) do
    R(pp[1], pp[2], pp[1] + pp[3] - 1, pp[2] + pp[4] - 1, pp[5])
    for yy = pp[2] + 3, pp[2] + pp[4] - 2, 2 do R(pp[1] + 1, yy, pp[1] + pp[3] - 3, yy, "#9a8aa0") end
    R(pp[1] + pp[3] - 1, pp[2] + 1, pp[1] + pp[3] - 1, pp[2] + pp[4] - 1, "#8a7a8a")
    P(pp[1] + floor(pp[3] / 2), pp[2], "#d84a4a")
  end
  -- a leaf sketch on one paper (map of herbs)
  P(325, 141, "#4e8a3c") P(326, 140, "#4e8a3c") P(327, 141, "#4e8a3c") P(326, 142, "#4e8a3c")
end

---------------------------------------------------------------- DO: drying racks + raised herb beds
-- drying rack (A-frames with two poles of hanging bundles)
local bundleCols = { { "#4e8a3c", "#78c050" }, { "#6a4ea0", "#a888dc" }, { "#c8902a", "#f0c040" }, { "#6a8a70", "#a8c4a8" }, { "#a0405a", "#d87090" } }
do
  gshadow(88, 180, 66, 5)
  local frame = HP.mask()
  for _, xx in ipairs({ 26, 150 }) do
    frame:add(line({ { xx - 8, 178 }, { xx, 140 } }, 3)):add(line({ { xx + 8, 178 }, { xx, 140 } }, 3))
  end
  local pole1 = rect(22, 141, 154, 143)
  local bundles = {}
  local bm = HP.mask()
  for i = 0, 10 do
    local bx = 34 + i * 11
    local len = 16 + floor(hs(i, 1, 61) * 8)
    local m = poly{ { bx - 1, 144 }, { bx + 1, 144 }, { bx + 5, 144 + len }, { bx - 5, 144 + len } }
    bundles[#bundles + 1] = { m = m, i = i, bx = bx, len = len }
    bm:add(m)
  end
  local sign = rect(78, 128, 98, 139)
  c:rim(frame:copy():add(pole1):add(bm):add(sign), "#3a2224")
  frame:each(function(x, y) P(x, y, ((x + y) % 5 == 0) and "#6b4232" or "#a8744a") end)
  pole1:each(function(x, y) P(x, y, (y == 141) and "#c9955e" or "#8a5a3c") end)
  for _, b in ipairs(bundles) do
    local cc = bundleCols[(b.i % #bundleCols) + 1]
    b.m:each(function(x, y)
      local col = cc[1]
      if (x < b.bx) and ((x + y) % 3 ~= 0) then col = cc[2] end
      if hs(x, y, b.i) > .82 then col = cc[2] end
      if y >= 144 + b.len - 1 then col = cc[1] end
      P(x, y, col)
    end)
    R(b.bx - 1, 145, b.bx + 1, 146, "#e8d8a8") -- twine tie
    P(b.bx, 144 + b.len + 1, cc[1])
  end
  -- quirk: watering can hung from the rack end
  local can = rect(140, 150, 150, 160):add(line({ { 150, 152 }, { 156, 148 } }, 2))
  c:rim(can, "#2e3e4a") M(can, "#7aa8b8") R(140, 150, 141, 160, "#a8d0dc") R(144, 146, 146, 149, "#5a7a8a")
  -- 'do' sign: hanging board with a leaf icon
  R(84, 126, 84, 127, "#3a2224") R(92, 126, 92, 127, "#3a2224")
  signBoard(78, 128, 21, 12, "#f2dcb0", "#3a2224")
  local lf = poly{ { 82, 137 }, { 86, 131 }, { 93, 130 }, { 92, 134 }, { 85, 138 } }
  M(lf, "#4e9a3c") line({ { 83, 137 }, { 91, 131 } }, 1):each(function(x, y) P(x, y, "#2e6a2a") end)
end
-- raised beds
local function bed(y0, y1, x0, x1, plant, s)
  local soilT = rect(x0, y0, x1, y0 + 6)
  local frontF = rect(x0, y0 + 7, x1, y1)
  local endF = poly{ { x1 + 1, y0 }, { x1 + 1, y1 }, { x1 + 5, y1 - 3 }, { x1 + 5, y0 - 2 } }
  gshadow((x0 + x1) / 2 + 4, y1 + 2, floor((x1 - x0) / 2) + 6, 3)
  c:rim(soilT:copy():add(frontF):add(endF), "#3a2224")
  soilT:each(function(x, y) P(x, y, (hs(x, y, s) > .8) and "#8a5a3a" or ((y - y0) % 3 == 0 and "#4a3028" or "#6a4430")) end)
  frontF:each(function(x, y)
    local col = "#a8744a"
    if (y - y0 - 7) % 5 == 0 then col = "#6b4232" end
    if (y - y0 - 7) % 5 == 1 then col = "#c9955e" end
    if hs(x, y, s + 1) > .93 then col = "#8a5a3c" end
    if (x - x0) % 40 == 0 then col = "#6b4232" end
    P(x, y, col)
  end)
  endF:each(function(x, y) P(x, y, "#7a4a34") end)
  -- plant clumps in rows
  local x = x0 + 4
  local k = 0
  while x < x1 - 6 do
    k = k + 1
    plant(x, y0 + 4, k)
    x = x + 11
  end
end
local function clumpMask(x, y, w, hgt)
  return poly{ { x - w, y + 1 }, { x - w + 1, y - hgt + 3 }, { x - 1, y - hgt }, { x + 2, y - hgt + 1 }, { x + w, y - hgt + 4 }, { x + w, y + 1 } }
end
local function lavender(x, y, k)
  local m = clumpMask(x, y, 5, 9)
  c:rim(m, "#2e4a3a")
  m:each(function(px, py) P(px, py, ((px + py) % 3 == 0) and "#5a8a6a" or "#86ac8a") end)
  for i = -3, 3, 2 do
    local top = y - 14 - (i % 3)
    R(x + i, top, x + i, y - 6, "#6a8a5a")
    R(x + i, top - 1, x + i, top + 4, "#8a6acc") P(x + i, top - 1, "#b89ae8") P(x + i - 1, top + 2, "#6a4ea0")
  end
end
local function marigoldBasil(x, y, k)
  local m = clumpMask(x, y, 5, 8)
  c:rim(m, "#244a24")
  m:each(function(px, py) P(px, py, (hs(px, py, k) > .55) and "#5aa040" or "#3e8030") end)
  P(x - 2, y - 6, "#9ad86a") P(x - 3, y - 4, "#9ad86a")
  if k % 2 == 0 then
    for _, d in ipairs({ { -2, -9 }, { 2, -8 } }) do
      local fx, fy = x + d[1], y + d[2]
      R(fx - 1, fy - 1, fx + 1, fy + 1, "#f0a028") P(fx, fy, "#c86a1a") P(fx - 1, fy - 1, "#f8d060")
      P(fx, fy - 2, "#f0a028") P(fx, fy + 2, "#f0a028") P(fx - 2, fy, "#f0a028") P(fx + 2, fy, "#e08a20")
    end
  end
end
local function sageChive(x, y, k)
  local m = clumpMask(x, y, 5, 8)
  c:rim(m, "#3a4a44")
  m:each(function(px, py) P(px, py, (hs(px, py, k + 9) > .5) and "#a8c4a8" or "#7fa08a") end)
  if k % 2 == 1 then
    for i = -2, 2, 2 do R(x + i, y - 13, x + i, y - 6, "#4e8a3c") R(x + i - 1, y - 15, x + i + 1, y - 13, "#c870b0") P(x + i, y - 15, "#e8a0d8") end
  else
    R(x - 2, y - 10, x - 1, y - 9, "#e04a3a") R(x + 2, y - 9, x + 3, y - 8, "#f08a2a") P(x - 2, y - 10, "#f8a070")
  end
end
bed(184, 200, 18, 170, lavender, 71)
bed(207, 224, 18, 164, marigoldBasil, 72)
-- quirk: giant mint escaping the front bed (drawn with bed 3)
bed(231, 252, 18, 152, sageChive, 73)
do
  local stem = line({ { 132, 235 }, { 138, 222 }, { 146, 212 } }, 2)
  local l1 = poly{ { 138, 222 }, { 128, 214 }, { 126, 206 }, { 136, 212 } }
  local l2 = poly{ { 146, 212 }, { 154, 202 }, { 163, 200 }, { 156, 210 } }
  local l3 = poly{ { 146, 212 }, { 140, 200 }, { 144, 192 }, { 149, 203 } }
  local all = stem:copy():add(l1):add(l2):add(l3)
  c:rim(all, "#1e4a2a")
  M(stem, "#4e8a3c")
  for i, l in ipairs({ l1, l2, l3 }) do l:each(function(x, y) P(x, y, ((x + y + i) % 4 == 0) and "#5ab060" or "#7ad07a") end) end
  P(128, 208, "#b8f0a8") P(156, 203, "#b8f0a8") P(143, 195, "#b8f0a8")
end

---------------------------------------------------------------- PEOPLE: table, benches, fire pit with kettle
do
  -- warm glow on the ground around the fire
  ell(430, 218, 34, 12):each(function(x, y) glowAt(x, y, .16) end)
  ell(430, 218, 22, 8):each(function(x, y) glowAt(x, y, .12) end)
  gshadow(368, 222, 40, 5)
  -- back bench
  local bb = rect(340, 192, 400, 195):add(rect(344, 196, 346, 202)):add(rect(394, 196, 396, 202))
  -- table
  local top = poly{ { 334, 203 }, { 404, 203 }, { 408, 210 }, { 330, 210 } }
  local tlegs = rect(336, 211, 339, 222):add(rect(398, 211, 401, 222))
  -- front bench
  local fb = rect(328, 222, 410, 225):add(rect(332, 226, 334, 228)):add(rect(404, 226, 406, 228))
  c:rim(bb:copy():add(top):add(tlegs):add(fb), "#3e2620")
  bb:each(function(x, y) P(x, y, (y == 192) and "#d6a468" or "#9a6440") end)
  tlegs:each(function(x, y) P(x, y, "#6b4232") end)
  top:each(function(x, y)
    local col = "#c48a50"
    if y == 203 then col = "#e6b878" end
    if y >= 209 then col = "#8a5a3c" end
    if (x * 3 + y) % 17 == 0 then col = "#a8744a" end
    P(x, y, col)
  end)
  -- checked cloth runner
  for y = 204, 208 do for x = 352, 382 do
    if ((x // 3) + (y // 2)) % 2 == 0 then P(x, y, "#d85a5a") else P(x, y, "#f2e2d0") end
  end end
  fb:each(function(x, y) P(x, y, (y == 222) and "#d6a468" or "#9a6440") end)
  -- teapot + cups on the table
  local pot = ell(366, 199, 5, 4):add(rect(364, 194, 368, 195))
  local cup1 = rect(346, 199, 350, 203)
  local cup2 = rect(386, 199, 390, 203)
  local jar = rect(374, 195, 379, 203)
  c:rim(pot:copy():add(cup1):add(cup2):add(jar), "#3a2a4a")
  M(pot, "#e88a5a") R(362, 197, 364, 198, "#f8b888") line({ { 371, 199 }, { 374, 196 } }, 1):each(function(x, y) P(x, y, "#c0663a") end)
  M(cup1, "#f2ecf6") R(346, 199, 350, 199, "#9a6440")
  M(cup2, "#a8d0ec") R(386, 199, 390, 199, "#9a6440")
  M(jar, "#f8c040") R(374, 195, 379, 196, "#e8e0d8") R(375, 198, 375, 202, "#fbe29a")
  -- steam wisps
  for i = 0, 3 do P(366 + (i % 2), 189 - i * 2, "#f0f0f4") end
  -- fire pit: stone ring, logs, flames, tripod + kettle (quirk: whistling kettle with a sprig in the spout)
  local ring = ell(432, 220, 16, 6)
  local inner = ell(432, 219, 11, 3)
  local tri = line({ { 420, 222 }, { 432, 194 } }, 2):add(line({ { 444, 222 }, { 432, 194 } }, 2))
  local kettle = ell(432, 206, 6, 5):add(rect(429, 199, 435, 201))
  c:rim(ring:copy():add(tri):add(kettle), "#2e2a3a")
  ring:each(function(x, y)
    local seg = (x // 5 + y // 3) % 2
    local col = seg == 0 and "#aaa4ae" or "#8a8494"
    if y <= 216 then col = "#c8c2c4" end
    P(x, y, col)
  end)
  M(inner, "#4a3028")
  local flame = poly{ { 424, 220 }, { 427, 210 }, { 430, 214 }, { 432, 204 }, { 435, 213 }, { 438, 209 }, { 440, 220 } }
  flame:each(function(x, y)
    local col = "#e05a2a"
    if y > 213 and abs(x - 432) < 5 then col = "#f8d060" elseif abs(x - 432) < 4 then col = "#f08a30" end
    P(x, y, col)
  end)
  tri:each(function(x, y) P(x, y, "#5a5468") end)
  M(kettle, "#5a6e8a") R(427, 203, 429, 205, "#8aa4c4") R(431, 197, 433, 198, "#2e2a3a")
  local spout = line({ { 438, 206 }, { 442, 201 } }, 2)
  M(spout, "#4a5a74")
  P(443, 199, "#5aa040") P(444, 198, "#78c050") P(442, 198, "#78c050")
  -- 'people' sign: post with a hanging board showing a mug icon
  local sp = rect(452, 182, 454, 228)
  local arm = rect(440, 182, 454, 184)
  c:rim(sp:copy():add(arm), "#3e2620")
  M(sp, "#8a5a3c") M(arm, "#a8744a")
  R(442, 185, 442, 186, "#3e2620") R(450, 185, 450, 186, "#3e2620")
  signBoard(438, 187, 15, 12, "#f2dcb0", "#3e2620")
  R(442, 190, 447, 196, "#d85a5a") R(448, 191, 449, 194, "#d85a5a") P(448, 192, "#f2dcb0") P(448, 193, "#f2dcb0")
  R(442, 190, 447, 190, "#f8a090")
  -- two bee-skep style straw hives quirk -> replaced by herb pots by the bench
  for i, px in ipairs({ 414, 420 }) do
    local m = poly{ { px - 3, 228 }, { px - 4, 222 }, { px + 4, 222 }, { px + 3, 228 } }
    c:rim(m, "#3a2224") M(m, "#c0663a") R(px - 4, 222, px + 4, 222, "#e08a5a")
    P(px - 1, 220, "#5aa040") P(px, 219, "#78c050") P(px + 1, 220, "#5aa040") P(px, 218, (i == 1) and "#c870b0" or "#f0c040")
  end
end

---------------------------------------------------------------- GATE FRAME: rustic posts, beam, vines, lantern, herb charm
do
  local postL = rect(0, 0, 13, H - 1)
  local postR = rect(466, 0, W - 1, H - 1)
  local beam = rect(0, 0, W - 1, 11)
  local all = postL:copy():add(postR):add(beam)
  c:rim(all, "#3e2620")
  local function wood(m, s)
    m:each(function(x, y)
      local col = "#8a5a3c"
      local vert = (y > 11)
      local g = vert and x or y
      local along = vert and y or x
      if (g * 7 + floor(along / 9)) % 6 == 0 then col = "#6b4232" end
      if hs(x // (vert and 1 or 6), y // (vert and 6 or 1), s) > .85 then col = "#a8744a" end
      P(x, y, col)
    end)
  end
  wood(postL, 1) wood(postR, 2) wood(beam, 3)
  R(0, 0, W - 1, 0, "#c9955e") R(0, 11, W - 1, 11, "#5a3a2c")
  R(1, 12, 1, H - 1, "#c9955e") R(467, 12, 467, H - 1, "#a8744a")
  R(12, 12, 13, H - 1, "#5a3a2c") R(478, 12, 479, H - 1, "#5a3a2c")
  -- bolts
  for _, p in ipairs({ { 6, 5 }, { 472, 5 }, { 120, 5 }, { 240, 5 }, { 360, 5 } }) do R(p[1], p[2], p[1] + 1, p[2] + 1, "#5a5468") P(p[1], p[2], "#aaa4ae") end
  -- vines winding round posts and along the beam (leaves)
  local function leafAt(x, y, flip, s)
    local d = flip and -1 or 1
    local m = poly{ { x, y }, { x + 3 * d, y - 2 }, { x + 6 * d, y }, { x + 3 * d, y + 2 } }
    c:rim(m, "#244a24")
    M(m, (hs(x, y, s) > .5) and "#5aa040" or "#4e8a3c")
    P(x + 2 * d, y - 1, "#9ad86a")
  end
  for y = 18, H - 6, 9 do
    local x = 6 + floor(4 * sin(y / 9))
    R(x, y, x, y + 8, "#3e6a2e")
    if y % 18 == 0 then leafAt(x + 1, y + 2, false, 1) else leafAt(x - 1, y + 4, true, 2) end
    local x2 = 472 + floor(4 * sin(y / 9 + 2))
    if y < 225 or y > 268 then
      R(x2, y, x2, y + 8, "#3e6a2e")
      if y % 18 == 0 then leafAt(x2 - 1, y + 2, true, 3) else leafAt(x2 + 1, y + 4, false, 4) end
    end
  end
  for x = 16, 462, 7 do
    local y = 13 + floor(2 * sin(x / 11))
    R(x, y, x + 6, y, "#3e6a2e")
    if (x // 7) % 2 == 0 then leafAt(x + 2, y + 2, false, 5) end
  end
  -- hanging herb bundles along the beam
  for i, bx in ipairs({ 112, 168, 312, 368 }) do
    local cc = bundleCols[(i % #bundleCols) + 1]
    local m = poly{ { bx - 1, 18 }, { bx + 1, 18 }, { bx + 5, 32 }, { bx - 5, 32 } }
    R(bx, 12, bx, 17, "#e8d8a8")
    c:rim(m, "#3a2224")
    m:each(function(x, y) P(x, y, (x < bx and (x + y) % 3 ~= 0) and cc[2] or cc[1]) end)
    R(bx - 1, 19, bx + 1, 20, "#e8d8a8")
  end
  -- copper lantern hanging left
  do
    local lx = 48
    R(lx, 12, lx, 19, "#3a3a4a")
    local cap = poly{ { lx - 6, 25 }, { lx, 19 }, { lx + 6, 25 } }
    local body = rect(lx - 5, 25, lx + 5, 38)
    local base = rect(lx - 6, 39, lx + 6, 41)
    c:rim(cap:copy():add(body):add(base), "#3a2224")
    M(cap, "#b0583a") line({ { lx - 5, 25 }, { lx, 20 } }, 1):each(function(x, y) P(x, y, "#f0aa6a") end)
    M(base, "#7a3a28") R(lx - 6, 39, lx + 6, 39, "#d87e4a")
    body:each(function(x, y)
      local col = (x == lx - 5 or x == lx + 5 or x == lx) and "#7a3a28" or ((y < 31) and "#fbe29a" or "#f6c460")
      P(x, y, col)
    end)
    R(lx - 2, 30, lx + 2, 35, "#fbf0c0")
    -- glow halo on the post (no circle: soft stepped)
    for y = 22, 48 do for x = lx - 14, lx + 14 do
      local d = abs(x - lx) + abs(y - 32) * 1.2
      if d > 9 and d < 16 and c:get(x, y) and not (x >= lx - 6 and x <= lx + 6 and y >= 19 and y <= 41) then glowAt(x, y, .18) end
    end end
  end
  -- lavender charm hanging right
  do
    local cx = 430
    R(cx, 12, cx, 22, "#e8d8a8")
    local charm = poly{ { cx - 5, 23 }, { cx + 5, 23 }, { cx + 2, 40 }, { cx - 2, 40 } }
    c:rim(charm, "#3a2a4a")
    charm:each(function(x, y) P(x, y, ((x + y) % 2 == 0) and "#a888dc" or "#7a5ab0") end)
    R(cx - 3, 26, cx + 3, 27, "#d85a5a")
    R(cx - 1, 41, cx + 1, 44, "#78c050")
  end
end

---------------------------------------------------------------- finish + save
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }
print("saved " .. OUT .. NAME)
