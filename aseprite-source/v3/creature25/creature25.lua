-- creature25: three example creatures drawn the way the 2.5D player gnome is (v3/gnome-dir): Hearth Pop palette, ONE 1 px ink outline, flat base + one shade band
-- on the lower right + a deep row underneath + a few hi pixels upper left, the gnome's 4x4 eye, a ground shadow instead of a pedestal. Side view, facing RIGHT
-- (the frog faces the viewer, like its mini). PROPOSAL for Josh, not in the game yet.
-- v2 (2026-11-10): a richness pass (fur, feather rows, warts, joints, second lights) and a quirk pass (see the `quirk` comments) on each.
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

-- small painters for the richness pass. `inside` = only repaint a pixel that already holds one of the given colours (never the outline, never another part)
local function inside(c, x, y, hex, ...) local v = c:get(x, y); for _, h in ipairs({ ... }) do if v == h:lower() then c:put(x, y, hex) return true end end end
local function tuft(c, x, y, r, hex) inside(c, x, y, hex or r.shade, r.base) inside(c, x + 1, y + 1, hex or r.shade, r.base) inside(c, x + 2, y, hex or r.shade, r.base) end   -- a little v of fur or feather
local function toplight(c, m, r, x0, x1, dy)   -- broken highlight just under the top edge: light from above
  for x = x0, x1 do if x % 4 ~= 0 then for y = 0, 95 do if m:has(x, y) then inside(c, x, y + (dy or 1), r.hi, r.base) break end end end end
end
local function belly(c, m, r, d)   -- a second, darker band along the underside
  m:each(function(x, y) if not m:has(x, y + (d or 3)) then inside(c, x, y, r.shade, r.base) end end)
end

