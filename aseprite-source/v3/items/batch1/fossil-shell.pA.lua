-- fossil-shell (pass A). Ammonite seen flat-on: log-spiral whorls (x2 per turn), each whorl a lit tube,
-- sinuous ribs, dark AO groove at every suture, open aperture step on the right. Cool slate stone.
-- quirk: a tiny coral hermit crab has moved into the aperture (eyes on stalks + one claw).
local NAME = "fossil-shell.pA"
local LIB = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local out = app.params.out or "./"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local sqrt, atan, log, floor, pi, sin, cos = math.sqrt, math.atan, math.log, math.floor, math.pi, math.sin, math.cos

local STONE = { "#2c2b4a", "#424767", "#5c6886", "#7f90a6", "#a9bcc4", "#d9e4dc" }
local CRAB  = { "#7d2c4a", "#c8433f", "#f07a52", "#ffb07a" }
local INK = "#2b1c26"

local CX, CY, R, G = 30.5, 35.5, 26.0, 2.05
local TA = -0.45                        -- aperture angle (image coords, y down)
local LG = log(G)
local shell = HP.mask()
local W, F, PHI = {}, {}, {}
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = x - CX, y - CY
  local r = sqrt(dx * dx + dy * dy)
  local th = atan(dy, dx)
  local phi = (TA - th) % (2 * pi)       -- angle travelled back from the aperture
  local rout = R * G ^ (-phi / (2 * pi))
  if r <= rout and r > 0.01 then
    shell:set(x, y)
    local w = log(r / R) / LG + phi / (2 * pi)
    W[K(x, y)], PHI[K(x, y)] = w, phi
    F[K(x, y)] = w - floor(w)
  end
end end
shell:set(30, 35) shell:set(31, 35)

local n, bias = {}, {}
shell:each(function(x, y)
  local k = K(x, y)
  local dx, dy = x - CX, y - CY
  local r = math.max(sqrt(dx * dx + dy * dy), 0.5)
  local ux, uy = dx / r, dy / r
  local f = F[k] or 0.5
  local s = (2 * f - 1) * 0.85
  local nx, ny, nz = ux * s, uy * s, sqrt(1 - s * s)
  -- ribs: count per turn, sinuous (curve forward on the outer flank), fade into the suture groove
  local turn = floor(W[k] or 0)
  local along = (PHI[k] or 0) / (2 * pi) - turn
  local ph = along * 20 + 0.35 * (f - 0.5) ^ 2 * 4
  local rib = sin(2 * pi * ph) * ((f > 0.18 and r > 6) and 0.55 or 0.1)
  nx, ny = nx + (-uy) * rib, ny + ux * rib
  local l = sqrt(nx * nx + ny * ny + nz * nz)
  n[k] = { nx / l, ny / l, nz / l }
  if f < 0.12 then bias[k] = -2 elseif f < 0.2 then bias[k] = -1 end
end)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
X.tone(c, shell, v, STONE, { bias = bias, cuts = { 0.22, 0.4, 0.56, 0.72, 0.87 }, tok = { r = { name = "stone" } } })
-- protoconch: tiny dark knot
c:put(30, 35, STONE[1]) c:put(31, 35, STONE[2])

-- aperture: inner lip shadow + pale rim
shell:each(function(x, y)
  local p = PHI[K(x, y)]
  if p and p < 0.16 and (F[K(x, y)] or 0) > 0.15 then c:put(x, y, STONE[1]) end
  if p and p >= 0.16 and p < 0.26 and (F[K(x, y)] or 0) > 0.15 then c:put(x, y, STONE[6]) end
end)

-- quirk: hermit crab in the aperture step (eyes + claw)
c:paint({
  "...a..a..",
  "...b..b..",
  "..eccccd.",
  ".ecddddcd",
  "ecc.dc.cdd",
  ".c..c..c..",
}, 43, 28, { a = INK, b = CRAB[1], c = CRAB[2], d = CRAB[1], e = CRAB[3] })
c:put(46, 28, "#fff4d6") c:put(49, 28, "#fff4d6")
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png" }
