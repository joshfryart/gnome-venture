-- npc-hedgehog (Bramble Mossfoot) PASS 2 (final). 64x80 cell, 3/4 top-down, feet baseline y=70. idle(2) + walk(4).
-- quirk: spikes are different lengths like a messy haircut (one cowlick bobs in the walk).
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local SUF = app.params.suffix or ""
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

local function under(c, m, hex)
  m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end)
end
-- silhouette spikes: {angle deg (0 right, 90 up), length, width}; messy haircut = uneven lengths
local SP = {
  { -34, 3, 0.26 }, { -18, 5, 0.25 }, { -2, 4, 0.24 }, { 14, 6, 0.24 }, { 29, 4, 0.23 }, { 44, 7, 0.24 }, { 60, 5, 0.23 },
  { 76, 9, 0.22 }, { 94, 4, 0.22 }, { 110, 6, 0.23 }, { 126, 4, 0.23 }, { 141, 7, 0.24 }, { 156, 5, 0.24 }, { 172, 6, 0.24 },
  { 188, 4, 0.25 }, { 203, 5, 0.25 }, { 216, 3, 0.26 },
}
-- inner quill chevrons ("^": pale apex, shade arms), staggered rows on the dome top
local QU = { { 24, 29 }, { 30, 27 }, { 36, 27 }, { 41, 30 }, { 20, 34 }, { 27, 32 }, { 33, 31 }, { 39, 33 }, { 44, 36 } }
-- remap: fold rarely used tones into a neighbour so the sprite stays near the colour budget
local function remap(c, map)
  local m = {}
  for k, v in pairs(map) do m[k:lower()] = v:lower() end
  for i, h in pairs(c.pix) do if m[h] then c.pix[i] = m[h] end end
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 80, name = NAME }
  local b, sx = -p.bob, p.sx or 0
  local function X(x) return x + sx end
  c:groundShadow(31.5, 68.5, 13.5, 3.5)
  -- feet: round paws with toe nicks
  local function paw(x, dy)
    local m = c:ellipse(x, 68 + dy, 3, 2)
    form(c, m, cp(P.wood), { off = 1, frac = 0.35 })
    under(c, m, P.wood.deep)
    c:put(x - 1, 69 + dy, P.wood.deep) c:put(x + 1, 69 + dy, P.wood.deep)
  end
  paw(27, p.ly or 0) paw(37, p.ry or 0)
  -- jumper: pear barrel with a ribbed hem (deep underside + rib ticks)
  local body = c:ellipse(X(32), 58 + b, 11, 8)
  body:add(c:rrect(X(23), 49 + b, X(41), 60 + b, 4))
  form(c, body, "moss", { frac = 0.3, off = 2 })
  under(c, body, P.moss.deep)
  for x = 24, 40, 2 do if body:has(X(x), 64 + b) then c:put(X(x), 64 + b, P.moss.shade) end end
  c:button(X(30), 59 + b)
  -- arms: stubby sleeves + brown paws, swing 2px
  local la, ra = (p.arm or 0) * 2, -(p.arm or 0) * 2
  local SL = cp(P.moss)
  for _, a in ipairs({ { 19, la, 0.35 }, { 42, ra, 0.6 } }) do
    local m = c:rrect(X(a[1]), 51 + b + a[2], X(a[1] + 3), 58 + b + a[2], 1)
    form(c, m, SL, { off = 1, frac = a[3] })
    under(c, m, P.moss.deep)
    form(c, c:ellipse(X(a[1] + 1.5), 59 + b + a[2], 2, 1.5), cp(P.wood), { off = 1 })
  end
  -- red scarf ring + tail that flips in the walk
  form(c, c:rrect(X(22), 47 + b, X(42), 51 + b, 2), "ember", { off = 1, frac = 0.25 })
  local tl = p.tail or 0
  local tail = c:poly{ {X(23), 50 + b}, {X(27), 50 + b}, {X(26) + tl, 58 + b}, {X(22) + tl, 58 + b} }
  form(c, tail, cp(P.ember), { off = 1, frac = 0.4 })
  c:put(X(23) + tl, 57 + b, P.ember.deep) c:put(X(25) + tl, 57 + b, P.ember.deep)
  -- spiky crown: dome seen from above + chunky triangular quills with pale tips
  local cx, cy = X(32), 37 + b
  local crown = c:ellipse(cx, cy, 14.5, 11.5)
  local tips = {}
  for i, s in ipairs(SP) do
    local a, L, w = math.rad(s[1]), s[2], s[3]
    if i == 8 then a = a + math.rad((p.lick or 0) * 6) end -- the cowlick flops
    local function at(ang, r) return { cx + math.cos(ang) * r * 14.5 / 11.5, cy - math.sin(ang) * r } end
    local b1, b2 = at(a - w, 10.5), at(a + w, 10.5)
    local t = { cx + math.cos(a) * (14.5 + L), cy - math.sin(a) * (11.5 + L) }
    crown:add(c:poly{ b1, t, b2, { cx, cy } })
    tips[#tips + 1] = { t, a, L }
  end
  local QR = { hi = P.wood.hi, base = P.wood.shade, shade = P.wood.deep, deep = P.wood.deep }
  form(c, crown, QR, { frac = 0.3, off = 2 })
  -- pale quill tips (2 px back from each tip, inside the outline)
  for _, t in ipairs(tips) do
    for k = 1, (t[3] >= 6 and 3 or 2) do
      local x = math.floor(t[1][1] - math.cos(t[2]) * k + 0.5)
      local y = math.floor(t[1][2] + math.sin(t[2]) * k + 0.5)
      if crown:has(x, y) then c:put(x, y, k == 1 and P.wood.hi or P.wood.base, QR) end
    end
  end
  -- inner quill chevrons on the dome top
  for _, q in ipairs(QU) do
    local x, y = X(q[1]), q[2] + b
    c:put(x, y, P.wood.hi)
    c:put(x - 1, y + 1, P.wood.base) c:put(x + 1, y + 1, P.wood.base)
    c:put(x - 2, y + 2, P.wood.base) c:put(x + 2, y + 2, P.wood.base)
  end
  -- face: pale heart-shaped mask with a widow's peak, snout pointing at the viewer (over the scarf)
  local face = c:ellipse(X(32), 41 + b, 9, 5.5)
  face:add(c:poly{ { X(24), 39 + b }, { X(32), 33 + b }, { X(40), 39 + b } })
  face:add(c:poly{ { X(25), 41 + b }, { X(39), 41 + b }, { X(35), 46 + b }, { X(29), 46 + b } })
  form(c, face, "skinA", { frac = 0.25, off = 1, inner = false })
  local snout = c:ellipse(X(32), 46.5 + b, 3.5, 2.5)
  form(c, snout, { hi = P.cream, base = P.skinA.hi, shade = P.skinA.base, deep = P.skinA.shade }, { off = 1, frac = 0.3 })
  c:fillMask(c:rect(X(31), 48 + b, X(33), 49 + b), P.ink) c:put(X(31), 48 + b, P.stone.base)
  c:eyeSmall(X(27), 39 + b) c:eyeSmall(X(36), 39 + b)
  c:cheek(X(24), 43 + b) c:cheek(X(39), 43 + b)
  -- small round ears peeking out where face meets quills
  for _, e in ipairs({ { 23, 0.2 }, { 41, 0.6 } }) do
    form(c, c:ellipse(X(e[1]), 35 + b, 1.5, 1.5), cp(P.skinA), { off = 1, frac = e[2] })
  end
  remap(c, { [P.skinA.deep] = P.wood.deep, [P.ember.deep] = P.wood.deep })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end

local idle = { { bob = 0 }, { bob = 1, lick = 1 } }
local walk = {
  { bob = 0, ly = 2, ry = -2, arm = -1, lick = -1, tail = 0 },
  { bob = 1, ly = 0, ry = -3, sx = -1, lick = 0, tail = 1 },
  { bob = 0, ly = -2, ry = 2, arm = 1, lick = 1, tail = 0 },
  { bob = 1, ly = -3, ry = 0, sx = 1, lick = 0, tail = -1 },
}
local fr = {}
for _, p in ipairs(idle) do fr[#fr + 1] = frame(p) end
for _, p in ipairs(walk) do fr[#fr + 1] = frame(p) end
local SH = HP.sheet{ cellw = 64, cellh = 80, frames = fr, tags = { { name = "idle", from = 1, to = 2 }, { name = "walk", from = 3, to = 6 } } }
SH:save{ aseprite = out .. NAME .. SUF .. ".aseprite", png = out .. NAME .. SUF .. ".png", scale = 1 }
if SUF == "" then SH:save{ png = out .. NAME .. "_x4.png", scale = 4 } end
