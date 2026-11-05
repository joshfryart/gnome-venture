-- finish5 kind cards: Do-tab kind cards 144x108 (craft, collect, tend, contest). Param: name=craft|collect|tend|contest|all
-- out: <this dir>/act-<name>.png/.aseprite
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local V3 = d .. "/../.."
local GX = dofile(V3 .. "/gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local H, INK, mix = X.hash, GX.INK, GX.mix
local CREAM = "#fff4d6"
local c
local function r(v) return floor(v + .5) end
local function R6(hi, base, shade, deep) return GX.ramp6{ hi = hi, base = base, shade = shade, deep = deep } end
local RED  = R6("#ff8a5c", "#e8493b", "#b52e3f", "#6e2038")
local REDD = R6("#e85a48", "#b8343a", "#862840", "#4e1c34")
local GRN  = R6("#c8f070", "#58b050", "#2e7648", "#1c4a40")
local GRND = R6("#7ec060", "#3e8a48", "#2a6040", "#1a3a34")
local YEL  = R6("#fff0a0", "#f5c43a", "#d0802a", "#8f4a1f")
local BLU  = R6("#8ac0f0", "#4a78d0", "#3a4a98", "#222a5c")
local PUR  = R6("#d8a8f0", "#9a58c8", "#683a98", "#38225e")
local WOOD = R6("#e8aa6a", "#b8703c", "#7e4434", "#442636")
local BOOT = R6("#a8683e", "#7e4a2e", "#5e3626", "#3a2220")
local IRN  = R6("#d8dcec", "#8e92ae", "#5c5e80", "#33344e")
local SKN  = R6("#ffd9b0", "#f2a878", "#c46c5a", "#7a3c48")
local SKN2 = R6("#d9a070", "#b57850", "#8a5638", "#55332a")
local NOSE = R6("#ffc8a0", "#f0907a", "#c05a5a", "#7a3040")
local NOSE2= R6("#e8a078", "#c06a50", "#8e4838", "#5a2a2a")
local WHT  = R6("#fffaf0", "#ece4e0", "#b8aac4", "#7a6a8c")
local BIRCH= R6("#fff0c8", "#f2d29a", "#d0a46c", "#8a6040")
local BRASS= R6("#fff2a8", "#e8b84a", "#b07a2c", "#6a4220")
local TEAL = R6("#a8f0e8", "#3fb8c0", "#2a7c98", "#1e4a6a")
local SOIL = R6("#9a6a4c", "#6e4434", "#4a2c2c", "#2e1c22")
local OAK  = R6("#e89a68", "#b8603c", "#80382e", "#4a2026")
local PNK  = R6("#ffb0d0", "#e8589a", "#a83a7e", "#5e2460")
local ORG  = R6("#ffc070", "#f08a30", "#c2562c", "#703028")

local function M() return HP.mask() end
local function E(cx, cy, rx, ry) return GX.disc(M(), r(cx), r(cy), rx, ry) end
local function Pl(p) local q = {} for i, v in ipairs(p) do q[i] = { r(v[1]), r(v[2]) } end return HP.poly(q) end
local function Rc(x0, y0, x1, y1) return HP.rect(r(x0), r(y0), r(x1), r(y1)) end
local function Ln(pts, w) local q = {} for i, v in ipairs(pts) do q[i] = { r(v[1]), r(v[2]) } end return HP.line(q, w or 1) end
local function px(x, y, col) c:px(r(x), r(y), col) end
local function fill(m, col) c:fillMask(m, col) end
local function obj(m, R, seed, o)
  o = o or {}
  return GX.lit(c, m, R, { R = o.R or 4, seed = seed or 1, tex = o.tex or .18, amb = .25, wrap = .3, rimlight = o.rim, ink = o.ink, fn = o.fn })
end
local function spark(x, y, col) px(x, y, col); px(x - 1, y, col); px(x + 1, y, col); px(x, y - 1, col); px(x, y + 1, col) end

-- background helpers -------------------------------------------------------
local function sky(y0, y1, cols, seed)
  for y = y0, y1 do for x = 0, 143 do
    local t = (y - y0) / (y1 - y0 + 1) + (GX.vn(x, y, 14, seed) - .5) * .12
    px(x, y, cols[max(1, min(#cols, floor(t * #cols) + 1))])
  end end
end
local function hillband(fn, y1, col, colTop)
  for x = 0, 143 do local y0 = r(fn(x)); for y = y0, y1 do px(x, y, (colTop and y == y0) and colTop or col) end end
end
local function field(fn, y1, R, seed, top, amt)
  for x = 0, 143 do
    local y0 = r(fn(x))
    for y = y0, y1 do
      local t = (y - y0) / max(1, y1 - y0)
      local v = (top or .62) - .25 * t + (GX.vn(x, y, 5, seed) - .5) * (amt or .35)
      local col = R[GX.idx(max(0, min(1, v)), { .1, .3, .5, .75, .92 })]
      if y == y0 then col = R[5] end
      px(x, y, col)
    end
  end
end
local function cloud(x, y, w, col, under)
  local m = M()
  GX.disc(m, r(x), r(y), r(w * .3), 4); GX.disc(m, r(x + w * .3), r(y - 3), r(w * .25), 5); GX.disc(m, r(x + w * .6), r(y), r(w * .28), 4)
  m:clip(Rc(0, 0, 143, r(y + 3)))
  m:each(function(xx, yy) px(xx, yy, (yy >= y + 2) and under or col) end)
end
local function tuft(x, y, R) GX.tuft(c, r(x), r(y), { shade = R[2], base = R[4], hi = R[6] }) end
local function frame()
  local OUTL, LT, MID, SH, DK = INK, "#d89a5c", "#b97a4a", "#864c33", "#51302b"
  for y = 0, 107 do for x = 0, 143 do
    local e = min(x, y, 143 - x, 107 - y)
    if e <= 6 then
      local lit = (y == e or x == e) and not (143 - x < e or 107 - y < e)
      lit = (min(x, y) == e)
      local col
      if e == 0 or e == 6 then col = OUTL
      elseif e <= 2 then col = lit and LT or MID
      elseif e <= 4 then col = lit and MID or SH
      else col = DK end
      if e >= 1 and e <= 4 and H(lit and floor((x + y) / 5) or floor((x + y) / 5) + 50, e, 3) < .18 then col = lit and MID or SH end
      px(x, y, col)
    end
  end end
  for _, p in ipairs({ { 0, 0 }, { 143, 0 }, { 0, 107 }, { 143, 107 } }) do c.pix[p[2] * c.w + p[1]] = nil; c.own[p[2] * c.w + p[1]] = nil end
  for _, p in ipairs({ { 2, 2 }, { 140, 2 }, { 2, 104 }, { 140, 104 } }) do
    px(p[1], p[2], YEL[6]); px(p[1] + 1, p[2], YEL[4]); px(p[1], p[2] + 1, YEL[4]); px(p[1] + 1, p[2] + 1, YEL[2])
  end
end

-- gnome --------------------------------------------------------------------
-- cx,fy = centre and foot baseline. o.dir 1 faces right, -1 left. o.front/o.back = hand {x,y}.
-- callbacks: o.behind (before body), o.mid (after body, before head), o.fore (after front arm)
local function arm(sx, sy, hand, coat, skin, seed)
  obj(Ln({ { sx, sy }, { hand[1], hand[2] } }, 4), coat, seed, { R = 2 })
  obj(E(hand[1], hand[2], 2, 2), skin, seed + 1, { R = 2 })
end
local function gnome(cx, fy, o)
  o = o or {}
  local dir = o.dir or 1
  local function Xd(dx) return r(cx + dir * dx) end
  local coat, hat, skin, nose = o.coat or BLU, o.hat or RED, o.skin or SKN, o.nose or NOSE
  if o.shadow then fill(E(cx + dir, fy + 1, 15, 2), o.shadow) end
  if o.back then arm(Xd(-6), fy - 19, o.back, coat, skin, 31) end
  if o.behind then o.behind() end
  obj(E(Xd(-5), fy - 3, 5, 3), BOOT, 2, { R = 2 }); obj(E(Xd(6), fy - 2, 5, 3), BOOT, 3, { R = 2 })
  local body = E(cx, fy - 14, 11, 11); body:cut(Rc(cx - 13, fy - 3, cx + 13, fy + 3))
  obj(body, coat, 4, { R = 7, rim = true })
  local belt = Rc(cx - 12, fy - 11, cx + 12, fy - 10); belt:clip(body); fill(belt, BOOT[2])
  fill(Rc(Xd(3) - 1, fy - 12, Xd(3) + 1, fy - 9), YEL[4]); px(Xd(3) - 1, fy - 12, YEL[6]); px(Xd(3), fy - 11, YEL[2]); px(Xd(3), fy - 10, YEL[2])
  if o.mid then o.mid() end
  obj(E(Xd(1), fy - 27, 9, 8), skin, 7, { R = 5 })
  local bd = Pl{ { Xd(-7), fy - 26 }, { Xd(10), fy - 26 }, { Xd(9), fy - 19 }, { Xd(5), fy - 12 }, { Xd(2), fy - 9 }, { Xd(-1), fy - 12 }, { Xd(-6), fy - 19 } }
  obj(bd, WHT, 8, { R = 4, tex = .14 })
  for k, sx in ipairs({ -3, 1, 5 }) do for yy = fy - 20, fy - 15 + (k == 2 and 3 or 0) do if bd:has(Xd(sx) + (yy % 3 == 0 and 1 or 0), yy) then px(Xd(sx) + (yy % 3 == 0 and 1 or 0), yy, WHT[3]) end end end
  -- mouth
  if o.mouth == "o" then fill(E(Xd(3), fy - 21, 1, 1), "#7a3040"); px(Xd(3), fy - 21, "#c05a5a")
  else px(Xd(1), fy - 22, "#7a3040"); for i = 2, 4 do px(Xd(i), fy - 21, "#7a3040") end; px(Xd(5), fy - 22, "#7a3040") end
  -- nose with lit tip
  obj(E(Xd(3), fy - 26, 3, 2), nose, 9, { R = 2 })
  px(Xd(3) - 1, fy - 27, nose[6]); px(Xd(3), fy - 27, nose[6])
  -- hat
  local hp = Pl{ { Xd(-10), fy - 35 }, { Xd(11), fy - 35 }, { Xd(8), fy - 44 }, { Xd(3), fy - 52 }, { Xd(-3), fy - 58 }, { Xd(-8), fy - 61 }, { Xd(-11), fy - 58 }, { Xd(-7), fy - 54 }, { Xd(-8), fy - 45 } }
  obj(hp, hat, 10, { R = 6, rim = true })
  obj(E(Xd(1), fy - 35, 11, 2), o.hatd or REDD, 11, { R = 2 })
  -- eyes (2x3 pill + glint), cheeks
  for _, ex in ipairs({ -1, 6 }) do
    local x = Xd(ex) - (dir < 0 and 1 or 0)
    fill(Rc(x, fy - 31, x + 1, fy - 29), INK); px(x, fy - 31, CREAM)
  end
  for _, ex in ipairs({ -4, 8 }) do local x = Xd(ex) - (dir < 0 and 1 or 0); px(x, fy - 28, "#f5809f"); px(x + 1, fy - 28, "#f5809f") end
  if o.front then arm(Xd(7), fy - 20, o.front, coat, skin, 41) end
  if o.fore then o.fore() end
end

-- props ------------------------------------------------------------------
local function curl(x, y, R)   -- wood shaving curl
  local m = E(x, y, 2, 2); m:cut(E(x, y, 0, 0))
  m:each(function(xx, yy) px(xx, yy, (yy < y or (yy == y and xx < x)) and R[6] or R[4]) end)
  px(x, y, R[2]); px(x + 2, y + 1, R[3]); px(x + 3, y + 2, R[5])
end
local function vbird(x, y, col) px(x - 2, y - 1, col); px(x - 1, y, col); px(x, y + 1, col); px(x + 1, y, col); px(x + 2, y - 1, col); px(x - 3, y - 1, col); px(x + 3, y - 1, col) end
local function leaf(x, y, a, len, R)
  local ca, sa = cos(a), sin(a)
  local pts = {}
  for i, p in ipairs({ { 0, 0 }, { len * .4, -len * .3 }, { len, 0 }, { len * .4, len * .3 } }) do pts[i] = { x + p[1] * ca - p[2] * sa, y + p[1] * sa + p[2] * ca } end
  local m = Pl(pts)
  c:rim(m, INK)
  m:each(function(xx, yy) px(xx, yy, ((xx - x) * -sa + (yy - y) * ca) < 0 and R[5] or R[3]) end)
  px(x + len * .35 * ca, y + len * .35 * sa, R[6])
end
local function smallbird(x, y, dir, body)   -- perched robin, 9px
  body = body or R6("#c8a080", "#8a6448", "#644432", "#3e2a24")
  obj(E(x, y, 4, 3), body, 5, { R = 2 })
  fill(E(x + dir, y + 1, 2, 1), RED[5])
  obj(E(x + dir * 3, y - 3, 2, 2), body, 6, { R = 2 })
  px(x + dir * 4, y - 4, INK); px(x + dir * 6, y - 3, YEL[4]); px(x + dir * 5, y - 3, YEL[4])
  px(x - dir * 5, y - 1, body[2]); px(x - dir * 6, y - 2, body[2])
end

-- cards --------------------------------------------------------------------
local S = {}

function S.craft()
  local WALL = R6("#f6d29c", "#dca468", "#b07648", "#74482e")
  for y = 0, 76 do for x = 0, 143 do
    local pl = floor((x - 7) / 13)
    local v = .55 + (H(pl, 1, 3) - .5) * .18 + (GX.vn(x * .35, y * 1.4, 3, pl + 5) - .5) * .3 + (1 - y / 76) * .1 - (y > 68 and .2 or 0)
    local col = WALL[GX.idx(max(0, min(1, v)), { .2, .36, .5, .7, .9 })]
    local k = (x - 7) % 13
    if k == 0 then col = WALL[2] elseif k == 1 then col = WALL[5] end
    if (k == 4 or k == 9) and (y == 12 or y == 60) then col = WALL[1] end
    px(x, y, col)
  end end
  -- window with morning light
  local win = Rc(12, 12, 32, 34)
  c:rim(win, INK); fill(win, WOOD[3])
  for _, p in ipairs({ { 14, 14, 21, 22 }, { 23, 14, 30, 22 }, { 14, 24, 21, 32 }, { 23, 24, 30, 32 } }) do
    fill(Rc(p[1], p[2], p[3], p[4]), "#b9e2f5"); fill(Rc(p[1], p[2], p[3], p[2]), "#e4f6ff"); px(p[1] + 1, p[2] + 2, "#e4f6ff"); px(p[1] + 2, p[2] + 1, "#e4f6ff")
    fill(Rc(p[1], p[4] - 1, p[3], p[4]), "#8bc4ea")
  end
  fill(Rc(17, 26, 19, 32), GRN[3]); fill(Rc(16, 28, 20, 30), GRN[4])   -- tree outside
  fill(Rc(11, 35, 33, 36), WOOD[4]); fill(Rc(11, 37, 33, 37), WOOD[2])  -- sill
  -- tool rail with saw and set square
  obj(Rc(88, 18, 134, 21), WOOD, 4, { R = 2 })
  for _, x in ipairs({ 94, 112, 128 }) do px(x, 19, YEL[5]) end
  local blade = Pl{ { 96, 24 }, { 120, 24 }, { 120, 30 }, { 98, 36 } }
  obj(blade, IRN, 5, { R = 3 })
  for x = 99, 119, 2 do local yb = r(36 - (x - 98) * 6 / 22); px(x, yb + 1, IRN[3]) end
  fill(Rc(100, 25, 116, 25), IRN[6])
  obj(Rr and Rc(119, 23, 125, 31) or Rc(119, 23, 125, 31), OAK, 6, { R = 2 }); fill(Rc(121, 26, 123, 28), OAK[1])
  fill(Ln({ { 94, 20 }, { 96, 24 } }, 1), INK)
  local sq = Rc(128, 22, 130, 40):add(Rc(128, 38, 134, 40))
  obj(sq, BRASS, 7, { R = 2 })
  -- floor
  local FL = R6("#c88a54", "#94603c", "#6a3e2e", "#422428")
  for y = 77, 107 do for x = 0, 143 do
    local row = floor((y - 77) / 6)
    local k = (x + row * 23) % 31
    local v = .6 - (y - 77) / 60 + (GX.vn(x * .3, y * 1.6, 3, row + 9) - .5) * .3
    local col = FL[GX.idx(max(0, min(1, v)), { .14, .3, .5, .72, .9 })]
    if (y - 77) % 6 == 5 or k == 0 then col = FL[1] end
    px(x, y, col)
  end end
  fill(Rc(0, 75, 143, 76), WALL[1]); fill(Rc(0, 74, 143, 74), WALL[3])
  -- bench
  obj(Rc(62, 77, 66, 98), OAK, 21, { R = 2 }); obj(Rc(124, 77, 128, 98), OAK, 22, { R = 2 })
  obj(Rc(66, 88, 124, 90), OAK, 23, { R = 2 })
  fill(Rc(64, 99, 70, 99), FL[1]); fill(Rc(124, 99, 132, 99), FL[1])
  obj(Rc(58, 76, 134, 79), OAK, 24, { R = 2 })
  obj(Rc(56, 70, 136, 75), OAK, 25, { R = 3, rim = true })
  for x = 60, 132, 9 do px(x, 72, OAK[3]); px(x + 1, 72, OAK[3]); px(x + 4, 73, OAK[3]) end
  -- half-made duck: rough block on the left, finished duck on the right
  local block = Rc(72, 52, 86, 69)
  block:cut(Pl{ { 72, 52 }, { 76, 52 }, { 72, 55 } })
  local duck = E(95, 62, 11, 7); duck:cut(Rc(80, 70, 110, 76))
  duck:add(Rc(100, 51, 104, 58)):add(E(102, 49, 5, 5))
  duck:add(Pl{ { 106, 47 }, { 113, 50 }, { 106, 52 } })
  duck:add(Pl{ { 84, 57 }, { 88, 55 }, { 90, 60 } })
  local wood = block:copy():add(duck)
  obj(wood, BIRCH, 26, { R = 4 })
  for _, l in ipairs({ { { 74, 58 }, { 77, 61 } }, { { 78, 54 }, { 80, 57 } }, { { 75, 64 }, { 79, 67 } } }) do fill(Ln(l, 1), BIRCH[3]) end
  -- chiselled seam between block and duck
  for y = 54, 69 do px(86 + ((y % 3 == 0) and 1 or 0), y, BIRCH[2]) end
  -- pencil plan of the duck's back over the block
  for i = 0, 6 do local x = 85 - i * 2; px(x, 56 + floor(i * .6), "#5a4a66") end
  px(103, 48, INK); px(102, 47, BIRCH[6])
  fill(Ln({ { 107, 50 }, { 112, 50 } }, 1), BIRCH[3])
  fill(Ln({ { 90, 61 }, { 98, 64 } }, 1), BIRCH[3])   -- wing line
  -- paint pot + brush (finishing touch)
  obj(Rc(118, 60, 128, 69), RED, 27, { R = 3 })
  obj(E(123, 60, 5, 1), REDD, 28, { R = 1 })
  fill(Rc(118, 63, 128, 64), RED[2])
  obj(Ln({ { 124, 59 }, { 130, 46 } }, 2), WOOD, 29, { R = 1 })
  -- shavings on the bench and floor
  for _, p in ipairs({ { 90, 68 }, { 110, 68 }, { 72, 96 }, { 84, 99 }, { 100, 94 }, { 48, 99 }, { 112, 97 } }) do curl(p[1], p[2], BIRCH) end
  -- gnome with raised hammer over a chisel stuck in the block
  gnome(40, 96, { dir = 1, shadow = FL[2], front = { 56, 64 }, back = { 30, 80 },
    fore = function()
      obj(Ln({ { 55, 67 }, { 61, 48 } }, 3), WOOD, 51, { R = 2 })
      obj(Ln({ { 55, 45 }, { 68, 49 } }, 5), IRN, 52, { R = 3 })
      fill(Rc(67, 47, 68, 51), IRN[2]); px(57, 44, IRN[6]); px(58, 44, IRN[6])
      obj(E(56, 64, 2, 2), SKN, 53, { R = 2 })
      -- chisel
      obj(Ln({ { 72, 53 }, { 76, 59 } }, 2), IRN, 54, { R = 1 })
      obj(Ln({ { 68, 46 }, { 71, 52 } }, 3), WOOD, 55, { R = 2 })
      -- strike marks + chips
      for _, p in ipairs({ { 73, 43 }, { 76, 46 }, { 64, 41 } }) do px(p[1], p[2], CREAM) end
      px(74, 42, CREAM); px(77, 45, CREAM)
      for _, p in ipairs({ { 80, 48 }, { 84, 51 }, { 78, 44 } }) do fill(Rc(p[1], p[2], p[1] + 1, p[2] + 1), BIRCH[5]); px(p[1] + 1, p[2] + 1, BIRCH[3]) end
    end })
  curl(32, 35, BIRCH)   -- quirk: a shaving caught on the hat tip
  frame()
end

function S.collect()
  sky(0, 64, { "#8eaaea", "#a2bcee", "#b8ccf2", "#cfdaf4", "#e2e6f2" }, 3)
  cloud(98, 30, 30, "#f4f0fa", "#d6d0ec"); cloud(14, 18, 22, "#f4f0fa", "#d6d0ec")
  hillband(function(x) return 54 + 4 * sin(x * .045 + 1) + 2 * sin(x * .12) end, 72, "#a6a8dc", "#bcbce6")
  hillband(function(x) return 62 + 3 * sin(x * .06 + 3) end, 76, "#7c98c4", "#92aed0")
  -- autumn tree far right
  GX.trunk(c, 118, 121, 50, 74, { hi = "#e8aa6a", base = "#b8703c", shade = "#7e4434", deep = "#442636" }, 4)
  GX.foliage(c, 120, 42, 14, 11, { hi = "#ffd070", base = "#f08a30", shade = "#c2562c", deep = "#703028" }, 7)
  local MEAD = R6("#d0ec88", "#82c460", "#4a9258", "#2a5a4c")
  field(function(x) return 72 + 2 * sin(x * .05) end, 107, MEAD, 5, .64, .18)
  for x = 10, 136, 11 do local y = 80 + floor(H(x, 2, 7) * 18); local col = ({ PNK[5], YEL[5], CREAM, PUR[5] })[1 + floor(H(x, 3, 1) * 4)]; GX.flower(c, x, y, col) end
  for _, p in ipairs({ { 64, 92 }, { 90, 86 }, { 120, 96 }, { 8, 98 } }) do tuft(p[1], p[2], MEAD) end
  -- the things being spotted: flock, butterfly, drifting leaves
  vbird(84, 16, "#4a3a6a"); vbird(94, 12, "#4a3a6a"); vbird(102, 19, "#4a3a6a"); vbird(76, 22, "#5a4a7a")
  leaf(102, 58, .6, 5, ORG); leaf(92, 68, -.4, 5, YEL); leaf(110, 70, 1.2, 4, ORG)
  -- butterfly
  local bx, by = 84, 40
  obj(E(bx - 3, by - 2, 3, 3), YEL, 61, { R = 2 }); obj(E(bx + 3, by - 2, 3, 3), YEL, 62, { R = 2 })
  obj(E(bx - 2, by + 2, 2, 2), ORG, 63, { R = 1 }); obj(E(bx + 2, by + 2, 2, 2), ORG, 64, { R = 1 })
  fill(Rc(bx, by - 3, bx, by + 3), INK); px(bx - 1, by - 5, INK); px(bx + 1, by - 5, INK); px(bx - 1, by - 4, INK); px(bx + 1, by - 4, INK)
  px(bx - 4, by - 3, CREAM); px(bx + 2, by - 3, CREAM)
  -- mossy stone
  local st = E(26, 98, 14, 5)
  obj(st, IRN, 8, { R = 3 })
  -- gnome with spyglass to the eye and notebook in the other hand
  gnome(38, 96, { dir = 1, shadow = MEAD[2], coat = R6("#9ae0b0", "#3a9a7a", "#2a6a64", "#1c3e48"), front = { 53, 62 }, back = { 24, 80 },
    fore = function()
      obj(Ln({ { 45, 66 }, { 52, 62 } }, 3), BRASS, 71, { R = 2 })
      obj(Ln({ { 52, 62 }, { 60, 57 } }, 4), BRASS, 72, { R = 2 })
      obj(Ln({ { 60, 57 }, { 69, 51 } }, 5), BRASS, 73, { R = 3 })
      fill(Ln({ { 52, 61 }, { 52, 63 } }, 1), BRASS[2]); fill(Ln({ { 60, 56 }, { 60, 58 } }, 1), BRASS[2])
      local lens = E(70, 50, 2, 2); fill(lens, "#5fc4c8"); px(69, 49, CREAM); px(71, 51, "#3a86b0")
      obj(E(53, 62, 2, 2), SKN, 74, { R = 2 })
      -- notebook, open, with a bird sketch
      local cov = Rc(12, 74, 30, 86)
      obj(cov, REDD, 75, { R = 2 })
      fill(Rc(13, 75, 20, 85), "#f4e8cc"); fill(Rc(22, 75, 29, 85), "#fbf0d8")
      fill(Rc(21, 75, 21, 85), "#c8b48e")
      vbird(17, 78, "#5a4a66"); for _, yy in ipairs({ 81, 83 }) do fill(Rc(14, yy, 19, yy), "#c8b48e") end
      for _, yy in ipairs({ 77, 79, 81 }) do fill(Rc(23, yy, 27, yy), "#c8b48e"); px(28, yy, GRN[3]) end
      obj(E(24, 82, 2, 2), SKN, 76, { R = 2 })
      smallbird(16, 70, 1)   -- quirk: robin perched on the notebook, watching the gnome
    end })
  frame()
end

function S.tend()
  sky(0, 62, { "#62b8ec", "#7cc8f0", "#9ad6f4", "#b8e4f6", "#d4f0f4" }, 9)
  obj(E(118, 20, 8, 8), YEL, 3, { R = 5, ink = false })
  for i = 0, 7 do local a = i * pi / 4; local x, y = 118 + cos(a) * 12, 20 + sin(a) * 12; px(x, y, YEL[5]); px(118 + cos(a) * 13, 20 + sin(a) * 13, YEL[6]) end
  cloud(26, 24, 30, "#fffaf0", "#d4e8f0"); cloud(74, 14, 20, "#fffaf0", "#d4e8f0")
  hillband(function(x) return 54 + 3 * sin(x * .05 + 2) end, 70, "#8cc8a0", "#a8dab0")
  -- fence
  local FEN = R6("#fff0d0", "#e8d0a8", "#b89a80", "#6a5a5a")
  obj(Rc(0, 56, 143, 58), FEN, 4, { R = 1 }); obj(Rc(0, 64, 143, 66), FEN, 5, { R = 1 })
  for x = 6, 136, 16 do obj(Pl{ { x, 52 }, { x + 2, 49 }, { x + 4, 52 }, { x + 4, 72 }, { x, 72 } }, FEN, 10 + x, { R = 2 }) end
  -- tally marks scratched on the near post: days of tending
  for i = 0, 3 do fill(Rc(120 + i, 55, 120 + i, 60), FEN[2]) end
  local GR = R6("#c8ee80", "#6cc058", "#3e8c4c", "#24544a")
  field(function(x) return 70 + sin(x * .08) end, 107, GR, 3, .7)
  -- raised bed
  local bed = Pl{ { 50, 80 }, { 138, 78 }, { 140, 96 }, { 48, 98 } }
  bed:each(function(x, y)
    local v = .55 + (GX.vn(x, y, 3, 4) - .5) * .5 - (y - 78) / 50
    if (y - 80) % 5 == 0 then v = v - .25 elseif (y - 80) % 5 == 1 then v = v + .15 end
    px(x, y, SOIL[GX.idx(max(0, min(1, v)))])
  end)
  c:rim(bed, INK)
  obj(Pl{ { 46, 96 }, { 142, 94 }, { 142, 99 }, { 46, 101 } }, WOOD, 6, { R = 2 })
  -- seedlings growing day by day along the row
  local function sprout(x, y, h, n, bud)
    if h > 2 then obj(Rc(x, y - h, x + 1, y), GRN, x, { R = 1 }) end
    for i = 1, n do
      local yy = y - h * (i / (n + .5)) - 1
      local s = 2 + i + floor(h / 6)
      leaf(x + 1, yy, -.5 - i * .1, s, GRN)
      leaf(x, yy + 1, pi + .5 + i * .1, s, GRN)
    end
    if bud then obj(E(x, y - h - 3, 3, 3), PNK, x + 3, { R = 2 }); fill(E(x, y - h - 3, 1, 1), YEL[5]) end
  end
  sprout(82, 86, 1, 1); sprout(98, 86, 6, 1); sprout(114, 86, 11, 2); sprout(130, 86, 18, 3, true)
  -- gnome watering
  gnome(32, 96, { dir = 1, shadow = GR[2], coat = R6("#ffd070", "#e89a38", "#b8602e", "#6a3030"), hat = RED, front = { 50, 72 }, back = { 20, 82 },
    behind = function()
      -- rake leaning behind
      obj(Ln({ { 14, 96 }, { 26, 52 } }, 2), WOOD, 81, { R = 1 })
      obj(Rc(8, 94, 20, 95), IRN, 82, { R = 1 })
      for x = 8, 20, 3 do px(x, 97, IRN[3]); px(x, 96, IRN[4]) end
    end,
    fore = function()
      local can = c:rrect(48, 72, 64, 86, 3)
      obj(can, TEAL, 83, { R = 4, rim = true })
      fill(Rc(48, 77, 64, 77), TEAL[2]); fill(Rc(48, 78, 64, 78), TEAL[5])
      local hd = E(54, 72, 6, 5); hd:cut(E(54, 72, 4, 3)); hd:clip(Rc(40, 60, 70, 72))
      obj(hd, TEAL, 84, { R = 1 })
      obj(Ln({ { 63, 82 }, { 74, 74 } }, 2), TEAL, 85, { R = 1 })
      obj(Pl{ { 73, 71 }, { 77, 72 }, { 76, 77 }, { 72, 76 } }, TEAL, 86, { R = 1 })
      obj(E(50, 71, 2, 2), SKN, 87, { R = 2 })
      -- water drops falling on the first sprout
      for _, p in ipairs({ { 78, 76 }, { 80, 80 }, { 77, 81 }, { 82, 77 }, { 83, 82 }, { 79, 84 } }) do px(p[1], p[2], "#e4f6ff"); px(p[1], p[2] + 1, "#5fc4c8") end
      -- quirk: snail riding on the can
      obj(E(57, 70, 3, 3), R6("#ffd070", "#e89a38", "#b8602e", "#6a3030"), 88, { R = 2 })
      px(57, 70, "#6a3030"); fill(Rc(53, 72, 61, 72), "#c8b0a0"); px(53, 71, "#c8b0a0"); px(52, 70, INK)
    end })
  frame()
end

function S.contest()
  sky(0, 70, { "#f6b8c4", "#f8c8c4", "#fad6c6", "#fce4c8", "#fdeed0" }, 12)
  hillband(function(x) return 60 + 3 * sin(x * .05 + .5) + 2 * sin(x * .13) end, 76, "#c8a4cc", "#d8b8d8")
  local GR = R6("#d6f08a", "#8ccc5c", "#52a050", "#2e6a4a")
  field(function(x) return 72 + sin(x * .06) end, 107, GR, 7, .68, .2)
  -- sandy ring
  local SAND = R6("#fff0c0", "#f0d08a", "#d0a464", "#8a6440")
  local ring = E(72, 94, 62, 9)
  ring:each(function(x, y) local v = .62 + (GX.vn(x, y, 3, 5) - .5) * .35 - (y - 86) / 40; px(x, y, SAND[GX.idx(max(0, min(1, v)))]) end)
  ring:edge():each(function(x, y) px(x, y, SAND[3]) end)
  for y = 86, 102, 3 do px(72, y, CREAM); px(72, y + 1, CREAM) end
  -- finish ribbon on striped posts
  for _, x in ipairs({ 12, 130 }) do
    local post = Rc(x, 46, x + 3, 92)
    c:rim(post, INK)
    post:each(function(xx, yy) local red = floor((yy - 46) / 4) % 2 == 0; px(xx, yy, red and (xx == x and RED[5] or RED[4]) or (xx == x and CREAM or "#f0e0c8")) end)
    obj(E(x + 1, 45, 3, 2), YEL, x, { R = 2 })
  end
  for x = 16, 129 do
    local y = r(56 + 4 * sin((x - 16) / 113 * pi))
    local red = floor(x / 3) % 2 == 0
    px(x, y - 1, INK); px(x, y + 2, INK)
    px(x, y, red and RED[5] or CREAM); px(x, y + 1, red and RED[3] or "#e6d4bc")
  end
  -- bunting
  local cols = { RED, YEL, BLU, GRN, PNK }
  local function bly(x) return 12 + 6 * sin((x - 7) / 129 * pi) end
  for x = 7, 136 do px(x, bly(x), "#6a4a52") end
  local i = 0
  for x = 10, 130, 12 do
    i = i + 1
    local y = r(bly(x + 3))
    local R = cols[(i - 1) % #cols + 1]
    obj(Pl{ { x, y }, { x + 7, y }, { x + 3.5, y + 8 } }, R, 90 + i, { R = 2 })
  end
  -- rosette hanging over the middle
  local rx, ry = 72, 34
  obj(Pl{ { rx - 6, ry + 4 }, { rx - 1, ry + 4 }, { rx - 3, ry + 24 }, { rx - 6, ry + 21 }, { rx - 9, ry + 24 } }, BLU, 101, { R = 2 })
  obj(Pl{ { rx + 1, ry + 4 }, { rx + 6, ry + 4 }, { rx + 9, ry + 22 }, { rx + 6, ry + 19 }, { rx + 3, ry + 22 } }, YEL, 102, { R = 2 })
  local pet = M()
  for k = 0, 11 do local a = k * pi / 6; GX.disc(pet, r(rx + cos(a) * 9), r(ry + sin(a) * 9), 3, 3) end
  GX.disc(pet, rx, ry, 9, 9)
  obj(pet, BLU, 103, { R = 6, rim = true })
  for k = 0, 11 do local a = k * pi / 6 + pi / 12; fill(Ln({ { rx + cos(a) * 7, ry + sin(a) * 7 }, { rx + cos(a) * 11, ry + sin(a) * 11 } }, 1), BLU[3]) end
  obj(E(rx, ry, 5, 5), YEL, 104, { R = 4, rim = true })
  local star = M()
  for k = 0, 4 do local a = -pi / 2 + k * 2 * pi / 5; star:add(Ln({ { rx, ry }, { rx + cos(a) * 3, ry + sin(a) * 3 } }, 1)) end
  fill(star, RED[4]); px(rx, ry, RED[6])
  fill(Ln({ { rx, ry - 10 }, { rx, r(bly(rx)) } }, 1), "#6a4a52")
  spark(56, 28, CREAM); spark(90, 40, YEL[6]); px(60, 46, YEL[6]); px(86, 24, CREAM)
  -- two gnomes squaring up, hands out
  gnome(44, 98, { dir = 1, shadow = SAND[3], coat = BLU, front = { 61, 74 }, back = { 58, 80 }, mouth = "o" })
  gnome(100, 98, { dir = -1, shadow = SAND[3], coat = PUR, hat = GRN, hatd = GRND, skin = SKN2, nose = NOSE2, front = { 83, 74 }, back = { 86, 80 } })
  -- quirk: a small bird referee on the right post
  smallbird(131, 40, -1, R6("#ffe38a", "#f5b82e", "#d98322", "#8f4a1f"))
  frame()
end

local want = app.params.name or "all"
for _, n in ipairs({ "craft", "collect", "tend", "contest" }) do
  if want == "all" or want == n then
    c = HP.canvas{ w = 144, h = 108, scale = 1, name = "act-" .. n }
    S[n]()
    HP.assertClean(c)
    c:save{ aseprite = d .. "/act-" .. n .. ".aseprite", png = d .. "/act-" .. n .. ".png", scale = 1 }
  end
end
