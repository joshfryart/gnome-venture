-- broken-gathering-pouch (aB11_3, Opus single pass). Teal canvas drawstring pouch sitting upright: round bulb,
-- pinched neck, pleated ruffle on top. Bulb: pillow light per pixel, fold creases radiating from the neck (dark crease
-- with a lit ridge beside it), diagonal weave lines in the lit cloth. Twisted cord round the neck, knotted, two ends
-- with wooden beads. Ambient shade under the cord and where the ruffle meets the neck.
-- broken: a jagged tear in the lower right with frayed threads; a hazelnut is falling out of it (the chip).
-- quirk: a sprig of clover tucked under the drawstring.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_3.lua")
local HP, X, K, G = A.HP, A.X, A.K, A.G
local T, Cd = A.TEAL, A.CORD
local floor, abs, max, min, sqrt, sin, atan = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.atan
local c = A.new("broken-gathering-pouch")
local CX = 32

c:groundShadow(CX, 54, 12, 2)

-- ruffle (pleated top above the neck)
local ruf = HP.mask()
for y = 14, 25 do
  local hw = 4.5 + (25 - y) * 0.42
  for x = floor(CX - hw + .5), floor(CX + hw - .5) do
    if y >= 15 + floor(1.2 * sin((x - CX) * 1.15) + 0.5) then ruf:set(x, y) end
  end
end
local rn, rb = {}, {}
ruf:each(function(x, y) local k = K(x, y)
  local px = sin((x - CX) * 1.1) * 0.75 + (x - CX) * 0.05
  local l = sqrt(px * px + 0.04 + 1)
  rn[k] = { px / l, -0.2 / l, 1 / l }
  if y >= 23 then rb[k] = -1 end
end)
local ri = A.tone(c, ruf, rn, T, { bias = rb, tok = { r = { name = "ruffle" } } })
-- open mouth: dark inner lip along the top edge
ruf:each(function(x, y) if not ruf:has(x, y - 1) and ruf:has(x, y + 1) and abs(x - CX) < 6 then c:put(x, y + 1, T[1]) end end)

-- bulb + neck
local bulb = HP.mask()
for y = 25, 53 do for x = 14, 50 do
  local dx, dy = (x - CX + 0.5) / 15.5, (y - 41.5) / 12.5
  local inb = dx * dx + dy * dy <= 1 and y <= 53
  local neck = y <= 31 and abs(x - CX + 0.5) <= 4.2 + max(0, y - 27) * 0.9
  if inb or neck then bulb:set(x, y) end
end end
local bn = X.pillow(bulb, 6)
local bb = {}
-- AO below the ruffle and in the neck pinch
bulb:each(function(x, y) local k = K(x, y) if y <= 28 then bb[k] = -2 elseif y <= 30 then bb[k] = -1 end end)
-- fold creases radiating from the neck
local folds = { -0.62, -0.28, 0.12, 0.5 }
bulb:each(function(x, y) local k = K(x, y)
  local dx, dy = x - CX + 0.5, y - 28
  local r = sqrt(dx * dx + dy * dy)
  if r > 3 and r < 15 and dy > 0 then
    local a = atan(dx, dy)
    for i, f in ipairs(folds) do
      local cur = f + 0.02 * r
      local d = (a - cur) * r
      local reach = (i % 2 == 0) and 13 or 10
      if r < reach then
        if abs(d) < 0.55 then bb[k] = (bb[k] or 0) - 1
        elseif d < -0.55 and d > -1.6 then bb[k] = (bb[k] or 0) + 1 end
      end
    end
  end
end)
local bi = A.tone(c, bulb, bn, T, { bias = bb, tok = { r = { name = "bulb" } } })
-- diagonal weave lines in the lit cloth only
bulb:each(function(x, y) local k = K(x, y) if bi[k] and bi[k] >= 5 and (x + y) % 4 == 0 then c:put(x, y, T[bi[k] - 1]) end end)
-- cool bounce on the lower right rim
bulb:edge():each(function(x, y) if x > CX + 6 and y > 40 and y < 51 then c:put(x, y, "#3f6f9a") end end)
-- specular on the shoulder
c:put(23, 35, T[6]) c:put(24, 35, T[6]) c:put(23, 36, A.SPEC)

-- broken: jagged tear lower right with frayed threads
local tear = c:poly{ { 37, 44 }, { 40, 42 }, { 42, 45 }, { 45, 44 }, { 44, 48 }, { 41, 50 }, { 38, 48 } }
c:fillMask(tear, "#15242f")
tear:each(function(x, y)
  if not tear:has(x, y - 1) then c:put(x, y, T[6]) end      -- lit torn lip on the upper edge
  if not tear:has(x - 1, y) and tear:has(x + 1, y) and y > 45 then c:put(x, y, "#223b4a") end end)
for _, p in ipairs{ { 39, 46, 4 }, { 43, 46, 5 }, { 40, 49, 4 }, { 44, 49, 3 } } do c:put(p[1], p[2], T[p[3]]) end
-- a loose thread hanging out of the tear
c:put(42, 51, T[4]) c:put(43, 52, T[3])
-- the chip: hazelnut falling out
c:paint({ ".ccc.", "cCccd", "hHnnd", "nHnnd", ".nnd.", "..d.." }, 47, 49,
  { c = "#a8784a", C = "#d8b07a", d = "#5e3a2a", h = "#e8b982", H = "#fff1cf", n = "#b97a4a" })

-- drawstring: twisted cord round the neck (AO row above/below), knot and two beaded ends
local cord = A.tube(A.lineP(26.5, 27, 38, 26.5), 1.0)
cord:each(function(x, y) if bulb:has(x, y + 1) and not cord:has(x, y + 1) then A.nudge(c, x, y + 1, T, -1) end end)
local cm, cn = A.tube(A.lineP(26.5, 27, 38, 26.5), 1.0)
local ci = A.tone(c, cm, cn, Cd, { cuts = { 0.3, 0.55, 0.8 } })
cm:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, Cd[1]) end end)
local function hang(p, bx, by)
  local m, n, Tt = A.tube(p, 0.6)
  m:each(function(x, y) c:put(x, y, (Tt[K(x, y)] * 10 + x) % 3 < 1 and Cd[2] or Cd[3]) end)
  local bm = c:ellipse(bx, by, 1.5, 1.5)
  local bnn = X.sphere(bx - 0.3, by - 0.3, 1.5, bm)
  A.tone(c, bm, bnn, A.WOOD, { cuts = { 0.2, 0.35, 0.5, 0.7, 0.85 } })
  c:put(floor(bx - 0.5), floor(by - 0.5), A.WOOD[6])
end
hang({ { 37, 27 }, { 41, 26 }, { 44, 29 }, { 45.5, 33 } }, 45.5, 35)
hang({ { 37, 28 }, { 39, 30 }, { 40, 33 }, { 40, 36 } }, 40, 38)
-- knot
c:paint({ ".ab.", "abbc", ".bc." }, 35, 25, { a = Cd[4], b = Cd[3], c = Cd[1] })

-- quirk: clover sprig tucked under the cord (left), leaflets fanned
c:put(26, 26, A.LEAF[3]) c:put(25, 25, A.LEAF[4]) c:put(24, 24, A.LEAF[4]) c:put(23, 23, A.LEAF[4])
c:paint({ ".ll..", "lLlmm", ".lsMm", ".dd..", ".dD.." }, 19, 18,
  { l = A.LEAF[5], L = A.LEAF[6], m = A.LEAF[4], M = A.LEAF[5], s = A.LEAF[2], d = A.LEAF[3], D = A.LEAF[4] })
A.save(c)
