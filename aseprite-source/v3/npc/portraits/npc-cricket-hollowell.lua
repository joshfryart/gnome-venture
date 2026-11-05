-- npc-cricket-hollowell portrait (npc2 P1_8) species: hedgehog
-- 80x100 head+shoulders, green disc; startled little 'o' mouth, apple on the quills.
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
local SPN = { hi = "#b0804e", base = "#80573a", shade = "#5a3c4c", deep = "#3c2840" }
local FACE = { hi = "#f8e6c4", base = "#e6c294", shade = "#b98c7c", deep = "#80606c" }
local PAW = { hi = "#eeac90", base = "#cc8070", shade = "#925668", deep = "#603852" }
local APL = { hi = "#ff9070", base = "#da443c", shade = "#9c2c48", deep = "#621c3e" }
local LEAF = { hi = "#aad85c", base = "#62aa3e", shade = "#3c7248", deep = "#26484c" }
local NAME = "npc-cricket-hollowell"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
-- shoulders: quilled back at the sides, cream chest
local body = c:ellipse(39.5, 106, 30, 28)
body:add(spikes(c, 39.5, 106, 28, 26, 195, 250, 14, 5, 6)) body:add(spikes(c, 39.5, 106, 28, 26, 290, 345, 14, 5, 6))
body = body:clip(c:rect(0, 72, 79, 99))
form(c, body, SPN, { frac = 0.3, off = 2 })
quills(c, body, SPN, 39.5, 106, 28, 26, 195, 250, 14, 5) quills(c, body, SPN, 39.5, 106, 28, 26, 290, 345, 14, 5)
local chest = c:ellipse(39.5, 104, 15, 24):clip(body)
form(c, chest, FACE, { frac = 0.3, off = 2, pop = { { 30, 86 }, { 31, 84 } } })
for _, y in ipairs({ 88, 93, 97 }) do onlyOver(c, c:line({ { 35, y }, { 37, y + 1 } }, 1), { [FACE.base] = true }, FACE.shade) end
-- head quill dome
local head = c:ellipse(39.5, 52, 20, 16)
head:add(spikes(c, 39.5, 50, 19, 15, 150, 390, 15, 7, 7))
form(c, head, SPN, { frac = 0.3, off = 2 })
quills(c, head, SPN, 39.5, 50, 19, 15, 150, 390, 15, 7)
for _, x in ipairs({ 18, 61 }) do
  local m = c:ellipse(x, 54, 3, 4) form(c, m, PAW, { off = 1, frac = 0.4 })
  c:fillMask(c:ellipse(x, 55, 1, 2), PAW.shade)
end
-- face
local face = c:ellipse(39.5, 58, 15.5, 11)
for _, x0 in ipairs({ 25, 31, 37, 43, 49 }) do face:cut(c:poly{ { x0, 46 }, { x0 + 5, 46 }, { x0 + 2.5, 50 } }) end
form(c, face, FACE, { frac = 0.28, off = 2, pop = { { 27, 52 }, { 26, 53 }, { 26, 54 } } })
c:eyeLocked(30, 51) c:eyeLocked(45, 51)
-- snout + nose
local sn = c:ellipse(39.5, 62, 6, 4)
form(c, sn, FACE, { off = 1, frac = 0.35, inner = false, pop = { { 36, 59 }, { 37, 59 }, { 36, 60 } } })
under(c, sn, FACE.shade)
c:fillMask(c:ellipse(39.5, 64, 2.5, 1.8), SPN.deep) c:put(38, 63, FACE.hi) c:put(39, 63, SPN.hi)
-- startled 'o' mouth
for _, q in ipairs({ { 39, 67 }, { 40, 67 }, { 38, 68 }, { 41, 68 }, { 39, 69 }, { 40, 69 } }) do c:put(q[1], q[2], P.ink) end
c:put(39, 68, P.petal.shade) c:put(40, 68, P.petal.base)
for _, x in ipairs({ 26, 50 }) do for dx = 0, 3 do for dy = 0, 1 do c:put(x + dx, 61 + dy, P.petal.base) end end c:put(x, 61, P.petal.hi) end
-- apple on the quills
local ap = c:ellipse(55, 29, 5.5, 5)
form(c, ap, APL, { off = 1, frac = 0.35, pop = { { 52, 26 }, { 53, 26 }, { 52, 27 } } })
under(c, ap, APL.deep)
c:put(55, 24, APL.deep) c:put(56, 25, APL.deep)
c:fillMask(c:line({ { 55, 23 }, { 57, 20 } }, 2), SPN.deep)
local lf = c:poly{ { 58, 21 }, { 63, 17 }, { 65, 19 }, { 61, 23 } }
form(c, lf, LEAF, { off = 1, frac = 0.4, inner = false })
c:fillMask(c:line({ { 59, 21 }, { 63, 19 } }, 1), LEAF.shade)
c:finish{ outline = true }
backdrop(c, { base = "#8cc06a", shade = "#64a052", deep = "#447648" })
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
