-- mini-clam-lurker (61x45 still, faces right). Opus third pass (richness).
-- Same creature as opus2: one big round pink clam opened a crack toward the right, the lurker is the clam's
-- own soft body: dark mouth gap, frilly peach mantle lips, cream teeth, two eye stalks, the foot lolling out
-- like a tongue with a pearl on it (quirk).
-- Richness: each valve is lit as a dome (6-tone hue-shifted pink ramp), with raised radial ribs (shaded
-- groove plus a lit ridge), concentric growth rings, a lit rim along the top and a cool sea bounce line along
-- the bottom; the mouth darkens toward the throat; the teeth have a shaded root; the mantle frill has two
-- tones; the tongue is wet with a specular; the pearl is iridescent (pink and blue glints). Look closer: a
-- tiny barnacle has settled on the upper valve.
local NAME = "mini-clam-lurker"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local Q = dofile(DIR .. "/_rich.lua").init(HP)
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local SHELL6 = { "#5e2456", "#8a3268", "#c44f84", "#f07ca0", "#ff9eb6", "#ffcad8" }
local MANT6 = { "#7e4058", "#b0646a", "#d88478", "#f8b89a", "#ffd2b4", "#ffe8d4" }
local MOUTH = { "#2e1430", "#4a1f3c", "#62294a" }
local TONG6 = { "#5a1636", "#8e2446", "#c03454", "#ec4e66", "#ff8290", "#ffc0c0" }
local BOUNCE = "#b07ab4"
local BARN = R("#f4ecd8", "#d6ccb8", "#a89c94", "#6c6070")

local c = HP.canvas{ w = 61, h = 45, scale = 1, name = NAME }
c:groundShadow(29, 41, 25, 2)
for y = 0, c.h - 1 do for x = 0, c.w - 1 do local i = y * c.w + x
  if c.pix[i] and not c.pix[i - 1] and not c.pix[i + 1] then c.pix[i], c.own[i] = nil, nil end end end

