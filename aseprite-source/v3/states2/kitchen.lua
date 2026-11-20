-- kitchen state sprites v2 (Hearth Pop v3). 96x80, ground contact centre (48,70).
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "/tmp/ase/states2/kitchen/"
local floor = math.floor
local INK, CREAM = P.ink, P.cream
local STONE, GOLD, WOOD, MOSS, EMBER, PETAL, SEA, SKY = P.stone, P.gold, P.wood, P.moss, P.ember, P.petal, P.sea, P.sky
local ROOF = { hi = EMBER.hi, base = EMBER.base, shade = EMBER.shade, deep = EMBER.deep }
local PLASTER = { hi = P.cream, base = "#f6dfae", shade = WOOD.hi, deep = WOOD.base }
local INTERIOR = "#3b2c48"
local SHD_A, SHD_B = "#7d6a84", "#55445f"
local DUSKSH = "#5a4660"
local SLATE, SLATE2 = "#33494b", "#2a3b42"
local c
local W_, H_ = 96, 80
local DY = 2   -- building is drawn with feet y=68 then shifted to y=70

local function hexrgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function lerp(a, b, t)
  local r1, g1, b1 = hexrgb(a); local r2, g2, b2 = hexrgb(b)
  return string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
local function hsh(x, y)
  local h = (x * 374761393 + y * 668265263) & 0xffffffff
  h = ((h ~ (h >> 13)) * 1274126177) & 0xffffffff
  return (h ~ (h >> 16)) % 100
end
local function R(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local function px(x, y, hex) c:px(x, y, hex) end
local function rise(i) return (i + 1) // 2 end
local function seg(x0, y0, x1, y1, hex)
  local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
  for i = 0, n do local t = n == 0 and 0 or i / n; px(floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5), hex) end
end
local function ink(...)
  local u = HP.mask()
  for _, m in ipairs({ ... }) do u:add(m) end
  c:rim(u, INK)
  return u
end
local LX, LY, LZ = -0.55, -0.62, 0.56
local function ball(m, cx, cy, rx, ry, T, o)
  o = o or {}
  m:each(function(x, y)
    local u, v = (x + .5 - cx - .5) / (rx + .5), (y + .5 - cy - .5) / (ry + .5)
    local q = 1 - u * u - v * v; if q < 0 then q = 0 end
    local l = LX * u + LY * v + LZ * math.sqrt(q)
    px(x, y, (l > .62 and T.hi) or (l > .2 and T.base) or (l > -.18 and T.shade) or T.deep)
  end)
  m:each(function(x, y) if (not m:has(x + 1, y) or not m:has(x, y + 1)) and c:get(x, y) == T.deep and (x - cx) + (y - cy) > rx * .5 then px(x, y, T.shade) end end)
end
local function sideWall(x1, yt, yb, d, extra)
  local m = HP.mask()
  for i = 1, d do local s = rise(i); for yy = yt - s - (extra or 0), yb - s do m:set(x1 + i, yy) end end
  return m
end
local function hipRoof(x0, x1, ye, yr, ov, a, d, ah)
  local rr, hd = rise(d), d // 2
  local EL, ER, BR = { x0 - ov, ye + 1 }, { x1 + ov + 1, ye + 1 }, { x1 + ov + d + 1, ye + 1 - rr }
  local RL, RR = { x0 - ov + a + hd, yr }, { x1 + ov + 1 - (ah or a + 3) + hd, yr }
  local F = c:poly{ EL, RL, RR, ER }
  local S = c:poly{ ER, RR, BR }:cut(F)
  return F, S
end
local function wallTones(base, lit)
  return { base = base, lite = lerp(base, lit or P.cream, .4), dark = lerp(base, DUSKSH, .12),
    eave = lerp(base, DUSKSH, .3), sbase = lerp(base, DUSKSH, .36), slite = lerp(base, DUSKSH, .27), sdark = lerp(base, DUSKSH, .47) }
end
local function mottle(m, base, lite, dark, seed, dens)
  m:each(function(x, y)
    if c:get(x, y) == base then
      local h = hsh(x * 3 + seed, y * 5 + seed)
      if h < dens then px(x, y, lite) if c:get(x + 1, y) == base and h < dens // 2 then px(x + 1, y, lite) end
      elseif h > 99 - dens then px(x, y, dark) end
    end
  end)
