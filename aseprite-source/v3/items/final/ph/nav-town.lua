-- nav-town (C3, Opus single pass): a tall, narrow timber-framed house (steep red tile roof) beside a low clapboard
-- cottage (violet slate roof, stone chimney with a smoke puff) on a grassy strip. Material: 6-tone plaster with
-- speckle, oak beams + braces with a lit top edge, staggered roof tiles (row grooves + butt joints), clapboard grooves
-- with lit lips, warm lit windows with mullions and a glint, door grain, eave shadow and contact shadow at the ground.
-- quirk: the weathervane on the tall house is a tiny red gnome hat.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_0.lua")
local HP, X, K, tok = A.HP, A.X, A.K, A.tok
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new("nav-town")
local RED   = { "#5e1a34", "#8e2638", "#b9363a", "#e0523c", "#f77e56", "#ffb08a" }
local VIO   = { "#262048", "#3a3078", "#4f4298", "#6a5ab8", "#8f7ed6", "#bcaef0" }
local PLAS  = { "#8a6a52", "#b8946a", "#dcbc8c", "#efd6a6", "#fbe8c0", "#fff6dc" }
local SAGE  = { "#2e4a50", "#46685e", "#628a72", "#82aa88", "#a8cca0", "#d6ecc0" }
local MOSS  = { "#1f4a40", "#2f7046", "#4a9a4e", "#6cb854", "#98d468", "#c4e886" }
local GLOW  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffd25a", "#ffe38a", "#fff4d6" }
local W, ST = A.WOOD, A.STONE

-- ground strip
local gm = c:rrect(7, 53, 57, 57, 2)
A.pil(c, gm, MOSS, 2, { tok = tok("ground") })
for _, x in ipairs{ 9, 14, 29, 33, 55 } do c:put(x, 53, MOSS[6], tok("ground")) c:put(x, 52, MOSS[5], tok("tuft")) end

-- chimney (behind the roof)
local chm = c:rect(47, 26, 50, 35)
A.vcyl(c, chm, ST, 47, 50, { tok = tok("chim") })
for y = 28, 34, 3 do for x = 47, 50 do c:put(x, y, ST[2], tok("chim")) end end
c:put(48, 30, ST[2], tok("chim")) c:put(49, 33, ST[2], tok("chim"))
local cap = c:rect(46, 25, 51, 26)
c:fillMask(cap, ST[3]) for x = 46, 50 do c:put(x, 25, ST[5]) end c:put(46, 25, ST[6])
-- smoke puffs
A.sph(c, 52, 20, 2.2, { "#8a8aa0", "#a8a8bc", "#c6c4d6", "#dcdae6", "#eceaf2", "#fff4d6" }, nil, { tok = tok("smoke1") })
A.sph(c, 55, 16, 1.4, { "#8a8aa0", "#a8a8bc", "#c6c4d6", "#dcdae6", "#eceaf2", "#fff4d6" }, nil, { tok = tok("smoke2") })

-- cottage walls (clapboard)
local cw = c:rect(31, 40, 53, 53)
local cb = {}
cw:each(function(x, y) if y <= 43 then cb[K(x, y)] = y <= 42 and -2 or -1 end if x >= 51 then cb[K(x, y)] = (cb[K(x, y)] or 0) - 1 end end)
local cidx = A.pil(c, cw, SAGE, 2, { bias = cb, tok = tok("cwall") })
cw:each(function(x, y)
  local i = cidx[K(x, y)]
  if (y - 41) % 3 == 0 and y < 53 then c:put(x, y, SAGE[max(1, i - 2)], tok("cwall"))
  elseif (y - 41) % 3 == 1 and y < 53 and i >= 3 then c:put(x, y, SAGE[min(6, i + 1)], tok("cwall")) end
end)
-- tall house walls (plaster)
local hw = c:rect(11, 32, 25, 53)
local hb = {}
hw:each(function(x, y) if y <= 35 then hb[K(x, y)] = y <= 34 and -2 or -1 end if x >= 24 then hb[K(x, y)] = (hb[K(x, y)] or 0) - 1 end end)
-- ambient where the houses face each other is not needed (air gap); cottage roof shades the gap side
local hidx = A.pil(c, hw, PLAS, 2, { bias = hb, tok = tok("hwall") })
hw:each(function(x, y) if X.hash(x, y, 3) > 0.9 and (hidx[K(x, y)] or 1) >= 3 then c:put(x, y, PLAS[hidx[K(x, y)] - 1], tok("hwall")) end end)
-- timber frame
local function beam(x0, y0, x1, y1)
  A.ln(c, x0, y0, x1, y1, W[3]) A.ln(c, x0, y0 + 1, x1, y1 + 1, W[2])
end
beam(11, 43, 25, 43)
A.ln(c, 11, 44, 25, 44, W[2])
for x = 11, 25 do c:put(x, 43, (x % 5 == 0) and W[2] or W[4]) end
A.ln(c, 12, 36, 15, 42, W[3]) A.ln(c, 13, 36, 16, 42, W[2])
A.ln(c, 24, 36, 21, 42, W[3]) A.ln(c, 23, 36, 20, 42, W[2])
for y = 36, 52 do c:put(11, y, W[4]) c:put(25, y, W[2]) end
-- windows
local function window(x0, y0, x1, y1, cross)
  c:fillMask(c:rect(x0 - 1, y0 - 1, x1 + 1, y1 + 1), W[2])
  for x = x0 - 1, x1 + 1 do c:put(x, y1 + 1, W[4]) end
  c:fillMask(c:rect(x0, y0, x1, y1), GLOW[4])
  for x = x0, x1 do c:put(x, y1, GLOW[3]) end
  for y = y0, y1 do c:put(x1, y, GLOW[3]) end
  c:put(x0, y0, GLOW[6]) c:put(x0 + 1, y0, GLOW[5]) c:put(x0, y0 + 1, GLOW[5])
  local mx, my = floor((x0 + x1) / 2 + .5), floor((y0 + y1) / 2 + .5)
  A.ln(c, mx, y0, mx, y1, W[3])
  if cross then A.ln(c, x0, my, x1, my, W[3]) end
