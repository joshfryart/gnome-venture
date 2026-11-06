-- grapefruit (final pass, Opus aB35_4). A grapefruit cut in half, the cut face tipped toward the viewer: thin yellow
-- zest, cream pith ring, eleven ruby segments split by pale membranes around a cream core, juice-vesicle texture and
-- wet glints. Below, the domed rind: per-pixel lit, pitted peel pores, a rosy blush on the shade side, cool bounce
-- light, ground shadow.
-- quirk: a single bead of juice has run over the rim and is dripping down the peel.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new("grapefruit")
local RIND  = { "#7a3a2c", "#b45a2e", "#de8a34", "#f5b23e", "#ffd35a", "#fff0a0" }
local BLUSH = { "#6e2836", "#a8403c", "#d8664a", "#f08a56", "#ffb070", "#ffe0a0" }
local FL    = { "#6e1a32", "#a82c3e", "#d6444c", "#ee6460", "#ff8e82", "#ffc2b2" }
local PITH  = { "#d9b48e", "#efd2ae", "#fbe8c8", "#fff4dc" }
local COOL, GLINT = "#9a6a8a", "#fff4d6"
local CX, CY, RX, RY = 32, 26, 19, 10.5

c:groundShadow(32, 49, 16, 2.5)
-- rind dome
local body = A.oval(CX, CY, RX, 22, 0, 1)
body:each(function(x, y) if y < CY then body.s[K(x, y)] = nil end end)
local face = c:ellipse(CX, CY, RX, RY)
local bm = body:copy() bm:cut(face)
local bn = X.sphere(CX - 1, CY + 6, 21, bm)
for k, n in pairs(bn) do bn[k] = { n[1], n[2] * 0.8 + 0.25, n[3] } end
local bb = {}
X.ao(bb, bm, face, 1, -1)
local v = X.light(bn, { amb = 0.08, wrap = 0.25 })
local rtok = A.tok("rind")
local idx = {}
bm:each(function(x, y) local k = K(x, y)
  local val = v[k] local i = 1
  for j, t in ipairs(A.CUTS) do if val >= t then i = j + 1 end end
  i = max(1, min(6, i + (bb[k] or 0)))
  if X.hash(x, y, 11) < 0.13 and i >= 3 and not bb[k] then i = i - 1 end   -- peel pores
  idx[k] = i
  local blush = ((x - 45) ^ 2 + (y - 40) ^ 2 * 1.4) < 120 + X.hash(x // 2, y // 2, 4) * 40
  c:put(x, y, (blush and BLUSH or RIND)[i], rtok)
end)
local rim = X.rim(bn)
bm:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.55 and y > CY + 6 and idx[k] <= 3 then c:put(x, y, COOL, rtok) end end)
do local gx, gy = A.specAt(bm, bn, 30) if gx then c:put(gx, gy, RIND[6], rtok) c:put(gx + 1, gy, RIND[6], rtok) end end

-- cut face
local ftok = A.tok("face")
local zest = face:edge()
local pith = face:shrink(1):edge() pith:add(face:shrink(2):edge())
local NS = 11
face:each(function(x, y) local k = K(x, y)
  local u, w = (x - CX), (y - CY) * RX / RY
  local rr = sqrt(u * u + w * w)
  local lit = (x - CX) + (y - CY) * 1.8
  if zest:has(x, y) then c:put(x, y, lit < -6 and RIND[5] or (lit > 8 and RIND[3] or RIND[4]), ftok) return end
  if pith:has(x, y) then c:put(x, y, lit > 10 and PITH[2] or PITH[3], ftok) return end
  if rr < 2.6 then c:put(x, y, rr < 1.4 and PITH[2] or PITH[3], ftok) return end
  local a = atan(w, u) + 0.2
  local s = (a / (2 * pi) * NS) % 1
  local mw = min(s, 1 - s) * 2 * pi / NS * rr
  if mw < 0.55 then c:put(x, y, rr > 13 and PITH[3] or PITH[4], ftok) return end
  local i = lit > 9 and 3 or (lit < -10 and 5 or 4)
  if mw < 1.5 or rr > 15 then i = i - 1 end                      -- AO next to membranes and pith
  local h = X.hash(x, y, 3)
  if h < 0.14 then i = i + 1 elseif h < 0.24 then i = i - 1 end  -- juice vesicles
  c:put(x, y, FL[max(1, min(6, i))], ftok)
end)
-- wet glints on the upper-left segments
for _, p in ipairs{ { 22, 22 }, { 23, 22 }, { 27, 19 }, { 36, 20 } } do c:put(p[1], p[2], p[1] == 23 and FL[6] or GLINT, ftok) end

-- quirk: a juice drip over the rim, running down the peel with a bead at the end
local dtok = A.tok("drip")
local dx0 = 44
local fy = CY + floor(RY * sqrt(1 - ((dx0 - CX) / (RX + 0.5)) ^ 2) + 0.5)
for y = fy - 1, fy + 5 do c:put(dx0, y, y < fy + 1 and FL[5] or FL[4], dtok) c:put(dx0 + 1, y, FL[3], dtok) end
A.rows(c, dx0 - 1, fy + 6, { ".ab.", "abbc", "abcd", ".cd." }, { a = FL[5], b = FL[4], c = FL[3], d = FL[2] }, dtok)
c:put(dx0, fy + 7, GLINT, dtok)
A.save(c, "grapefruit")
