-- goat-milk-porridge (final, Opus aB35 single pass). A deep cream-glazed bowl seen 3/4 from above: sphere-lit belly
-- with a curved cobalt band, glossy rim with a bright glaze glint, unglazed foot ring, inner back wall in shadow.
-- Lumpy oat porridge mound (normal noise + oat flecks), a honey pool with a specular, cinnamon dust, a wooden spoon
-- (grain lines, paler end) sunk into it. AO where porridge meets the bowl and around the spoon; ground shadow.
-- quirk: one lazy drip of porridge has crept over the rim and down the outside of the bowl.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_0.lua")
local HP, X, K, norm = A.HP, A.X, A.K, A.norm
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = A.new("goat-milk-porridge")
local GLAZE = { "#5c5272", "#8e86a0", "#c2bcc6", "#e4ded8", "#f6f1e6", "#fffcf2" }
local BLUE  = { "#1e2c5e", "#2a4a8a", "#3a6ab8", "#5a8ed6", "#8ab6ea", "#bcdcf8" }
local OAT   = { "#8a6448", "#b08c64", "#d2b486", "#e8d4a8", "#f6ebcc", "#fff8e8" }
local WOOD  = { "#51302b", "#7a4a32", "#a06a42", "#c48c58", "#e0b07a", "#f4d4a2" }
local HONEY = { "#8f4a1f", "#c06a1a", "#e8961e", "#f5b82e", "#ffd76a", "#fff1b0" }
local CX, RIMY, RX, RY = 30, 28, 18, 6

c:groundShadow(CX, 50, 11, 2)
-- foot ring
local foot = HP.rrect(CX - 7, 45, CX + 7, 49, 1)
local fn = {} foot:each(function(x, y) local dx = (x - CX) / 7.5 fn[K(x, y)] = { norm(dx, 0.2, sqrt(max(0.05, 1 - dx * dx))) } end)
A.shade(c, foot, fn, OAT, { tok = { r = { name = "foot" } }, cuts = { 0.25, 0.42, 0.6, 0.78, 0.95 } })
-- belly: lower half of a squashed sphere
local belly = HP.ellipse(CX, RIMY, RX, 18):clip(HP.rect(0, RIMY, 63, 63))
belly:cut(HP.rect(0, 47, 63, 63))
local bn = X.sphere(CX, RIMY + 2, RX + 1, belly)
local btok = { r = { name = "bowl" } }
local bb = {}
belly:each(function(x, y) if y >= 45 then bb[K(x, y)] = -1 end end)   -- AO above the foot
local bidx = A.shade(c, belly, bn, GLAZE, { tok = btok, bias = bb, amb = 0.1 })
-- curved cobalt band + a dotted line below it (same light index, other ramp)
local function bandY(x) return RIMY + 5 + 3.2 * sqrt(max(0, 1 - ((x - CX) / (RX + 0.5)) ^ 2)) end
belly:each(function(x, y) local k = K(x, y) local by = bandY(x)
  if y >= floor(by + 0.5) and y <= floor(by + 0.5) + 1 then c:put(x, y, BLUE[bidx[k] or 3], btok)
  elseif y == floor(by + 0.5) + 4 and x % 3 == 0 then c:put(x, y, BLUE[min(6, (bidx[k] or 3) + 1)], btok) end
end)
-- rim ring
local outer = HP.ellipse(CX, RIMY, RX, RY)
local inner = HP.ellipse(CX, RIMY, RX - 2, RY - 2)
local rim = outer:copy():cut(inner)
local rn = {}
for k, n in pairs(X.pillow(rim, 1.2)) do rn[k] = { norm(n[1], n[2] * 0.6 - 0.6, n[3]) } end
local ridx = A.shade(c, rim, rn, GLAZE, { tok = btok, amb = 0.25 })
-- inner back wall (shadowed glaze)
local por = HP.ellipse(CX, RIMY + 1, RX - 3, RY - 3):add(HP.ellipse(CX - 1, RIMY - 1, RX - 7, 4)):clip(inner:copy():add(HP.rect(0, 0, 63, RIMY)))
local back = inner:copy():cut(por)
back:each(function(x, y) c:put(x, y, (back:has(x, y - 1)) and GLAZE[2] or GLAZE[1], btok) end)
-- spoon (before porridge so the porridge covers its sunk end)
local sm, sn, ST, SS, sidx = A.stem(c, { { 36, 28 }, { 41, 21 }, { 47, 13 }, { 52, 7 } }, function(t)
  return t > 0.92 and 2.0 or 1.5 end, WOOD, { tok = { r = { name = "spoon" } } })
