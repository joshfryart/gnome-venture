-- creature25: three example creatures drawn the way the 2.5D player gnome is (v3/gnome-dir): Hearth Pop palette, ONE 1 px ink outline, flat base + one shade band
-- on the lower right + a deep row underneath + a few hi pixels upper left, the gnome's 4x4 eye, a ground shadow instead of a pedestal. Side view, facing RIGHT
-- (the frog faces the viewer, like its mini). PROPOSAL for Josh, not in the game yet.
--   aseprite -b --script-param out=<dir>/ --script aseprite-source/v3/creature25/creature25.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local floor, sqrt, max, min = math.floor, math.sqrt, math.max, math.min

-- the gnome's painters (copied from gnome-dir.lua): form = base, a shade band on the right `frac` of every row and where the shape ends lower right, hi pops
local function form(c, m, r, o)
  o = o or {}
  c:part(m, r, { noshade = true, nopop = true, inner = o.inner })
  if not o.noshade then
    local rows = {}
    m:each(function(x, y) local t = rows[y]
      if not t then rows[y] = { x, x } else t[1] = min(t[1], x) t[2] = max(t[2], x) end end)
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
  if o.pop then for _, q in ipairs(o.pop) do if m:has(q[1], q[2]) then c:put(q[1], q[2], r.hi, r) end end end
  return m
