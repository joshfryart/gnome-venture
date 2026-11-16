-- mini-blight-mother (101x81 still, side view, faces right). Opus second pass.
-- Kept from the game picture: a fat violet moth-mother on six dark legs, a big upper forewing, a pale
-- lilac hind wing low at the back, a ringed eyespot on the far forewing, a segmented abdomen, a round
-- head facing right with an orange curled proboscis. Fixed: the tangled black smear is now a clean
-- feathered antenna pair; the gear-shaped eyespot is a proper round eyespot (cream ring, violet iris,
-- sickly green pupil = the blight); a pale fur ruff splits head from body so the body plan reads
-- (head, thorax ruff, abdomen); legs are jointed with lit knees; wings have veins and a dotted border.
-- quirk: the curled orange proboscis, kept, with one drip of green blight nectar.
local NAME = "mini-blight-mother"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local WING = R("#b8a0ee", "#8a6fd0", "#6650b0", "#3e3078")
local FAR = R("#9a84dc", "#7058bc", "#54429a", "#35295f")
local HIND = R("#efe4ff", "#d2bff4", "#a894dc", "#7462b0")
local BODY = R("#8a74d2", "#5a459e", "#43347e", "#2c2256")
local RUFF = R("#fbf2ff", "#e2d2fa", "#b8a4e4", "#8270bc")
local LEG = R("#6a58a8", "#3e3172", "#2e2456", "#241c44")
local BLIGHT = R("#e4f6a0", "#a8d860", "#6aa848", "#3e6e40")
local PROB = R("#ffd4a0", "#f0a060", "#c06a44", "#7e4036")

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
local function veins(m, ax, ay, tips, col)
  local inner = m:copy():shrink(1)
  for _, t in ipairs(tips) do c:fillMask(c:line({ { ax, ay }, t }, 1):clip(inner), col) end
end
local function border(m, r, w, side)
  -- dark outer border band with pale dots, on the far side of the wing only
  local b = m:copy():cut(m:copy():shrink(w))
  local l = {}
  b:each(function(x, y) if side(x, y) then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], (q[1] * 3 + q[2] * 5) % 7 == 0 and r.hi or r.deep) end
end

-- far legs
local function leg(pts, r)
  c:part(c:line({ pts[1], pts[2] }, 3), r, { band = 1, nopop = true, inner = false })
  c:part(c:line({ pts[2], pts[3] }, 2), r, { band = 1, nopop = true, noshade = true, inner = false })
  c:fillMask(c:line({ pts[3], pts[4] }, 1), r.shade)
  c:put(pts[2][1], pts[2][2], r.hi)
end
leg({ { 44, 56 }, { 38, 64 }, { 36, 74 }, { 33, 75 } }, LEG)
leg({ { 58, 55 }, { 66, 63 }, { 68, 74 }, { 71, 75 } }, LEG)

-- pale hind wing, low at the back
local hw = oval(19, 46, 16, 10, 18)
c:part(hw, HIND, { band = 2, pop = { x = 9, y = 40 } })
veins(hw, 36, 50, { { 5, 38 }, { 6, 48 }, { 14, 56 } }, HIND.shade)
border(hw, HIND, 2, function(x, y) return x < 22 end)
-- far forewing, upper left, with the eyespot
local fw = oval(24, 20, 20, 12, 28)
c:part(fw, FAR, { band = 2, nopop = true })
veins(fw, 42, 34, { { 6, 8 }, { 14, 4 }, { 4, 18 } }, FAR.shade)
border(fw, FAR, 2, function(x, y) return x < 26 and y < 26 end)
c:fillMask(c:ellipse(16, 15, 5, 5), P.cream)
c:fillMask(c:ellipse(16, 15, 3.5, 3.5), WING.base)
c:fillMask(c:ellipse(16, 15, 2, 2), BLIGHT.shade)
c:put(15, 14, BLIGHT.hi) c:put(16, 15, BLIGHT.base)