-- WILD BOAR (88x64, feet on y = 56) ------------------------------------------------------------------
local function boar()
  local c = HP.canvas{ w = 88, h = 64, name = "boar" }
  c:groundShadow(40, 56.5, 25, 3.5)
  local function leg(x, r, top, mud)
    local m = c:poly{ { x - 1, top }, { x + 7, top }, { x + 6, 53 }, { x, 53 } }
    form(c, m, r, { frac = 0.34, off = 1 })
    for xx = x, x + 5 do inside(c, xx, 48, r.shade, r.base) end                 -- knee crease
    c:fillMask(c:rect(x - 1, 53, x + 6, 55), P.wood.deep) c:put(x + 2, 55, P.ink) c:put(x, 53, W.shade) c:put(x + 1, 53, W.shade)   -- cloven hoof with a dull shine
    if mud then dots(c, { { x + 1, 50 }, { x + 4, 51 }, { x + 2, 52 }, { x + 5, 49 } }, W.deep) end   -- mud up the shins
  end
  leg(27, darker(W), 42) leg(53, darker(W), 42)                                -- far legs
  local tail = c:line({ { 17, 33 }, { 13, 31 }, { 11, 27 }, { 13, 24 } }, 2)   -- thin tail, curled up, a dark tuft
  form(c, tail, W, { noshade = true })
  c:fillMask(c:ellipse(14, 22.5, 2, 2), W.deep) c:put(13, 22, W.shade)
  local body = c:ellipse(37, 37, 21, 12.5)
  body:add(c:ellipse(23, 38, 9, 11)) body:add(c:ellipse(49, 35, 11, 12.5))     -- haunch, heavy shoulder hump
  form(c, body, W, { frac = 0.3, off = 4, pop = { { 22, 29 }, { 23, 29 }, { 22, 30 }, { 44, 25 }, { 45, 25 } } })
  under(c, body, W.deep) belly(c, body, W, 3) toplight(c, body, W, 18, 54, 2)
  for _, q in ipairs({ { 20, 36 }, { 26, 33 }, { 32, 36 }, { 24, 40 }, { 30, 42 }, { 37, 39 }, { 43, 34 }, { 40, 43 }, { 47, 40 }, { 35, 31 } }) do tuft(c, q[1], q[2], W) end   -- coarse fur
  for x = 22, 54, 4 do   -- a ridge of bristles along the spine, every other one taller
    local y = 0; for yy = 10, 40 do if body:has(x, yy) then y = yy break end end
    local h = (x % 8 == 2) and 6 or 4
    form(c, c:poly{ { x - 2, y + 1 }, { x + 3, y + 1 }, { x - 1, y - h } }, darker(W), { noshade = true }) c:put(x - 1, y - h + 1, W.base)
  end
  dots(c, { { 26, 45 }, { 27, 46 }, { 33, 47 }, { 34, 48 }, { 40, 47 }, { 41, 48 }, { 44, 46 } }, W.deep)   -- shaggy belly fringe
  leg(19, W, 43, true) leg(46, W, 43, true)                                    -- near legs
  local jowl = c:poly{ { 52, 43 }, { 64, 44 }, { 58, 50 } }                     -- a beard of fur under the jaw
  form(c, jowl, W, { frac = 0.4, off = 1 }) under(c, jowl, W.deep)
  local head = c:ellipse(58, 36, 10.5, 10)
  form(c, head, W, { frac = 0.3, off = 4, pop = { { 52, 29 }, { 53, 29 }, { 52, 30 } } })
  under(c, head, W.deep)
  for _, q in ipairs({ { 51, 36 }, { 54, 40 }, { 50, 41 } }) do tuft(c, q[1], q[2], W) end
  local ear = c:poly{ { 49, 29 }, { 51, 19 }, { 58, 27 } }
  ear:cut(c:poly{ { 50, 22 }, { 53, 23 }, { 50, 25 } })                         -- quirk: a notch bitten out of its ear
  form(c, ear, W, { frac = 0.3, off = 1 }); dots(c, { { 53, 24 }, { 53, 25 }, { 54, 25 }, { 54, 26 }, { 55, 26 } }, PT.shade) c:put(54, 24, PT.base)
  local snout = c:rrect(63, 36, 73, 45, 3)
  form(c, snout, W, { frac = 0.2, off = 2 }) under(c, snout, W.deep)
  dots(c, { { 65, 37 }, { 66, 38 }, { 68, 37 }, { 69, 38 } }, W.shade) dots(c, { { 64, 38 }, { 65, 38 } }, W.hi)   -- wrinkles over the snout
  local nose = c:ellipse(73, 40.5, 2.5, 4)
  form(c, nose, PT, { frac = 0.34, off = 1, pop = { { 72, 38 } } })
  dots(c, { { 74, 39 }, { 74, 42 } }, PT.deep)
  dots(c, { { 62, 46 }, { 63, 47 }, { 64, 47 }, { 65, 47 }, { 66, 47 }, { 67, 46 } }, W.deep)   -- mouth
  dots(c, { { 67, 46 }, { 68, 45 }, { 68, 44 }, { 69, 43 }, { 69, 42 }, { 69, 41 }, { 68, 46 }, { 69, 45 }, { 69, 44 }, { 70, 43 } }, P.cream)   -- tusk
  dots(c, { { 69, 46 }, { 70, 45 }, { 70, 44 } }, CREAM.shade)
  dots(c, { { 71, 46 }, { 72, 45 } }, CREAM.base)                               -- quirk: the far tusk is a broken stump
  eye(c, 59, 31)
  dots(c, { { 58, 30 }, { 59, 29 }, { 60, 29 }, { 61, 30 }, { 62, 31 } }, W.deep)   -- a grumpy brow
  dots(c, { { 59, 35 }, { 60, 35 }, { 61, 35 } }, W.shade)                      -- a bag under the eye
  c:put(61, 39, PT.base) c:put(62, 39, PT.base)                                -- cheek
  c:fillMask(c:poly{ { 30, 19 }, { 36, 17 }, { 34, 22 } }, M.base); c:put(31, 19, M.hi) c:put(34, 20, M.shade) c:put(33, 21, M.shade)   -- quirk: a leaf caught in the bristles
  -- quirk: a sticking plaster on its rump (two crossed strips)
  for i = 0, 4 do inside(c, 20 + i, 33 + i, CREAM.hi, W.base, W.shade, W.hi) inside(c, 21 + i, 33 + i, CREAM.base, W.base, W.shade, W.hi) inside(c, 24 - i, 33 + i, CREAM.hi, W.base, W.shade, W.hi) inside(c, 25 - i, 33 + i, CREAM.base, W.base, W.shade, W.hi) end
  c:put(22, 35, CREAM.deep) c:put(23, 35, CREAM.deep)
  -- quirk: it snorts: two round puffs from the nostrils
  c:fillMask(c:ellipse(80, 38, 2, 2), P.stone.hi) c:put(81, 39, P.stone.base) c:put(80, 39, P.stone.base) c:put(79, 37, P.cream)
  c:fillMask(c:rect(84, 33, 85, 34), P.stone.hi) c:put(85, 34, P.stone.base)
  c:finish()
  return c