end
local function paintWalls(front, side, W, seed)
  c:fillMask(front, W.base) c:fillMask(side, W.sbase)
  mottle(front, W.base, W.lite, W.dark, seed or 1, 7)
  mottle(side, W.sbase, W.slite, W.sdark, (seed or 1) + 9, 9)
end
local function eaveShadow(x0, x1, yt, d, W, rows)
  for r = 0, (rows or 1) - 1 do R(x0, yt + r, x1, yt + r, W.eave) end
  for i = 1, d do local s = rise(i); for r = 0, (rows or 1) do px(x1 + i, yt - s + r, W.sdark) end end
end
local function roof(F, S, Rr, seed)
  c:fillMask(F, Rr.base) c:fillMask(S, Rr.shade)
  local x0, y0, x1, y1 = F:bbox()
  F:each(function(x, y)
    local row, course = (y - y0) % 3, (y - y0) // 3
    local tx = x - x0 + (course % 2) * 2
    if row == 2 then px(x, y, lerp(Rr.base, Rr.deep, .4))
    elseif tx % 5 == 0 then px(x, y, Rr.shade)
    else
      local t = hsh(tx // 5 + 3 + seed, course + seed)
      if t < 12 then px(x, y, lerp(Rr.base, Rr.hi, .45)) elseif t > 88 then px(x, y, lerp(Rr.base, Rr.shade, .5)) end
    end
  end)
  F:each(function(x, y) if not F:has(x, y - 1) and not S:has(x, y - 1) then px(x, y, Rr.hi) end end)
  for xx = x0, x1 do if F:has(xx, y1) then px(xx, y1, Rr.deep) end end
  S:each(function(x, y) if (y - y0) % 3 == 2 then px(x, y, lerp(Rr.shade, Rr.deep, .5)) end end)
end
local function window(wx, wy, w, h, o)
  o = o or {}
  local fr = o.frame or WOOD.shade
  R(wx - 1, wy - 1, wx + w, wy + h, fr)
  R(wx, wy, wx + w - 1, wy + h - 1, o.glass or SEA.base)
  local rec = o.rec or INTERIOR
  R(wx, wy, wx + w - 1, wy, rec) R(wx, wy, wx, wy + h - 1, rec)
  local mx, my = wx + w // 2, wy + h // 2
  R(mx, wy, mx, wy + h - 1, fr) R(wx, my, wx + w - 1, my, fr)
  px(wx + 1, wy + 1, o.glint or CREAM)
  px(wx - 1, wy - 1, lerp(fr, CREAM, .35))
  R(wx - 2, wy + h, wx + w + 1, wy + h, STONE.hi)
  R(wx - 1, wy + h + 1, wx + w + 1, wy + h + 1, o.sillsh or STONE.shade)
  if o.shut then
    local S = o.shut
    for _, sx in ipairs{ wx - 3, wx + w + 1 } do
      R(sx, wy - 1, sx + 1, wy + h - 1, S.base)
      for yy = wy, wy + h - 1, 2 do R(sx, yy, sx + 1, yy, S.shade) end
      px(sx, wy - 1, S.hi)
    end
  end
end
local function door(dx0, dx1, dy0, yb, o)
  o = o or {}
  local fr = o.frame or WOOD.deep
  c:fillMask(c:rrect(dx0 - 1, dy0 - 1, dx1 + 1, yb, o.arch or 2), fr)
  local leaf = c:rrect(dx0, dy0, dx1, yb, math.max((o.arch or 2) - 1, 0))
  c:fillMask(leaf, WOOD.base)
  for xx = dx0 + 2, dx1 - 1, 2 do leaf:each(function(x, y) if x == xx then px(x, y, WOOD.shade) end end) end
  leaf:each(function(x, y) if not leaf:has(x, y - 1) or x == dx0 then px(x, y, lerp(WOOD.shade, WOOD.deep, .5)) end end)
  px(dx1 - 1, dy0 + (yb - dy0) // 2 + 1, GOLD.hi)
  if o.lintel then R(dx0 - 2, dy0 - 2, dx1 + 2, dy0 - 2, o.lintel) end
  R(dx0 - 2, yb, dx1 + 2, yb, STONE.base) R(dx0 - 2, yb, dx1 + 1, yb, STONE.hi)
end
local function plinth(x0, x1, yb, d, rows)
  R(x0, yb - rows + 1, x1, yb, STONE.base)
  R(x0, yb - rows + 1, x1, yb - rows + 1, STONE.hi)
  R(x0, yb, x1, yb, STONE.shade)
  for xx = x0 + 2, x1, 5 do px(xx, yb - rows + 2, STONE.shade) end
  for i = 1, d do local s = rise(i); for r = 0, rows - 1 do px(x1 + i, yb - s - r, (r == rows - 1) and STONE.shade or STONE.deep) end end
end
local function quoins(xc, y0, y1, dir, lite, dark)
  for yy = y0, y1, 4 do R(xc, yy, xc + dir * 2, yy + 1, lite) R(xc, yy + 2, xc + dir, yy + 3, lite) px(xc + dir * 2, yy + 1, dark) end
end
local function castShadow(x0, x1, yb, d, hw, L)
  L = (L or 6) + 3
  local m = HP.mask()
  for j = 1, 3 do for xx = x0 + j, x1 + d + j + 1 do m:set(xx, yb + j) end end
  local rr = rise(d)
  for yy = yb - rr - hw, yb do
    local t = (yy - (yb - rr - hw)) / (hw + rr)
    for xx = x1 + d + 1, x1 + d + 1 + floor(t * L + .5) do m:set(xx, yy) end
  end
  local k = HP.mask() for xx = x0 + 1, x1 + d do k:set(xx, yb + 2) end
  c:fillMask(m, SHD_A) c:fillMask(k, SHD_B)
end

-- a glazed cooking pot: round coloured body, iron lid with gold knob, two ear handles.
-- 9 wide (handles), 9 tall; (cx, ytop) = knob position.  dx/dy move the lid (rattle).
local function pot(cx, ytop, T, dx, dy)
  dx, dy = dx or 0, dy or 0
  local body = c:rrect(cx - 3, ytop + 3, cx + 3, ytop + 8, 2)
  local lid = c:rect(cx - 3 + dx, ytop + 2 + dy, cx + 3 + dx, ytop + 2 + dy):add(c:rect(cx - 2 + dx, ytop + 1 + dy, cx + 2 + dx, ytop + 1 + dy))
  local knob = HP.mask():set(cx + dx, ytop + dy)
  local ears = c:rect(cx - 4, ytop + 4, cx - 4, ytop + 5):add(c:rect(cx + 4, ytop + 4, cx + 4, ytop + 5))
  ink(body, lid, knob, ears)
  ball(body, cx, ytop + 5.5, 3, 3, T)
  R(cx - 3, ytop + 3, cx + 3, ytop + 3, T.deep)          -- shadow under the lid
  for xx = cx - 2, cx + 2, 2 do if body:has(xx, ytop + 6) then px(xx, ytop + 6, CREAM) end end   -- glaze dots
  c:part(lid, STONE, { band = 1 })
  c:fillMask(ears, STONE.shade) px(cx - 4, ytop + 4, STONE.base)
  px(cx + dx, ytop + dy, GOLD.hi)
end
local STM = { hi = CREAM, base = SKY.hi, shade = SKY.base, deep = SKY.shade }
local SMK = { hi = CREAM, base = STONE.hi, shade = STONE.base, deep = STONE.shade }
local function puffs(list, ramp)
  local u = HP.mask()
  for _, p in ipairs(list) do u:add(c:ellipse(p[1], p[2], p[3], p[3])) end
  ink(u)
  c:part(u, ramp)
end
local CURL = { { 0, 1, 0 }, { -1, 0, 2 }, { 1, -1, 0 }, { 0, 2, -2 } }
local function smoke(cx, top, f)
  local d = CURL[f or 1]
  puffs({ { cx + d[1], top - 3, 2 }, { cx + 1 + d[2], top - 7, 2 }, { cx - 1 + d[3], top - 11, 3 } }, SMK)
end
local GLASS = { GOLD.hi, CREAM, GOLD.hi, GOLD.base }

------------------------------------------------------------ the kitchen (feet at y=68 in the work canvas)
local function kitchen(lvl, f)
  c = HP.canvas{ w = W_, h = H_, scale = 1, name = "kitchen" }
  local x0, x1, yt, d, y = 26, 65, 44, 5, 68
  castShadow(x0, x1, y, d, 12, 6)
  if lvl == 3 then R(84, y - 3, 90, y - 3, SHD_A) R(86, y - 2, 92, y, SHD_A) R(87, y + 1, 91, y + 1, SHD_B) end
  local front, side = c:rect(x0, yt, x1, y), sideWall(x1, yt, y, d, 1)
  local F, S = hipRoof(x0, x1, yt - 1, y - 43, 4, 18, d)
  local chim, chs, cap, capTop
  if lvl == 3 then capTop = 15; chim, chs, cap = c:rect(54, 17, 61, 36), sideWall(61, 17, 35, 2), c:rect(53, 15, 64, 16)
  else capTop = 20; chim, chs, cap = c:rect(55, 22, 59, 36), sideWall(59, 22, 35, 2), c:rect(54, 20, 61, 21) end
  local F2, S2 = F:copy():cut(chim):cut(chs), S:copy():cut(chim):cut(chs)
  ink(front, side, F, S, chim, chs, cap)
  local W = wallTones(PLASTER.base, P.cream)
  paintWalls(front, side, W, 2)
  roof(F2, S2, ROOF, 2)
  c:fillMask(chim, STONE.base) c:fillMask(chs, STONE.shade)
  local cx0, _, cx1 = chim:bbox()
  for yy = capTop + 3, 35, 3 do R(cx0, yy, cx1, yy, lerp(STONE.base, STONE.shade, .5)) end
  R(cx0, capTop + 2, cx0, 35, STONE.hi)
  c:fillMask(cap, lvl == 3 and GOLD.base or STONE.shade)
  R(cx0 - 1, capTop, cx1 + 1, capTop, lvl == 3 and GOLD.hi or STONE.hi)
  if lvl == 3 then R(cx0, 21, cx1, 22, GOLD.base) R(cx0, 21, cx1, 21, GOLD.hi) R(cx1 + 1, 21, cx1 + 2, 22, GOLD.shade) end
  eaveShadow(x0, x1, yt, d, W, 2)
  quoins(x0, yt + 3, y - 4, 1, CREAM, W.dark)
  quoins(x1, yt + 3, y - 4, -1, CREAM, W.dark)
  plinth(x0, x1, y, d, 3)
  R(67, 51, 69, 54, WOOD.shade) R(68, 52, 68, 53, INTERIOR) px(69, 53, WOOD.base)
  door(43, 49, 52, 68, { frame = WOOD.deep, arch = 3, lintel = STONE.base })
  local SH = { hi = MOSS.hi, base = MOSS.base, shade = MOSS.shade }
  local g = f and GLASS[f] or GOLD.hi
  window(29, 49, 6, 7, { glass = g, rec = GOLD.base, frame = WOOD.shade, shut = SH, sillsh = W.eave })
  window(56, 49, 6, 7, { glass = g, rec = GOLD.base, frame = WOOD.shade, shut = SH, sillsh = W.eave })

  -- wooden prep counter with the pots
  local bx0 = lvl >= 2 and 11 or 21
  local bench = c:rect(bx0, 62, 41, 68)
  ink(bench)
  c:part(bench, WOOD)
  R(bx0, 62, 41, 62, WOOD.hi)
  for xx = bx0 + 5, 40, 6 do R(xx, 64, xx, 67, WOOD.shade) end
  R(bx0, 68, 41, 68, WOOD.deep)
  local d1 = f and ({ -1, 0, 1, 0 })[f] or 0
  local dy1 = f and ({ 0, 0, -1, 0 })[f] or 0
  local d2 = f and ({ 1, 0, -1, 0 })[f] or 0
  local dy2 = f and ({ -1, 0, 0, 0 })[f] or 0
  if lvl >= 2 then pot(16, 53, MOSS) end
  pot(26, 53, SEA, d1, dy1)
  pot(36, 53, EMBER, d2, dy2)

  if lvl >= 2 then
    -- striped awning over the door, scalloped hem
    local awn = c:poly{ { 38, 45 }, { 54, 45 }, { 57, 50 }, { 35, 50 } }
    ink(awn)
    for k = 0, 8 do
      c:fillMask(c:rect(35 + k * 3, 45, 37 + k * 3, 50):clip(awn), k % 2 == 0 and EMBER.base or CREAM)
    end
    awn:each(function(x, y)
      if y == 45 then px(x, y, ((x - 35) // 3) % 2 == 0 and EMBER.hi or CREAM) end
      if y == 50 then px(x, y, ((x - 35) // 3) % 2 == 0 and EMBER.shade or lerp(CREAM, DUSKSH, .25)) end
    end)
    -- herb bunch hanging from a peg beside the door
    R(51, 52, 51, 52, WOOD.deep)
    local herb = c:ellipse(52, 56, 1, 3)
    local chili = HP.mask():set(54, 53):set(54, 54):set(54, 55)
    ink(herb, chili)
    c:part(herb, MOSS) px(52, 56, MOSS.hi)
    c:fillMask(chili, EMBER.base) px(54, 53, EMBER.hi)
  end
  if lvl == 3 then
    -- timber wing with its own roof, lit window, pan rack
    local wing = c:rect(72, 47, 86, 68)
    local wroof = c:poly{ { 70, 48 }, { 73, 41 }, { 85, 41 }, { 88, 48 } }
    ink(wing, wroof)
    c:part(wing, WOOD)
    for xx = 75, 85, 3 do R(xx, 48, xx, 68, WOOD.shade) end
    R(85, 48, 86, 68, WOOD.shade) R(72, 48, 86, 48, WOOD.deep)
    c:part(wroof, ROOF)
    for xx = 74, 86, 4 do R(xx, 43, xx, 47, ROOF.shade) end
    window(74, 51, 4, 5, { glass = g, rec = GOLD.base, frame = WOOD.deep })
    -- pan rack: copper rail with two pans
    R(79, 50, 85, 50, GOLD.shade) R(79, 50, 85, 50, GOLD.shade)
    for _, px0 in ipairs{ 80, 84 } do
      local pan = c:ellipse(px0, 54, 1, 1)
      local hd = HP.mask():set(px0, 51):set(px0, 52)
      ink(pan, hd)
      c:fillMask(hd, WOOD.deep)
      c:part(pan, GOLD, { band = 1 })
    end
    -- bunting along the eave, split by the awning
    seg(24, 45, 36, 45, WOOD.deep) seg(56, 45, 67, 45, WOOD.deep)
    local cols = { EMBER.base, GOLD.base, MOSS.base, PETAL.base }
    for i, fx in ipairs{ 25, 29, 33, 57, 61, 65 } do
      R(fx, 46, fx + 2, 46, cols[(i - 1) % 4 + 1]) px(fx + 1, 47, cols[(i - 1) % 4 + 1])
    end
    -- lantern on a post at the far left
    local post = c:rect(8, 49, 8, 67)
    ink(post) c:fillMask(post, WOOD.shade)
    local lant = c:rect(6, 43, 10, 48)
    ink(lant) c:part(lant, GOLD) px(7, 44, CREAM)
    R(7, 42, 9, 42, WOOD.deep)
    -- feast table in front of the wall with roast, goblets and a fourth pot
    local top = c:rect(52, 63, 71, 64)
    local legs = c:rect(54, 65, 54, 69):add(c:rect(69, 65, 69, 69))
    ink(top, legs)
    c:fillMask(legs, WOOD.deep)
    c:part(top, WOOD)
    R(52, 63, 71, 63, WOOD.hi)
    local plate = c:rect(54, 62, 61, 62)
    local roast = c:ellipse(57, 60, 3, 1)
    local g1 = c:rect(63, 59, 64, 62)
    ink(plate, roast, g1)
    c:fillMask(plate, CREAM)
    c:part(roast, GOLD, { band = 1 }) px(56, 60, EMBER.base) px(58, 60, EMBER.base)
    c:fillMask(g1, SEA.hi) px(63, 62, SEA.base) px(64, 62, SEA.base)
    pot(68, 54, PETAL)
  end
  if lvl >= 2 then
    -- firewood pile (round log ends)
    local logs = { { 75, 66 }, { 78, 66 }, { 81, 66 }, { 84, 66 }, { 76, 63 }, { 79, 63 }, { 82, 63 }, { 77, 60 }, { 80, 60 } }
    local ms = {}
    for i, l in ipairs(logs) do ms[i] = c:ellipse(l[1], l[2], 1, 1) end
    ink(table.unpack(ms))
    for i, l in ipairs(logs) do
      c:fillMask(ms[i], WOOD.base) px(l[1], l[2], WOOD.hi) px(l[1] + 1, l[2] + 1, WOOD.shade) px(l[1] - 1, l[2], WOOD.shade)
    end
  end
  smoke(lvl == 3 and 58 or 57, capTop, f or 1)
  return c
end

local function shifted(cv, dy)
  local n = HP.canvas{ w = W_, h = H_, scale = 1, name = cv.name }
  for k, v in pairs(cv.pix) do
    local x, y = k % W_, k // W_
    local ny = y + dy
    if ny >= 0 and ny < H_ then n.pix[ny * W_ + x] = v; n.own[ny * W_ + x] = cv.own[k] end
  end
  return n
end

------------------------------------------------------------ BUILD lettering (3x5)
local GL = {
  B = { "110", "101", "110", "101", "110" }, U = { "101", "101", "101", "101", "111" },
  I = { "111", "010", "010", "010", "111" }, L = { "100", "100", "100", "100", "111" },
  D = { "110", "101", "101", "101", "110" },
}
local function build(x, y, col)
  for i = 1, 5 do
    local ch = ("BUILD"):sub(i, i)
    for r = 1, 5 do for q = 1, 3 do if GL[ch][r]:sub(q, q) == "1" then px(x + (i - 1) * 4 + q - 1, y + r - 1, col) end end end
  end
end

------------------------------------------------------------ empty plot with the chalkboard easel
local function empty(f)
  c = HP.canvas{ w = W_, h = H_, scale = 1, name = "kitchen-empty" }
  local patch = c:ellipse(48, 64, 28, 6)
  ink(patch)
  c:part(patch, WOOD)
  for _, p in ipairs{ { 28, 66 }, { 40, 69 }, { 62, 68 }, { 70, 63 }, { 33, 61 } } do px(p[1], p[2], WOOD.deep) px(p[1] + 1, p[2], WOOD.shade) end
  -- stakes + string (string behind easel)
  local st = { { 25, 61 }, { 71, 61 }, { 77, 69 }, { 19, 69 } }
  for i = 1, 4 do local a, b = st[i], st[i % 4 + 1]; seg(a[1], a[2] - 5, b[1], b[2] - 5, CREAM) end
  -- easel shadow (hard, lower right)
  local sh = c:poly{ { 40, 66 }, { 60, 66 }, { 70, 69 }, { 50, 69 } }
  c:fillMask(sh, SHD_A) R(48, 69, 68, 69, SHD_B)
  -- easel legs + ledge
  local legL = c:line({ { 42, 56 }, { 39, 66 } }, 1)
  local legR = c:line({ { 54, 56 }, { 57, 66 } }, 1)
  local legB = c:line({ { 48, 56 }, { 48, 63 } }, 1)
  local ledge = c:rect(35, 57, 61, 58)
  local sx = ({ 0, 1, 1, 0 })[f]
  local board = c:rect(36 + sx, 40, 60 + sx, 56)
  ink(legL, legR, legB, ledge, board)
  c:fillMask(legB, WOOD.deep)
  c:part(legL, WOOD, { band = 1, nopop = true }) c:part(legR, WOOD, { band = 1, nopop = true })
  c:part(ledge, WOOD, { band = 1 })
  R(35, 57, 61, 57, WOOD.hi)
  -- board: wood frame, slate face
  c:part(board, WOOD, { band = 1, nopop = true })
  R(37 + sx, 41, 59 + sx, 55, SLATE)
  R(37 + sx, 41, 59 + sx, 41, SLATE2) R(37 + sx, 41, 37 + sx, 55, SLATE2)
  px(36 + sx, 40, WOOD.hi) px(37 + sx, 40, WOOD.hi)
  -- tiny pot icon (chalk-bright glaze)
  local ox = 48 + sx
  px(ox, 42, GOLD.hi)
  R(ox - 2, 44, ox + 2, 44, STONE.hi) R(ox - 1, 43, ox + 1, 43, STONE.hi)
  R(ox - 3, 45, ox + 3, 47, EMBER.base)
  R(ox - 3, 47, ox + 3, 47, EMBER.shade) R(ox - 2, 45, ox, 45, EMBER.hi)
  px(ox - 4, 45, STONE.hi) px(ox + 4, 45, STONE.hi)
  px(ox + 3, 47, EMBER.deep)
  build(39 + sx, 50, CREAM)
  px(58 + sx, 54, "#8da39a")   -- chalk smudge
  px(54, 57, CREAM) px(55, 57, CREAM)   -- chalk stub on the ledge
  -- stakes (drawn over the string)
  for _, s in ipairs(st) do
    local m = c:rect(s[1], s[2] - 5, s[1], s[2])
    ink(m) c:fillMask(m, WOOD.base) px(s[1], s[2] - 5, WOOD.hi)
  end
  -- stones, flowers, a wooden spoon
  for _, p in ipairs{ { 30, 67 }, { 64, 66 }, { 22, 63 } } do
    local m = c:ellipse(p[1], p[2], 1, 1); ink(m); c:part(m, STONE, { band = 1 })
  end
  local function flower(x, y, col)
    local stem = c:rect(x, y + 1, x, y + 3)
    local head = HP.mask():set(x, y - 1):set(x - 1, y):set(x, y):set(x + 1, y):set(x, y + 1)
    ink(stem, head); c:fillMask(stem, MOSS.base); c:fillMask(head, col); px(x, y, GOLD.hi)
  end
  flower(25, 66, PETAL.base) flower(69, 67, SKY.hi) flower(13, 66, GOLD.base)
  local handle = c:line({ { 76, 64 }, { 73, 60 } }, 1)
  local bowl = c:ellipse(77, 66, 1, 1)
  ink(handle, bowl) c:fillMask(handle, WOOD.base) c:part(bowl, WOOD, { band = 1 })
  -- blowing leaf (life detail)
  local lp = { { 9, 47 }, { 30, 51 }, { 55, 45 }, { 80, 51 } }
  local lx, ly = lp[f][1], lp[f][2]
  local leaf = HP.mask():set(lx, ly):set(lx + 1, ly):set(lx + 2, ly - 1):set(lx + 1, ly + 1):set(lx + 2, ly)
  ink(leaf) c:fillMask(leaf, MOSS.base) px(lx + 1, ly, MOSS.hi) px(lx + 2, ly, MOSS.shade)
  return c
end

------------------------------------------------------------ badge
local BOB = { 0, -1, 0, 1 }
local function badge(cy)
  local m = c:ellipse(90, cy, 4, 4)
  ink(m)
  c:part(m, GOLD)
  R(89, cy - 2, 90, cy + 0, CREAM) R(89, cy + 2, 90, cy + 2, CREAM)
end

local function save(cv, name)
  HP.assertClean(cv)
  cv:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
for lvl = 1, 3 do save(shifted(kitchen(lvl), DY), "kitchen-l" .. lvl) end
local function strip(frames, name, tag)
  HP.sheet{ cellw = W_, cellh = H_, frames = frames, tags = { { name = tag, from = 1, to = 4 } } }:save{
    aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
local fr = {}
for f = 1, 4 do fr[f] = empty(f); HP.assertClean(fr[f]) end
strip(fr, "kitchen-empty", "empty")
-- ready
local STA = { { { 26, 50, 1 } }, { { 26, 50, 2 } }, { { 26, 50, 2 }, { 27, 46, 1 } }, { { 26, 50, 2 }, { 25, 46, 2 } } }
local STB = {
  { { 36, 50, 2 } },
  { { 36, 50, 2 }, { 37, 46, 2 } },
  { { 36, 50, 2 }, { 35, 46, 2 }, { 37, 42, 2 } },
  { { 36, 50, 3 }, { 37, 45, 3 }, { 35, 40, 3 } },
}
fr = {}
for f = 1, 4 do
  local k = shifted(kitchen(1, f), DY)
  c = k
  puffs(STA[f], STM)
  puffs(STB[f], STM)
  badge(8 + BOB[f])
  HP.assertClean(c)
  fr[f] = c
end
strip(fr, "kitchen-ready", "ready")
