-- npc-hedgehog (Bramble Mossfoot) PASS 1 (form). 64x80 cell, 3/4 top-down, feet baseline y=70. idle(2) + walk(4).
-- quirk: spikes are different lengths like a messy haircut (one cowlick bobs in the walk).
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local SUF = app.params.suffix or ".p1"
local NAME = "npc-hedgehog"
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

local SP = { -- angle (deg, 0 = right, 90 = up), length: messy haircut
  { -12, 4 }, { 8, 7 }, { 26, 5 }, { 42, 9 }, { 58, 6 }, { 74, 8 }, { 90, 11 }, { 106, 6 }, { 122, 9 }, { 138, 5 }, { 154, 8 }, { 172, 6 }, { 192, 4 },
}
local function frame(p)
  local c = HP.canvas{ w = 64, h = 80, name = NAME }
  local b, sx = -p.bob, p.sx or 0
  local function X(x) return x + sx end
  c:groundShadow(31.5, 68.5, 13.5, 3.5)
  -- feet: little round paws
  form(c, c:ellipse(27, 68 + (p.ly or 0), 3, 2), "wood", { off = 1, frac = 0.35 })
  form(c, c:ellipse(37, 68 + (p.ry or 0), 3, 2), "wood", { off = 1, frac = 0.35 })
  -- jumper body: round barrel
  local body = c:ellipse(X(32), 58 + b, 11.5, 8.5)
  form(c, body, "moss", { frac = 0.3, off = 2 })
  c:button(X(30), 60 + b)
  -- arms
  local la, ra = p.arm or 0, -(p.arm or 0)
  local SL = cp(P.moss)
  form(c, c:rrect(X(18), 52 + b + la, X(22), 59 + b + la, 2), SL, { off = 1, frac = 0.4 })
  form(c, c:rrect(X(42), 52 + b + ra, X(46), 59 + b + ra, 2), SL, { off = 1, frac = 0.5 })
  form(c, c:ellipse(X(20), 60 + b + la, 2, 1.5), "wood", { off = 1 })
  form(c, c:ellipse(X(44), 60 + b + ra, 2, 1.5), "wood", { off = 1 })
  -- scarf ring + tail
  form(c, c:rrect(X(21), 47 + b, X(43), 51 + b, 2), "ember", { off = 1, frac = 0.25 })
  form(c, c:poly{ {X(23), 50 + b}, {X(27), 50 + b}, {X(26), 58 + b}, {X(22), 58 + b} }, cp(P.ember), { off = 1, frac = 0.4 })
  -- spiky crown: dome + radiating chunky spikes of messy lengths
  local cx, cy = X(32), 37 + b
  local crown = c:ellipse(cx, cy, 15, 12)
  for i, s in ipairs(SP) do
    local a, L = math.rad(s[1]), s[2]
    if i == 7 then a = a + math.rad((p.lick or 0) * 8) end
    local function at(ang, r) return { cx + math.cos(ang) * r * 15 / 12, cy - math.sin(ang) * r } end
    local b1, b2 = at(a - 0.2, 11), at(a + 0.2, 11)
    local t = { cx + math.cos(a) * (15 + L), cy - math.sin(a) * (12 + L) }
    crown:add(c:poly{ b1, t, b2, { cx, cy } })
  end
  form(c, crown, "wood", { frac = 0.3, off = 2 })
  -- spike texture: inner chevrons
  local IN = cp(P.wood)
  for _, s in ipairs({ { 22, 30 }, { 29, 27 }, { 36, 28 }, { 42, 31 }, { 25, 35 }, { 39, 34 }, { 32, 33 } }) do
    local x, y = X(s[1]), s[2] + b
    form(c, c:poly{ { x - 2.5, y + 4 }, { x, y - 1 }, { x + 2.5, y + 4 } }, IN, { noshade = true })
    c:put(x, y, P.wood.hi, IN)
  end
  -- face mask with widow's peak, snout
  local face = c:ellipse(X(32), 44 + b, 9.5, 6.5)
  face:add(c:poly{ { X(25), 40 + b }, { X(32), 35 + b }, { X(39), 40 + b } })
  form(c, face, "skinA", { frac = 0.25, off = 1 })
  form(c, c:ellipse(X(32), 48.5 + b, 3.5, 2.5), cp(P.skinA), { off = 1, frac = 0.3 })
  c:fillMask(c:rect(X(31), 50 + b, X(32), 51 + b), P.ink)
  c:put(X(31), 50 + b, P.cream)
  c:eyeSmall(X(27), 42 + b) c:eyeSmall(X(36), 42 + b)
  c:cheek(X(24), 46 + b) c:cheek(X(39), 46 + b)
  -- ears
  form(c, c:ellipse(X(21), 39 + b, 2, 2), cp(P.skinA), { off = 1 })
  form(c, c:ellipse(X(43), 39 + b, 2, 2), cp(P.skinA), { off = 1 })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end

local idle = { { bob = 0 }, { bob = 1, lick = 1 } }
local walk = {
  { bob = 0, ly = 1, ry = -2, arm = -1, lick = -1 },
  { bob = 1, ly = 0, ry = -3, sx = -1, lick = 0 },
  { bob = 0, ly = -2, ry = 1, arm = 1, lick = 1 },
  { bob = 1, ly = -3, ry = 0, sx = 1, lick = 0 },
}
local fr = {}
for _, p in ipairs(idle) do fr[#fr + 1] = frame(p) end
for _, p in ipairs(walk) do fr[#fr + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 80, frames = fr, tags = { { name = "idle", from = 1, to = 2 }, { name = "walk", from = 3, to = 6 } } }
  :save{ aseprite = out .. NAME .. SUF .. ".aseprite", png = out .. NAME .. SUF .. ".png", scale = 1 }
