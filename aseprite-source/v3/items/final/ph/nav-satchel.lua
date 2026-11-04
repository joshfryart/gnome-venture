-- nav-satchel (final, Opus single pass). A leather satchel: a slim arched carry handle (tube light, a stitched
-- edge groove) on two brass D-rings; a rounded body with pore grain, a bottom seam and AO under the flap; a domed
-- flap with a curved lip, gold saddle stitching along its edge and a contact shadow on the body; a bevelled brass
-- buckle with a dark eye, the strap tongue through it and a bright edge glint.
-- quirk: a little paper luggage tag on a twisted string hangs from the right ring, a red heart drawn on it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("nav-satchel")
local LEA  = { "#3a1d22", "#5c2f27", "#80462f", "#a5633b", "#c6834c", "#e2a96c" }
local DARK = { "#2e171e", "#4a2523", "#6a3828", "#8b4f32", "#ad6b40", "#cc8c56" }
local BRASS = { "#5a3418", "#8f5a1f", "#c08a2a", "#e2b442", "#f6d870", "#fff2b8" }
local TAG  = { "#a08562", "#d2b88a", "#ecd8aa", "#fbeccb" }
local STR  = { "#7a5a44", "#c8a878" }
local GOLD = "#f5b82e"

-- handle: arched tube from left ring over to right ring
local hp = { { 22, 28 }, { 21, 9 }, { 43, 9 }, { 42, 28 } }
local hm, hn, HT, HS = A.tube(hp, function(t) return 1.6 end)
local hi = A.shade(c, hm, hn, DARK, { wrap = 0.3 })
-- stitched edge groove along the handle (inner side), every other pixel
A.adjust(c, hm, hi, DARK, function(x, y)
  local k = K(x, y)
  if HS[k] and HS[k] > 0.25 and HS[k] < 0.75 and floor(HT[k] * 60) % 3 ~= 0 then return -1 end
end)

-- D-rings (brass) where the handle meets the body
local function dring(cx)
  local m = c:ellipse(cx, 28, 2, 2)
  m:cut(c:rect(cx - 2, 29, cx + 2, 30))
  m:each(function(x, y)
    local v = 4
    if x < cx or y < 27 then v = 5 end
    if x > cx and y >= 28 then v = 3 end
    c:put(x, y, BRASS[v])
  end)
  c:put(cx, 28, BRASS[1])
  c:put(cx - 1, 26, BRASS[6])
end
dring(22) dring(42)

-- body
local bm = c:rrect(13, 29, 51, 55, 6)
bm:cut(c:rect(13, 29, 15, 30)):cut(c:rect(49, 29, 51, 30))
local bn = X.pillow(bm, 4, 0.9)
local bi = A.shade(c, bm, bn, LEA, { wrap = 0.3 })
-- pore grain
A.adjust(c, bm, bi, LEA, function(x, y, i)
  local h = X.hash(x, y, 7)
  if h > 0.9 and i > 2 then return -1 end
  if h < 0.05 and i < 6 then return 1 end
end)
-- bottom seam: groove + lit lip
for x = 17, 47 do c:put(x, 51, LEA[2]) if c:get(x, 52) then c:put(x, 52, LEA[4]) end end

-- flap: top band plus a soft curved lip
local fm = c:rect(14, 29, 50, 38):add(c:ellipse(32, 38, 18, 7))
fm:clip(c:rect(14, 29, 50, 46))
fm:cut(c:rect(14, 29, 14, 29)):cut(c:rect(50, 29, 50, 29))
-- contact shadow of the flap on the body (2 rows) + AO
A.cast(c, bm, bi, LEA, fm, 0, 1, -2)
A.cast(c, bm, bi, LEA, fm, 1, 2, -1)
local fn = X.pillow(fm, 3.2, 1)
local fbias = {}
fm:each(function(x, y) if y <= 30 then fbias[K(x, y)] = -1 end end)   -- fold where the flap bends over the top
local fi = A.shade(c, fm, fn, LEA, { bias = fbias, wrap = 0.3 })
A.adjust(c, fm, fi, LEA, function(x, y, i)
  local h = X.hash(x, y, 3)
  if h > 0.92 and i > 2 then return -1 end
  if y == 32 and x > 15 and x < 49 then return 1 end                 -- crease highlight
end)
-- saddle stitching 2 px inside the flap edge (sides + curve), 2 on 1 off
local inner = fm:shrink(2)
local ring = inner:edge()
ring:each(function(x, y)
  if y >= 33 then
    local ang = math.atan(y - 38, x - 32)
    local d = floor((ang * 18) + 100) % 3
    if d ~= 0 then c:put(x, y, GOLD) end
  end
end)

-- strap tongue running down from the flap lip into the buckle
local sm = c:rect(29, 42, 35, 50)
sm:each(function(x, y)
  local v = 3
  if x == 29 then v = 4 end if x == 35 then v = 2 end
  c:put(x, y, DARK[v + 1])
end)
for x = 29, 35 do c:put(x, 51, DARK[2]) end                          -- AO under the strap end
-- buckle: bevelled brass frame with a dark eye and prong
local km = c:rrect(27, 41, 37, 47, 1)
local kn = X.pillow(km, 1.5, 1.2)
local ki = A.shade(c, km, kn, BRASS, { wrap = 0.2 })
for y = 43, 45 do for x = 29, 35 do c:put(x, y, DARK[3]) end end    -- the eye shows the strap
for x = 29, 35 do c:put(x, 43, DARK[1]) end
for y = 43, 45 do c:put(32, y, BRASS[3]) end                         -- prong
c:put(32, 43, BRASS[5])
c:put(28, 41, BRASS[6]) c:put(29, 41, BRASS[6])                      -- bright edge glint

-- quirk: luggage tag on a twisted string from the right ring
for i, p in ipairs{ { 43, 30 }, { 44, 31 }, { 44, 32 }, { 45, 33 } } do c:put(p[1], p[2], STR[(i % 2) + 1]) end
local tm = c:poly{ { 44, 34 }, { 49, 32 }, { 52, 39 }, { 47, 41 } }
local ti = {}
tm:each(function(x, y) local v = 3
  if (x - 44) * 0.4 - (y - 34) > -1.0 then v = 4 end
  if x * 0.4 + y > 52 * 0.4 + 38 then v = 2 end
  c:put(x, y, TAG[v]) end)
c:put(46, 34, TAG[1])                                                  -- string hole
-- tiny red heart
c:put(47, 36, "#d83a48") c:put(49, 36, "#d83a48")
c:put(47, 37, "#b52e3f") c:put(48, 37, "#d83a48") c:put(49, 37, "#b52e3f")
c:put(48, 38, "#b52e3f")
-- tag contact shadow on the flap
for _, p in ipairs{ { 48, 42 }, { 49, 42 }, { 53, 39 }, { 53, 40 } } do
  if fi[K(p[1], p[2])] then c:put(p[1], p[2], LEA[2]) end
end

A.save(c, "nav-satchel")