end

-- GREAT HAWK (96x96, feet on y = 88) ------------------------------------------------------------------
local function hawk()
  local c = HP.canvas{ w = 96, h = 96, name = "hawk" }
  c:groundShadow(46, 88.5, 24, 4)
  local DK = darker(W)
  local function feather(bx, by, ang, len, wid, r, tipc)   -- a long feather from (bx, by): banded near a pale tip
    local a = math.rad(ang); local dx, dy = math.cos(a), math.sin(a); local nx, ny = -dy, dx
    local ex, ey = bx + dx * len, by + dy * len
    local m = c:poly{ { bx + nx * wid * .4, by + ny * wid * .4 }, { ex + nx * wid * .5, ey + ny * wid * .5 }, { ex - nx * wid * .5, ey - ny * wid * .5 }, { bx - nx * wid * .4, by - ny * wid * .4 } }
    m:add(c:ellipse(floor(ex + .5), floor(ey + .5), wid * .5, wid * .5))
    form(c, m, r, { frac = 0.3, off = 1 }) under(c, m, W.deep)
    m:each(function(x, y) local t = ((x - bx) * dx + (y - by) * dy) / len
      if t > 0.97 then c:put(x, y, tipc or CREAM.base) elseif t > 0.82 then c:put(x, y, W.deep) elseif t > 0.56 and t < 0.64 then inside(c, x, y, W.base, r.base, r.shade) end end)
    return m
  end
  feather(30, 62, 197, 22, 7, DK) feather(30, 64, 182, 24, 7, DK) feather(30, 66, 167, 23, 7, DK) feather(31, 68, 152, 20, 7, DK)   -- tail fan
  local function legf(x)
    form(c, c:rect(x, 70, x + 2, 85), G, { frac = 0.34, off = 1 })
    for y = 73, 84, 3 do c:put(x, y, G.shade) c:put(x + 1, y, G.shade) end                 -- scaly shins
    form(c, c:line({ { x - 1, 86 }, { x + 8, 86 } }, 2), G, { noshade = true })
    dots(c, { { x + 9, 87 }, { x + 10, 88 }, { x + 5, 87 }, { x + 5, 88 }, { x - 2, 87 }, { x - 3, 88 }, { x + 2, 88 } }, P.ink)   -- talons
  end
  legf(40)
  local body = c:ellipse(46, 54, 19, 21)
  body:add(c:ellipse(52, 44, 13, 14))
  form(c, body, W, { frac = 0.3, off = 4, pop = { { 34, 40 }, { 35, 40 }, { 34, 41 } } })
  under(c, body, W.deep)
  local chest = c:ellipse(55, 56, 11, 16); chest:clip(body)
  form(c, chest, CREAM, { frac = 0.25, off = 2, inner = false })
  for row = 0, 5 do for i = 0, 2 do   -- chest flecks, row on row, thinning toward the throat
    local x, y = 48 + i * 5 + (row % 2) * 2, 46 + row * 4
    if chest:has(x, y) and chest:has(x + 2, y + 1) and (row > 0 or i == 1) then c:put(x, y, W.base) c:put(x + 1, y + 1, W.shade) c:put(x + 2, y, W.base) end
  end end
  legf(52)
  for _, t in ipairs({ { 42, W }, { 54, CREAM } }) do   -- feathered thighs with a ragged hem
    local m = c:ellipse(t[1], 70, 5, 4.5)
    for i = -1, 1 do m:add(c:poly{ { t[1] + i * 3 - 2, 73 }, { t[1] + i * 3 + 2, 73 }, { t[1] + i * 3, 77 } }) end
    form(c, m, t[2], { frac = 0.3, off = 1, inner = false }) under(c, m, t[2].deep)
  end
  -- wing: three long primaries under a shoulder of covert rows
  feather(36, 62, 118, 20, 6, DK, W.base) feather(33, 60, 108, 20, 6, DK, W.base) feather(31, 58, 98, 17, 6, DK, W.base)
  local wing = c:ellipse(37, 54, 11, 16)
  form(c, wing, DK, { frac = 0.22, off = 2, pop = { { 30, 43 }, { 31, 43 }, { 33, 41 }, { 34, 41 } } })
  under(c, wing, W.deep)
  for row = 0, 4 do for i = 0, 4 do   -- covert rows: a dark scallop with a lit edge under it
    local x, y = 28 + i * 5 + (row % 2) * 2, 45 + row * 5
    if wing:has(x, y) and wing:has(x + 3, y + 2) then
      dots(c, { { x, y }, { x + 1, y + 1 }, { x + 2, y + 1 }, { x + 3, y } }, W.deep)
      inside(c, x + 1, y + 2, W.base, DK.base) inside(c, x + 2, y + 2, W.base, DK.base)
    end
  end end
  local head = c:ellipse(60, 28, 11.5, 10.5)
  form(c, head, W, { frac = 0.3, off = 4, pop = { { 53, 21 }, { 54, 21 }, { 53, 22 } } })
  head:each(function(x, y) if y < 23 then inside(c, x, y, DK.base, W.base) end end)                -- a dark cap
  dots(c, { { 50, 28 }, { 51, 28 }, { 52, 27 }, { 53, 27 }, { 54, 27 }, { 55, 26 }, { 56, 26 }, { 57, 26 }, { 58, 26 }, { 59, 26 } }, W.deep)   -- eye stripe
  for _, q in ipairs({ { 52, 31 }, { 56, 33 }, { 51, 35 }, { 60, 35 } }) do tuft(c, q[1], q[2], W) end
  dots(c, { { 63, 32 }, { 64, 32 }, { 65, 33 }, { 64, 33 }, { 63, 33 }, { 66, 33 } }, CREAM.shade)   -- pale throat
  for i, t in ipairs({ { 50, 20, 44, 12 }, { 61, 18, 61, 9 } }) do   -- crest
    local m = c:poly{ { t[1] - 3, t[2] + 2 }, { t[1] + 3, t[2] + 1 }, { t[3], t[4] } }
    form(c, m, W, { frac = 0.3, off = 1 })
    m:each(function(x, y) if y < t[4] + 4 then c:put(x, y, CREAM.base) end end)   -- pale tips
  end
  local bent = c:line({ { 55, 19 }, { 54, 13 } }, 3); bent:add(c:line({ { 54, 13 }, { 59, 10 } }, 2))   -- quirk: the middle crest feather is kinked over
  form(c, bent, W, { frac = 0.3, off = 1 }) bent:each(function(x, y) if x > 56 then c:put(x, y, CREAM.base) end end)
  local beak = c:poly{ { 69, 25 }, { 79, 29 }, { 80, 33 }, { 77, 38 }, { 75, 34 }, { 69, 34 } }
  form(c, beak, G, { frac = 0.3, off = 1, pop = { { 72, 27 }, { 73, 27 } } })
  under(c, beak, G.shade)
  for y = 25, 34 do inside(c, 69, y, G.hi, G.base, G.shade) inside(c, 70, y, G.hi, G.base) end   -- cere: the pale base of the beak
  dots(c, { { 71, 31 }, { 72, 31 }, { 73, 32 }, { 74, 32 }, { 75, 33 } }, G.deep) c:put(72, 28, G.deep)   -- gape, nostril
  dots(c, { { 77, 36 }, { 77, 37 }, { 78, 35 }, { 76, 35 } }, W.deep)             -- dark hook
  eye(c, 62, 24)
  c:put(62, 25, G.base) c:put(65, 26, G.base) c:put(62, 26, G.base)             -- a yellow iris
  dots(c, { { 60, 22 }, { 61, 22 }, { 62, 23 }, { 63, 23 }, { 64, 24 }, { 65, 24 }, { 66, 25 } }, W.deep)   -- the hawk's glare
  form(c, c:rect(52, 78, 54, 80), P.ember, { noshade = true }) c:put(52, 78, P.ember.hi) c:put(55, 79, P.ember.shade)   -- quirk: a red ring on one leg
  -- quirk: it is moulting: one small feather drifts down behind it
  local lf = c:ellipse(15, 36, 3, 1.5); c:fillMask(lf, W.base) c:put(12, 36, CREAM.base) c:put(13, 36, CREAM.base) c:put(13, 35, CREAM.base) c:put(16, 36, W.shade) c:put(17, 36, W.shade) c:put(19, 37, W.deep)
  c:finish()
  return c
