-- pandanus (final, aC31_5, Opus single pass; replaces the Sonnet draft). A slim, egg-shaped pandanus fruit (screw-pine
-- syncarp) hanging from a short fibrous stalk under three long arching strap leaves. The fruit is built from domed
-- hexagonal keys laid out on the sphere (they shrink and crowd toward the edges), each with a dark woody stigma tip;
-- keys ripen from green at the crown through gold to orange-red at the base. Material: per-pixel light (sphere +
-- per-key bump), dark grooves between keys, one specular, cool reflected light lower-right, AO under the stalk.
-- Leaves: keeled midrib, 6-tone fold light, spiny serrated margins.
-- quirk: one ripe key has dropped out - a pale fibrous socket on the fruit, the loose key lying below it.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan, asin = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan, math.asin
local norm = G.norm
local c = G.new2("pandanus")

local LEAF  = { "#173a33", "#22553c", "#2f7343", "#46904a", "#69ad55", "#9acb6c" }
local STALK = { "#4a3a26", "#6e5734", "#93784a", "#b49c64", "#d2bf88" }
local GRN   = { "#2a4a2c", "#3f6a34", "#5e8c3c", "#82aa48", "#a8c65c", "#d0e284" }
local GOLD  = { "#6a3a1c", "#9a5a1e", "#c8862a", "#e6aa36", "#f6cc58", "#fff0a0" }
local ORG   = { "#5e1e22", "#922e24", "#c44a24", "#e46c2a", "#f6943e", "#ffc070" }
local CORE  = { "#8a6a46", "#b8945e", "#dcbc82", "#f0dcaa" }
local BOUNCE, SPEC = "#9a6a8c", "#fff3d6"