sm:each(function(x, y) local k = K(x, y)
  if abs(SS[k]) < 0.25 and ST[k] > 0.15 and ST[k] < 0.9 and (x + y) % 5 == 0 then c:put(x, y, WOOD[max(1, sidx[k] - 2)]) end
  if ST[k] > 0.96 then c:put(x, y, WOOD[min(6, sidx[k] + 1)]) end   -- pale end grain
end)
-- porridge: lumpy oats
local pn = X.pillow(por, 3)
local pnn, pb = {}, {}
for k, n in pairs(pn) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local hx, hy = X.hash(x, y, 3) - 0.5, X.hash(x, y, 7) - 0.5
  pnn[k] = { norm(n[1] * 0.7 + hx * 0.5, n[2] * 0.7 - 0.45 + hy * 0.4, n[3]) }
end
X.ao(pb, por, rim, 1, -1)
X.ao(pb, por, sm, 1, -1)
local ptok = { r = { name = "oat" } }
local pidx = A.shade(c, por, pnn, OAT, { tok = ptok, bias = pb, amb = 0.2 })
por:each(function(x, y) local h = X.hash(x, y, 11)
  if h < 0.07 then A.step(c, pidx, OAT, x, y, -2, ptok) elseif h > 0.94 then A.step(c, pidx, OAT, x, y, 1, ptok) end end)
-- honey pool + swirl
local hp = HP.ellipse(CX - 3, RIMY - 1, 3, 1.5)
local hn = X.pillow(hp, 1.5)
for k, n in pairs(hn) do hn[k] = { norm(n[1], n[2] - 0.5, n[3]) } end
A.shade(c, hp, hn, HONEY, { tok = ptok, amb = 0.3 })
c:put(CX - 5, RIMY - 2, HONEY[6]) c:put(CX - 4, RIMY - 2, "#fff4d6")
for _, p in ipairs{ { CX + 1, RIMY - 1 }, { CX + 2, RIMY }, { CX + 1, RIMY + 1 }, { CX - 1, RIMY + 1 } } do c:put(p[1], p[2], HONEY[3], ptok) end
-- cinnamon dust
for _, p in ipairs{ { CX - 8, RIMY }, { CX - 6, RIMY + 2 }, { CX + 5, RIMY - 2 }, { CX + 7, RIMY + 1 }, { CX - 2, RIMY + 3 } } do
  if por:has(p[1], p[2]) then c:put(p[1], p[2], "#864c33", ptok) end end
-- glaze glint on the belly + rim
c:put(CX - 12, RIMY + 5, "#fff4d6") c:put(CX - 12, RIMY + 6, "#fff4d6") c:put(CX - 11, RIMY + 4, GLAZE[6])
-- quirk: a porridge drip over the front rim, running down the belly
local dr = HP.rect(CX + 7, RIMY + 3, CX + 8, RIMY + 9):add(HP.ellipse(CX + 7.5, RIMY + 10, 1.5, 1.5))
dr:add(HP.rect(CX + 6, RIMY + 3, CX + 9, RIMY + 4))
local dn = {} dr:each(function(x, y) local dx = (x - CX - 7.5) / 2 dn[K(x, y)] = { norm(dx, 0.1, sqrt(max(0.05, 1 - dx * dx))) } end)
A.shade(c, dr, dn, OAT, { tok = ptok, amb = 0.15 })
c:put(CX + 7, RIMY + 5, OAT[6])
-- contact shadow beside the drip on the glaze
for y = RIMY + 5, RIMY + 11 do if belly:has(CX + 10, y) and not dr:has(CX + 10, y) then A.step(c, bidx, GLAZE, CX + 10, y, -1, btok) end end
A.save(c, "goat-milk-porridge")
