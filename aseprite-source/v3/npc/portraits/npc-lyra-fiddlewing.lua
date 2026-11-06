-- npc-lyra-fiddlewing portrait (npc2 P1_19) species: grasshopper
-- Same design as the sprite: green grasshopper, eye bulges, pale snout plate, straw hat + red band, orange smock, knees behind shoulders, fiddle. Teal disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function bz(a, b, cc, t) local u = 1 - t
  return u*u*a[1] + 2*u*t*b[1] + t*t*cc[1], u*u*a[2] + 2*u*t*b[2] + t*t*cc[2] end


local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local NAME = "npc-lyra-fiddlewing"
local GREEN = R("#c4e07a", "#86c05a", "#4f8a5a", "#33584f")
local MUZ   = R("#eef4a8", "#c2dc7c", "#86b266", "#4f8a5a")
local SHIRT = R("#ffd36a", "#f0a531", "#c06a3a", "#8a4140")
local STRAW = R("#ffeaa0", "#e8c060", "#b98a4a", "#7f5a42")
local BAND  = R("#ee6a62", "#c03a48", "#8a2a44", "#5e2040")
local WOOD  = R("#eaa262", "#b8683a", "#874437", "#5a2e34")
local KNOB  = R("#b49ae0", "#7a5fb8", "#5a4290", "#3e2e6a")
local CREAM = R("#fff1c8", "#f3e0b0", "#c8a890", "#8a6a70")
local TEAL  = R("#9ad4c8", "#6cb8b0", "#4e9090", "#3a6a72")
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
-- folded hind-leg knees rising behind the shoulders
c:part(c:line({ { 16, 99 }, { 11, 80 }, { 9, 70 } }, 5), GREEN, { band = 2, pop = { x = 8, y = 70 } })
c:part(c:line({ { 63, 99 }, { 68, 80 }, { 70, 70 } }, 5), GREEN, { band = 2, nopop = true })
-- neck + smock + collar
c:part(c:rect(33, 72, 46, 86), GREEN, { band = 1, nopop = true })
c:part(c:ellipse(39.5, 108, 33, 27):clip(c:rect(0, 82, 79, 99)), SHIRT, { band = 3, pop = { x = 16, y = 90 } })
c:part(c:poly{ { 28, 82 }, { 39, 91 }, { 38, 94 }, { 25, 87 } }, CREAM, { band = 1, nopop = true })
c:part(c:poly{ { 51, 82 }, { 40, 91 }, { 41, 94 }, { 54, 87 } }, CREAM, { band = 1, nopop = true })
for y = 93, 99, 3 do c:put(39, y, SHIRT.deep) end
-- fiddle held up at lower left, bow behind
c:fillMask(c:line({ { 4, 78 }, { 30, 99 } }, 1), WOOD.deep)
local fid = c:ellipse(18, 93, 7, 6) fid:add(c:ellipse(18.5, 84.5, 5.5, 4.5))
c:part(fid, WOOD, { band = 2, pop = { x = 15, y = 82 } })
c:put(15, 90, WOOD.deep) c:put(15, 91, WOOD.deep) c:put(21, 90, WOOD.deep) c:put(21, 91, WOOD.deep)
c:part(c:line({ { 18, 81 }, { 15, 68 } }, 2), WOOD, { band = 1, nopop = true })
c:part(c:ellipse(14.5, 66, 2, 2.5), WOOD, { band = 1, pop = { x = 14, y = 65 } })
for y = 70, 97 do local x = math.floor(18 - (math.max(0, 81 - y)) * 0.23 + 0.5) if y > 80 or y < 80 then c:put(x, y, CREAM.base) end end
c:part(c:rect(15, 95, 21, 96), WOOD, { band = 1, nopop = true })
-- head with side eye bulges
local head = c:ellipse(39.5, 58, 19.5, 17)
head:add(c:ellipse(21, 55, 4, 5.5)) head:add(c:ellipse(58, 55, 4, 5.5))
c:part(head, GREEN, { band = 3, pop = { x = 25, y = 52 } })
-- snout plate (nose) with notch, little mandibles, smile
c:part(c:ellipse(39.5, 66, 9, 6.5), MUZ, { band = 2, nopop = true })
c:part(c:ellipse(39.5, 62, 3.5, 2.5), MUZ, { band = 1, pop = { x = 38, y = 61 } })
c:put(39, 63, GREEN.shade) c:put(40, 63, GREEN.shade) c:put(39, 64, GREEN.shade)
c:put(36, 71, GREEN.deep) c:put(43, 71, GREEN.deep)
for _, q in ipairs{ { 34, 67 }, { 35, 68 }, { 36, 69 }, { 37, 69 }, { 38, 69 }, { 41, 69 }, { 42, 69 }, { 43, 69 }, { 44, 68 }, { 45, 67 }, { 39, 69 }, { 40, 69 } } do c:px(q[1], q[2], P.ink) end
c:eyeLocked(26, 53) c:eyeLocked(49, 53)
c:cheek(27, 62) c:cheek(51, 62)
-- straw sun hat
local brim = c:ellipse(39.5, 46, 28, 5)
c:part(brim, STRAW, { band = 2, pop = { x = 16, y = 45 } })
for x = 14, 66, 3 do if brim:has(x, 48) then c:put(x, 48, STRAW.shade) end end
local crown = c:rrect(27, 25, 52, 46, 7)
c:part(crown, STRAW, { band = 3, pop = { x = 31, y = 28 } })
for y = 28, 35, 3 do for x = 30 + (y % 2) * 2, 50, 4 do if crown:has(x, y) then c:put(x, y, STRAW.shade) end end end
c:part(c:rect(27, 38, 52, 42), BAND, { band = 1, pop = { x = 29, y = 38 } })
for x = 27, 52 do if crown:has(x, 45) then c:put(x, 45, STRAW.deep) end end
-- antenna knobs
local tips = { { 23, 12 }, { 56, 12 } }
for _, t in ipairs(tips) do c:part(c:ellipse(t[1], t[2], 2.5, 2.5), KNOB, { band = 1, pop = { x = t[1] - 1, y = t[2] - 1 } }) end
c:finish{ outline = true }
c:fillMask(c:line({ { 33, 24 }, { 28, 18 }, { 25, 15 } }, 1), P.ink)
c:fillMask(c:line({ { 46, 24 }, { 51, 18 }, { 54, 15 } }, 1), P.ink)
backdrop(c, TEAL)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
