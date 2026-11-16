-- mini-blight-mother (101x81 still, side view, faces right). Opus third pass (richness).
-- Same creature as opus2: a fat violet moth-mother on six dark legs, tall near forewing, far forewing with
-- a round blight eyespot, a pale lilac hind wing, a segmented abdomen, a pale fur ruff, a round head with
-- one locked eye, feathered antennae and the curled orange proboscis with a blight drip.
-- Richness: 6-tone hue-shifted ramps; wings darken toward the root and carry staggered wing-scale rows and
-- veins with a lit side; furry body with tufted edges, a lit rim on top and a sickly green bounce line
-- underneath (the blight glow); ruff and head get fur strokes; legs get a lit knee and dark claw.
-- Quirk (look closer): the proboscis drip, and a clutch of three pale-green blight eggs stuck to the
-- underside of the abdomen tip.
local NAME = "mini-blight-mother"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local Q = dofile(DIR .. "/_rich.lua").init(HP)
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local WING6 = Q.ramp("#8a6fd0")
local FAR6 = Q.ramp("#7058bc")
local HIND6 = { "#7462b0", "#9482cc", "#b2a0e4", "#d2bff4", "#e6dafa", "#f6eefa" }
local BODY6 = Q.ramp("#5a459e")
local RUFF6 = { "#7a68b4", "#a08cd6", "#c4b2ec", "#e2d2fa", "#efe6fb", "#faf4f2" }
local LEG6 = Q.ramp("#3e3172")
local BLIGHT = R("#e4f6a0", "#a8d860", "#6aa848", "#3e6e40")
local PROB = R("#ffd4a0", "#f0a060", "#c06a44", "#7e4036")
local GREENBOUNCE = "#5f8a78"

local c = HP.canvas{ w = 101, h = 81, scale = 1, name = NAME }
c:groundShadow(48, 76, 38, 3)
for y = 0, c.h - 1 do for x = 0, c.w - 1 do local i = y * c.w + x
  if c.pix[i] and not c.pix[i - 1] and not c.pix[i + 1] then c.pix[i], c.own[i] = nil, nil end end end

