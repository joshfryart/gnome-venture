-- npc-dew-dewberry portrait (npc2 P1_8) species: ladybug
-- 80x100 head+shoulders, violet disc; straw cone hat, dew-bead antennae, holds a leaf cup with a dewdrop.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function R2(v) return math.floor(v + 0.5) end
local function form(c, m, r, o)
  o = o or {}
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
  if o.pop then for _, q in ipairs(o.pop) do c:put(q[1], q[2], r.hi, r) end end
  return m
end
local function under(c, m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
local function spikes(c, cx, cy, rx, ry, a0, a1, step, len, w)
  local m = HP.mask()
  for a = a0, a1, step do
    local r, r1, r2 = math.rad(a), math.rad(a - w), math.rad(a + w)
    m:add(c:poly{ { R2(cx + math.cos(r1) * rx), R2(cy + math.sin(r1) * ry) }, { R2(cx + math.cos(r) * (rx + len)), R2(cy + math.sin(r) * (ry + len)) }, { R2(cx + math.cos(r2) * rx), R2(cy + math.sin(r2) * ry) } })
  end
  return m
end
local function quills(c, m, R, cx, cy, rx, ry, a0, a1, step, len)
  for a = a0, a1, step do
    local r = math.rad(a)
    local lm = c:line({ { R2(cx + math.cos(r) * (rx - 3)), R2(cy + math.sin(r) * (ry - 3)) }, { R2(cx + math.cos(r) * (rx + len - 2)), R2(cy + math.sin(r) * (ry + len - 2)) } }, 1)
    local aa = a % 360
    local lit = aa >= 185 and aa <= 265
    lm:each(function(x, y) if m:has(x, y) then c:put(x, y, lit and R.hi or R.shade) end end)
    local q = math.rad(a + step / 2)
    local lm2 = c:line({ { R2(cx + math.cos(q) * (rx - 4)), R2(cy + math.sin(q) * (ry - 4)) }, { R2(cx + math.cos(q) * (rx - 1)), R2(cy + math.sin(q) * (ry - 1)) } }, 1)
    lm2:each(function(x, y) if m:has(x, y) then c:put(x, y, R.deep) end end)
  end
end
local function onlyOver(c, m, hexset, hex) m:each(function(x, y) if hexset[c:get(x, y) or ""] then c:put(x, y, hex) end end) end
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
local HEAD = { hi = "#6c5c8e", base = "#4b3e6a", shade = "#35294e", deep = "#291d3c" }
local NOSE = { hi = "#a08cbc", base = "#7c6a9c", shade = "#58497c", deep = "#3c3060" }
local SHELL = { hi = "#ff7c5e", base = "#e03a3c", shade = "#a22648", deep = "#681a42" }
local SPOT = "#3a2a4a"
local CRM = { hi = "#fbefd6", base = "#f0dcb4", shade = "#c7aa9a", deep = "#8c7486" }
local STRAW = { hi = "#ffe08c", base = "#e9b44e", shade = "#b47c40", deep = "#7c503c" }
local DEW = { hi = "#eef8f0", base = "#a2dcea", shade = "#5ca2cc", deep = "#3c6c9c" }
local LEAF = { hi = "#aad85c", base = "#62aa3e", shade = "#3c7248", deep = "#26484c" }
local NAME = "npc-dew-dewberry"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
-- shoulders: shell with spots, dark parting plate
local body = c:ellipse(39.5, 106, 31, 30):clip(c:rect(0, 70, 79, 99))
form(c, body, SHELL, { frac = 0.3, off = 2, pop = { { 16, 85 }, { 17, 84 }, { 18, 83 } } })
local plate = c:poly{ { 35, 72 }, { 44, 72 }, { 50, 99 }, { 29, 99 } }:clip(body)
form(c, plate, HEAD, { frac = 0.35, off = 1 })
for _, s in ipairs({ { 18, 92, 3 }, { 25, 81, 2.5 }, { 58, 82, 2.5 }, { 63, 94, 3 } }) do
  onlyOver(c, c:ellipse(s[1], s[2], s[3], s[3]), { [SHELL.base] = true, [SHELL.shade] = true, [SHELL.hi] = true }, SPOT)
end
-- head
local head = c:ellipse(39.5, 57, 20, 15)
form(c, head, HEAD, { frac = 0.28, off = 2 })
for _, x in ipairs({ 25, 54 }) do
  local m = c:ellipse(x, 63, 5, 3.5) form(c, m, CRM, { off = 1, frac = 0.4, inner = false, pop = { { x - 3, 61 } } })
end
c:eyeLocked(29, 52) c:eyeLocked(46, 52)
local sn = c:ellipse(39.5, 61.5, 3.5, 2.5)
form(c, sn, NOSE, { off = 1, frac = 0.35, inner = false, pop = { { 37, 60 }, { 38, 60 } } })
under(c, sn, NOSE.deep)
c:put(38, 62, NOSE.deep) c:put(41, 62, NOSE.deep)
for _, q in ipairs({ { 34, 65 }, { 35, 66 }, { 36, 67 }, { 37, 67 }, { 38, 67 }, { 39, 67 }, { 40, 67 }, { 41, 67 }, { 42, 67 }, { 43, 66 }, { 44, 65 } }) do c:put(q[1], q[2], CRM.base) end
for x = 37, 42 do c:put(x, 68, P.petal.base) end
-- antenna beads
form(c, c:ellipse(16, 24, 2.5, 2.5), DEW, { off = 1, frac = 0.4, inner = false }) c:put(15, 23, DEW.hi)
form(c, c:ellipse(64, 22, 2.5, 2.5), DEW, { off = 1, frac = 0.4, inner = false }) c:put(63, 21, DEW.hi)
-- straw cone hat
local brim = c:ellipse(39.5, 43, 26, 5.5)
form(c, brim, STRAW, { frac = 0.3, off = 1, pop = { { 16, 42 }, { 17, 41 }, { 18, 41 } } })
under(c, brim, STRAW.deep)
local cone = c:poly{ { 24, 42 }, { 55, 42 }, { 43, 12 } }
form(c, cone, STRAW, { frac = 0.35, off = 2, pop = { { 35, 24 }, { 34, 26 }, { 36, 22 }, { 33, 28 } } })
cone:each(function(x, y) if (x + y) % 4 == 0 and c:get(x, y) == STRAW.base then c:put(x, y, STRAW.shade) end end)
cone:each(function(x, y) if (x - y) % 7 == 0 and c:get(x, y) == STRAW.base then c:put(x, y, STRAW.hi) end end)
local band = c:rect(0, 36, 79, 38):clip(cone)
c:fillMask(band, LEAF.base) band:each(function(x, y) if x > 47 or y == 38 then c:put(x, y, LEAF.shade) elseif y == 36 and x < 36 then c:put(x, y, LEAF.hi) end end)
for x = 14, 65 do local y = R2(43 + 5.5 * math.sqrt(math.max(0, 1 - ((x - 39.5) / 26) ^ 2)) - 1.5)
  if brim:has(x, y) and (x % 3 ~= 0) then c:put(x, y, STRAW.shade) end end
-- prop: hand + leaf cup + dewdrop lower right
form(c, c:ellipse(57, 88, 3, 3), HEAD, { off = 1, frac = 0.4 })
local leaf = c:ellipse(63, 86, 8, 3.5)
form(c, leaf, LEAF, { off = 1, frac = 0.35, inner = false, pop = { { 57, 84 }, { 58, 84 } } })
under(c, leaf, LEAF.deep)
c:fillMask(c:line({ { 57, 86 }, { 69, 86 } }, 1):clip(leaf), LEAF.shade)
local dew = c:ellipse(63, 80, 5, 4.5)
dew:add(c:poly{ { 60, 78 }, { 66, 78 }, { 63, 71 } })
form(c, dew, DEW, { off = 1, frac = 0.35, inner = false })
c:put(60, 78, DEW.hi) c:put(61, 77, DEW.hi) c:put(61, 76, DEW.hi) c:put(66, 82, DEW.hi) c:put(65, 83, DEW.hi)
c:finish{ outline = true }
c:fillMask(c:line({ { 28, 39 }, { 23, 32 }, { 18, 26 } }, 1), P.ink)
c:fillMask(c:line({ { 51, 39 }, { 57, 30 }, { 62, 24 } }, 1), P.ink)
backdrop(c, { base = "#a888cc", shade = "#8064aa", deep = "#5e4888" })
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