-- leaves first (fruit and stalk paint over their bases)
local TX, TY = 35, 16
local ltok = { r = { name = "leaf" } }
local function strap(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t) return w * (1 - t ^ 2.2) + 0.25 end, { fold = 0.6 })
  local id = G.toneN(c, m, n, LEAF, { tok = ltok, amb = 0.12, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.18 and T[k] < 0.9 then c:put(x, y, LEAF[max(1, id[k] - 2)], ltok) end   -- keel
  end)
  -- spines: tiny pale teeth on the outer edge, every ~3 px, pointing toward the tip
  local e = m:edge()
  local cnt = 0
  e:each(function(x, y) local k = K(x, y)
    if S[k] > 0.6 and T[k] > 0.12 and T[k] < 0.85 and X.hash(x, y, 3) > 0.6 then
      local dx, dy = 0, 0
      if not m:has(x + 1, y) then dx = 1 elseif not m:has(x, y + 1) then dy = 1 elseif not m:has(x - 1, y) then dx = -1 elseif not m:has(x, y - 1) then dy = -1 end
      if (dx ~= 0 or dy ~= 0) and not c:get(x + dx, y + dy) then c:put(x + dx, y + dy, LEAF[5], ltok) end
    end
  end)
  return m
end
strap(TX, TY, 20, 3, 8, 20, 2.2)
strap(TX, TY, 44, 2, 56, 15, 2.1)
strap(TX, TY, 48, 8, 53, 30, 1.9)

-- stalk: short fibrous peduncle from the leaf tuft to the fruit crown
local stm, stn, ST, SS = G.tube({ { TX, TY }, { 34, 20 }, { 32, 22 }, { 31, 26 } }, function(t) return 1.6 + t * 0.5 end)
local stid = G.toneN(c, stm, stn, STALK, { tok = { r = { name = "stalk" } }, cuts = { 0.22, 0.42, 0.6, 0.78 } })
stm:each(function(x, y) if (y % 2 == 0) and abs(SS[K(x, y)]) < 0.3 then c:put(x, y, STALK[2], { r = { name = "stalk" } }) end end)

-- fruit: sphere-ish ellipsoid, hex keys on (lon, lat)
local FX, FY, RX, RY = 31, 40, 11, 13.5
local fm = c:ellipse(FX, FY, RX, RY)
local DL = 0.42
local function cellAt(lon, lat)
  local best, b2, bid, bc = 1e9, 1e9
  local r0 = floor(lat / DL + 0.5)
  for r = r0 - 1, r0 + 1 do
    local clat = r * DL
    local sp = 0.46 / max(0.35, cos(clat))
    local off = (r % 2 == 0) and 0 or sp / 2
    local j0 = floor((lon - off) / sp + 0.5)
    for j = j0 - 1, j0 + 1 do
      local clon = j * sp + off
      local d = (lat - clat) ^ 2 + ((lon - clon) * cos(lat)) ^ 2
      if d < best then b2 = best best, bid, bc = d, r * 100 + j, { clon, clat } elseif d < b2 then b2 = d end
    end
  end
  return bid, sqrt(b2) - sqrt(best), bc
end
local fn, groove, cid, ccen, dcen = {}, {}, {}, {}, {}
fm:each(function(x, y)
  local u, v = (x - FX) / (RX + 0.5), (y - FY) / (RY + 0.5)
  local z = sqrt(max(0.02, 1 - u * u - v * v))
  local lon, lat = atan(u, z), asin(max(-1, min(1, v)))
  local id, gap, cc = cellAt(lon, lat)
  local k = K(x, y)
  cid[k], ccen[k] = id, cc
  -- per-key dome bump
  local du, dv = (lon - cc[1]) * cos(lat), lat - cc[2]
  dcen[k] = sqrt(du * du + dv * dv)
  fn[k] = { norm(u + du * 3.2, v + dv * 3.2, z) }
  if gap < 0.06 then groove[k] = true end
end)
-- socket of the missing key (quirk): one cell at lower right
local sock
do local u, v = 0.42, 0.42
  local z = sqrt(1 - u * u - v * v)
  sock = cellAt(atan(u, z), asin(v)) end
local fb = {}
X.ao(fb, fm, stm, 2, -1)
local ftok = { r = { name = "fruit" } }
local v = X.light(fn, { amb = 0.08, wrap = 0.3 })
local fid = {}
fm:each(function(x, y) local k = K(x, y)
  local lat = ccen[k][2]
  local R = lat < -0.75 and GRN or (lat < -0.15 and GOLD or ORG)
  local val = v[k]
  local i = 1 for j, t in ipairs({ 0.18, 0.34, 0.5, 0.66, 0.82 }) do if val >= t then i = j + 1 end end
  i = i + (fb[k] or 0)
  if groove[k] then i = i - 3 end
  if dcen[k] < 0.07 and not groove[k] then i = 2 end   -- woody stigma tip
  i = max(1, min(6, i))
  fid[k] = i
  if cid[k] == sock then
    -- pale fibrous socket, deep at the back wall (upper-left), lit at the lower-right lip
    local q = (groove[k] or (x - FX) + (y - FY) < 10.5) and 1 or (((x - FX) + (y - FY)) % 2 == 0 and 2 or 3)
    if dcen[k] > 0.1 and (ccen[k][1] - 0) > 0 and (x + y) % 3 == 0 then q = 4 end
    c:put(x, y, CORE[q], ftok)
  else
    c:put(x, y, R[i], ftok)
  end
end)
-- cool reflected light on the lower-right rim (not in grooves)
local rim = X.rim(fn)
fm:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.6 and not groove[k] and cid[k] ~= sock and (x - FX) + (y - FY) > 8 then c:put(x, y, BOUNCE, ftok) end end)
-- specular on an upper-left key + bloom specks
local sx, sy = G.specAt(fm, fn, 30)
c:put(sx, sy, SPEC, ftok) c:put(sx + 1, sy, GOLD[6], ftok)
-- crown: stalk cup where it meets the fruit (dark ring + stub)
for _, p in ipairs{ { 29, 27 }, { 30, 27 }, { 32, 27 }, { 33, 27 }, { 31, 28 } } do if fm:has(p[1], p[2]) then c:put(p[1], p[2], GRN[1], ftok) end end

-- the loose key lying below-right: wedge, pale fibrous base end left, woody orange cap right
c:groundShadow(48, 58, 5, 1)
local km, kn = G.drop(48, 55, 4.6, 3.0, pi + 0.25, 0.8)
local ktok = { r = { name = "key" } }
local kid = G.toneN(c, km, kn, ORG, { tok = ktok, amb = 0.12, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
km:each(function(x, y) if x < 46 then c:put(x, y, ((x + y) % 2 == 0) and CORE[3] or CORE[2], ktok) end end)
c:put(51, 55, ORG[1], ktok) c:put(50, 53, ORG[6], ktok)
for _, p in ipairs{ { 50, 54 }, { 52, 54 }, { 52, 56 }, { 50, 56 } } do if km:has(p[1], p[2]) then c:put(p[1], p[2], ORG[2], ktok) end end

G.save2(c, "pandanus")