local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  local R0 = math.max(rx, ry)
  for y = math.floor(cy - R0 - 1), math.ceil(cy + R0 + 1) do for x = math.floor(cx - R0 - 1), math.ceil(cx + R0 + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end

-- wing: darker at the root, lighter to the tip, cel shade band lower-right, lit rim upper-left,
-- staggered scale rows, veins (dark line, lit pixel on the upper-left side), dotted border on the outer edge
local function wing(m, r6, ax, ay, maxd, tips, borderSide, o)
  o = o or {}
  local tok = { r = { name = "wing" .. ax .. ay } }
  local inner = m:copy():shrink(1)
  local vm = HP.mask()
  for _, t in ipairs(tips) do vm:add(c:line({ { ax, ay }, t }, 1)) end
  vm:clip(inner)
  m:each(function(x, y)
    local d = math.sqrt((x - ax) ^ 2 + (y - ay) ^ 2) / maxd
    local t = 2 + math.floor(math.min(0.99, d) * 3.2)
    if not m:has(x + 2, y + 2) or not m:has(x + 1, y + 2) then t = t - 1 end
    if not m:has(x + 1, y + 1) then t = t - 1 end
    if not m:has(x - 1, y) or not m:has(x, y - 1) then t = t + 1 end
    -- wing scales: short staggered dashes one tone up
    local row = y % 3
    if row == 0 and (x + (y // 3 % 2) * 3) % 6 < 2 and t >= 3 and t <= 5 then t = t + 1 end
    t = t + (o.shift or 0)
    if o.sepFrom and (o.sepFrom:has(x - 1, y) or o.sepFrom:has(x, y + 1) or o.sepFrom:has(x + 1, y) or o.sepFrom:has(x, y - 1))
      and not (m:has(x - 1, y) and m:has(x + 1, y) and m:has(x, y - 1) and m:has(x, y + 1)) then t = 1 end
    c:put(x, y, r6[math.max(1, math.min(6, t))], tok)
  end)
  vm:each(function(x, y) c:put(x, y, r6[2], tok) if m:has(x - 1, y - 1) and not vm:has(x - 1, y - 1) then c:put(x - 1, y - 1, r6[5], tok) end end)
  if borderSide then
    local b = m:copy():cut(m:copy():shrink(2))
    b:each(function(x, y) if borderSide(x, y) then
      c:put(x, y, (x * 3 + y * 5) % 7 == 0 and r6[6] or r6[1], tok) end end)
  end
  return tok
end

-- legs: thick lit femur, thinner shin, a dark claw; knee glint
local function leg(pts)
  local f = c:line({ pts[1], pts[2] }, 3)
  Q.body(c, f, LEG6, { R = 1.5, amb = 0.25 })
  local s = c:line({ pts[2], pts[3] }, 2)
  s:each(function(x, y) c:put(x, y, s:has(x - 1, y) and LEG6[3] or LEG6[5], { r = { name = "shin" } }) end)
  c:fillMask(c:line({ pts[3], pts[4] }, 1), LEG6[2])
  c:put(pts[4][1], pts[4][2], LEG6[1])
  c:put(pts[2][1], pts[2][2], LEG6[6]) c:put(pts[2][1] - 1, pts[2][2], LEG6[5])
end
leg({ { 44, 56 }, { 38, 64 }, { 36, 74 }, { 33, 75 } })
leg({ { 58, 55 }, { 66, 63 }, { 68, 74 }, { 71, 75 } })

-- pale hind wing, low at the back
local hw = oval(19, 46, 16, 10, 18)
wing(hw, HIND6, 36, 50, 30, { { 5, 38 }, { 6, 48 }, { 14, 56 } }, function(x, y) return x < 22 end)
-- far forewing, upper left, with the blight eyespot
local fw = oval(24, 20, 20, 12, 28)
wing(fw, FAR6, 42, 34, 38, { { 6, 8 }, { 14, 4 }, { 4, 18 } }, function(x, y) return x < 26 and y < 26 end, { shift = -1 })
c:fillMask(c:ellipse(16, 15, 5, 5), P.cream)
c:fillMask(c:ellipse(16, 15, 5, 5):cut(c:ellipse(16, 15, 5, 5):shift(-1, -1)), "#d8c8a0") -- ring shade lower-right
c:fillMask(c:ellipse(16, 15, 3.5, 3.5), WING6[4])
c:fillMask(c:ellipse(16, 15, 3.5, 3.5):cut(c:ellipse(16, 15, 3.5, 3.5):shift(1, 1)), WING6[2])
c:fillMask(c:ellipse(16, 15, 2, 2), BLIGHT.shade)
c:put(15, 14, BLIGHT.hi) c:put(16, 15, BLIGHT.base) c:put(17, 16, BLIGHT.deep)

-- abdomen: fat, furry, segmented, curving down at the tail
local ab = c:ellipse(37, 48, 19, 12.5)
ab:add(c:ellipse(22, 53, 8, 7))
-- fur tufts on the top and back edge
for _, q in ipairs{ { 26, 39 }, { 33, 35.5 }, { 41, 35.5 }, { 16, 49 }, { 15, 55 } } do ab:add(c:ellipse(q[1], q[2], 1.5, 1.5)) end
local abTok = { r = { name = "abdomen" } }
local abIdx = Q.body(c, ab, BODY6, { R = 7, amb = 0.12, tok = abTok, bounce = GREENBOUNCE,
  tex = function(x, y) local h = Q.hash(x, y, 5) if h < 0.07 then return -1 elseif h > 0.95 then return 1 end end })
-- curved segment seams: dark groove, lit trailing lip
for _, sx in ipairs{ 24, 31, 38, 45 } do
  local arc = HP.mask()
  for y = 34, 62 do arc:set(sx + math.floor(((y - 48) / 9) ^ 2), y) end
  arc:clip(ab:copy():shrink(1))
  local l = {} arc:each(function(x, y) l[#l + 1] = { x, y } end)
  for _, q in ipairs(l) do
    c:put(q[1], q[2], BODY6[1], abTok)
    if ab:has(q[1] - 1, q[2]) then c:put(q[1] - 1, q[2], q[2] < 47 and BODY6[6] or BODY6[4], abTok) end
  end
end
-- lit rim along the top of the abdomen
Q.side(ab, 0, -1):each(function(x, y) if x > 22 and x < 48 then c:put(x, y, BODY6[6], abTok) end end)
-- blight blotches (with a pale halo where the rot spreads)
for _, q in ipairs{ { 34, 52 }, { 41, 55 }, { 27, 47 } } do
  c:put(q[1] - 1, q[2], BODY6[3]) c:put(q[1] + 2, q[2] + 1, BODY6[3])
  c:put(q[1], q[2], BLIGHT.shade) c:put(q[1] + 1, q[2], BLIGHT.base) c:put(q[1], q[2] + 1, BLIGHT.deep) c:put(q[1] + 1, q[2] - 1, BLIGHT.hi)
end
-- quirk: three blight eggs glued under the abdomen tip
for _, q in ipairs{ { 19, 61 }, { 22, 62 }, { 25, 61 } } do
  c:put(q[1], q[2], BLIGHT.base) c:put(q[1] + 1, q[2], BLIGHT.shade) c:put(q[1], q[2] + 1, BLIGHT.shade) c:put(q[1] + 1, q[2] + 1, BLIGHT.deep)
  c:put(q[1], q[2], BLIGHT.hi)
end

-- near forewing, tall, rising from the thorax
local nw = oval(47, 21, 13, 19, -12)
local farSep = fw:copy():cut(nw)
wing(nw, WING6, 54, 40, 34, { { 38, 8 }, { 46, 2 }, { 56, 4 }, { 36, 22 } }, function(x, y) return y < 18 end, { shift = 1 })
-- inner line where the near wing overlaps the far wing
Q.side(nw, -1, 0):add(Q.side(nw, 0, 1)):each(function(x, y) if farSep:has(x - 1, y) or farSep:has(x, y + 1) then c:put(x, y, WING6[1]) end end)
-- contact shade where the near wing sits on the abdomen
Q.side(nw, 0, 1):each(function(x, y) if ab:has(x, y + 1) then c:put(x, y + 1, BODY6[1]) end end)

-- fur ruff (thorax) between abdomen and head: tufted, with fur strokes
local ruff = c:ellipse(57, 46, 7, 11)
for _, q in ipairs{ { 52, 36 }, { 51, 42 }, { 51, 48 }, { 52, 54 }, { 56, 57 } } do ruff:add(c:ellipse(q[1], q[2], 2.5, 2.5)) end
local rTok = { r = { name = "ruff" } }
Q.body(c, ruff, RUFF6, { R = 4, amb = 0.2, tok = rTok, ao = { { ab, 1, -1 } } })
for _, q in ipairs{ { 54, 41 }, { 53, 47 }, { 54, 52 }, { 58, 38 }, { 57, 44 }, { 59, 50 }, { 56, 55 } } do
  c:put(q[1], q[2], RUFF6[2], rTok) c:put(q[1] + 1, q[2] + 1, RUFF6[3], rTok) c:put(q[1] - 1, q[2] - 1, RUFF6[6], rTok)
end
-- inner line where the ruff meets the abdomen
Q.side(ruff, -1, 0):each(function(x, y) if ab:has(x - 1, y) and not ruff:has(x - 1, y) then c:put(x - 1, y, BODY6[1]) end end)

-- near legs (in front)
leg({ { 50, 57 }, { 44, 66 }, { 43, 74 }, { 40, 75 } })
leg({ { 58, 57 }, { 58, 66 }, { 55, 74 }, { 53, 75 } })
leg({ { 64, 54 }, { 74, 62 }, { 78, 73 }, { 81, 74 } })

-- head: furry ball, lit rim upper-left, green bounce below
local hd = c:ellipse(72, 44, 12, 11)
for _, a in ipairs{ 200, 225, 250, 275, 300, 325 } do local r = math.rad(a) hd:add(c:ellipse(72 + math.cos(r) * 11.5, 44 + math.sin(r) * 10.5, 2, 2)) end
local hTok = { r = { name = "head" } }
Q.body(c, hd, BODY6, { sphere = { 70, 42, 13 }, amb = 0.12, tok = hTok, bounce = GREENBOUNCE,
  ao = { { ruff, 1, -1 } },
  tex = function(x, y) local h = Q.hash(x, y, 9) if h < 0.06 then return -1 end end })
-- separation from the ruff
Q.side(hd, -1, 0):each(function(x, y) if ruff:has(x - 1, y) then c:put(x, y, BODY6[1], hTok) end end)
-- fur strokes on the crown
for _, q in ipairs{ { 66, 36 }, { 70, 34 }, { 75, 35 }, { 64, 41 } } do c:put(q[1], q[2], BODY6[6], hTok) c:put(q[1] + 1, q[2] + 1, BODY6[4], hTok) end
for _, q in ipairs{ { 64, 50 }, { 67, 53 }, { 75, 54 }, { 80, 51 } } do c:put(q[1], q[2], BODY6[1], hTok) end
c:eyeLocked(72, 39)
c:put(70, 48, P.petal.base) c:put(71, 48, P.petal.base) -- cheek
c:fillMask(c:line({ { 76, 49 }, { 78, 50 }, { 80, 49 } }, 1), BODY6[1]) -- mouth
-- curled proboscis (lit top, shaded under) + one blight drip (quirk)
local pr = c:line({ { 82, 47 }, { 87, 47 }, { 89, 50 }, { 88, 53 }, { 85, 53 }, { 85, 51 } }, 1)
c:part(pr, PROB, { band = 1, nopop = true, noshade = true })
c:put(83, 47, PROB.hi) c:put(84, 47, PROB.hi) c:put(89, 51, PROB.shade) c:put(88, 53, PROB.shade) c:put(86, 53, PROB.deep)
c:put(89, 55, BLIGHT.hi) c:put(89, 56, BLIGHT.base) c:put(89, 57, BLIGHT.shade)
-- feathered antennae
local function frond(x0, y0, x1, y1, w)
  c:fillMask(c:line({ { x0, y0 }, { x1, y1 } }, 1), BODY6[1])
  local sx, sy = x0 + (x1 - x0) * 0.35, y0 + (y1 - y0) * 0.35
  local dx, dy = x1 - sx, y1 - sy
  local len = math.sqrt(dx * dx + dy * dy)
  local m = oval((sx + x1) / 2, (sy + y1) / 2, len / 2, w, math.deg(math.atan(dy, dx)))
  local tok = { r = { name = "frond" .. x0 } }
  local ux, uy = dx / len, dy / len
  m:each(function(x, y)
    local px, py = x + .5 - sx, y + .5 - sy
    local u, v = px * ux + py * uy, -px * uy + py * ux
    local col
    if math.abs(v) < 0.75 then col = BODY6[1]
    elseif math.floor(u) % 2 == 0 then col = v < 0 and WING6[3] or WING6[2]
    else col = v < 0 and WING6[6] or WING6[4] end
    c:put(x, y, col, tok)
  end)
end
frond(69, 34, 74, 8, 4)
frond(77, 35, 93, 17, 4)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