end
local function under(c, m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
local function eye(c, x, y)   -- the gnome's eye: ink lid, cream white, ink pupil looking right
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function dots(c, list, hex) for _, q in ipairs(list) do c:put(q[1], q[2], hex) end end
local function darker(r) return { hi = r.base, base = r.shade, shade = r.deep, deep = r.deep } end   -- the far side of a pair (legs, wings)
local CREAM = { hi = P.cream, base = "#ffe0bd", shade = "#f0b98d", deep = "#c98462" }
local W, G, M, PT = P.wood, P.gold, P.moss, P.petal

-- WILD BOAR (80x64, feet on y = 56) ------------------------------------------------------------------
local function boar()
  local c = HP.canvas{ w = 80, h = 64, name = "boar" }
  c:groundShadow(40, 56.5, 25, 3.5)
  local function leg(x, r, top)
    local m = c:poly{ { x - 1, top }, { x + 7, top }, { x + 6, 53 }, { x, 53 } }
    form(c, m, r, { frac = 0.34, off = 1 })
    local h = c:rect(x - 1, 53, x + 6, 55); c:fillMask(h, P.wood.deep)   -- hoof
    c:put(x + 2, 55, P.ink)                                                -- cloven
  end
  leg(27, darker(W), 42) leg(53, darker(W), 42)                          -- far legs
  local tail = c:line({ { 17, 33 }, { 13, 31 }, { 11, 27 }, { 13, 24 } }, 2)   -- thin tail, curled up, a dark tuft
  form(c, tail, W, { noshade = true })
  c:fillMask(c:ellipse(14, 22.5, 2, 2), W.deep)
  local body = c:ellipse(37, 37, 21, 12.5)
  body:add(c:ellipse(23, 38, 9, 11)) body:add(c:ellipse(49, 35, 11, 12.5))   -- haunch, heavy shoulder hump
  form(c, body, W, { frac = 0.3, off = 4, pop = { { 22, 29 }, { 23, 29 }, { 22, 30 }, { 44, 25 }, { 45, 25 } } })
  under(c, body, W.deep)
  for x = 22, 54, 4 do   -- a ridge of bristles along the spine
    local y = floor(body:has(x, 0) and 0 or 0); for yy = 10, 40 do if body:has(x, yy) then y = yy break end end
    form(c, c:poly{ { x - 2, y + 1 }, { x + 3, y + 1 }, { x - 1, y - 4 } }, darker(W), { noshade = true })
  end
  c:fillMask(c:poly{ { 30, 20 }, { 36, 18 }, { 34, 23 } }, M.base); c:put(31, 20, M.hi); c:put(34, 21, M.shade)   -- quirk: a leaf caught in the bristles
  dots(c, { { 26, 44 }, { 27, 45 }, { 33, 46 }, { 34, 47 }, { 40, 46 }, { 41, 47 } }, W.shade)   -- shaggy belly
  leg(19, W, 43) leg(46, W, 43)                                          -- near legs
  local head = c:ellipse(58, 36, 10.5, 10)
  form(c, head, W, { frac = 0.3, off = 4, pop = { { 52, 29 }, { 53, 29 }, { 52, 30 } } })
  under(c, head, W.deep)
  local ear = c:poly{ { 49, 29 }, { 51, 19 }, { 58, 27 } }
  form(c, ear, W, { frac = 0.3, off = 1 }); dots(c, { { 52, 24 }, { 52, 25 }, { 53, 25 }, { 53, 26 }, { 54, 26 } }, PT.shade)
  local snout = c:rrect(63, 36, 73, 45, 3)
  form(c, snout, W, { frac = 0.2, off = 2 }) under(c, snout, W.deep)
  local nose = c:ellipse(73, 40.5, 2.5, 4)
  form(c, nose, PT, { frac = 0.34, off = 1, pop = { { 72, 38 } } })
  dots(c, { { 74, 39 }, { 74, 42 } }, PT.deep)
  dots(c, { { 62, 46 }, { 63, 47 }, { 64, 47 }, { 65, 47 }, { 66, 47 }, { 67, 46 } }, W.deep)   -- mouth
  dots(c, { { 67, 46 }, { 68, 45 }, { 68, 44 }, { 69, 43 }, { 69, 42 }, { 69, 41 }, { 68, 46 }, { 69, 45 }, { 69, 44 }, { 70, 43 } }, P.cream)   -- tusk
  dots(c, { { 69, 46 }, { 70, 45 }, { 70, 44 } }, CREAM.shade)
  eye(c, 59, 31)
  dots(c, { { 58, 29 }, { 59, 29 }, { 60, 30 }, { 61, 30 } }, W.deep)    -- a grumpy brow
  c:put(61, 39, PT.base) c:put(62, 39, PT.base)                          -- cheek
  c:finish()
  return c
end

-- GREAT HAWK (96x96, feet on y = 88) ------------------------------------------------------------------
local function hawk()
  local c = HP.canvas{ w = 96, h = 96, name = "hawk" }
  c:groundShadow(46, 88.5, 24, 4)
  local DK = darker(W)
  for i, t in ipairs({ { 10, 60, 14, 52 }, { 6, 68, 12, 60 }, { 8, 76, 14, 68 } }) do   -- tail fan: three feathers, pale tips with a dark bar
    local m = c:poly{ { 30, 58 + i * 3 }, { 30, 64 + i * 3 }, { t[1], t[2] }, { t[3], t[4] } }
    form(c, m, DK, { frac = 0.3, off = 1 }) under(c, m, W.deep)
    m:each(function(x, y) local d = x - t[1]; if d >= 4 and d <= 6 then c:put(x, y, CREAM.base) end end)
  end
  local function legf(x)
    form(c, c:rect(x, 70, x + 2, 85), G, { frac = 0.34, off = 1 })
    form(c, c:line({ { x, 86 }, { x + 8, 86 } }, 2), G, { noshade = true }) c:put(x + 9, 87, P.ink) c:put(x + 5, 87, P.ink) c:put(x - 2, 86, G.shade) c:put(x - 3, 87, P.ink)   -- toes and claws
  end
  legf(40)
  local body = c:ellipse(46, 54, 19, 21)
  body:add(c:ellipse(52, 44, 13, 14))
  form(c, body, W, { frac = 0.3, off = 4, pop = { { 34, 40 }, { 35, 40 }, { 34, 41 } } })
  under(c, body, W.deep)
  local chest = c:ellipse(55, 56, 11, 16); chest:clip(body)
  form(c, chest, CREAM, { frac = 0.25, off = 2, inner = false })
  for _, q in ipairs({ { 50, 48 }, { 56, 50 }, { 61, 54 }, { 52, 56 }, { 58, 60 }, { 53, 64 }, { 60, 66 }, { 56, 69 } }) do   -- chest flecks (little chevrons)
    if chest:has(q[1], q[2]) and chest:has(q[1] + 2, q[2]) then c:put(q[1], q[2], W.base) c:put(q[1] + 1, q[2] + 1, W.base) c:put(q[1] + 2, q[2], W.base) end
  end
  legf(52)
  form(c, c:ellipse(42, 71, 5, 4), W, { frac = 0.3, off = 1 }) form(c, c:ellipse(54, 71, 5, 4), CREAM, { frac = 0.3, off = 1 })   -- feathered thighs
  local wing = c:ellipse(37, 54, 11, 17)
  wing:add(c:poly{ { 28, 60 }, { 44, 62 }, { 26, 80 } })
  form(c, wing, DK, { frac = 0.22, off = 2, pop = { { 30, 43 }, { 31, 43 } } })
  under(c, wing, W.deep)
  for row = 0, 3 do for i = 0, 3 do   -- feather scallops
    local x, y = 30 + i * 5 + (row % 2) * 2, 48 + row * 6
    if wing:has(x, y) and wing:has(x + 3, y + 1) then dots(c, { { x, y }, { x + 1, y + 1 }, { x + 2, y + 1 }, { x + 3, y } }, W.deep) end
  end end
  local head = c:ellipse(60, 28, 11.5, 10.5)
  form(c, head, W, { frac = 0.3, off = 4, pop = { { 53, 21 }, { 54, 21 }, { 53, 22 } } })
  for i, t in ipairs({ { 50, 20, 44, 12 }, { 55, 18, 52, 8 }, { 61, 18, 61, 9 } }) do   -- crest
    local m = c:poly{ { t[1] - 3, t[2] + 2 }, { t[1] + 3, t[2] + 1 }, { t[3], t[4] } }
    form(c, m, W, { frac = 0.3, off = 1 })
    m:each(function(x, y) if y < t[4] + 4 then c:put(x, y, CREAM.base) end end)   -- pale tips
  end
  local beak = c:poly{ { 69, 25 }, { 79, 29 }, { 80, 33 }, { 77, 38 }, { 75, 34 }, { 69, 34 } }
  form(c, beak, G, { frac = 0.3, off = 1, pop = { { 71, 27 }, { 72, 27 } } })
  under(c, beak, G.shade)
  dots(c, { { 70, 31 }, { 71, 31 }, { 72, 31 }, { 73, 32 }, { 74, 32 } }, G.deep) c:put(72, 28, G.deep)   -- gape, nostril
  eye(c, 62, 24)
  dots(c, { { 60, 22 }, { 61, 22 }, { 62, 23 }, { 63, 23 }, { 64, 24 }, { 65, 24 }, { 66, 25 } }, W.deep)   -- the hawk's glare
  dots(c, { { 64, 30 }, { 65, 31 } }, W.shade)
  form(c, c:rect(52, 78, 54, 80), P.ember, { noshade = true }) c:put(52, 78, P.ember.hi)   -- quirk: a red ring on one leg
  c:finish()
  return c
end

-- BULLFROG (64x56, sits on y = 49, faces the viewer) --------------------------------------------------
local function frog()
  local c = HP.canvas{ w = 64, h = 56, name = "frog" }
  c:groundShadow(32, 49.5, 22, 3.5)
  for _, s in ipairs({ -1, 1 }) do   -- folded back legs, wide webbed feet
    local m = c:ellipse(32 + s * 17, 41, 7, 7)
    form(c, m, M, { frac = s > 0 and 0.4 or 0.15, off = 2 }) under(c, m, M.deep)
    local f = c:ellipse(32 + s * 19, 47, 7, 2.5)
    form(c, f, M, { frac = 0.3, off = 1 }) under(c, f, M.deep)
    for i = -1, 1 do c:put(32 + s * 19 + i * 4, 46, M.deep) end
  end
  local body = c:ellipse(32, 35, 18, 13.5)
  form(c, body, M, { frac = 0.28, off = 4, pop = { { 20, 27 }, { 21, 27 }, { 20, 28 } } })
  under(c, body, M.deep)
  local belly = c:ellipse(32, 42, 12, 7.5); belly:clip(body)
  form(c, belly, CREAM, { frac = 0.25, off = 2, inner = false })
  for _, s in ipairs({ -1, 1 }) do
    local b = c:ellipse(32 + s * 10, 22, 6.5, 6.5)   -- eye bumps
    form(c, b, M, { frac = s > 0 and 0.3 or 0.12, off = 2, pop = s < 0 and { { 18, 18 }, { 19, 18 } } or nil })
    local w = c:ellipse(32 + s * 10, 22.5, 3.5, 3.5); c:fillMask(w, P.cream)
    w:each(function(x, y) if not w:has(x, y - 1) then c:put(x, y, P.ink) end end)                       -- lid
    c:fillMask(c:rect(32 + s * 10 - 1, 22, 32 + s * 10 + 1, 24), P.ink) c:put(32 + s * 10 - 1, 22, P.cream)   -- pupil with a glint
  end
  for x = 17, 47 do local y = floor(33.5 + 2.2 * sqrt(max(0, 1 - ((x - 32) / 15.5) ^ 2)) - 1.5 + 0.5); c:put(x, y, M.deep) end   -- a very wide mouth
  c:put(16, 32, M.deep) c:put(48, 32, M.deep)
  dots(c, { { 29, 29 }, { 34, 29 } }, M.deep)                                                           -- nostrils
  dots(c, { { 19, 35 }, { 20, 35 }, { 44, 35 }, { 45, 35 } }, PT.base)                                   -- cheeks
  dots(c, { { 25, 25 }, { 26, 25 }, { 38, 26 }, { 39, 26 }, { 41, 30 }, { 23, 30 }, { 32, 24 }, { 33, 24 } }, M.shade)   -- warts
  for _, s in ipairs({ -1, 1 }) do   -- front legs and toes
    local a = c:ellipse(32 + s * 9, 43.5, 2.5, 4.5)
    form(c, a, M, { frac = 0.34, off = 1, inner = false })
    a:each(function(x, y) if not a:has(x - s, y) and y < 47 then c:put(x, y, M.shade) end end)   -- a soft edge against the belly, not a hard line
    local t = c:rect(32 + s * 9 - 3, 47, 32 + s * 9 + 3, 48); c:fillMask(t, M.base)
    c:put(32 + s * 9 - 1, 48, M.deep) c:put(32 + s * 9 + 1, 48, M.deep)
  end
  dots(c, { { 31, 12 }, { 32, 12 }, { 32, 13 } }, P.ink) dots(c, { { 30, 11 }, { 33, 11 } }, P.sky.base)   -- quirk: a fly it has not noticed
  c:finish()
  return c
end

for _, f in ipairs({ boar, hawk, frog }) do local c = f(); c:save{ png = out .. "c25-" .. c.name .. ".png", aseprite = out .. "c25-" .. c.name .. ".aseprite" } print(c.name, c.w .. "x" .. c.h) end
