-- fossil-shell (pass B, final; pass A = fossil-shell.pA). Ammonite seen flat-on: log-spiral whorls (x2 per turn), each whorl a lit tube,
-- sinuous ribs, dark AO groove at every suture, open aperture step on the right. Cool slate stone.
-- Pass B: frilly calcite suture lines (gold) on the two outer whorls, polished glint on the upper-left crest,
-- cool reflected light on the lower-right rim, quieter inner whorls, deeper umbilicus, aperture re-cut as a dark
-- mouth with a pale lip, crab redrawn (carapace light, bigger claw, legs gripping the lip).
-- quirk: a tiny coral hermit crab has moved into the aperture (eyes on stalks + one claw).
local NAME = "fossil-shell"
local LIB = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local out = app.params.out or "./"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local sqrt, atan, log, floor, pi, sin, cos = math.sqrt, math.atan, math.log, math.floor, math.pi, math.sin, math.cos

local STONE = { "#2c2b4a", "#424767", "#5c6886", "#7f90a6", "#a9bcc4", "#d9e4dc" }
local CRAB  = { "#6e2038", "#c23b3d", "#ee6a4a", "#ffa77a" }
local SUT = { "#9a6a2c", "#d9a347", "#f6d27a" }
local SPEC, BOUNCE = "#f4fbf2", "#8fa6d6"
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
  local rib = sin(2 * pi * ph) * ((f > 0.18 and r > 6) and (r > 11 and 0.6 or 0.35) or 0.05)
  nx, ny = nx + (-uy) * rib, ny + ux * rib
  local l = sqrt(nx * nx + ny * ny + nz * nz)
  n[k] = { nx / l, ny / l, nz / l }
  if f < 0.12 then bias[k] = -2 elseif f < 0.2 then bias[k] = -1 end
end)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
X.tone(c, shell, v, STONE, { bias = bias, cuts = { 0.22, 0.4, 0.56, 0.72, 0.87 }, tok = { r = { name = "stone" } } })
-- protoconch: tiny dark knot
c:fillMask(c:ellipse(30.5, 35.5, 1, 1):clip(shell), STONE[1]) c:put(30, 35, STONE[2])

-- frilly suture lines across the two outer whorls (calcite, gold), every 1/9 turn, lit side brighter
shell:each(function(x, y)
  local k = K(x, y)
  local w, f, p = W[k], F[k], PHI[k]
  if w and w > -1 and f > 0.16 and f < 0.96 and p > 0.6 then
    local dx, dy = x - CX, y - CY
    local r = sqrt(dx * dx + dy * dy)
    local turn = floor(w)
    local along = p - 2 * pi * turn
    local step = 2 * pi / 6
    local ph = (along + 0.06 * sin(f * pi * 7)) % step
    if math.min(ph, step - ph) * r < 0.75 then
      c:put(x, y, v[k] > 0.62 and SUT[3] or v[k] > 0.35 and SUT[2] or SUT[1])
    end
  end
end)
-- polished glint on the upper-left crest + one sparkle pixel
for _, p in ipairs{ {16, 26}, {17, 24}, {18, 23} } do c:put(p[1], p[2], STONE[6]) end
c:put(17, 25, SPEC) c:put(16, 27, SPEC)
-- cool reflected light on the lower-right outer rim
shell:edge():each(function(x, y)
  local dx, dy = x - CX, y - CY
  local r = sqrt(dx * dx + dy * dy)
  if (dx + dy) / r > 0.9 and r > 10 then c:put(x, y, BOUNCE) end
end)

-- aperture: dark mouth (end of the body chamber) + pale lip just behind it
shell:each(function(x, y)
  local p, f = PHI[K(x, y)], F[K(x, y)] or 0
  if p and p < 0.2 and f > 0.12 then c:put(x, y, (f > 0.3 and f < 0.85) and STONE[2] or STONE[3]) end
  if p and p >= 0.2 and p < 0.3 and f > 0.12 then c:put(x, y, STONE[6]) end
end)

-- quirk: hermit crab peeking out of the mouth (eyes on stalks, carapace, one big claw, legs on the lip)
c:paint({
  ".ga.ga.....",
  "..d..d.....",
  "..d..d..ee.",
  ".dddcc.edcc",
  "dccccccdcc.",
  "cbcbcbc....",
  ".b.b.b.....",
}, 45, 23, { a = INK, b = CRAB[1], c = CRAB[2], d = CRAB[3], e = CRAB[4], g = "#fff4d6" })

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png" }
