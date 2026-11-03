-- ico-plate-cutlery (Opus single pass, aA8_2). A table setting from above: a round glazed ceramic plate in the middle,
-- a slim steel fork standing on the left and a table knife with a wooden handle on the right, air between all three.
-- Material: plate lit per pixel from a turned height profile (sunk well, sloped wall, rolled rim), 6-tone warm cream
-- glaze with cool-violet deeps, a blue painted band on the rim and a little blue flower glazed in the well, glaze
-- specular on the upper-left rim; drop shadow to the lower right. Fork: 6-tone steel, pillow bevel, bright edge,
-- dark gaps between tines, AO where the neck meets the head. Knife: bevelled blade with a bright cutting edge and a
-- specular streak, steel bolster, walnut handle with grain lines and two brass rivets.
-- quirk: the fork's left tine is bent outward, as if someone used it to open a jar.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = A.new("ico-plate-cutlery")

local CER   = { "#5d4f6e", "#8f829c", "#c2b6bd", "#e3d8c9", "#f5ecd8", "#fffaec" }
local BLUE  = { "#2a3a72", "#33569a", "#3f78bf", "#5c9ad6", "#86bde8", "#b8dcf5" }
local STEEL = { "#33354f", "#4f5373", "#767b98", "#9ea4bd", "#c6cbdc", "#eceff6" }
local WOOD  = { "#3f2324", "#5f3328", "#844a32", "#a8653e", "#c88552", "#e2a96c" }
local BRASS = { "#8f4a1f", "#d98322", "#ffe38a" }
local SPEC = "#fffdf4"

-- plate -------------------------------------------------------------------------------------------------------
local PX, PY, RX, RY = 32, 33, 14, 13
c:groundShadow(PX + 2, PY + 3, RX, RY)
local plate = c:ellipse(PX, PY, RX, RY)
local function e(x, y) return sqrt(((x + .5 - PX - .5) / (RX + .5))^2 + ((y + .5 - PY - .5) / (RY + .5))^2) end
local function ph(x, y)
  local q = e(x, y)
  if q < 0.52 then return 0 end
  if q < 0.7 then return (q - 0.52) / 0.18 * 2.2 end
  if q < 0.9 then local t = (q - 0.8) / 0.1 return 2.2 + 0.8 * (1 - t * t) end
  return 2.2 - (q - 0.9) / 0.1 * 1.6
end
local pn = {}
plate:each(function(x, y)
  local gx = (ph(x + 1, y) - ph(x - 1, y)) / 2
  local gy = (ph(x, y + 1) - ph(x, y - 1)) / 2
  pn[K(x, y)] = { A.norm(-gx, -gy, 1) }
end)
local pv = A.lightV(pn, 0.12, 0.3)
local pbias = {}
-- AO at the foot of the wall (where the well meets the slope)
plate:each(function(x, y) local q = e(x, y) if q > 0.5 and q < 0.58 then pbias[K(x, y)] = -1 end end)
local ptok = { r = { name = "plate" } }
local pidx = A.toneV(plate, pv, CER, { 0.2, 0.36, 0.52, 0.66, 0.82 }, pbias, ptok)
-- blue painted band on the rim (same light index, blue ramp)
plate:each(function(x, y) local q = e(x, y) if q > 0.83 and q < 0.9 then
  A.px(x, y, BLUE[max(2, min(5, pidx[K(x, y)] - 1))], ptok) end end)
-- glazed flower in the well
A.bmp({
  "..a..",
  ".aba.",
  "abcba",
  ".aba.",
  "..a..",
}, PX - 2, PY - 2, { a = BLUE[4], b = BLUE[3], c = "#f5b82e" }, ptok)
A.pts({ { PX - 4, PY - 4 }, { PX + 4, PY + 4 }, { PX + 4, PY - 4 }, { PX - 4, PY + 4 } }, BLUE[5], ptok)
-- glaze specular on the upper-left rim + bright lip
A.pts({ { 22, 24 }, { 23, 23 }, { 24, 22 }, { 25, 22 } }, CER[6], ptok)
A.pts({ { 23, 24 }, { 24, 23 } }, SPEC, ptok)
-- inner rim lip catching light lower-right (inside of the wall facing up-left)
plate:each(function(x, y) local q = e(x, y)
  if q > 0.6 and q < 0.68 and x - PX > 3 and y - PY > 3 then A.px(x, y, CER[6], ptok) end end)

