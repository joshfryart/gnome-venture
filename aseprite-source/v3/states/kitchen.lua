-- kitchen state sprites (Hearth Pop v3, volume kit from garden-patch6.lua). 96x80, feet centre (48,68).
-- Outputs: kitchen-empty, kitchen-l1, kitchen-l2, kitchen-l3 (.png/.aseprite) and kitchen-ready (4-frame strip).
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local floor = math.floor

local INK, CREAM = P.ink, P.cream
local STONE, GOLD, WOOD, MOSS, EMBER, PETAL, SEA = P.stone, P.gold, P.wood, P.moss, P.ember, P.petal, P.sea
local ROOF = { hi = P.ember.hi, base = P.ember.base, shade = P.ember.shade, deep = P.ember.deep }
local PLASTER = { hi = P.cream, base = "#f6dfae", shade = P.wood.hi, deep = P.wood.base }
local INTERIOR = "#3b2c48"
local SHD_A, SHD_B = "#7d6a84", "#55445f"   -- cast shadow (cool violet, hard), contact row
local DUSKSH = "#5a4660"
local GLASS_HI, GLASS_LO = GOLD.hi, GOLD.base
local c   -- canvas currently drawn into

------------------------------------------------------------ helpers
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
local function seg(x0, y0, x1, y1, hex)   -- 1 px line
  local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    px(floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5), hex)
  end
end
-- ink outline: one 1 px ring outside the union of the given masks, painted before the fills
local function ink(...)
  local u = HP.mask()
  for _, m in ipairs({ ... }) do u:add(m) end
  c:rim(u, INK)
  return u
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
-- roof: tile courses on the lit slope, cool hip plane, ridge and eave edges
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
-- recessed window: frame, glass (lit or dim), dark inner top/left edge, cross bar, sill, optional shutters
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
  R(wx - 2, wy + h, wx + w + 1, wy + h, P.stone.hi)
  R(wx - 1, wy + h + 1, wx + w + 1, wy + h + 1, o.sillsh or P.stone.shade)
  if o.shut then
    local S = o.shut
    for _, sx in ipairs{ wx - 3, wx + w + 1 } do
      R(sx, wy - 1, sx + 1, wy + h - 1, S.base)
      for yy = wy, wy + h - 1, 2 do R(sx, yy, sx + 1, yy, S.shade) end
      px(sx, wy - 1, S.hi)
    end
  end
end
-- recessed plank door with frame, arch, shadowed jamb, handle and a lit step
local function door(dx0, dx1, dy0, yb, o)
  o = o or {}
  local Rw = WOOD
  local fr = o.frame or Rw.deep
  c:fillMask(c:rrect(dx0 - 1, dy0 - 1, dx1 + 1, yb, o.arch or 2), fr)
  local leaf = c:rrect(dx0, dy0, dx1, yb, math.max((o.arch or 2) - 1, 0))
  c:fillMask(leaf, Rw.base)
  for xx = dx0 + 2, dx1 - 1, 2 do leaf:each(function(x, y) if x == xx then px(x, y, Rw.shade) end end) end
  leaf:each(function(x, y) if not leaf:has(x, y - 1) or x == dx0 then px(x, y, lerp(Rw.shade, Rw.deep, .5)) end end)
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
-- hard cast shadow to the lower right (solid cool violet; the sprite has no ground to tint)
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
-- a small iron cooking pot with a lid (lid can rattle sideways by dx)
local function pot(cx, ytop, dx, ramp)
  dx = dx or 0
  ramp = ramp or STONE
  local body = c:rrect(cx - 2, ytop + 2, cx + 2, ytop + 5, 1)
  local lid = c:rect(cx - 3 + dx, ytop + 1, cx + 3 + dx, ytop + 1)
  local knob = HP.mask():set(cx + dx, ytop)
  local ears = HP.mask():set(cx - 3, ytop + 3):set(cx + 3, ytop + 3)
  ink(body, lid, knob, ears)
  c:part(body, ramp)
  c:part(lid, ramp, { band = 1 })
  c:part(ears, ramp, { band = 1 })
  px(cx + dx, ytop, CREAM)
end
-- outlined cloud made of round puffs (smoke, steam)
local function puffs(list, ramp)
  local u = HP.mask()
  for _, p in ipairs(list) do u:add(c:ellipse(p[1], p[2], p[3], p[3])) end
  ink(u)
  c:part(u, ramp or STONE)
