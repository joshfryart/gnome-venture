-- folk-frog PASS 1 (form). 64x80 cell, 3/4 top-down, feet baseline y=70. idle(2) + walk(4).
-- quirk: a lily-pad umbrella hat that sways.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local SUF = app.params.suffix or ".p1"
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

local PAD = { hi = P.moss.hi, base = P.moss.shade, shade = P.moss.deep, deep = P.moss.deep }
local function frame(p)
  local c = HP.canvas{ w = 64, h = 80, name = NAME }
  local b, sx = -p.bob, p.sx or 0
  local function X(x) return x + sx end
  c:groundShadow(31.5, 68.5, 13.5, 3.5)
  -- big splayed webbed feet
  form(c, c:ellipse(25, 68 + (p.ly or 0), 4.5, 2), "moss", { off = 1, frac = 0.3 })
  form(c, c:ellipse(39, 68 + (p.ry or 0), 4.5, 2), cp(P.moss), { off = 1, frac = 0.3 })
  -- pear body
  form(c, c:ellipse(X(32), 58 + b, 11, 9), "moss", { frac = 0.3, off = 2 })
  local belly = c:ellipse(X(32), 60 + b, 5.5, 6)
  c:fillMask(belly, P.moss.hi)
  -- waistcoat panels
  local W = cp(P.dusk)
  form(c, c:poly{ {X(21), 51 + b}, {X(28), 50 + b}, {X(29), 66 + b}, {X(22), 63 + b}, {X(20), 57 + b} }, W, { frac = 0.2, off = 1 })
  form(c, c:poly{ {X(43), 51 + b}, {X(36), 50 + b}, {X(35), 66 + b}, {X(42), 63 + b}, {X(44), 57 + b} }, cp(P.dusk), { frac = 0.6, off = 1 })
  c:button(X(27), 57 + b)
  -- arms
  local la, ra = p.arm or 0, -(p.arm or 0)
  form(c, c:rrect(X(17), 51 + b + la, X(20), 59 + b + la, 2), cp(P.moss), { off = 1, frac = 0.4 })
  form(c, c:rrect(X(44), 51 + b + ra, X(47), 59 + b + ra, 2), cp(P.moss), { off = 1, frac = 0.5 })
  -- head: wide flat dome, eye bumps on top
  form(c, c:ellipse(X(32), 43 + b, 15, 7.5), cp(P.moss), { frac = 0.25, off = 2 })
  form(c, c:ellipse(X(24), 37 + b, 4.5, 4), cp(P.moss), { frac = 0.3, off = 1 })
  form(c, c:ellipse(X(40), 37 + b, 4.5, 4), cp(P.moss), { frac = 0.4, off = 1 })
  c:eyeSmall(X(24), 36 + b) c:eyeSmall(X(40), 36 + b)
  -- smile
  for _, q in ipairs({ {25,46},{26,47},{27,47},{28,48},{29,48},{30,48},{31,48},{32,48},{33,48},{34,48},{35,48},{36,47},{37,47},{38,46} }) do c:put(X(q[1]), q[2] + b, P.ink) end
  c:cheek(X(21), 45 + b) c:cheek(X(42), 45 + b)
  -- lily-pad umbrella: stem + pad with a notch, sways
  local s = p.sway or 0
  form(c, c:line({ { X(32), 36 + b }, { X(32) + s, 30 + b } }, 1), "wood", { noshade = true })
  local pad = c:ellipse(X(32) + s, 27 + b, 13, 4.5)
  pad:cut(c:poly{ { X(32) + s, 27 + b }, { X(34) + s * 2, 33 + b }, { X(38) + s * 2, 32 + b } })
  form(c, pad, PAD, { frac = 0.25, off = 1, pop = { X(25) + s, 25 + b } })
  for _, v in ipairs({ { -7, -2 }, { 0, -3 }, { 7, -2 }, { -8, 2 } }) do
    c:fillMask(c:line({ { X(32) + s, 27 + b }, { X(32) + s + v[1], 27 + b + v[2] } }, 1), P.moss.deep)
  end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end

local idle = { { bob = 0, sway = 0 }, { bob = 1, sway = 1 } }
local walk = {
  { bob = 0, ly = 1, ry = -2, arm = -1, sway = 1 },
  { bob = 1, ly = 0, ry = -3, sx = -1, sway = 0 },
  { bob = 0, ly = -2, ry = 1, arm = 1, sway = -1 },
  { bob = 1, ly = -3, ry = 0, sx = 1, sway = 0 },
}
local fr = {}
for _, p in ipairs(idle) do fr[#fr + 1] = frame(p) end
for _, p in ipairs(walk) do fr[#fr + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 80, frames = fr, tags = { { name = "idle", from = 1, to = 2 }, { name = "walk", from = 3, to = 6 } } }
  :save{ aseprite = out .. NAME .. SUF .. ".aseprite", png = out .. NAME .. SUF .. ".png", scale = 1 }