-- fork (left) -------------------------------------------------------------------------------------------------
local fork = HP.mask()
fork:add(c:rect(8, 17, 15, 19))                    -- tine bridge
fork:add(c:rrect(9, 18, 14, 24, 2))                -- shoulder
fork:add(c:rect(10, 24, 13, 30))                   -- neck
fork:add(c:rrect(9, 30, 14, 56, 2))                -- handle (6 wide, rounded end)
fork:cut(c:rect(9, 30, 9, 33)):cut(c:rect(14, 30, 14, 33))  -- taper into handle
for _, tx in ipairs({ 11, 14 }) do fork:add(c:rect(tx, 8, tx + 1, 17)) end
-- quirk: left tine bent outward
fork:add(c:rect(8, 12, 9, 17)):add(c:rect(7, 10, 8, 11)):add(c:rect(6, 8, 7, 9))
fork:add(c:rect(8, 8, 8, 8)):cut(c:rect(8, 8, 8, 8))
local fidx, fn = A.pil(fork, 2, STEEL, { amb = 0.12, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 },
  bias = (function() local b = {} fork:each(function(x, y) if y >= 23 and y <= 25 then b[K(x, y)] = -1 end end) return b end)() })
-- bright edge down the lit side of the handle + spec glint
for yy = 34, 52 do A.px(10, yy, STEEL[6]) end
A.px(10, 40, SPEC) A.px(10, 41, SPEC)
-- handle tip hole (hanging eye)
A.pts({ { 11, 52 }, { 12, 52 }, { 11, 53 }, { 12, 53 } }, STEEL[2]) A.px(12, 53, STEEL[1])

-- knife (right) -----------------------------------------------------------------------------------------------
local blade = c:poly({ { 50, 13 }, { 52, 9 }, { 55, 8 }, { 56, 9 }, { 56, 33 }, { 50, 33 } })
local btok = { r = { name = "blade" } }
local bidx, bn = A.pil(blade, 2, STEEL, { amb = 0.12, wrap = 0.3, tok = btok })
-- cutting edge (left) bright, spine (right) darker groove, specular streak
for yy = 13, 32 do A.px(50, yy, STEEL[5], btok) end
for yy = 10, 32 do A.px(55, yy, STEEL[3], btok) end
for yy = 16, 27 do A.px(52, yy, STEEL[6], btok) end
A.px(52, 19, SPEC, btok) A.px(52, 20, SPEC, btok)
local bolster = c:rrect(49, 33, 57, 36, 1)
A.pil(bolster, 1, STEEL, { amb = 0.1, cuts = { 0.25, 0.4, 0.55, 0.7, 0.86 }, bias = (function()
  local b = {} bolster:each(function(x, y) if y == 33 then b[K(x, y)] = -1 end end) return b end)() })
local handle = c:rrect(50, 37, 55, 57, 3)
local hb = {}
A.ao(hb, handle, bolster, 1, -1)
local hidx = A.pil(handle, 3, WOOD, { amb = 0.1, wrap = 0.3, bias = hb, tok = { r = { name = "wood" } } })
-- walnut grain: wavy darker lines along the handle
handle:each(function(x, y)
  local g = (x - 50) + 0.6 * math.sin(y * 0.55)
  if (abs(g - 1.6) < 0.5 or abs(g - 4.3) < 0.45) and y > 38 and y < 56 then
    local h = A.at(x, y) for i, w in ipairs(WOOD) do if w:lower() == h then A.px(x, y, WOOD[max(1, i - 1)]) end end
  end end)
-- brass rivets
for _, ry in ipairs({ 42, 51 }) do
  A.px(53, ry, BRASS[2]) A.px(52, ry, BRASS[3]) A.px(53, ry + 1, BRASS[1]) A.px(52, ry + 1, BRASS[2])
end
A.done()