end
local CURL = { { 0, 0, 0 }, { -2, 1, -2 }, { 1, -2, 1 }, { -1, 2, -1 } }
local function smoke(cx, top, f)
  local d = CURL[f or 1]
  puffs({ { cx + d[1], top - 3, 2 }, { cx + 1 + d[2], top - 7, 2 }, { cx - 1 + d[3], top - 11, 3 } }, STONE)
end
local STEAM = {   -- steam above pot B (cx 29), growing over the ready frames
  { { 29, 54, 1 } },
  { { 29, 53, 1 }, { 30, 50, 1 } },
  { { 29, 53, 2 }, { 30, 49, 1 } },
  { { 29, 52, 2 }, { 29, 48, 2 } },
}
local LID_DX = { 0, -1, 0, 1 }            -- lid rattle
local BOB = { 0, -1, 0, 1 }               -- badge bob, 1 px
local GLASS = { GLASS_HI, GLASS_LO, GLASS_HI, GLASS_LO }   -- window flicker
local function badge(cy)
  local m = c:ellipse(87, cy, 4, 4)
  ink(m)
  c:part(m, GOLD)
  R(86, cy - 3, 87, cy, INK)      -- the '!' bar
  R(86, cy + 2, 87, cy + 3, INK)  -- and its dot
  px(84, cy - 2, CREAM)
end