end

-- BULLFROG (64x56, sits on y = 49, faces the viewer) --------------------------------------------------
local function frog()
  local c = HP.canvas{ w = 64, h = 56, name = "frog" }
  c:groundShadow(32, 49.5, 22, 3.5)
  for _, s in ipairs({ -1, 1 }) do   -- folded back legs with dark bars, wide webbed feet with toe pads
    local m = c:ellipse(32 + s * 17, 41, 7, 7)
    form(c, m, M, { frac = s > 0 and 0.4 or 0.15, off = 2 }) under(c, m, M.deep)
    for i = 0, 2 do for j = 0, 2 do inside(c, 32 + s * (14 + i * 3) + j * (s > 0 and 1 or -1), 37 + i * 2 + j, M.deep, M.base, M.shade) end end
    local f = c:ellipse(32 + s * 19, 47, 7, 2.5)
    form(c, f, M, { frac = 0.3, off = 1 }) under(c, f, M.deep)
    for i = -1, 1 do c:put(32 + s * 19 + i * 4, 46, M.deep) c:put(32 + s * 19 + i * 4 - 2, 46, M.hi) end
  end
  local body = c:ellipse(32, 35, 18, 13.5)
  form(c, body, M, { frac = 0.28, off = 4, pop = { { 20, 27 }, { 21, 27 }, { 20, 28 } } })
  under(c, body, M.deep) toplight(c, body, M, 22, 42, 1)
  local bel = c:ellipse(32, 42, 12, 7.5); bel:clip(body)
  form(c, bel, CREAM, { frac = 0.25, off = 2, inner = false })
  dots(c, { { 27, 40 }, { 31, 43 }, { 35, 41 }, { 29, 46 }, { 36, 45 } }, CREAM.shade)               -- speckled belly
  for x = 24, 40 do if bel:has(x, 37) and x % 2 == 0 then c:put(x, 37, CREAM.shade) end end          -- the fold of the throat
  for _, s in ipairs({ -1, 1 }) do
    local cx = 32 + s * 10
    local b = c:ellipse(cx, 22, 6.5, 6.5)   -- eye bumps
    form(c, b, M, { frac = s > 0 and 0.3 or 0.12, off = 2, pop = s < 0 and { { 18, 18 }, { 19, 18 } } or nil })
    local w = c:ellipse(cx, 22.5, 3.5, 3.5); c:fillMask(w, G.base)                                    -- a golden eye
    w:each(function(x, y) if not w:has(x, y - 1) then c:put(x, y, P.ink) elseif not w:has(x, y + 1) then c:put(x, y, G.shade) end end)
    -- quirk: both eyes have rolled inward and up, at the fly sitting between them
    c:fillMask(c:rect(cx - s * 2 - 1, 21, cx - s * 2, 23), P.ink) c:put(cx - s * 2 - (s > 0 and 0 or 1), 21, P.cream)
    c:put(cx + s * 2, 24, G.hi)
  end
  for x = 17, 47 do local y = floor(33.5 + 2.2 * sqrt(max(0, 1 - ((x - 32) / 15.5) ^ 2)) - 1.5 + 0.5); c:put(x, y, M.deep) end   -- a very wide mouth
  c:put(16, 32, M.deep) c:put(48, 32, M.deep) c:put(15, 31, M.deep) c:put(49, 31, M.deep)
  dots(c, { { 40, 35 }, { 41, 35 }, { 40, 36 }, { 41, 36 }, { 41, 37 } }, PT.base) c:put(40, 37, PT.shade) c:put(41, 38, PT.shade)   -- quirk: the tip of its tongue is already out
  dots(c, { { 29, 29 }, { 34, 29 } }, M.deep) dots(c, { { 29, 28 }, { 34, 28 } }, M.hi)             -- nostrils
  dots(c, { { 19, 35 }, { 20, 35 }, { 44, 31 }, { 45, 31 } }, PT.base)                               -- cheeks
  for _, q in ipairs({ { 25, 25 }, { 38, 26 }, { 41, 30 }, { 23, 30 }, { 15, 38 }, { 47, 36 }, { 27, 31 }, { 36, 31 } }) do   -- warts: a dark dot with a lit top
    inside(c, q[1], q[2], M.shade, M.base) inside(c, q[1] + 1, q[2], M.shade, M.base) inside(c, q[1], q[2] - 1, M.hi, M.base)
  end
  for _, s in ipairs({ -1, 1 }) do   -- front legs and toes
    local a = c:ellipse(32 + s * 9, 43.5, 2.5, 4.5)
    form(c, a, M, { frac = 0.34, off = 1, inner = false })
    a:each(function(x, y) if not a:has(x - s, y) and y < 47 then c:put(x, y, M.shade) end end)   -- a soft edge against the belly, not a hard line
    local t = c:rect(32 + s * 9 - 3, 47, 32 + s * 9 + 3, 48); c:fillMask(t, M.base)
    c:put(32 + s * 9 - 1, 48, M.deep) c:put(32 + s * 9 + 1, 48, M.deep) c:put(32 + s * 9 - 3, 47, M.hi) c:put(32 + s * 9, 47, M.hi) c:put(32 + s * 9 + 3, 47, M.hi)
  end
  c:put(26, 23, P.cream) c:put(27, 33, P.sky.hi)                                                    -- wet shine
  -- the fly: on the frog's head, between its eyes
  dots(c, { { 31, 19 }, { 32, 19 }, { 32, 20 }, { 31, 20 } }, P.ink) dots(c, { { 30, 18 }, { 33, 18 }, { 29, 17 }, { 34, 17 } }, P.sky.base) c:put(31, 19, P.ember.base)
  c:finish()
  return c
end

for _, f in ipairs({ boar, hawk, frog }) do local c = f(); c:save{ png = out .. "c25-" .. c.name .. ".png", aseprite = out .. "c25-" .. c.name .. ".aseprite" } print(c.name, c.w .. "x" .. c.h) end