-- abdomen: fat, segmented, curving down at the tail
local ab = c:ellipse(37, 48, 19, 12.5)
ab:add(c:ellipse(22, 53, 8, 7))
c:part(ab, BODY, { band = 3, pop = { x = 30, y = 38 } })
for _, sx in ipairs{ 24, 31, 38, 45 } do
  local arc = HP.mask()
  for y = 34, 62 do arc:set(sx + math.floor(((y - 48) / 9) ^ 2), y) end
  arc:clip(ab:copy():shrink(1))
  local l = {} arc:each(function(x, y) l[#l + 1] = { x, y } end)
  for _, q in ipairs(l) do c:put(q[1], q[2], BODY.deep) if ab:has(q[1] - 1, q[2]) and q[2] < 46 then c:put(q[1] - 1, q[2], BODY.hi) end end
end
-- blight blotches on the abdomen
for _, q in ipairs{ { 34, 52 }, { 41, 55 }, { 27, 47 } } do
  c:put(q[1], q[2], BLIGHT.shade) c:put(q[1] + 1, q[2], BLIGHT.base) c:put(q[1], q[2] + 1, BLIGHT.deep)
end

-- near forewing, tall, rising from the thorax
local nw = oval(47, 21, 13, 19, -12)
c:part(nw, WING, { band = 2, pop = { x = 40, y = 6 }, sep = true })
veins(nw, 54, 40, { { 38, 8 }, { 46, 2 }, { 56, 4 }, { 36, 22 } }, WING.shade)
border(nw, WING, 2, function(x, y) return y < 18 end)

-- fur ruff (thorax) between abdomen and head
local ruff = c:ellipse(57, 46, 7, 11)
for _, q in ipairs{ { 52, 36 }, { 51, 42 }, { 51, 48 }, { 52, 54 }, { 56, 57 } } do ruff:add(c:ellipse(q[1], q[2], 2.5, 2.5)) end
c:part(ruff, RUFF, { band = 2, pop = { x = 53, y = 37 } })
for _, q in ipairs{ { 54, 41 }, { 53, 47 }, { 54, 52 }, { 58, 38 } } do c:put(q[1], q[2], RUFF.shade) c:put(q[1] + 1, q[2] + 1, RUFF.shade) end

-- near legs (in front)
leg({ { 50, 57 }, { 44, 66 }, { 43, 74 }, { 40, 75 } }, LEG)
leg({ { 58, 57 }, { 58, 66 }, { 55, 74 }, { 53, 75 } }, LEG)
leg({ { 64, 54 }, { 74, 62 }, { 78, 73 }, { 81, 74 } }, LEG)

-- head
local hd = c:ellipse(72, 44, 12, 11)
for _, a in ipairs{ 200, 225, 250, 275, 300, 325 } do local r = math.rad(a) hd:add(c:ellipse(72 + math.cos(r) * 11.5, 44 + math.sin(r) * 10.5, 2, 2)) end
c:part(hd, BODY, { band = 3, pop = { x = 65, y = 36 } })
for _, q in ipairs{ { 64, 50 }, { 67, 53 }, { 75, 54 }, { 80, 51 } } do c:put(q[1], q[2], BODY.deep) end
c:eyeLocked(72, 39)
c:put(70, 48, P.petal.base) c:put(71, 48, P.petal.base) -- cheek
c:fillMask(c:line({ { 76, 49 }, { 78, 50 }, { 80, 49 } }, 1), BODY.deep) -- mouth
-- curled proboscis + one blight drip (quirk)
c:part(c:line({ { 82, 47 }, { 87, 47 }, { 89, 50 }, { 88, 53 }, { 85, 53 }, { 85, 51 } }, 1), PROB, { band = 1, nopop = true, noshade = true })
c:put(87, 47, PROB.hi)
c:put(89, 55, BLIGHT.base) c:put(89, 56, BLIGHT.shade)
-- feathered antennae (the clean replacement for the black smear)
local function frond(x0, y0, x1, y1, w)
  c:fillMask(c:line({ { x0, y0 }, { x1, y1 } }, 1), BODY.deep)
  local sx, sy = x0 + (x1 - x0) * 0.35, y0 + (y1 - y0) * 0.35
  local dx, dy = x1 - sx, y1 - sy
  local len = math.sqrt(dx * dx + dy * dy)
  local m = oval((sx + x1) / 2, (sy + y1) / 2, len / 2, w, math.deg(math.atan(dy, dx)))
  c:part(m, WING, { band = 1, nopop = true, inner = false })
  local ux, uy = dx / len, dy / len
  local l = {}
  m:each(function(x, y)
    local px, py = x + .5 - sx, y + .5 - sy
    local u, v = px * ux + py * uy, -px * uy + py * ux
    if math.abs(v) < 0.75 then l[#l + 1] = { x, y, BODY.deep }
    elseif math.floor(u) % 2 == 0 then l[#l + 1] = { x, y, WING.shade }
    elseif v < 0 then l[#l + 1] = { x, y, WING.hi } end
  end)
  for _, q in ipairs(l) do c:put(q[1], q[2], q[3]) end
end
frond(69, 34, 74, 8, 4)
frond(77, 35, 93, 17, 4)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
