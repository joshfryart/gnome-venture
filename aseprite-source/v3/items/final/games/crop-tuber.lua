-- crop-tuber (final, Opus single pass). A purple-top root crop pulled from the bed: a round-shouldered globe,
-- violet on top with a ragged sun line, cream below, tapering into a thin twisted tap root; three slim
-- lobed leaves on violet-tinged stalks fanning out of a sunken crown.
-- Material: per-pixel globe light (6-tone violet + 6-tone cream, cool shade), waxy bloom specks on the violet,
-- faint growth rings on the cream, one specular, cool reflected light lower-right, AO at the crown,
-- twist bands on the tap root, fine root hairs. Leaves: midrib + veins, two lobes low on each blade.
-- quirk: a clod of garden soil (with one tiny pebble) still clings to the tap root.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, pi, max, min, sqrt, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.abs
local c = A.new("crop-tuber")
local VIO   = { "#35204e", "#55296a", "#783688", "#9a4ea2", "#bd76ba", "#dea6d4" }
local CRM   = { "#6f6694", "#988fb4", "#c2bad0", "#e3dce0", "#f5efe4", "#fff9ee" }
local LEAF  = { "#183c38", "#215842", "#2d7648", "#43964e", "#68b658", "#9ad06c" }
local STALK = { "#4a2a58", "#74407a", "#a0689a", "#c896bc" }
local ROOT  = { "#5e5478", "#8c82a2", "#b6aec2", "#dcd4d6" }
local SOIL  = { "#2f1e1e", "#4e3228", "#70493a", "#93684e" }
local SPEC, BOUNCE = "#fff4d6", "#8a9ad0"
local CX, CY, R = 32, 38, 9.5

-- leaves (behind the globe): lobed blade on a violet stalk
local function leafStalk(ax, ay, qx, qy, bx, by, w)
  local wfn = function(t)
    if t > 0.985 then return -1 end
    if t < 0.32 then return 0.6 end
    local tt = (t - 0.32) / 0.68
    local base = w * sin(pi * min(1, tt * 0.95 + 0.05)) ^ 0.6
    if tt < 0.3 then base = base * (0.55 + 0.45 * abs(sin(tt * 10.5))) end
    return max(0.5, base)
  end
  local m, T, S, idx = A.leaf(c, ax, ay, qx, qy, bx, by, w, LEAF, { wfn = wfn, vs = 2.8 })
  m:each(function(x, y) local k = K(x, y)
    if T[k] < 0.34 then c:put(x, y, (S[k] <= 0) and STALK[3] or STALK[2]) end end)
end
leafStalk(31, 30, 24, 18, 15, 12, 3.6)
leafStalk(33, 30, 41, 18, 50, 13, 3.4)
leafStalk(32, 30, 31, 19, 33, 9, 3.2)

-- tap root first (globe overlaps), twisted bands + root hairs
local RT = { r = { name = "root" } }
local rm, rn, TT, TS, ridx = A.stem(c, { {32, 45}, {32, 50}, {30, 53}, {29, 57} }, function(t) return 2.8 * (1 - t) ^ 1.1 + 0.45 end, ROOT, { tok = RT })
rm:each(function(x, y) local k = K(x, y)
  local ph = (TT[k] * 22 + TS[k] * 1.6) % 3
  if ph < 0.9 and TT[k] > 0.15 then c:put(x, y, ROOT[max(1, (ridx[k] or 2) - 1)], RT) end
end)


-- globe: round, slightly flattened top, taper into the root
local g = c:ellipse(CX, CY, R, R - 0.5):add(c:poly{ {CX - 6, 43}, {CX + 6.5, 43}, {CX + 1, 50}, {CX - 1, 50} })
g = g:grow(1):shrink(1)
local n = A.body(g, CX - 0.5, CY + 0.5, R + 1, 5, 0.7)
local bias = {}
X.ao(bias, g, c:rect(29, 27, 35, 28), 2, -1)
-- violet top with a ragged sun line + tapering streaks down into the cream
local vio, crm = HP.mask(), HP.mask()
g:each(function(x, y)
  local line = 38.5 + 1.2 * sin((x - CX) * 0.9) + 0.08 * (x - CX)
  local p = y < line
  for _, s in ipairs{ {27, 3}, {33, 4}, {37, 2} } do
    if x == s[1] and y >= line and y < line + s[2] then p = true end
  end
  if p then vio:set(x, y) else crm:set(x, y) end
end)
local v = X.light(n, { amb = 0.06, wrap = 0.22 })
local vtok, ctok = { r = { name = "vio" } }, { r = { name = "crm" } }
X.tone(c, vio, v, VIO, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 }, bias = bias, tok = vtok })
local cb = {}
crm:each(function(x, y) local ry = y + 0.05 * (x - CX)^2
  if (ry % 3.4) < 0.8 and y < 47 and X.hash(x, y, 4) > 0.35 then cb[K(x, y)] = -1 end end)
X.tone(c, crm, v, CRM, { cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 }, bias = cb, tok = ctok })
-- waxy bloom on lit violet
vio:copy():shrink(1):each(function(x, y) if v[K(x, y)] > 0.7 and X.hash(x, y, 13) > 0.86 then c:put(x, y, VIO[6], vtok) end end)
-- reflected light
local rim = X.rim(n)
g:edge():each(function(x, y) if rim[K(x, y)] > 0.72 and y > 38 and y < 47 then c:put(x, y, BOUNCE, ctok) end end)
-- specular
c:put(26, 33, SPEC, vtok) c:put(27, 33, SPEC, vtok) c:put(26, 34, VIO[6], vtok) c:put(28, 32, VIO[6], vtok)
-- sunken crown with stalk bases
c:fillMask(c:rect(29, 29, 35, 29), VIO[1])
c:put(30, 30, VIO[2]) c:put(34, 30, VIO[2]) c:put(32, 30, VIO[1])
for _, p in ipairs{ {30, 28, 2}, {31, 28, 3}, {32, 28, 2}, {33, 28, 3}, {34, 28, 1} } do c:put(p[1], p[2], STALK[p[3]]) end

-- quirk: soil clod with a pebble on the tap root
local cl = c:ellipse(34, 52.5, 2.2, 1.7):add(c:ellipse(35.5, 53.5, 1.3, 1.2))
local ctk = { r = { name = "soil" } }
local cln = A.body(cl, 33.5, 52, 3, 2, 0.6)
local clidx = A.shade(c, cl, cln, SOIL, { tok = ctk, cuts = { 0.3, 0.55, 0.78 } })
cl:each(function(x, y) if X.hash(x, y, 17) > 0.8 then c:put(x, y, SOIL[max(1, (clidx[K(x, y)] or 2) - 1)], ctk) end end)
c:put(35, 52, "#b8b6c4", ctk) c:put(36, 52, "#8a889e", ctk) c:put(35, 53, "#8a889e", ctk) c:put(33, 51, SOIL[4], ctk)
-- root hairs (after the clod, off the left edge of the root)
for _, p in ipairs{ {29, 51}, {28, 52}, {28, 55}, {27, 56} } do c:put(p[1], p[2], ROOT[2], RT) end
A.save(c, "crop-tuber")
