-- Crag Quill (pl-cnd-1), yard sprite 64x64. Opus second pass (c09/opus2), built on the c09/haiku concept.
-- Thornblade, common, Condor's Crag. "A bronze quill the condor dropped, and it thinks it is a spear."
-- A long bronze flight feather standing on its quill, leaning right like a held spear. Real feather build: a pale
-- rachis running the full length, a wide lit vane on the left (where the face is) and a narrow vane on the right,
-- barbs sweeping toward the tip, one split in the wide vane, a bright shine streak, wispy afterfeather at the base.
-- quirk: it has lashed a chipped flint spearhead onto its own tip with twine, and wears a fierce little frown.
-- closer look: cream afterfeather wisps curling off the base of the vane.
-- Fixes over haiku: symmetrical lozenge on a pole read as a lantern (now an asymmetric feather with barbs and a
-- spearhead), grey pole through the face (now the face sits on the wide vane beside the rachis), flat ramps.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cnd-1-yard", 64)

local BRZ = { "#3e2420", "#6a3a26", "#94582c", "#bd7a34", "#dca050", "#f2cc86" }
local FLINT = { "#2f2a44", "#444663", "#5f6680", "#8a8fa8", "#b8bccc", "#dfe0ea" }
local TWINE = { "#5e3a2e", "#a07a52", "#d4b07a" }
local QUILL = { "#8a6a52", "#c9a882", "#ecd8b4", "#faf0d8" }

c:groundShadow(23, 55, 11, 2)

-- axis Q (quill foot) -> T (vane tip)
local Qx, Qy, Tx, Ty = 17, 55, 44, 16
local L = math.sqrt((Tx - Qx) ^ 2 + (Ty - Qy) ^ 2)
local dx, dy = (Tx - Qx) / L, (Ty - Qy) / L
local px, py = -dy, dx                 -- perpendicular, points lower-right (shade side)
local function proj(x, y) local rx, ry = x + .5 - Qx, y + .5 - Qy return (rx * dx + ry * dy) / L, rx * px + ry * py end
local function wid(t, side)
  if t < .2 or t > 1 then return -1 end
  local u = (t - .2) / .8
  local shape = (u < .65) and math.sin(math.min(1, u / .25) * math.pi / 2) or (1 - (u - .65) / .35) ^ .8
  return (side < 0 and 8.5 or 6) * shape
end
local vane, vn, VT, VS = HP.mask(), {}, {}, {}
for y = 0, 63 do for x = 0, 63 do
  local t, s = proj(x, y)
  local w = wid(t, s)
  if w > 0 and math.abs(s) <= w + .3 then
    -- the split: a notch in the wide vane
    if not (s < -4 and t > .74 and t < .77) then
      vane:set(x, y)
      local sn = math.max(-.9, math.min(.9, s / (w + .8)))
      vn[K(x, y)] = { px * sn, py * sn, math.sqrt(1 - sn * sn) }
      VT[K(x, y)], VS[K(x, y)] = t, s
    end
  end
end end
local vI, vTk = O.shadeN(c, vane, vn, BRZ, { amb = .22, wrap = .4, rim = true, bounce = "#7a5a9a", bmax = 2, sep = BRZ[1] })
local function face(x, y) return x >= 23 and x <= 38 and y >= 30 and y <= 41 end
O.tex(c, vI, vTk, BRZ, function(x, y, i)
  local t, s = VT[K(x, y)], VS[K(x, y)]
  if not t then return 0 end
  if face(x, y) then return 0 end
  if math.abs(s) < .7 then return 5 end                              -- pale rachis (clamped to top tone)
  if s > .7 and s < 1.7 then return -2 end                            -- rachis shadow
  local ph = t * L - math.abs(s) * .9                            -- barbs sweep toward the tip
  if math.abs(s) > 2 and math.floor(ph) % 3 == 0 then return -1 end
  if s < -2 and s > -3.5 and t > .25 and t < .85 and math.floor(ph) % 3 ~= 0 then return 1 end    -- shine streak
end)

-- bare quill below the vane
local q, qn = O.tube({ { Qx, Qy }, { Qx + dx * 4, Qy + dy * 4 }, { Qx + dx * 8, Qy + dy * 8 }, { Qx + dx * 12, Qy + dy * 12 } }, function(t) return 1.2 end)
O.shadeN(c, q, qn, QUILL, { amb = .35, wrap = .5, cuts = { .3, .55, .8 }, sep = QUILL[1] })
-- afterfeather wisps at the base of the vane
for wi, d in ipairs({ { { 21, 49 }, { 18, 49 }, { 15, 48 }, { 13, 45 } }, { { 22, 50 }, { 24, 52 }, { 27, 52 }, { 29, 50 } } }) do
  local m, n = O.tube(d, function(t) return 1.3 * (1 - t) + .35 end)
  O.shadeN(c, m, n, QUILL, { amb = .35, wrap = .5, cuts = { .3, .55, .8 }, sep = QUILL[1] })
end

-- flint spearhead lashed on the tip
local function at(t, s) return Qx + dx * L * t + px * s, Qy + dy * L * t + py * s end
local bx1, by1 = at(.93, -3) local bx2, by2 = at(.93, 3)
local mx1, my1 = at(1.06, -4.5) local mx2, my2 = at(1.06, 4.5)
local tx, ty = at(1.23, 0)
local head = c:poly({ { bx1, by1 }, { mx1, my1 }, { tx, ty }, { mx2, my2 }, { bx2, by2 } })
local hI, hT = O.shade(c, head, FLINT, { R = 2, amb = .3, wrap = .45, rim = true, sep = FLINT[1] })
O.tex(c, hI, hT, FLINT, function(x, y, i) if H(x // 2, y // 2, 4) > .72 then return -1 end end) -- knapped facets
-- twine lashing across the join
for _, tt in ipairs({ .9, .94, .98 }) do
  local ax, ay = at(tt, -4) local bx, by = at(tt + .03, 4)
  local m = c:line({ { ax, ay }, { bx, by } }, 1)
  O.flat(c, m, TWINE[2], "twine")
  O.dot(c, math.floor(ax + .5), math.floor(ay + .5), TWINE[3])
end
local lx, ly = at(.9, 4.5)
O.dots(c, { { math.floor(lx + 1), math.floor(ly + 1) }, { math.floor(lx + 1), math.floor(ly + 2) }, { math.floor(lx + 2), math.floor(ly + 3) } }, TWINE[1]) -- loose tail

-- face across the vane (the rachis stops above and below it): fierce, brows in a V
c:eyeLocked(24, 33)
c:eyeLocked(32, 32)
O.dots(c, { { 24, 31 }, { 25, 31 }, { 26, 32 }, { 27, 32 } }, P.ink)
O.dots(c, { { 36, 30 }, { 35, 30 }, { 34, 31 }, { 33, 31 } }, P.ink)
c:cheek(23, 39) c:cheek(36, 38)
O.dots(c, { { 28, 40 }, { 29, 39 }, { 30, 39 }, { 31, 39 }, { 32, 39 } }, P.ink) -- scowl

O.done(c, "pl-cnd-1-yard")
