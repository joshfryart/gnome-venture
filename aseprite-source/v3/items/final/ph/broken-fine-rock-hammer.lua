-- broken-fine-rock-hammer (aB11_1, Opus single pass). Geologist's hammer: forged steel head with a square striking
-- face on the left, a boss round the eye and a long slightly drooping pick on the right; slim steel shank with a
-- stacked-leather-washer grip (tan rings with navy spacers) and a steel butt cap. Material: pillow-bevelled steel,
-- lit striking face, specular streak on the pick, ring texture on the leather, AO where shank enters the head.
-- broken: a chunk has sheared off the face corner (pale crystalline fracture), a crack runs into the head, and the
-- steel chunk flies off. quirk: a small spiral ammonite fossil lies by the handle.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_1.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.start(debug.getinfo(1, "S").source)
local S, L = D.STEEL, D.LEATHER
local FRAC = { "#9ea4bc", "#d4d8e6" }

-- shank (steel) from the butt up into the head
local ax, ay, bx, by = 25, 57, 33, 17
local sm, sT, sS = D.cyl(c, ax, ay, bx, by, function(t) return 1.3 end, S)
-- stacked leather washers over the lower 60%
local gm, gT, gS = D.cyl(c, ax, ay, ax + (bx - ax) * 0.6, ay + (by - ay) * 0.6, function(t) return 2.2 + 0.25 * sin(pi * t) end, L)
local glen = sqrt((bx - ax) ^ 2 + (by - ay) ^ 2) * 0.6
gm:each(function(x, y) local k = K(x, y)
  local d = floor(gT[k] * glen)
  if d % 2 == 0 then
    local cur = c:get(x, y)
    for i = 1, 5 do if cur == L[i + 1] then c:px(x, y, L[i]) break end end
  end
  if d % 7 == 3 then c:px(x, y, gS[k] < -0.3 and D.NAVY[4] or (gS[k] > 0.4 and D.NAVY[1] or D.NAVY[3])) end
end)
-- steel butt cap
D.cyl(c, ax - 0.3, ay + 1.5, ax + 0.2, ay - 1, function() return 2.4 end, S)
c:px(ax - 2, ay, S[6])
-- AO: shank darker just under the grip top and under the head
sm:each(function(x, y) local k = K(x, y) if sT[k] > 0.9 then c:px(x, y, sS[k] < -0.2 and S[3] or S[1]) end end)

-- head in local frame (axis tilted to sit square on the shank)
local ang = math.atan(bx - ax, -(by - ay)) -- rotation from vertical
local ux, uy = cos(ang), sin(ang)
local ox, oy = 34, 15
local function cb(a) if a > 4 then return 0.011 * (a - 4) ^ 2 else return 0 end end
local function hh(a)
  if a < -13 then return 4.2 elseif a < -7 then return 4.2 - (a + 13) / 6 * 1.8
  elseif a < -4 then return 2.4 + (a + 7) / 3 * 0.9 elseif a <= 4 then return 3.3
  else return 3.3 * (1 - (a - 4) / 16) ^ 0.75 + 0.35 end
end
local function chunk(a, b) return a < -11 and (b - 0.8) > (a + 16.5) * 0.9 end
local function inHead(a, b) return a >= -16 and a <= 20 and abs(b - cb(a)) <= hh(a) end
local hm, HA, HB = D.shape(ox, oy, ang, -17, 21, -6, 6, function(a, b) return inHead(a, b) and not chunk(a, b) end)
local hn = X.pillow(hm, 2)
local bias = {}
hm:each(function(x, y) local k = K(x, y)
  local a, b = HA[k], HB[k]
  if abs(a) < 4.3 and b > 2.2 then bias[k] = -1 end          -- under the boss
  if a > -4.5 and a < -3.2 then bias[k] = (bias[k] or 0) - 1 end -- neck groove
end)
D.toneN(c, hm, hn, S, { bias = bias, amb = 0.12, wrap = 0.3, cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 } })
D.paintMask(c, hm, function(x, y) local k = K(x, y)
  local a, b = HA[k], HB[k]
  if a < -15 then return b < 0 and S[6] or S[5] end                       -- striking face (lit end)
  if chunk(a - 1.1, b) then return (floor(a + b) % 2 == 0) and FRAC[2] or FRAC[1] end -- fracture face
  if a > 7 and a < 15 and abs(b - cb(a) + hh(a) * 0.45) < 0.5 then return S[6] end -- pick specular streak
  if abs(a) < 0.6 and abs(b) < 1.5 then return S[2] end                  -- eye wedge
end)
-- crack from the chipped corner into the head
for _, p in ipairs{ { -12, 0 }, { -11, -1 }, { -10, -1 }, { -9, 0 }, { -8, -1 } } do
  local a, b = p[1], p[2]
  local x, y = floor(ox + a * ux - b * uy + 0.5), floor(oy + a * uy + b * ux + 0.5)
  if hm:has(x, y) then c:px(x, y, S[1]) end
end
-- flying steel chunk (the chip) below-left of the face
c:paint({ ".ab", "abc", "bcd" }, 12, 25, { a = FRAC[2], b = S[5], c = S[3], d = S[2] })

-- quirk: ammonite fossil lying by the handle
local fx, fy = 42, 50
local am = c:ellipse(fx, fy, 3, 3)
D.toneN(c, am, X.sphere(fx - 0.5, fy - 0.5, 3, am), D.STONE)
for _, p in ipairs{ { 0, 0 }, { 1, 0 }, { 1, 1 }, { 0, 1 }, { -1, 1 }, { -1, 0 }, { -1, -1 }, { 0, -2 }, { 1, -2 }, { 2, -1 }, { 2, 0 }, { 2, 1 } } do
  c:px(fx + p[1], fy + p[2], (p[2] < 0 or p[1] < 0) and D.STONE[2] or D.STONE[1])
end
c:px(fx - 2, fy - 2, D.STONE[6])

D.fin(c)
