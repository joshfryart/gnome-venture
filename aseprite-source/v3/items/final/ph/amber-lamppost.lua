-- amber-lamppost (final, Opus). A slim cast-iron street lamp: ball finial, bevelled pagoda cap with an overhanging
-- brim, a tapered lantern of three amber glass panes (front pane brightest, side panes falling off, bright glass rim
-- and a pale core round a small flame), drip pan, ladder-rest crossbar with ball ends, a 4 px round post with two
-- collar rings and a specular streak, flared foot on a stepped plinth, 2-tone ground shadow. The lantern's warm
-- light spills onto the iron right next to the glass (brim underside, pan, mullions); everything else stays cool.
-- quirk: a moth has settled on the glowing front pane, a dark backlit silhouette beside the flame.
local NAME = "amber-lamppost"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)
local IRON = { "#191723", "#262435", "#36354d", "#4b4b67", "#676887", "#9192b4" }
local SPEC = "#c4c8e4"
local WARM = { "#3c2a30", "#5e3c36", "#8a5a40", "#c08850" }      -- iron lit by the lantern
local AMB  = { "#8a3418", "#b44e1c", "#d87022", "#f29a30", "#ffc24c", "#ffe080", "#fff4c4" }
local MOTH = { "#3a2028", "#55303a" }
local itok = { r = { name = "iron" } }

local function iron(m, R, o)
  o = o or {}
  local n = X.pillow(m, R or 1.6)
  return A.shade(c, m, n, IRON, { bias = o.bias, tok = itok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.06, wrap = 0.2 })
end

c:groundShadow(32, 54, 12, 1.6)

-- plinth + flared foot
iron(c:rrect(24, 50, 40, 53, 1), 1.6)
iron(c:rrect(26, 48, 38, 49, 0), 1.2)
iron(c:poly{ { 28.5, 43 }, { 36.5, 43 }, { 38, 48 }, { 27, 48 } }, 1.6)

-- post (round, 4 px): cylinder normals, specular streak on the lit side
local pm, pn = X.cyl(32.5, 43, 32.5, 31, function() return 1.8 end)
local pb = {}
X.ao(pb, pm, c:rect(26, 43, 38, 44), 1, -1)
A.shade(c, pm, pn, IRON, { bias = pb, tok = itok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.06, wrap = 0.2 })
for y = 33, 41 do if y ~= 37 and y ~= 38 then c:put(31, y, SPEC, itok) end end
-- collar rings
iron(c:rrect(30, 37, 35, 38, 0), 1)
iron(c:rrect(30, 30, 35, 31, 0), 1)

-- ladder-rest crossbar with ball ends
iron(c:rect(25, 34, 40, 35), 1)
for _, bx in ipairs{ 24, 41 } do
  local bm = c:ellipse(bx, 34.5, 1.5, 1.5)
  A.shade(c, bm, X.sphere(bx - 0.3, 34.2, 1.5, bm), IRON, { tok = itok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.06 })
end
c:put(23, 33, SPEC, itok)

-- drip pan under the lantern
local pan = c:poly{ { 26.5, 27 }, { 38.5, 27 }, { 35.5, 29.6 }, { 29.5, 29.6 } }
local panIdx = iron(pan, 1.2)

-- lantern: tapered body (wider at the top), iron frame + three amber panes
local body = c:poly{ { 24.5, 15 }, { 40.5, 15 }, { 38.5, 26 }, { 26.5, 26 } }
local frame = body:copy():cut(body:shrink(1))
local glass = body:shrink(1)
for _, xm in ipairs{ 29, 36 } do glass:each(function(x, y) if x == xm then frame:set(x, y) end end) end
glass:cut(frame)
-- glass: emissive, brightest round the flame, side panes darker; rim bright, core pale
local FX, FY = 32.5, 21.5
local gtok = { r = { name = "glass" } }
glass:each(function(x, y)
  local d = sqrt(((x - FX) / 1.3)^2 + (y - FY)^2)
  local i = 6 - floor(d / 2.1)
  if x < 29 then i = i - 1 elseif x > 36 then i = i - 2 end
  -- bright rim along the upper-left edge of each pane
  local up, lf = frame:has(x, y - 1), frame:has(x - 1, y)
  if (up or lf) and x <= 36 then i = i + 1 end
  if frame:has(x + 1, y) or frame:has(x, y + 1) then i = i - 1 end
  c:put(x, y, AMB[max(1, min(7, i))], gtok)
end)
-- flame
c:paint({ ".a.", "aba", "aba", ".a." }, 31, 19, { a = AMB[6], b = AMB[7] })
c:put(32, 18, AMB[5])
-- frame: iron, warm where it borders the glass
local fidx = iron(frame, 1)
frame:each(function(x, y)
  local near = glass:has(x + 1, y) or glass:has(x - 1, y) or glass:has(x, y + 1) or glass:has(x, y - 1)
  if near then c:put(x, y, WARM[min(4, max(1, (fidx[K(x, y)] or 3) - 1))], itok) end
end)
-- warm spill on the pan top row
for x = 27, 38 do if pan:has(x, 27) then c:put(x, 27, (x < 34) and WARM[4] or WARM[3], itok) end end

-- cap: brim + pagoda roof + finial
local brim = c:rrect(22, 13, 42, 14, 0)
iron(brim, 1)
for x = 24, 40 do c:put(x, 14, (x < 33) and WARM[3] or WARM[2], itok) end   -- underside lit by the lantern
local roof = c:poly{ { 23.5, 13 }, { 41.5, 13 }, { 35.5, 8 }, { 29.5, 8 } }
local rb = {}
X.ao(rb, roof, brim, 1, -1)
iron(roof, 2, { bias = rb })
c:put(27, 11, SPEC, itok) c:put(28, 10, SPEC, itok)
iron(c:rect(31, 7, 34, 7), 1)
local fm = c:ellipse(32.5, 5, 1.5, 1.5)
A.shade(c, fm, X.sphere(32.2, 4.7, 1.5, fm), IRON, { tok = itok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.06 })
c:put(32, 4, SPEC, itok)

-- quirk: moth resting on the front pane
c:paint({ "a...a", ".a.a.", "bbabb", ".bbb.", "..b.." }, 33, 19, { a = MOTH[1], b = MOTH[2] })
A.save(c, NAME)
