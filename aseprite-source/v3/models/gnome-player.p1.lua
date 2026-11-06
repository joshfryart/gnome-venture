-- gnome-player PASS 1 (form). 64x80 cell, 3/4 top-down, feet baseline y=70. idle(2) + walk(4).
-- Also writes gnome-player-grey (hat + beard in light stone for multiply tint).
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local SUF = app.params.suffix or ".p1"
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

local function frame(p, grey)
  local c = HP.canvas{ w = 64, h = 80, name = "gnome" }
  local b, sx = -p.bob, p.sx or 0
  local function X(x) return x + sx end
  local hat = grey and LSTONE or P.ember
  local beard = LSTONE
  c:groundShadow(31.5, 68.5, 13.5, 3.5)
  -- boots (feet stay put; lifted foot rises and tucks under hem)
  local function boot(x, dy, lift)
    local m = c:ellipse(x, 68 + dy, 3.5, 2)
    form(c, m, "wood", { frac = 0.35, off = 1 })
  end
  boot(27, p.ly or 0) boot(38, p.ry or 0)
  -- tunic: cylinder with curved hem
  local tunic = c:poly{ {X(23), 45 + b}, {X(43), 45 + b}, {X(46), 60 + b}, {X(20), 60 + b} }
  tunic:add(c:ellipse(X(33), 61 + b, 13, 4.5))
  form(c, tunic, "sea", { frac = 0.3, off = 2 })
  -- sleeves + hands (swing opposite each other)
  local la, ra = p.arm or 0, -(p.arm or 0)
  local SL = cp(P.sea)
  form(c, c:rrect(X(17), 47 + b + la, X(21), 55 + b + la, 2), SL, { frac = 0.4, off = 1 })
  form(c, c:rrect(X(45), 47 + b + ra, X(49), 55 + b + ra, 2), SL, { frac = 0.5, off = 1 })
  form(c, c:ellipse(X(19), 56 + b + la, 2, 1.5), "skinA", { off = 1, frac = 0.3 })
  form(c, c:ellipse(X(47), 56 + b + ra, 2, 1.5), "skinA", { off = 1, frac = 0.3 })
  -- scarf ring + tail on the right
  form(c, c:rrect(X(21), 43 + b, X(45), 47 + b, 2), "gold", { frac = 0.25, off = 1 })
  form(c, c:poly{ {X(40), 46 + b}, {X(44), 46 + b}, {X(45), 55 + b}, {X(41), 55 + b} }, cp(P.gold), { frac = 0.4, off = 1 })
  -- head
  form(c, c:ellipse(X(33), 39 + b, 10, 6), "skinA", { frac = 0.25, off = 1 })
  form(c, c:ellipse(X(22), 40 + b, 1.5, 2), cp(P.skinA), { off = 1 })
  form(c, c:ellipse(X(44), 40 + b, 1.5, 2), cp(P.skinA), { off = 1 })
  -- beard
  local bm = c:poly{ {X(23), 42 + b}, {X(44), 42 + b}, {X(46), 47 + b}, {X(43), 53 + b}, {X(38), 57 + b},
    {X(34), 59 + b}, {X(30), 57 + b}, {X(25), 53 + b}, {X(21), 47 + b} }
  form(c, bm, beard, { frac = 0.3, off = 2, pop = { X(25), 47 + b } })
  local MU = cp(LSTONE)
  form(c, c:ellipse(X(30), 44.5 + b, 3.5, 1.5), MU, { off = 1, frac = 0.2 })
  form(c, c:ellipse(X(38), 44.5 + b, 3.5, 1.5), MU, { off = 1, frac = 0.3 })
  -- nose
  form(c, c:ellipse(X(34), 42.5 + b, 2, 1.5), cp(P.skinA), { off = 1, frac = 0.35, pop = { X(33), 41 + b } })
  -- eyes, cheeks
  c:eyeSmall(X(28), 39 + b) c:eyeSmall(X(38), 39 + b)
  c:cheek(X(25), 42 + b) c:cheek(X(41), 42 + b)
  -- hat: cone with a front rim arc, droopy tip with bell
  local hm = c:poly{ {X(19), 35 + b}, {X(47), 35 + b}, {X(43), 29 + b}, {X(39), 23 + b}, {X(35), 18 + b},
    {X(31), 15 + b}, {X(28), 15 + b}, {X(26), 17 + b}, {X(25), 21 + b}, {X(23), 27 + b} }
  hm:add(c:ellipse(X(33), 34 + b, 14, 3.5))
  form(c, hm, hat, { frac = 0.33, off = 2, pop = { X(27), 22 + b } })
  local flop = c:line({ {X(29), 15 + b}, {X(26), 14 + b}, {X(23), 15 + b}, {X(21), 18 + b} }, 3)
  form(c, flop, cp(hat), { off = 1, frac = 0.3 })
  form(c, c:ellipse(X(21) + (p.bell or 0), 21.5 + b, 2, 2), "gold", { off = 1, frac = 0.3, pop = { X(20) + (p.bell or 0), 20 + b } })
  -- hat band stitch along the front rim arc (the one seam)
  local pts = {}
  for x = 21, 45, 2 do pts[#pts + 1] = { X(x), math.floor(34 + 3.5 * math.sqrt(math.max(0, 1 - ((x - 33) / 14) ^ 2)) - 1.5 + b + 0.5) } end
  c:stitch(pts)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end

local idle = { { bob = 0 }, { bob = 1, bell = 0 } }
local walk = {
  { bob = 0, ly = 1, ry = -2, arm = -1, bell = 0 },
  { bob = 1, ly = 0, ry = -3, arm = 0, sx = -1, bell = 1 },
  { bob = 0, ly = -2, ry = 1, arm = 1, bell = 0 },
  { bob = 1, ly = -3, ry = 0, arm = 0, sx = 1, bell = -1 },
}
local function sheet(grey, name)
  local fr = {}
  for _, p in ipairs(idle) do fr[#fr + 1] = frame(p, grey) end
  for _, p in ipairs(walk) do fr[#fr + 1] = frame(p, grey) end
  local s = HP.sheet{ cellw = 64, cellh = 80, frames = fr, tags = { { name = "idle", from = 1, to = 2 }, { name = "walk", from = 3, to = 6 } } }
  s:save{ aseprite = out .. name .. SUF .. ".aseprite", png = out .. name .. SUF .. ".png", scale = 1 }
end
sheet(false, "gnome-player")
sheet(true, "gnome-player-grey")
