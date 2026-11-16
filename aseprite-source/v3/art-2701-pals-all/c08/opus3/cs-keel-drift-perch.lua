-- Keel Drift (cs-keel-drift), perch sprite 36x36. Opus richness pass (c08/opus3), hand-built at this size: old olive-brown domed
-- carapace with bold ink scute seams and lit plate edges, a 1 px gold rim, two cream barnacles, paddle flippers,
-- head turned to us with one 2x3 pill eye.
-- Richness kept bold: hue-shifted ramps, one growth ring in the central scute, a moss stain, pale flipper
-- leading edges, and the plastron as hinged plates with dark seams (the yard fix carried over).
-- quirk: the slow wink (closed lid arc on the other eye).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("cs-keel-drift-perch", 36)

local SHEL = { "#2a2020", "#463624", "#6a5628", "#927e36", "#b8a858", "#e0d494" }
local SKIN = { "#14303e", "#1e5252", "#307866", "#4ea27a", "#86c88e", "#c8ecb0" }
local SKNB = { "#14303e", "#1e5252", "#286a5e", "#38886a", "#4ea27a" }
local GOLD = "#f5b82e"

c:groundShadow(17, 33, 13, 1.5)
local function flip(p, w, ramp)
  local m, n = O.tube(p, function(t) return w * (.7 + math.sin(math.pi * t) * .5) * (1 - t * .45) end)
  O.shadeN(c, m, n, ramp, { amb = .28, wrap = .35, sep = SKIN[1], rim = (ramp == SKIN) })
end
flip({ { 22, 14 }, { 25, 10 }, { 28, 8 }, { 30, 6 } }, 1.6, SKNB)
flip({ { 8, 17 }, { 6, 15 }, { 5, 14 }, { 4, 14 } }, 1.1, SKNB)
O.flat(c, c:rect(7, 24, 25, 25), "#e2c482", "plastron")
O.dots(c, { { 10, 24 }, { 10, 25 }, { 15, 24 }, { 15, 25 }, { 20, 24 }, { 20, 25 } }, "#7a5a3a")
O.dots(c, { { 11, 24 }, { 16, 24 }, { 21, 24 } }, "#f8ecc0")
O.dots(c, { { 8, 25 }, { 13, 25 }, { 18, 25 }, { 23, 25 } }, "#b89058")
local shell = c:ellipse(15, 18, 11, 7.5) shell:cut(c:rect(0, 25, 35, 35))
O.shade(c, shell, SHEL, { sphere = { 12, 14, 12 }, amb = .3, wrap = .4, sep = SHEL[1], rim = true, bounce = "#2a6a8a", bmax = 2 })
-- seams: hexagon in the middle + ribs
local seamPx = {}
local function seg(x0, y0, x1, y1)
  local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0), 1)
  for t = 0, n do seamPx[#seamPx+1] = { math.floor(x0 + (x1 - x0) * t / n + .5), math.floor(y0 + (y1 - y0) * t / n + .5) } end
end
seg(11, 15, 13, 13) seg(13, 13, 17, 13) seg(17, 13, 19, 15) seg(19, 15, 19, 17) seg(19, 17, 17, 19) seg(17, 19, 13, 19) seg(13, 19, 11, 17) seg(11, 17, 11, 15)
seg(11, 16, 6, 16) seg(19, 16, 24, 16) seg(12, 19, 9, 23) seg(18, 19, 21, 23) seg(15, 13, 15, 11)
O.mark(c, seamPx, SHEL[1])
O.mark(c, { { 12, 15 }, { 13, 14 }, { 14, 14 }, { 7, 15 }, { 8, 15 }, { 20, 15 }, { 21, 15 } }, SHEL[5])
O.mark(c, { { 14, 16 }, { 15, 16 }, { 16, 16 }, { 17, 16 }, { 14, 17 }, { 17, 17 } }, SHEL[3]) -- growth ring
O.mark(c, { { 9, 13 }, { 10, 13 } }, "#5e8a40") -- moss
-- gold rim along the shell's lower edge
local l = {}
for x = 5, 25 do for y = 24, 18, -1 do if shell:has(x, y) then l[#l+1] = { x, y } break end end end
O.mark(c, l, GOLD)
O.dots(c, { { 8, 19 }, { 21, 18 } }, "#efe4c8") O.dots(c, { { 8, 20 }, { 21, 19 } }, "#6e5a4a")
flip({ { 21, 23 }, { 24, 26 }, { 26, 28 }, { 29, 29 } }, 1.8, SKIN)
flip({ { 7, 23 }, { 6, 25 }, { 4, 26 }, { 3, 26 } }, 1.2, SKIN)
local head = c:ellipse(28, 17, 5.5, 5) head:add(c:ellipse(29, 20, 4, 2.5))
O.shade(c, head, SKIN, { sphere = { 26, 14, 7 }, amb = .3, wrap = .4, sep = SKIN[1], rim = true })
c:eyeSmall(25, 15)
O.dots(c, { { 29, 17 }, { 30, 16 }, { 31, 16 }, { 32, 17 } }, P.ink)
O.dots(c, { { 25, 19 }, { 32, 19 } }, "#f5809f")
O.dots(c, { { 27, 20 }, { 28, 21 }, { 29, 21 }, { 30, 21 }, { 31, 20 } }, P.ink)
O.shift(c, -1, -2)
O.done(c, "cs-keel-drift-perch")
