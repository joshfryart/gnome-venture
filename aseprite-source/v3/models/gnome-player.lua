-- gnome-player PASS 2 (final). 64x80 cell, 3/4 top-down, feet baseline y=70. idle(2) + walk(4).
-- Also writes gnome-player-grey (hat + beard in light stone for multiply tint).
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local SUF = app.params.suffix or ""
local function cp(r) return { hi = r.hi, base = r.base, shade = r.shade, deep = r.deep } end
-- light stone (spec 5.3: tint layers use stone.hi/base/shade); cream is the pop
local LSTONE = { hi = P.cream, base = P.stone.hi, shade = P.stone.base, deep = P.stone.shade }

-- form: flat base, cylinder shade band (right fraction of each row) + lower-right offset band, optional pop
local function form(c, m, r, o)
  o = o or {}
  r = type(r) == "string" and P[r] or r
  c:part(m, r, { noshade = true, nopop = true, inner = o.inner })
  if not o.noshade then
    local rows = {}
    m:each(function(x, y) local t = rows[y]
      if not t then rows[y] = { x, x } else t[1] = math.min(t[1], x) t[2] = math.max(t[2], x) end end)
    local frac, off = o.frac or 0.3, o.off or 2
    local list = {}
    m:each(function(x, y)
      if c:get(x, y) ~= r.base:lower() then return end
      local t = rows[y]
      local s = (x - t[1] + 0.5) / (t[2] - t[1] + 1) > 1 - frac
      if not m:has(x + off, y + off) then s = true end
      if s then list[#list + 1] = { x, y } end
    end)
    for _, p in ipairs(list) do c:put(p[1], p[2], r.shade, r) end
  end
  if o.pop then c:put(o.pop[1], o.pop[2], r.hi, r) c:put(o.pop[1] + 1, o.pop[2], r.hi, r) end
  return m
end

-- deep underside row: pixels of mask m whose lower neighbour is outside m
local function under(c, m, hex, x0, x1)
  m:each(function(x, y) if not m:has(x, y + 1) and (not x0 or (x >= x0 and x <= x1)) then c:put(x, y, hex) end end)
end

-- remap: fold rarely used tones into a neighbour so the sprite stays near the colour budget
local function remap(c, map)
  local m = {}
  for k, v in pairs(map) do m[k:lower()] = v:lower() end
  for i, h in pairs(c.pix) do if m[h] then c.pix[i] = m[h] end end
end
local function frame(p, grey)
  local c = HP.canvas{ w = 64, h = 80, name = "gnome" }
  local b, sx = -p.bob, p.sx or 0
  local function X(x) return x + sx end
  local hat = grey and LSTONE or P.ember
  local beard = LSTONE
  c:groundShadow(31.5, 68.5, 13.5, 3.5)
  -- boots with a little pointed toe turned outward; lifted foot rises, tucks under the hem
  local function boot(x, dy, dir)
    local m = c:ellipse(x, 68 + dy, 3.5, 2)
    m:add(c:rect(x + dir * 4, 68 + dy, x + dir * 4, 69 + dy))
    form(c, m, cp(P.wood), { frac = 0.35, off = 1 })
    under(c, m, P.wood.deep)
  end
  boot(27, p.ly or 0, -1) boot(38, p.ry or 0, 1)
  -- tunic: flared cylinder, hem curve with a deep underside row (form, not a flat cut)
  local hs = p.hem or 0
  local tunic = c:poly{ {X(24), 45 + b}, {X(42), 45 + b}, {X(47), 61 + b}, {X(19), 61 + b} }
  tunic:add(c:ellipse(X(33) + hs, 62 + b, 13.5, 4.5))
  form(c, tunic, "sea", { frac = 0.3, off = 2 })
  under(c, tunic, P.sea.deep)
  -- sleeves (cuff flare) + mitten hands, swing 2px opposite
  local la, ra = (p.arm or 0) * 2, -(p.arm or 0) * 2
  local SL = cp(P.sea)
  local function sleeve(x0, dy, dir)
    local m = c:poly{ {X(x0 + 1), 46 + b}, {X(x0 + 4), 46 + b}, {X(x0 + 4 + (dir > 0 and 1 or 0)), 54 + b + dy}, {X(x0 - (dir < 0 and 1 or 0)), 54 + b + dy} }
    form(c, m, SL, { frac = dir < 0 and 0.35 or 0.55, off = 1 })
    under(c, m, P.sea.deep)
    form(c, c:ellipse(X(x0 + 2) + (dir < 0 and 0 or 1), 55.5 + b + dy, 2, 1.5), cp(P.skinA), { off = 1, frac = 0.35 })
  end
  sleeve(17, la, -1) sleeve(45, ra, 1)
  -- scarf ring + knotted tail with darker fringe (tail lags 1px in walk)
  form(c, c:rrect(X(19), 44 + b, X(47), 48 + b, 2), "gold", { frac = 0.25, off = 1 })
  local tl = p.tail or 0
  local tail = c:poly{ {X(42), 47 + b}, {X(47), 47 + b}, {X(48) + tl, 55 + b}, {X(44) + tl, 55 + b} }
  form(c, tail, cp(P.gold), { frac = 0.45, off = 1 })
  for x = 44, 48 do if (x % 2 == 0) then c:put(X(x) + tl, 55 + b, P.gold.shade) end end
  -- head + ears
  form(c, c:ellipse(X(33), 39 + b, 10, 6), "skinA", { frac = 0.25, off = 1 })
  form(c, c:poly{ {X(24), 38 + b}, {X(19), 36 + b}, {X(21), 41 + b}, {X(24), 42 + b} }, cp(P.skinA), { off = 1, frac = 0.2 })
  form(c, c:poly{ {X(42), 38 + b}, {X(47), 36 + b}, {X(45), 41 + b}, {X(42), 42 + b} }, cp(P.skinA), { off = 1, frac = 0.6 })
  -- beard: scalloped fluffy bottom, strands, curl at the tip
  local bm = c:poly{ {X(23), 42 + b}, {X(44), 42 + b}, {X(46), 47 + b}, {X(43), 53 + b}, {X(23), 53 + b}, {X(20), 47 + b} }
  bm:add(c:ellipse(X(26), 53 + b, 3, 2.5)) bm:add(c:ellipse(X(40), 53 + b, 3, 2.5))
  bm:add(c:ellipse(X(33), 56 + b, 4, 3))
  bm:add(c:poly{ {X(23), 52 + b}, {X(44), 52 + b}, {X(40), 56 + b}, {X(26), 56 + b} })
  form(c, bm, beard, { frac = 0.3, off = 2, pop = { X(24), 47 + b } })
  -- scallop clefts (shade notches between the three lobes), no loose strands
  for _, q in ipairs({ { 29, 55 }, { 29, 54 }, { 37, 55 }, { 37, 54 } }) do c:put(X(q[1]), q[2] + b, beard.shade) end
  -- moustache: one wide shape whose ends curl up
  local MU = cp(LSTONE)
  local ml = c:ellipse(X(30), 45 + b, 3.5, 1.5) ml:add(c:rect(X(26), 43 + b, X(26), 44 + b))
  local mr = c:ellipse(X(37), 45 + b, 3.5, 1.5) mr:add(c:rect(X(41), 43 + b, X(41), 44 + b))
  form(c, ml, MU, { off = 1, frac = 0.15, inner = false })
  form(c, mr, MU, { off = 1, frac = 0.35, inner = false })
  c:put(X(33), 45 + b, beard.shade) c:put(X(33), 46 + b, beard.shade)
  -- nose (big, round, the face's anchor)
  local nose = c:ellipse(X(33.5), 42.5 + b, 2.5, 2)
  form(c, nose, cp(P.skinA), { off = 1, frac = 0.35, inner = false })
  under(c, nose, P.skinA.shade)
  c:put(X(32), 41 + b, P.cream)
  -- eyes, cheeks
  c:eyeSmall(X(28), 39 + b) c:eyeSmall(X(38), 39 + b)
  c:cheek(X(25), 42 + b) c:cheek(X(41), 42 + b)
  -- hat: tall cone, bigger rim ellipse (we look down on it), droopy tip, fold crease, bell
  local hm = c:poly{ {X(19), 34 + b}, {X(47), 34 + b}, {X(44), 29 + b}, {X(40), 23 + b}, {X(36), 18 + b},
    {X(32), 15 + b}, {X(29), 15 + b}, {X(27), 17 + b}, {X(25), 22 + b}, {X(22), 29 + b} }
  hm:add(c:ellipse(X(33), 33.5 + b, 14, 3.5))
  form(c, hm, hat, { frac = 0.36, off = 2, pop = { X(27), 23 + b } })
  under(c, hm, hat.deep, X(22), X(44))
  local bx, by = (p.bell or 0), (p.bdy or 0)
  local flop = c:line({ { X(30), 15 + b }, { X(27), 14 + b }, { X(24), 15 + b }, { X(22) + bx, 18 + b + by } }, 3)
  form(c, flop, cp(hat), { off = 1, frac = 0.25 })
  c:put(X(29), 17 + b, hat.deep) c:put(X(28), 18 + b, hat.deep) c:put(X(30), 17 + b, hat.shade)
  local bell = c:ellipse(X(21.5) + bx, 21.5 + b + by, 2, 2)
  form(c, bell, "gold", { off = 1, frac = 0.3 })
  c:put(X(21) + bx, 23 + b + by, P.gold.deep) c:put(X(22) + bx, 23 + b + by, P.gold.deep)
  -- hat band stitch along the front rim arc (the one seam)
  local pts = {}
  for x = 21, 45, 2 do pts[#pts + 1] = { X(x), math.floor(33.5 + 3.5 * math.sqrt(math.max(0, 1 - ((x - 33) / 14.5) ^ 2)) - 1.5 + b + 0.5) } end
  c:stitch(pts)
  remap(c, { [P.gold.deep] = P.wood.deep, [P.skinA.deep] = P.wood.deep })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end

local idle = { { bob = 0 }, { bob = 1, bdy = 1 } }
local walk = {
  { bob = 0, ly = 2, ry = -2, arm = -1, bell = 1, hem = 1, tail = 0 },
  { bob = 1, ly = 0, ry = -3, arm = 0, sx = -1, bell = 0, bdy = 1, tail = 1 },
  { bob = 0, ly = -2, ry = 2, arm = 1, bell = -1, hem = -1, tail = 0 },
  { bob = 1, ly = -3, ry = 0, arm = 0, sx = 1, bell = 0, bdy = 1, tail = -1 },
}
local function sheet(grey, name)
  local fr = {}
  for _, p in ipairs(idle) do fr[#fr + 1] = frame(p, grey) end
  for _, p in ipairs(walk) do fr[#fr + 1] = frame(p, grey) end
  local s = HP.sheet{ cellw = 64, cellh = 80, frames = fr, tags = { { name = "idle", from = 1, to = 2 }, { name = "walk", from = 3, to = 6 } } }
  s:save{ aseprite = out .. name .. SUF .. ".aseprite", png = out .. name .. SUF .. ".png", scale = 1 }
  if SUF == "" then s:save{ png = out .. name .. "_x4.png", scale = 4 } end
end
sheet(false, "gnome-player")
sheet(true, "gnome-player-grey")
