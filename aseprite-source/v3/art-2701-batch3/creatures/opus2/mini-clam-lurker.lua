-- mini-clam-lurker (61x45 still, faces right). Opus second pass.
-- Kept from the game picture: one big round pink clam, opened a crack toward the right, something
-- lurking inside with pale teeth. Named defect: the grey head poking out read as a bird or a cat.
-- Fix: no head at all; the lurker is the clam's own soft body. A dark mouth gap between the two
-- ribbed valves, a frilly peach mantle along both lips, a row of cream teeth, two eye stalks leaning
-- out of the gap, and the pink foot lolling out like a tongue. quirk: a pearl balanced on the tongue.
local NAME = "mini-clam-lurker"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local SHELL = R("#ffb4cc", "#f07ca0", "#c44f84", "#7d2c5e")
local MANT = R("#ffe0c8", "#f8b89a", "#d88478", "#9a5060")
local MOUTH = "#4a1f3c"
local TONG = R("#ff9cb0", "#e8607e", "#b23e66", "#6e2448")
local PEARL = R("#fffaf0", "#e8eef4", "#b8c4d8", "#7e88a8")

local c = HP.canvas{ w = 61, h = 45, scale = 1, name = NAME }
c:groundShadow(29, 41, 25, 2)
for y = 0, c.h - 1 do for x = 0, c.w - 1 do local i = y * c.w + x
  if c.pix[i] and not c.pix[i - 1] and not c.pix[i + 1] then c.pix[i], c.own[i] = nil, nil end end end

local HX, HY = 5, 23 -- hinge at the back (left)
local shell = c:ellipse(29, 22, 25, 17.5)
do local nub = {} shell:each(function(x, y) if not shell:has(x - 1, y) and not shell:has(x + 1, y) then nub[#nub + 1] = { x, y } end end)
  for _, q in ipairs(nub) do shell.s[(q[2] + 256) * 1024 + q[1] + 256] = nil end end
-- the gap: a wedge from the hinge opening to the right
local function upperY(x) return HY + (19 - HY) * (x - HX) / (55 - HX) end
local function lowerY(x) return HY + (29 - HY) * (x - HX) / (55 - HX) end
local up, low, gap = HP.mask(), HP.mask(), HP.mask()
shell:each(function(x, y)
  if y <= upperY(x) then up:set(x, y) elseif y >= lowerY(x) then low:set(x, y) else gap:set(x, y) end
end)
-- mouth (dark inside), then mantle lips
c:fillMask(gap, MOUTH)
local lipU, lipL = HP.mask(), HP.mask()
gap:each(function(x, y)
  if x > 14 then
    if y - upperY(x) < 1.6 then lipU:set(x, y) end
    if lowerY(x) - y < 1.6 then lipL:set(x, y) end
  end
end)
-- frill: the lips wave
for x = 14, 56 do if x % 4 == 0 then lipU:set(x, math.floor(upperY(x)) + 2) lipL:set(x, math.floor(lowerY(x)) - 2) end end
lipU:clip(gap) lipL:clip(gap)
c:fillMask(lipU, MANT.base) c:fillMask(lipL, MANT.shade)
-- teeth hanging from the upper lip
for x = 22, 52, 4 do local y = math.floor(upperY(x)) + 2
  if gap:has(x, y) then c:put(x, y, P.cream) c:put(x + 1, y, P.cream) c:put(x, y + 1, P.cream) end end
-- valves
local function valve(m, top)
  c:part(m, SHELL, { band = top and 2 or 3, nopop = true })
  -- ribs radiating from the hinge
  for a = (top and -70 or 16), (top and -10 or 76), 15 do
    local r = math.rad(a)
    local l = c:line({ { HX, HY }, { HX + math.cos(r) * 60, HY + math.sin(r) * 60 } }, 1):clip(m:copy():shrink(1))
    local pts = {}
    l:each(function(x, y) if (x - HX) > 6 then pts[#pts + 1] = { x, y } end end)
    for _, q in ipairs(pts) do c:put(q[1], q[2], top and SHELL.shade or SHELL.deep) end
  end
  -- growth ring near the rim (lit on the upper valve)
  local ring = m:copy():shrink(3):edge()
  local pts = {}
  ring:each(function(x, y) if (top and y < upperY(x) - 2) or (not top and y > lowerY(x) + 2) then pts[#pts + 1] = { x, y } end end)
  for _, q in ipairs(pts) do if c:get(q[1], q[2]) == SHELL.base then c:put(q[1], q[2], SHELL.hi) end end
  -- the valve lip: a dark edge along the gap
  local e = {}
  m:each(function(x, y) if gap:has(x, y + 1) or gap:has(x, y - 1) then e[#e + 1] = { x, y } end end)
  for _, q in ipairs(e) do c:put(q[1], q[2], SHELL.deep) end
end
valve(up, true)
valve(low, false)
-- shine on the upper valve and the hinge knob
c:put(15, 9, P.cream) c:put(16, 9, SHELL.hi) c:put(15, 10, SHELL.hi)
c:part(c:ellipse(5, 23, 2.5, 3), SHELL, { band = 1, nopop = true })

-- tongue (the foot) lolling out of the gap, over the lower valve, with the pearl
local tong = c:ellipse(51, 30, 6, 3)
tong:add(c:ellipse(56, 32, 3.5, 2.5))
c:part(tong, TONG, { band = 1, pop = { x = 48, y = 28 } })
c:fillMask(c:line({ { 46, 30 }, { 54, 31 } }, 1), TONG.shade)
local pearl = c:rrect(54, 26, 58, 30, 2)
c:part(pearl, PEARL, { band = 1, nopop = true })
c:put(55, 27, P.cream)
-- eye stalks leaning out of the gap, in front of the upper valve
local function stalk(base, tip)
  c:part(c:line({ base, tip }, 2), MANT, { band = 1, nopop = true })
  local bulb = c:ellipse(tip[1], tip[2] - 1, 3, 3)
  c:part(bulb, MANT, { band = 1, nopop = true })
  c:eyeSmall(tip[1] - 1, tip[2] - 3)
end
stalk({ 44, 21 }, { 46, 11 })
stalk({ 49, 21 }, { 54, 13 })
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