end
window(16, 36, 20, 40, true)
window(20, 47, 23, 50, true)
window(44, 44, 49, 47, true)
-- flower box under cottage window
c:fillMask(c:rect(43, 49, 50, 50), W[3]) for x = 43, 50 do c:put(x, 49, W[5]) end c:put(50, 50, W[2])
for _, p in ipairs{ { 44, 48, "#f5809f" }, { 46, 48, "#ffc4d8" }, { 48, 48, "#f5809f" }, { 45, 48, MOSS[4] }, { 47, 48, MOSS[5] }, { 49, 48, MOSS[4] } } do c:put(p[1], p[2], p[3]) end
-- doors
local DOOR = { "#3a2420", "#51302b", "#6e4030", "#8a5638", "#a8704a", "#c88a58" }
local d1 = c:rrect(13, 46, 18, 53, 2)
A.pil(c, d1, DOOR, 1.5, { tok = tok("door1") })
for y = 47, 53 do c:put(15, y, DOOR[2]) end
c:put(17, 50, "#ffd25a") c:put(17, 51, "#c27a22")
local d2 = c:rrect(35, 44, 40, 53, 3)
A.pil(c, d2, DOOR, 1.5, { tok = tok("door2") })
for y = 45, 53 do c:put(37, y, DOOR[2]) if y % 3 == 0 then c:put(36, y, DOOR[5]) end end
c:put(39, 49, "#ffd25a") c:put(39, 50, "#c27a22")
-- doorstep stones + contact shadow at the base
for x = 12, 26 do c:put(x, 54, MOSS[1], tok("ground")) end
for x = 32, 54 do c:put(x, 54, MOSS[1], tok("ground")) end
for x = 34, 41 do c:put(x, 55, ST[5]) c:put(x, 56, ST[3]) end c:put(34, 55, ST[6])
for x = 12, 19 do c:put(x, 55, ST[5]) c:put(x, 56, ST[3]) end c:put(12, 55, ST[6])

-- roofs: per-slope light, staggered tiles
local function roof(pts, ramp, apx, apy, name, row)
  local m = c:poly(pts)
  local bias = {}
  m:each(function(x, y) if x > apx then bias[K(x, y)] = -1 end end)
  local idx = A.pil(c, m, ramp, 2, { bias = bias, tok = tok(name) })
  m:each(function(x, y)
    local i = idx[K(x, y)] or 3
    local r = y - apy
    if r > 2 and r % row == row - 1 then c:put(x, y, ramp[max(1, i - 2)], tok(name))
    elseif r > 2 and ((x + (floor(r / row) % 2) * 2) % 4 == 0) then c:put(x, y, ramp[max(1, i - 1)], tok(name)) end
  end)
  -- ridge highlight on the lit slope edge
  return m, idx
end
local rr = roof({ { 8, 33 }, { 18, 11 }, { 28, 33 } }, RED, 18, 11, "roofR", 3)
local rv = roof({ { 28, 41 }, { 42, 25 }, { 56, 41 } }, VIO, 42, 25, "roofV", 3)
-- eave lines (deep under-edge)
for x = 9, 27 do if rr:has(x, 33) then c:put(x, 33, RED[1], tok("roofR")) end end
for x = 29, 55 do if rv:has(x, 41) then c:put(x, 41, VIO[1], tok("roofV")) end end
-- lit ridge pixels on left slopes
for y = 12, 30 do local x = floor(18 - (y - 11) * 10 / 22 + .5) if rr:has(x + 1, y) then c:put(x + 1, y, RED[6], tok("roofR")) end end
for y = 26, 38 do local x = floor(42 - (y - 25) * 14 / 16 + .5) if rv:has(x + 1, y) then c:put(x + 1, y, VIO[6], tok("roofV")) end end
-- red roof casts onto cottage roof where they meet
for y = 34, 41 do for x = 28, 30 do if rv:has(x, y) and not rr:has(x, y) then c:put(x, y, VIO[2], tok("roofV")) end end end
-- tiny dormer-ish attic vent on red roof
c:fillMask(c:rect(17, 22, 19, 25), RED[1]) c:put(17, 22, RED[3]) c:put(18, 26, RED[4]) c:put(17, 26, RED[4]) c:put(19, 26, RED[4])

-- quirk: weathervane pole + red gnome-hat vane
for y = 7, 10 do c:put(18, y, y == 7 and "#ffd25a" or A.BRASS[3]) end
A.paint(c, {
  "Ffa",
  "Fbbbd",
  "Fdd",
}, 19, 7, { F = "#fff4d6", f = "#e2ddd0", a = "#ff8a5c", b = "#e8493b", d = "#b52e3f" })
c:put(17, 9, A.BRASS[2])

A.fin()
