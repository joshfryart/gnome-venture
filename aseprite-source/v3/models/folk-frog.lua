-- folk-frog PASS 2 (final). 64x80 cell, 3/4 top-down, feet baseline y=70. idle(2) + walk(4).
-- quirk: a lily-pad umbrella hat that sways.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local SUF = app.params.suffix or ""
local NAME = "folk-frog"
local function cp(r) return { hi = r.hi, base = r.base, shade = r.shade, deep = r.deep } end
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

local function under(c, m, hex)
  m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end)
end
local PAD = { hi = P.moss.hi, base = P.moss.shade, shade = P.moss.deep, deep = P.moss.deep } -- pad sits one step darker than the frog
local function frame(p)
  local c = HP.canvas{ w = 64, h = 80, name = NAME }
  local b, sx = -p.bob, p.sx or 0
  local function X(x) return x + sx end
  c:groundShadow(31.5, 68.5, 13.5, 3.5)
  -- big splayed webbed feet: three toe pads each, turned outward
  local function foot(x, dy, dir)
    local m = c:ellipse(x + dir, 68 + dy, 4.5, 2)
    m:cut(c:rect(x + dir - 2, 70 + dy, x + dir - 2, 70 + dy)) m:cut(c:rect(x + dir + 2, 70 + dy, x + dir + 2, 70 + dy))
    form(c, m, cp(P.moss), { off = 1, frac = 0.3 })
    under(c, m, P.moss.deep)
  end
  foot(27, p.ly or 0, -1) foot(37, p.ry or 0, 1)
  -- pear body with pale belly
  local body = c:ellipse(X(32), 58 + b, 10.5, 8.5)
  form(c, body, "moss", { frac = 0.3, off = 2 })
  under(c, body, P.moss.deep)
  local belly = c:ellipse(X(32), 60 + b, 5.5, 5.5)
  c:fillMask(belly, P.moss.hi)
  belly:each(function(x, y) if not belly:has(x + 2, y + 1) then c:put(x, y, P.moss.base) end end)
  -- tiny waistcoat: short open panels with pointed tips, lapel notch, gold button
  local W = cp(P.dusk)
  local wl = c:poly{ {X(21), 51 + b}, {X(29), 50 + b}, {X(28), 61 + b}, {X(26), 65 + b}, {X(22), 62 + b}, {X(21), 57 + b} }
  local wr = c:poly{ {X(43), 51 + b}, {X(35), 50 + b}, {X(36), 61 + b}, {X(38), 65 + b}, {X(42), 62 + b}, {X(43), 57 + b} }
  wl:clip(body) wr:clip(body)
  form(c, wl, W, { frac = 0.2, off = 1, pop = { X(23), 53 + b } })
  form(c, wr, cp(P.dusk), { frac = 0.55, off = 1 })
  c:put(X(27), 51 + b, P.dusk.hi) c:put(X(37), 51 + b, P.dusk.shade)
  c:button(X(27), 57 + b)
  -- skinny arms with round finger pads
  local la, ra = (p.arm or 0) * 2, -(p.arm or 0) * 2
  for _, a in ipairs({ { 18, la, 0.35 }, { 44, ra, 0.6 } }) do
    local m = c:rrect(X(a[1]), 51 + b + a[2], X(a[1] + 2), 58 + b + a[2], 1)
    form(c, m, cp(P.moss), { off = 1, frac = a[3] })
    local h = c:ellipse(X(a[1] + 1), 59 + b + a[2], 1.5, 1.5)
    form(c, h, cp(P.moss), { off = 1, frac = a[3] })
  end
  -- head: wide flat dome seen from above, lighter crown, eye bumps riding the top
  local head = c:ellipse(X(32), 43 + b, 15, 7)
  form(c, head, cp(P.moss), { frac = 0.25, off = 2 })
  for _, e in ipairs({ { 24, 0.25 }, { 40, 0.45 } }) do
    local m = c:ellipse(X(e[1]), 37 + b, 4.5, 3.5)
    form(c, m, cp(P.moss), { frac = e[2], off = 1 })
  end
  c:eyeSmall(X(23), 36 + b) c:eyeSmall(X(40), 36 + b)
  -- wide smile that curls up at both ends
  for _, q in ipairs({ {24,45},{25,46},{26,47},{27,47},{28,47},{29,48},{30,48},{31,48},{32,48},{33,48},{34,48},{35,48},{36,47},{37,47},{38,47},{39,46},{40,45} }) do c:put(X(q[1]), q[2] + b, P.ink) end
  c:put(X(31), 49 + b, P.moss.shade) c:put(X(32), 49 + b, P.moss.shade) c:put(X(33), 49 + b, P.moss.shade)
  c:cheek(X(20), 45 + b) c:cheek(X(43), 45 + b)
  c:put(X(30), 41 + b, P.moss.deep) c:put(X(34), 41 + b, P.moss.deep) -- nostrils
  -- lily-pad umbrella: curved stem + pad seen from above, big notch toward the viewer, veins; sways and tilts
  local s = p.sway or 0
  c:fillMask(c:line({ { X(32), 37 + b }, { X(32), 33 + b }, { X(32) + s, 31 + b } }, 1), P.wood.shade)
  local pcx, pcy = X(32) + s, 26 + b
  local pad = c:ellipse(pcx, pcy, 14, 4.5)
  pad:cut(c:poly{ { pcx + 1, pcy + 0.5 }, { pcx + 2, pcy + 6 }, { pcx + 8, pcy + 6 } })
  form(c, pad, PAD, { frac = 0.25, off = 1, pop = { pcx - 8, pcy - 2 } })
  under(c, pad, P.moss.deep)
  -- rim highlight on the upper-left edge, veins from the centre
  for x = pcx - 10, pcx - 4 do c:put(x, pcy - 4, P.moss.base) end
  for _, v in ipairs({ { -9, -2 }, { -3, -4 }, { 4, -4 }, { 10, -2 }, { -10, 2 } }) do
    c:fillMask(c:line({ { pcx, pcy }, { pcx + v[1], pcy + v[2] } }, 1), P.moss.deep)
  end
  c:put(pcx, pcy, P.moss.base)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end

local idle = { { bob = 0, sway = 0 }, { bob = 1, sway = 1 } }
local walk = { -- waddle: weight shifts side to side, pad lags the body
  { bob = 0, ly = 2, ry = -2, arm = -1, sway = 1 },
  { bob = 1, ly = 0, ry = -3, sx = -1, sway = 1 },
  { bob = 0, ly = -2, ry = 2, arm = 1, sway = -1 },
  { bob = 1, ly = -3, ry = 0, sx = 1, sway = -1 },
}
local fr = {}
for _, p in ipairs(idle) do fr[#fr + 1] = frame(p) end
for _, p in ipairs(walk) do fr[#fr + 1] = frame(p) end
local SH = HP.sheet{ cellw = 64, cellh = 80, frames = fr, tags = { { name = "idle", from = 1, to = 2 }, { name = "walk", from = 3, to = 6 } } }
SH:save{ aseprite = out .. NAME .. SUF .. ".aseprite", png = out .. NAME .. SUF .. ".png", scale = 1 }
if SUF == "" then SH:save{ png = out .. NAME .. "_x4.png", scale = 4 } end
