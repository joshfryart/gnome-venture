-- Crag Quill (pl-cnd-1), perch sprite 36x36. Opus second pass (c09/opus2), hand-built at this size.
-- Bronze feather leaning right on its quill: pale rachis, barbs, shine; cream afterfeather wisps at the base.
-- quirk: a flint spearhead lashed onto its tip with twine, and a fierce V brow.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cnd-1-perch", 36)
local BRZ = { "#3e2420", "#6a3a26", "#94582c", "#bd7a34", "#dca050", "#f2cc86" }
local FLINT = { "#2f2a44", "#444663", "#5f6680", "#8a8fa8", "#b8bccc", "#dfe0ea" }
local QUILL = { "#8a6a52", "#c9a882", "#ecd8b4", "#faf0d8" }
c:groundShadow(13, 31, 6, 1.2)
local Qx, Qy, Tx, Ty = 10, 31, 24, 9
local L = math.sqrt((Tx - Qx) ^ 2 + (Ty - Qy) ^ 2)
local dx, dy = (Tx - Qx) / L, (Ty - Qy) / L
local px, py = -dy, dx
local vane, vn, VT, VS = HP.mask(), {}, {}, {}
for y = 0, 35 do for x = 0, 35 do
  local rx, ry = x + .5 - Qx, y + .5 - Qy
  local t, s = (rx * dx + ry * dy) / L, rx * px + ry * py
  if t > .2 and t <= 1 then
    local u = (t - .2) / .8
    local w = (s < 0 and 5 or 3.5) * ((u < .6) and math.sin(math.min(1, u / .25) * math.pi / 2) or (1 - (u - .6) / .4) ^ .8)
    if math.abs(s) <= w + .3 then
      vane:set(x, y) local sn = math.max(-.9, math.min(.9, s / (w + .8)))
      vn[K(x, y)] = { px * sn, py * sn, math.sqrt(1 - sn * sn) } VT[K(x, y)], VS[K(x, y)] = t, s
    end
  end
end end
local I, T = O.shadeN(c, vane, vn, BRZ, { amb = .22, wrap = .4, rim = true, bounce = "#7a5a9a", bmax = 2, sep = BRZ[1] })
local function face(x, y) return x >= 11 and x <= 21 and y >= 17 and y <= 23 end
O.tex(c, I, T, BRZ, function(x, y, i)
  local t, s = VT[K(x, y)], VS[K(x, y)]
  if face(x, y) then return 0 end
  if math.abs(s) < .6 then return 5 end
  if s > .6 and s < 1.5 then return -2 end
  if math.abs(s) > 1.5 and math.floor(t * L - math.abs(s)) % 3 == 0 then return -1 end
end)
local q, qn = O.tube({ { Qx, Qy }, { Qx + dx * 2, Qy + dy * 2 }, { Qx + dx * 4, Qy + dy * 4 }, { Qx + dx * 6, Qy + dy * 6 } }, function() return .8 end)
O.shadeN(c, q, qn, QUILL, { amb = .35, wrap = .5, cuts = { .3, .55, .8 }, sep = QUILL[1] })
O.dots(c, { { 9, 25 }, { 8, 26 }, { 15, 27 }, { 16, 28 } }, QUILL[3])
local function at(t, s) return Qx + dx * L * t + px * s, Qy + dy * L * t + py * s end
local a1, b1 = at(.92, -2) local a2, b2 = at(.92, 2) local m1, n1 = at(1.05, -3) local m2, n2 = at(1.05, 3) local tx, ty = at(1.27, 0)
local head = c:poly({ { a1, b1 }, { m1, n1 }, { tx, ty }, { m2, n2 }, { a2, b2 } })
O.shade(c, head, FLINT, { R = 1, amb = .3, wrap = .45, rim = true, sep = FLINT[1] })
for _, tt in ipairs({ .9, .96 }) do local ax, ay = at(tt, -3) local bx, by = at(tt + .03, 3) O.flat(c, c:line({ { ax, ay }, { bx, by } }, 1), "#a07a52", "twine") end
c:eyeSmall(13, 19) c:eyeSmall(18, 18)
O.dots(c, { { 12, 17 }, { 13, 17 }, { 14, 18 } }, P.ink) O.dots(c, { { 21, 16 }, { 20, 16 }, { 19, 17 } }, P.ink)
O.dots(c, { { 15, 23 }, { 16, 22 }, { 17, 22 } }, P.ink)
O.done(c, "pl-cnd-1-perch")
