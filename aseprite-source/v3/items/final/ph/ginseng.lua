-- ginseng (Opus single pass). A whole wild ginseng plant: an ivory man-shaped root (ringed wrinkles, forked legs,
-- two thin rootlet arms, hair-fine tips), a ringed rhizome neck, a slim stem with two palmate leaves of three serrate
-- leaflets each, and a tight cluster of glossy red berries on a peduncle. Tube/pillow normals, 6-tone ramps, AO where
-- legs and arms meet the body and where the stem meets the neck.
-- quirk: a forager's red thread is knotted round the neck, one end fluttering loose.
local NAME = "ginseng"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sin, pi = math.floor, math.abs, math.max, math.min, math.sin, math.pi
local c = G.new2(NAME)
local ROOT = { "#4e3530", "#7a5a44", "#a8845e", "#cdab7e", "#e6cc9c", "#f8ead0" }
local NECK = { "#3e2824", "#634232", "#8a6244", "#ad8558", "#c9a571", "#e2c58e" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM = { "#24544a", "#3f9150", "#7cc35a", "#b8dc92" }
local BERRY = { "#5a1830", "#8e2034", "#c42f36", "#e8493b", "#ff7a58", "#ffb48a" }
local RED = { "#6e2038", "#b52e3f", "#e8493b" }
local CUT6 = { 0.15, 0.3, 0.47, 0.64, 0.82 }
local rtok, ltok, stok = { r = { name = "root" } }, { r = { name = "leaf" } }, { r = { name = "stem" } }

-- root parts
local body, bn, BT, BS = G.tube({ { 32, 31 }, { 32.5, 36 }, { 31.5, 41 }, { 31.5, 45 } }, function(t) return 2.6 + 1.3 * sin(pi * min(1, t * 1.1)) end)
local legL, nL, TL = G.tube({ { 30.5, 43 }, { 29, 47.5 }, { 26.5, 51.5 }, { 24, 55 } }, function(t) return 2.0 * (1 - t) ^ 0.9 + 0.35 end)
local legR, nR, TR = G.tube({ { 33, 43 }, { 35, 47.5 }, { 37.5, 51.5 }, { 40.5, 55 } }, function(t) return 2.1 * (1 - t) ^ 0.9 + 0.35 end)
local armL, nAL = G.tube({ { 29.5, 36 }, { 27, 37.5 }, { 24.5, 39 }, { 21.5, 42.5 } }, function(t) return 1.1 * (1 - t) + 0.3 end)
local armR, nAR = G.tube({ { 34.5, 37.5 }, { 37, 38.5 }, { 39.5, 39 }, { 42.5, 41 } }, function(t) return 1.0 * (1 - t) + 0.3 end)
-- draw back-to-front: arms, legs, body (body over the joints)
local function shade(m, n, bias)
  return G.toneN(c, m, n, ROOT, { tok = rtok, bias = bias, cuts = CUT6, amb = 0.12, wrap = 0.3 })
end
local bA = {} X.ao(bA, armL, body, 1, -1) X.ao(bA, armR, body, 1, -1)
local aL = armL:copy():cut(body) local aR = armR:copy():cut(body)
shade(aL, nAL, bA) shade(aR, nAR, bA)
local bL = {} X.ao(bL, legL, body, 2, -1)
local lL = legL:copy():cut(body) local lR = legR:copy():cut(body):cut(legL)
local iL = shade(lL, nL, bL)
local bR = {} X.ao(bR, legR, body, 2, -1) X.ao(bR, legR, legL, 1, -1)
local iR = shade(lR, nR, bR)
-- wrinkle rings on the legs
lL:each(function(x, y) local k = K(x, y) local t = TL[k] if t and ((t > 0.2 and t < 0.25) or (t > 0.5 and t < 0.54)) then c:put(x, y, ROOT[max(1, (iL[k] or 3) - 2)], rtok) end end)
lR:each(function(x, y) local k = K(x, y) local t = TR[k] if t and ((t > 0.28 and t < 0.33) or (t > 0.6 and t < 0.64)) then c:put(x, y, ROOT[max(1, (iR[k] or 3) - 2)], rtok) end end)
-- hair-fine root tips
for _, p in ipairs{ { 23, 56 }, { 22, 57 }, { 41, 56 }, { 42, 57 }, { 20, 43 }, { 19, 44 }, { 43, 41 }, { 44, 41 } } do c:put(p[1], p[2], ROOT[2], rtok) end
-- body with ringed wrinkles (pale lip above each dark ring)
local ib = shade(body, bn, {})
body:each(function(x, y) local k = K(x, y) local t = BT[k] local i = ib[k] or 3
  for _, r in ipairs{ 0.2, 0.42, 0.62, 0.82 } do
    local d = (t - r) * 15 + BS[k] * 0.6
    if d >= 0 and d < 1 then c:put(x, y, ROOT[max(1, i - 2)], rtok) elseif d >= -1 and d < 0 and i < 6 then c:put(x, y, ROOT[min(6, i + 1)], rtok) end
  end
end)
-- crotch shadow and body specular
c:put(31, 46, ROOT[1], rtok) c:put(32, 46, ROOT[2], rtok)
c:put(30, 33, ROOT[6], rtok) c:put(30, 34, "#fff4d6", rtok)

-- rhizome neck: stacked bud scars
local nm, nn = G.lathe(32, 25, 31, function(y) return 1.9 + (y - 25) * 0.12 end)
nm:cut(body)
local inn = G.toneN(c, nm, nn, NECK, { tok = rtok, cuts = CUT6, amb = 0.12, wrap = 0.3 })
nm:each(function(x, y) if y % 2 == 0 then c:put(x, y, NECK[max(1, (inn[K(x, y)] or 3) - 2)], rtok) end end)

-- stem up to the leaf whorl
local sm, sn = G.tube({ { 32, 25 }, { 32, 22 }, { 32, 20 }, { 32, 18 } }, function() return 0.9 end)
G.toneN(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
-- petioles out to two palmate leaves
local function petiole(pts)
  for i = 0, 24 do local x, y = G.bez(pts, i / 24) c:put(floor(x + .5), floor(y + .5), i < 4 and STEM[2] or STEM[3], stok) end
end
petiole{ { 32, 19 }, { 28, 17 }, { 25, 18 }, { 22, 19 } }
petiole{ { 32, 19 }, { 36, 17 }, { 39, 18 }, { 42, 19 } }
local function palm(hx, hy, dir)
  local used = HP.mask()
  for _, q in ipairs{ { -0.75, 8.5, 1.9 }, { -0.05, 9.5, 2.2 }, { 0.75, 7.5, 1.8 } } do
    local a = q[1] local ux, uy = G.rot(dir, 0, -a * dir) -- fan around the outward direction
    local ex, ey = hx + ux * q[2], hy + uy * q[2] - 1.5
    local mx, my = hx + ux * q[2] * 0.5 - uy * 0.8 * dir, hy + uy * q[2] * 0.5 - 1
    local m = G.lance(c, hx, hy, mx, my, ex, ey, q[3], LEAF, ltok, { cut = used:copy(), veins = 2.6, cool = "#3a6c72", pow = 0.6 })
    -- serrate margin: nick every other edge pixel on the shade side
    m:edge():each(function(x, y) if (x + y) % 3 == 0 and X.hash(x, y, 2) > 0.5 then c:put(x, y, LEAF[2], ltok) end end)
    used:add(m)
  end
end
palm(21, 19, -1)
palm(43, 19, 1)

-- peduncle and berry cluster
for y = 11, 18 do c:put(32, y, y > 15 and STEM[2] or STEM[3], stok) end
c:put(31, 15, STEM[4], stok)
local bt = { r = { name = "berries" } }
local done = HP.mask()
for _, b in ipairs{ { 32, 7.5 }, { 29.5, 9 }, { 34.5, 9 }, { 31, 11 }, { 33.5, 11.5 } } do
  local m = G.ball(c, b[1], b[2], 1.6, BERRY, bt, { cut = done:copy() })
  done:add(m)
end
for _, b in ipairs{ { 32, 7.5 }, { 29.5, 9 }, { 34.5, 9 }, { 31, 11 }, { 33.5, 11.5 } } do c:put(floor(b[1] - 0.6), floor(b[2] - 0.6), "#fff4d6", bt) end

-- quirk: red forager's thread knotted round the neck, loose end fluttering right
local qt = { r = { name = "thread" } }
for x = 30, 34 do c:put(x, 28, x < 32 and RED[3] or RED[2], qt) end
c:put(34, 27, RED[3], qt) c:put(35, 27, RED[2], qt) c:put(36, 28, RED[2], qt) c:put(37, 29, RED[1], qt) c:put(38, 29, RED[2], qt)
c:put(35, 29, RED[2], qt) c:put(36, 30, RED[1], qt)

G.save2(c, NAME)
