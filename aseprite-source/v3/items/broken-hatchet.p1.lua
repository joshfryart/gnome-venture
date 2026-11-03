-- broken-hatchet pass 1 (form): side-on bearded hatchet, handle tilted, head axis-aligned with a curved bit.
-- Handle snapped under the head: head+stub knocked up-right, zigzag break, one chip flying.
-- quirk: gold thread wrapped round the grip, its loose end unravelling in a curl.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local out = app.params.out or "./"
local P = HP.P
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "broken-hatchet.p1" }
local function handleQuad(x0, y0, x1, y1, hw)          -- straight handle segment, half-width hw
  local dx, dy = x1 - x0, y1 - y0
  local L = math.sqrt(dx*dx + dy*dy)
  local ox, oy = -dy / L * hw, dx / L * hw
  return c:poly{ {x0+ox, y0+oy}, {x1+ox, y1+oy}, {x1-ox, y1-oy}, {x0-ox, y0-oy} }
end
-- lower handle: from the break (zigzag top) down to a flared butt knob
local low = handleQuad(37, 33, 22, 54, 2.8)
low:add(c:ellipse(20.5, 53.5, 3.5, 2.5))
low:cut(c:poly{ {30,27},{42,27},{42,35},{40,33},{38,36},{36,33},{34,35},{30,32} })   -- zigzag top edge
c:part(low, "wood", { band = 2 })
-- upper piece (head + stub), knocked up-right by (2,-2)
local SX, SY = 2, -2
local stub = handleQuad(46, 12, 36, 33, 2.8)
stub:cut(c:poly{ {30,31},{33,34},{35,31},{37,34},{39,31},{41,34},{41,42},{30,42} })  -- matching zigzag bottom
c:part(stub:shift(SX, SY), "wood", { band = 1 })
local head = c:poly{ {29,13},{22,11},{16,8},{13,10},{11,15},{11,21},{13,26},{17,30},{21,26},{29,21} }
head:add(c:rect(28, 13, 39, 20))                       -- cheek
head:add(c:rrect(38, 10, 48, 22, 2))                   -- eye + short poll
c:part(head:shift(SX, SY), "stone", { band = 2 })
-- sharpened bevel along the curved bit
local bevel = head:copy():clip(c:poly{ {8,4},{17,4},{15,10},{14,16},{14,21},{16,26},{19,32},{8,32} })
c:fillMask(bevel:shift(SX, SY), P.stone.hi)
-- chip flying off right of the break
c:part(c:poly{ {47,35},{51,33},{52,37},{49,38} }, "wood", { band = 1, nopop = true })
-- quirk: gold thread, 2 wraps on the grip + unravelling loose end that curls
for _, y in ipairs{ 44, 47 } do
  local x = 37 - (y - 33) * 15 / 21
  c:fillMask(c:line({ {x - 3, y + 1}, {x + 2, y - 1} }, 1), P.gold.base)
end
c:fillMask(c:line({ {31, 46}, {35, 47}, {38, 49}, {40, 52}, {43, 53}, {45, 51}, {44, 49}, {42, 50} }, 1), P.gold.base)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ png = out .. "broken-hatchet.p1.png" }
