-- Beehive state sprites (48x56, feet centre at (24,48)). Hearth Pop v3.
-- Run: AppRun -b --script-param out=/tmp/ase/states/beehive/ --script /tmp/ase/states/beehive.lua
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "/tmp/ase/states/beehive/"
local floor = math.floor

local c   -- current canvas (every helper below draws into it)
local function newc() c = HP.canvas{ w = 48, h = 56, scale = 1, name = "beehive" } return c end
local function px(x, y, hex) c:px(x, y, hex) end
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local function R(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end

local function hexrgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function lerp(a, b, t)
  local r1, g1, b1 = hexrgb(a); local r2, g2, b2 = hexrgb(b)
  return string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
local DUSKSH = "#5a4660"   -- cool violet for contact / cast shadows (never black)
local INTERIOR = "#3b2c48" -- dark hive mouth (cool, never black)
local THATCH = { hi = P.gold.hi, base = P.gold.base, shade = P.gold.shade, deep = P.gold.deep }
local WAX = { hi = P.cream, base = "#f6dfae", shade = "#e8c48a", deep = "#b97a4a" }

local function shadeUnder(m, t) m:each(function(x, y) local v = c:get(x, y); if v then px(x, y, lerp(v, DUSKSH, t)) end end) end
local function ink(...) local u = HP.mask() for _, m in ipairs{ ... } do u:add(m) end c:rim(u, P.ink) return u end

local function rampOf(r) if type(r) == "string" then return P[r] end return r end
local function step(x, y, r, dir)
  r = rampOf(r)
  local v = c:get(x, y); if not v then return end
  local T = { r.hi, r.base, r.shade, r.deep }
  for i = 1, 4 do
    if v == T[i] then
      local n
      if dir > 0 then n = (i == 3) and lerp(r.shade, r.deep, .45) or (i == 4) and nil or T[i + 1]
      else n = (i == 1) and lerp(r.hi, P.cream, .5) or (i == 4) and r.shade or T[i - 1] end
      if n then px(x, y, n) end
      return
    end
  end
end
local function dk(x, y, r) step(x, y, r, 1) end
-- straw lattice: a dark mark on some interior pixels (hard, no blending)
local function strands(m, r, y0, y1, every, gap)
  for y = y0, y1, gap or 2 do for x = 0, 47 do
    if m:has(x, y) and m:has(x - 1, y) and m:has(x + 1, y) and m:has(x, y + 1) and (x + y) % every == 0 then dk(x, y, r) end
  end end
end

-- sphere shading, 4 hard tones, lit from the upper left, reflected light on the lower-right edge
local LX, LY, LZ = -0.55, -0.62, 0.56
local function ball(m, cx, cy, rx, ry, T, o)
  o = o or {}
  local t1, t2, t3 = o.t1 or .62, o.t2 or .2, o.t3 or -.18
  m:each(function(x, y)
    local u, v = (x + .5 - cx - .5) / (rx + .5), (y + .5 - cy - .5) / (ry + .5)
    local q = 1 - u * u - v * v; if q < 0 then q = 0 end
    local l = LX * u + LY * v + LZ * math.sqrt(q)
    px(x, y, (l > t1 and T.hi) or (l > t2 and T.base) or (l > t3 and T.shade) or T.deep)
  end)
  if not o.norefl then
    m:each(function(x, y) if (not m:has(x + 1, y) or not m:has(x, y + 1)) and c:get(x, y) == T.deep and (x - cx) + (y - cy) * (rx / math.max(ry, 1)) > rx * .5 then px(x, y, T.shade) end end)
  end
end

-------------------------------------------------------------- ground
-- packed dirt patch (the plot). Outlined like any sprite piece.
local function patch()
  local m = c:rrect(4, 39, 44, 52, 4)
  ink(m)
  c:part(m, "wood", { band = 2, nopop = true })
  for _, p in ipairs{ { 9, 45 }, { 30, 50 }, { 39, 44 }, { 17, 51 }, { 26, 42 } } do px(p[1], p[2], P.wood.deep) end
  return m
end
-- cast shadow on the ground, lower right of the hive (only lands on dirt)
local function shadow(cx, cy, rx, ry) shadeUnder(E(cx, cy, rx, ry), .38) end

-- the wooden stand: one board on two trestles
local function stand()
  local board = c:rect(9, 40, 38, 41)
  local legs = c:rect(11, 42, 12, 47):add(c:rect(35, 42, 36, 47))
  ink(board, legs)
  c:part(legs, "wood", { band = 1, nopop = true })
  c:part(board, "wood", { band = 1, pop = { x = 12, y = 40, horizontal = true } })
end

-------------------------------------------------------------- small props
local function bee(x, y)
  local body = c:rect(x, y, x + 2, y + 1)
  local wing = c:rect(x + 1, y - 1, x + 2, y - 1)
  c:rim(HP.mask():add(body):add(wing), P.ink)
  c:fillMask(wing, P.sky.hi)
  c:fillMask(body, P.gold.base)
  px(x, y, P.gold.hi); px(x + 2, y + 1, P.gold.shade)
  px(x + 1, y, P.ink); px(x + 1, y + 1, P.ink)
end
local function flower(x, y, col)
  local head = HP.mask():set(x, y - 1):set(x - 1, y):set(x, y):set(x + 1, y):set(x, y + 1)
  local stem = c:rect(x, y + 2, x, y + 3)
  c:rim(HP.mask():add(head):add(stem), P.ink)
  c:fillMask(stem, P.moss.base)
  c:fillMask(head, col or P.petal.base)
  px(x, y, P.gold.hi)
end
local function jar(x, y)  -- 5 wide, 6 tall, (x,y) = top-left of the lid
  local lid = c:rect(x + 1, y, x + 3, y + 1)
  local body = c:rrect(x, y + 2, x + 4, y + 5, 1)
  ink(lid, body)
  c:part(body, "gold", { band = 2, pop = { x = x + 1, y = y + 3, horizontal = true } })
  c:part(lid, "wood", { band = 1, nopop = true })
end
local function candle(x, y)  -- 2 wide body, top-left (x,y); flame above
  local body = c:rect(x, y, x + 1, y + 4)
  local flame = c:rect(x, y - 3, x, y - 2)
  ink(body, flame)
  c:part(body, WAX, { band = 1, pop = { x = x, y = y + 1, horizontal = true } })
  c:fillMask(flame, P.gold.base); px(x, y - 3, P.gold.hi)
end
local function lamp()   -- a small post with a hook arm and a hanging lantern
  local pole = c:rect(5, 14, 5, 35):add(c:rect(6, 14, 8, 14))
  ink(pole)
  c:part(pole, "wood", { band = 1, nopop = true })
  local cap = c:rect(7, 15, 9, 15)
  local body = c:rect(7, 16, 9, 18)
  ink(cap, body)
  c:part(cap, "wood", { band = 1, nopop = true })
  c:part(body, "gold", { band = 1, pop = { x = 7, y = 16, horizontal = true } })
  px(8, 17, P.cream)
end

-------------------------------------------------------------- the skep
-- tiers top to bottom: { cx, cy, rx, ry }. Lower tiers overwrite the upper ones.
local function laterHas(ms, i, x, y) for j = i + 1, #ms do if ms[j]:has(x, y) then return true end end return false end
local function skep(tiers)
  local ms, u = {}, HP.mask()
  for i, t in ipairs(tiers) do ms[i] = E(t[1], t[2], t[3], t[4]); u:add(ms[i]) end
  c:rim(u, P.ink)
  for i, t in ipairs(tiers) do ball(ms[i], t[1], t[2], t[3], t[4], THATCH, { nospec = true }) end
  -- a dark groove where one tier tucks under the next
  for i = 1, #ms - 1 do
    ms[i]:each(function(x, y)
      -- visible bottom row of this tier, sitting just above the next tier: ink seam
      if not laterHas(ms, i, x, y) and laterHas(ms, i, x, y + 1) then px(x, y, P.ink) end
    end)
  end
  strands(u, "gold", 12, 40, 4, 2)
  return u
end
local function band(u, y0, y1)   -- decorative band: ember with cream beads
  u:each(function(x, y) if y >= y0 and y <= y1 then px(x, y, (x % 4 == 0) and P.cream or P.ember.base) end end)
end
local function hole(x0, y0, y1)  -- dark mouth with a lit lip underneath
  R(x0, y0, x0 + 2, y1, INTERIOR)
  R(x0, y1 + 1, x0 + 2, y1 + 1, P.gold.hi)
end

local L1T = { { 24, 21, 5, 4 }, { 24, 27, 7, 5 }, { 24, 33, 9, 6 } }
local L2T = { { 21, 16, 6, 4 }, { 21, 22, 8, 5 }, { 21, 28, 10, 5 }, { 21, 34, 12, 5 } }
local L3T = { { 25, 16, 6, 4 }, { 25, 22, 8, 5 }, { 25, 28, 10, 5 }, { 25, 34, 12, 5 } }

-------------------------------------------------------------- pieces
local function drawEmpty()
  newc()
  local dirt = patch()
  local function string(x0, y0, x1, y1) c:fillMask(c:line({ { x0, y0 }, { x1, y1 } }, 1), P.cream) end
  -- the string line first, then the four corner stakes on top
  string(6, 31, 40, 31); string(40, 31, 43, 42); string(43, 42, 5, 42); string(5, 42, 6, 31)
  local function stake(x, y0, y1) local m = c:rect(x, y0, x, y1); ink(m); c:part(m, "wood", { band = 1, nopop = true }) end
  stake(6, 31, 39); stake(40, 31, 39); stake(5, 42, 51); stake(43, 42, 51)
  -- 'for building' signpost: a hammer on a board, no text
  local post = c:rect(14, 22, 14, 39)
  ink(post); c:part(post, "wood", { band = 1, nopop = true })
  local board = c:rect(9, 14, 19, 21)
  ink(board); c:part(board, "wood", { band = 1, pop = { x = 10, y = 15, horizontal = true } })
  c:part(c:rect(12, 16, 16, 17), "stone", { band = 1, nopop = true })
  c:fillMask(c:rect(13, 18, 14, 20), P.wood.shade)
  -- stand and a few wildflowers
  stand()
  flower(8, 47, P.petal.base); flower(22, 48, P.sky.hi); flower(27, 51, P.gold.base); flower(40, 48, P.petal.base)
  return c
end

local function drawLevel1(bees)
  newc()
  patch(); shadow(31, 46, 12, 3)
  stand()
  skep(L1T)
  hole(23, 36, 38)
  if bees then bee(35, 14); bee(9, 22) end
  return c
end

local function drawLevel2()
  newc()
  patch(); shadow(29, 46, 13, 3)
  stand()
  local u = skep(L2T)
  band(u, 24, 25)
  hole(20, 33, 35)
  -- honey tray beside the skep: two jars
  local tray = c:rect(31, 42, 43, 43)
  local legs = c:rect(32, 44, 33, 47):add(c:rect(41, 44, 42, 47))
  ink(tray, legs)
  c:part(legs, "wood", { band = 1, nopop = true })
  c:part(tray, "wood", { band = 1, pop = { x = 32, y = 42, horizontal = true } })
  jar(33, 36); jar(38, 36)
  flower(6, 44, P.petal.base); flower(9, 47, P.gold.base); flower(45, 46, P.petal.base)
  bee(33, 8); bee(7, 16); bee(38, 20)
  return c
end

local function drawLevel3()
  newc()
  patch(); shadow(31, 46, 13, 3)
  stand()
  -- second, smaller skep behind the main one
  skep({ { 41, 40, 5, 4 }, { 41, 35, 3, 3 } })
  local u = skep(L3T)
  -- crown and finial
  local crown = c:rect(21, 10, 29, 11):add(c:rect(21, 8, 21, 9)):add(c:rect(29, 8, 29, 9)):add(c:rect(25, 7, 25, 9))
  local finial = c:rect(24, 4, 26, 6):add(c:rect(25, 2, 25, 3))
  ink(crown, finial)
  c:part(crown, "gold", { band = 1, nopop = true })
  c:part(finial, "gold", { band = 1, pop = { x = 24, y = 4, horizontal = true } })
  band(u, 24, 25)
  hole(24, 34, 36)
  -- beeswax candles on a small shelf
  local shelf = c:rect(1, 36, 11, 37)
  local posts = c:rect(2, 38, 2, 47):add(c:rect(10, 38, 10, 47))
  ink(shelf, posts)
  c:part(posts, "wood", { band = 1, nopop = true })
  c:part(shelf, "wood", { band = 1, pop = { x = 2, y = 36, horizontal = true } })
  candle(3, 31); candle(6, 31); candle(9, 31)
  lamp()
  -- honey jars at the front
  jar(14, 41); jar(20, 42)
  flower(5, 46, P.petal.base); flower(27, 46, P.gold.base); flower(31, 47, P.petal.base); flower(41, 47, P.sky.hi)
  bee(33, 3); bee(39, 11); bee(12, 5); bee(10, 12); bee(42, 24)
  return c
end

-- ready: level 1 base, bees on a loop, honey drip, sparkle and the badge
local ORBIT = {  -- top-left of each bee per frame
  { { 43, 23 }, { 10, 17 } },
  { { 23, 33 }, { 38, 17 } },
  { { 3, 23 }, { 37, 30 } },
  { { 23, 13 }, { 9, 30 } },
}
local DRIP = { { 33, nil }, { 35, 33 }, { 38, 33 }, { 41, 33 } }   -- { drop top y, trail start y }
local SPARK = { { 8, 13 }, { 13, 8 }, { 6, 22 }, { 40, 28 } }
local BOB = { 0, -1, 0, 1 }

local function badge(dy)
  local disc = E(40, 7 + dy, 4, 4)
  ink(disc)
  c:part(disc, "gold", { band = 2, pop = { x = 38, y = 5 + dy, horizontal = true } })
  c:fillMask(c:rect(40, 4 + dy, 40, 7 + dy), P.ink)
  c:fillMask(c:rect(40, 9 + dy, 40, 9 + dy), P.ink)
  px(37, 5 + dy, P.cream)
end

local function drawReady(k)
  drawLevel1(false)
  for _, b in ipairs(ORBIT[k]) do bee(b[1], b[2]) end
  local dy_, trail = DRIP[k][1], DRIP[k][2]
  if trail then c:fillMask(c:rect(27, trail, 27, dy_ - 1), P.gold.shade) end
  c:fillMask(c:rect(27, dy_, 28, dy_ + 1), P.gold.shade)
  px(27, dy_, P.gold.base)
  c:sparkle(SPARK[k][1], SPARK[k][2])
  badge(BOB[k])
  return c
end

-------------------------------------------------------------- output
local function save(canvas, name)
  HP.report(canvas, true)
  HP.assertClean(canvas)
  canvas:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end

save(drawEmpty(), "beehive-empty")
save(drawLevel1(true), "beehive-l1")
save(drawLevel2(), "beehive-l2")
save(drawLevel3(), "beehive-l3")
local frames = {}
for k = 1, 4 do frames[k] = drawReady(k) end
for k = 1, 4 do HP.assertClean(frames[k]) end
HP.sheet{ cellw = 48, cellh = 56, frames = frames, tags = { { name = "ready", from = 1, to = 4 } } }
  :save{ aseprite = out .. "beehive-ready.aseprite", png = out .. "beehive-ready.png", scale = 1 }