------------------------------------------------------------ the kitchen
-- lvl 1: base cottage. lvl 2: third pot, wider chimney with herbs, awning, firewood, window box.
-- lvl 3: fourth pot on a feast table, timber wing with its own roof, gold chimney, bunting, copper rack, lantern.
local function kitchen(lvl, f)
  c = HP.canvas{ w = 96, h = 80, scale = 1, name = "kitchen-l" .. lvl }
  local x0, x1, yt, d, y = 26, 65, 44, 5, 68
  castShadow(x0, x1, y, d, 12, 6)
  local front, side = c:rect(x0, yt, x1, y), sideWall(x1, yt, y, d, 1)
  local F, S = hipRoof(x0, x1, yt - 1, y - 43, 4, 18, d)
  local chim, chs, cap
  if lvl == 3 then
    chim, chs, cap = c:rect(54, 12, 61, 36), sideWall(61, 12, 35, 2), c:rect(53, 10, 64, 11)
  elseif lvl == 2 then
    chim, chs, cap = c:rect(54, 22, 60, 36), sideWall(60, 22, 35, 2), c:rect(53, 20, 61, 21)
  else
    chim, chs, cap = c:rect(55, 22, 59, 36), sideWall(59, 22, 35, 2), c:rect(54, 20, 61, 21)
  end
  local F2, S2 = F:copy():cut(chim):cut(chs), S:copy():cut(chim):cut(chs)
  ink(front, side, F, S, chim, chs, cap)
  local W = wallTones(PLASTER.base, P.cream)
  paintWalls(front, side, W, 2)
  roof(F2, S2, ROOF, 2)
  -- chimney: brick courses, cool side, capped
  c:fillMask(chim, STONE.base) c:fillMask(chs, STONE.shade)
  local cx0, cx1 = chim:bbox()
  local _, ctop = cap:bbox()
  for yy = ctop + 3, 35, 3 do R(cx0, yy, cx1, yy, lerp(STONE.base, STONE.shade, .5)) end
  c:fillMask(cap, lvl == 3 and GOLD.base or STONE.shade)
  R(cx0 - 1, ctop, cx1 + 1, ctop, lvl == 3 and GOLD.hi or STONE.hi)
  if lvl == 3 then   -- gold trim bands on the big chimney
    R(cx0, 16, cx1, 17, GOLD.base) R(cx0, 16, cx1, 16, GOLD.hi)
    R(cx1 + 1, 16, cx1 + 2, 17, GOLD.shade)
  end
  eaveShadow(x0, x1, yt, d, W, 2)
  quoins(x0, yt + 3, y - 4, 1, CREAM, W.dark)
  quoins(x1, yt + 3, y - 4, -1, CREAM, W.dark)
  plinth(x0, x1, y, d, 3)
  -- side wall: a small round window
  R(67, 51, 69, 54, WOOD.shade) R(68, 52, 68, 53, INTERIOR) px(69, 53, WOOD.base)
  -- door, lintel, windows (glass flickers in the ready frames)
  door(43, 49, 52, 68, { frame = WOOD.deep, arch = 3, lintel = STONE.base })
  local SH = { hi = MOSS.hi, base = MOSS.base, shade = MOSS.shade }
  local g = f and GLASS[f] or GLASS_HI
  window(29, 49, 6, 7, { glass = g, rec = GLASS_LO, frame = WOOD.shade, shut = SH, sillsh = W.eave })
  window(56, 49, 6, 7, { glass = g, rec = GLASS_LO, frame = WOOD.shade, shut = SH, sillsh = W.eave })

  -- bench in front of the wall, with pots on it
  local bench = c:rect(20, 62, 41, 68)
  ink(bench)
  c:part(bench, STONE)
  for xx = 24, 40, 5 do px(xx, 64, STONE.shade) px(xx, 65, STONE.shade) end
  local lidDx = f and LID_DX[f] or 0
  pot(29, 56, lidDx)
  pot(37, 56, 0)
  if lvl >= 2 then
    -- third pot
    pot(22, 56, 0)
    -- herb bunch hanging from the chimney on a string
    seg(52, 22, 52, 26, WOOD.deep)
    local herb = c:ellipse(51, 28, 2, 3)
    ink(herb)
    c:part(herb, MOSS)
    px(50, 26, MOSS.hi)
    -- striped lean-to awning over the door
    local awn = c:poly{ { 38, 46 }, { 53, 46 }, { 55, 49 }, { 36, 49 } }
    ink(awn)
    for k = 0, 8 do
      local sx = 36 + k * 3
      local strip = c:rect(sx, 46, sx + 2, 48):clip(awn)
      c:fillMask(strip, k % 2 == 0 and EMBER.base or CREAM)
    end
    awn:each(function(x, y) if y == 49 then px(x, y, ((x - 36) // 3) % 2 == 0 and EMBER.shade or lerp(CREAM, DUSKSH, .15)) end end)
    -- window box with flowers under the right window
    local box = c:rect(55, 58, 62, 59)
    ink(box)
    c:part(box, WOOD)
    px(56, 57, PETAL.base) px(58, 57, GOLD.hi) px(60, 57, PETAL.hi) px(62, 57, PETAL.base)
    px(57, 57, MOSS.base) px(59, 57, MOSS.shade) px(61, 57, MOSS.base)
    -- firewood stack on the right side wall
    for i = 0, 2 do
      local lg = c:rect(71, 60 + 2 * i, 76, 61 + 2 * i)
      ink(lg)
      c:part(lg, WOOD)
      px(71, 60 + 2 * i, WOOD.hi) px(71, 61 + 2 * i, WOOD.base)
    end
    R(70, 66, 77, 67, WOOD.deep)
  end
  if lvl == 3 then
    -- timber wing with its own small roof, and a lit window
    local wing = c:rect(71, 47, 78, 68)
    local wroof = c:poly{ { 70, 47 }, { 72, 41 }, { 79, 41 }, { 79, 47 } }
    ink(wing, wroof)
    c:part(wing, WOOD)
    for xx = 73, 77, 3 do R(xx, 47, xx, 68, WOOD.shade) end
    c:part(wroof, ROOF)
    window(73, 51, 4, 5, { glass = g, rec = GLASS_LO, frame = WOOD.shade })
    -- bunting along the eave, split by the awning
    seg(24, 45, 37, 45, WOOD.deep) seg(55, 45, 66, 45, WOOD.deep)
    local cols = { EMBER.base, GOLD.base, MOSS.base, PETAL.base }
    local fl = { 25, 29, 33, 56, 60, 64 }
    for i, fx in ipairs(fl) do
      R(fx, 46, fx + 2, 46, cols[(i - 1) % 4 + 1]) px(fx + 1, 47, cols[(i - 1) % 4 + 1])
    end
    -- copper pot-hanger rack beside the door, with two hanging pans
    local rail = c:rect(37, 50, 40, 50)
    ink(rail)
    c:fillMask(rail, GOLD.shade)
    local pa = c:rect(37, 51, 38, 53)
    local pb = c:rect(40, 51, 41, 54)
    ink(pa, pb)
    c:part(pa, GOLD) c:part(pb, GOLD)
    -- lantern on a post at the far left
    local post = c:rect(18, 49, 18, 67)
    ink(post)
    c:fillMask(post, WOOD.shade)
    local lant = c:rect(17, 43, 21, 48)
    ink(lant)
    c:part(lant, GOLD)
    px(18, 44, CREAM)
    -- feast table outside, roast and goblets, a fourth pot
    local top = c:rect(66, 61, 80, 62)
    local legs = HP.mask():set(67, 63):set(67, 64):set(67, 65):set(67, 66):set(67, 67):set(67, 68)
    legs:add(HP.mask():set(79, 63):set(79, 64):set(79, 65):set(79, 66):set(79, 67):set(79, 68))
    ink(top, legs)
    c:fillMask(legs, WOOD.deep)
    c:part(top, WOOD)
    local roast = c:ellipse(69, 59, 2, 1)
    ink(roast)
    c:part(roast, GOLD)
    local g1, g2 = c:rect(66, 59, 67, 60), c:rect(73, 59, 74, 60)
    ink(g1, g2)
    c:fillMask(g1, SEA.hi) c:fillMask(g2, SEA.hi)
    pot(78, 55, 0, STONE)
  end
  -- smoke from the chimney (curl shape follows the ready frame when f is given)
  smoke(57, lvl == 3 and 10 or 20, f or 1)
  return c
end

------------------------------------------------------------ empty plot
local function empty()
  c = HP.canvas{ w = 96, h = 80, scale = 1, name = "kitchen-empty" }
  -- packed dirt patch, centred on the feet point
  local patch = c:ellipse(48, 68, 26, 7)
  ink(patch)
  c:part(patch, WOOD)
  for _, p in ipairs{ { 30, 72 }, { 44, 74 }, { 58, 72 }, { 36, 64 }, { 66, 68 }, { 52, 63 } } do
    px(p[1], p[2], STONE.base) px(p[1] + 1, p[2], STONE.shade)
  end
  -- four corner stakes joined by a string line
  local st = { { 27, 62 }, { 69, 62 }, { 74, 70 }, { 22, 70 } }
  for _, s in ipairs(st) do
    local m = c:rect(s[1], s[2] - 4, s[1], s[2])
    ink(m)
    c:fillMask(m, WOOD.base)
    px(s[1], s[2] - 4, WOOD.hi)
  end
  for i = 1, 4 do
    local a, b = st[i], st[i % 4 + 1]
    seg(a[1], a[2] - 4, b[1], b[2] - 4, CREAM)
  end
  -- small 'for building' signpost: a hammer on a board, no text
  local post = c:rect(59, 50, 60, 66)
  ink(post)
  c:fillMask(post, WOOD.shade)
  local board = c:rect(53, 43, 66, 49)
  ink(board)
  c:part(board, WOOD)
  R(56, 44, 61, 45, INK)                 -- hammer head
  R(58, 46, 59, 48, INK)                 -- handle
  px(54, 44, CREAM)
  -- three planks and a bucket
  for i = 0, 2 do
    local pl = c:rect(15, 60 + 2 * i, 25, 61 + 2 * i)
    ink(pl)
    c:part(pl, WOOD)
    px(15, 60 + 2 * i, WOOD.hi)
  end
  local bucket = c:poly{ { 71, 64 }, { 78, 64 }, { 77, 70 }, { 72, 70 } }
  seg(71, 63, 73, 59, STONE.shade) seg(73, 59, 77, 63, STONE.shade)
  ink(bucket)
  c:part(bucket, WOOD)
  R(72, 66, 77, 66, STONE.base)   -- hoop
  return c
end

------------------------------------------------------------ build and save
local function save(cv, name)
  HP.assertClean(cv)
  cv:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end

save(empty(), "kitchen-empty")
save(kitchen(1), "kitchen-l1")
save(kitchen(2), "kitchen-l2")
save(kitchen(3), "kitchen-l3")

-- ready: level 1 base, badge bobs, lid rattles, steam grows, smoke curls, window glow flickers
local frames = {}
for f = 1, 4 do
  kitchen(1, f)                 -- lid rattle, window flicker and smoke curl are set by frame f
  puffs(STEAM[f], P.sky)        -- growing steam over pot B
  badge(9 + BOB[f])
  frames[f] = c
end
HP.sheet{ cellw = 96, cellh = 80, frames = frames,
  tags = { { name = "ready", from = 1, to = 4 } } }:save{
  aseprite = out .. "kitchen-ready.aseprite", png = out .. "kitchen-ready.png", scale = 1 }