local HX, HY = 5, 23 -- hinge at the back (left)
local shell = c:ellipse(29, 22, 25, 17.5)
do local nub = {} shell:each(function(x, y) if not shell:has(x - 1, y) and not shell:has(x + 1, y) then nub[#nub + 1] = { x, y } end end)
  for _, q in ipairs(nub) do shell.s[(q[2] + 256) * 1024 + q[1] + 256] = nil end end
local function upperY(x) return HY + (19 - HY) * (x - HX) / (55 - HX) end
local function lowerY(x) return HY + (29 - HY) * (x - HX) / (55 - HX) end
local up, low, gap = HP.mask(), HP.mask(), HP.mask()
shell:each(function(x, y)
  if y <= upperY(x) then up:set(x, y) elseif y >= lowerY(x) then low:set(x, y) else gap:set(x, y) end
end)
-- mouth: darker toward the throat (left), a little lighter at the opening
gap:each(function(x, y) c:put(x, y, x < 22 and MOUTH[1] or (x < 40 and MOUTH[2] or MOUTH[3])) end)
local lipU, lipL = HP.mask(), HP.mask()
gap:each(function(x, y)
  if x > 14 then
    if y - upperY(x) < 1.6 then lipU:set(x, y) end
    if lowerY(x) - y < 1.6 then lipL:set(x, y) end
  end
end)
for x = 14, 56 do if x % 4 == 0 then lipU:set(x, math.floor(upperY(x)) + 2) lipL:set(x, math.floor(lowerY(x)) - 2) end end
lipU:clip(gap) lipL:clip(gap)
-- frill: lit tips, shaded folds
lipU:each(function(x, y) c:put(x, y, (x % 4 == 0) and MANT6[5] or ((x % 4 == 2) and MANT6[3] or MANT6[4])) end)
lipL:each(function(x, y) c:put(x, y, (x % 4 == 0) and MANT6[4] or ((x % 4 == 2) and MANT6[2] or MANT6[3])) end)
-- teeth hanging from the upper lip: cream with a shaded root and tip shadow
for x = 22, 52, 4 do local y = math.floor(upperY(x)) + 2
  if gap:has(x, y) then
    c:put(x, y, P.cream) c:put(x + 1, y, "#e6d4b8") c:put(x, y + 1, P.cream)
    if gap:has(x + 1, y + 1) then c:put(x + 1, y + 1, MOUTH[1]) end
  end end

-- valves lit as domes
local function valve(m, top)
  local tok = { r = { name = top and "up" or "low" } }
  local cx, cy = top and 26 or 30, top and 12 or 26
  local idx = Q.body(c, m, SHELL6, { sphere = { cx, cy, top and 24 or 22 }, amb = 0.2, wrap = 0.4, tok = tok,
    bounce = (not top) and BOUNCE or nil, bounceMinX = 10 })
  -- radial ribs: a dark groove with a lit ridge on its upper-left side
  for a = (top and -70 or 16), (top and -10 or 76), 15 do
    local r = math.rad(a)
    local l = c:line({ { HX, HY }, { HX + math.cos(r) * 60, HY + math.sin(r) * 60 } }, 1):clip(m:copy():shrink(1))
    local pts = {}
    l:each(function(x, y) if (x - HX) > 6 then pts[#pts + 1] = { x, y } end end)
    for _, q in ipairs(pts) do
      local k = Q.X.K(q[1], q[2])
      local i = idx[k] or 4
      c:put(q[1], q[2], SHELL6[math.max(1, i - 2)], tok)
      local lx, ly = q[1] + (top and 1 or 0), q[2] - 1
      if m:has(lx, ly) and not l:has(lx, ly) then c:put(lx, ly, SHELL6[math.min(6, (idx[Q.X.K(lx, ly)] or 4) + 1)], tok) end
    end
  end
  -- concentric growth rings: one step darker, every 3 px in from the rim
  for d = 4, 4 do
    local ring = m:copy():shrink(d):edge()
    ring:each(function(x, y)
      if ((top and y < upperY(x) - 2) or (not top and y > lowerY(x) + 2)) and (x + y) % 5 ~= 0 then
        local i = idx[Q.X.K(x, y)] or 4
        if c:get(x, y) == SHELL6[i] then c:put(x, y, SHELL6[math.max(1, i - 1)], tok) end
      end
    end)
  end
  -- lit rim along the top edge of the upper valve
  if top then Q.side(m, 0, -1):each(function(x, y) if x < 40 then c:put(x, y, SHELL6[6], tok) end end) end
  -- the valve lip: a dark edge along the gap, lit on the lower valve's lip (light from above)
  m:each(function(x, y)
    if gap:has(x, y + 1) then c:put(x, y, SHELL6[1], tok)
    elseif gap:has(x, y - 1) then c:put(x, y, SHELL6[5], tok) end
  end)
  return tok
end
valve(up, true)
valve(low, false)
-- glossy shine on the upper valve, the hinge knob
c:put(15, 9, P.cream) c:put(16, 9, SHELL6[6]) c:put(15, 10, SHELL6[6]) c:put(17, 8, SHELL6[6])
local knob = c:ellipse(5, 23, 2.5, 3)
Q.body(c, knob, SHELL6, { R = 2, amb = 0.25 })
-- look closer: a tiny barnacle on the upper valve
c:paint({ ".hb.", "hbbs", "bdds", ".ss." }, 28, 6, { h = BARN.hi, b = BARN.base, s = BARN.shade, d = BARN.deep })

-- tongue (the foot) lolling out of the gap, wet, with the pearl
local tong = c:ellipse(51, 30, 6, 3)
tong:add(c:ellipse(56, 32, 3.5, 2.5))
local tTok = { r = { name = "tongue" } }
Q.body(c, tong, TONG6, { R = 2.5, amb = 0.22, tok = tTok })
c:fillMask(c:line({ { 46, 30 }, { 54, 31 } }, 1), TONG6[2])
-- inner line where the tongue lies over the lower valve
tong:each(function(x, y) for _, d in ipairs{ { 0, 1 }, { -1, 0 }, { 0, -1 } } do
  if low:has(x + d[1], y + d[2]) and not tong:has(x + d[1], y + d[2]) then c:put(x, y, TONG6[1], tTok) end end end)
c:put(47, 28, TONG6[6]) c:put(48, 28, TONG6[6]) c:put(57, 31, TONG6[6])
-- iridescent pearl
local pearl = c:rrect(54, 26, 58, 30, 2)
c:paint({ ".hcp.", "hccbb", "cccbs", "pcbss", ".bss." }, 54, 26,
  { h = "#fbf6ee", c = "#ecf0f4", b = "#c4d0e4", s = "#8e98b8", p = "#f4c8d8" })
c:put(55, 27, "#fbf6ee")
-- eye stalks leaning out of the gap, in front of the upper valve
local function stalk(base, tip)
  local st = c:line({ base, tip }, 2)
  local tok = { r = { name = "stalk" .. base[1] } }
  st:each(function(x, y) c:put(x, y, st:has(x - 1, y) and MANT6[3] or MANT6[5], tok) end)
  local bulb = c:ellipse(tip[1], tip[2] - 1, 3, 3)
  Q.body(c, bulb, MANT6, { sphere = { tip[1] - 1, tip[2] - 2, 3.5 }, amb = 0.25, tok = { r = { name = "bulb" .. base[1] } } })
  c:eyeSmall(tip[1] - 1, tip[2] - 3)
end
stalk({ 44, 21 }, { 46, 11 })
stalk({ 49, 21 }, { 54, 13 })
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
