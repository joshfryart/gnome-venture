-- peanut (final pass, Opus aC32_4). A slim two-seed peanut pod lying on the diagonal: pinched waist, the upper lobe ends
-- in a small beak, netted shell (lengthwise ribs and cross ridges lit on the upper-left side, recessed cells), a dark
-- AO crease at the waist, pale stalk scar at the lower end. Beside it a loose kernel in a glossy brick-red skin.
-- quirk: the loose kernel's papery skin is peeling back, showing the cream nut and a curled flake.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "peanut"
local c = A.new(NAME)
local SH = { "#5a3626", "#865a36", "#b0814c", "#cfa466", "#e6c486", "#f7e2ae" }
local SKIN = { "#4a1a24", "#76262a", "#a43a32", "#c8583c", "#e27e56", "#f6a87a" }
local NUT = { "#9a6a3e", "#c8985e", "#e6c48a", "#f7e2b4" }

-- pod along the axis A (lower-left) -> B (upper-right); half width profile with a waist
local AX, AY, BX, BY = 16, 47, 44, 19
local len = sqrt((BX - AX)^2 + (BY - AY)^2)
local function hw(t)
  local d = t * len
  local function lobe(cc, R) local q = R * R - (d - cc)^2 return q > 0 and sqrt(q) or 0 end
  local w = max(lobe(7.4, 7.3), lobe(len - 7.6, 7.0))
  if d > 7 and d < len - 7 then w = max(w, 4.7) end
  return w
end
local m, n, T, S = A.tube({ { AX, AY }, { AX + 9, AY - 9 }, { BX - 9, BY + 9 }, { BX, BY } }, function(t) return hw(t) end, 220)
-- beak at the upper end
m:set(BX + 1, BY - 1) m:set(BX + 2, BY - 2) m:set(BX + 1, BY - 2)
local np = X.pillow(m, 4.5)
local nn = {}
for k, a in pairs(np) do local b = n[k] or a
  nn[k] = { A.norm(a[1] * 0.5 + b[1] * 0.5, a[2] * 0.5 + b[2] * 0.5, a[3] * 0.5 + b[3] * 0.5) } end
local bias = {}
-- waist crease AO
m:each(function(x, y) local k = K(x, y) local t = T[k]
  if t and t > 0.46 and t < 0.54 then bias[k] = (bias[k] or 0) - 1 end
  if t and t > 0.485 and t < 0.515 then bias[k] = (bias[k] or 0) - 1 end end)
local tok = { r = { name = "pod" } }
local idx = A.shade(c, m, nn, SH, { amb = 0.08, wrap = 0.25, bias = bias, tok = tok })
local function put(x, y, i) local k = K(x, y) i = max(1, min(6, i)) idx[k] = i c:put(x, y, SH[i], tok) end
-- netted shell: ribs along the pod (S bands) and cross ridges (T steps); cells recessed
m:each(function(x, y) local k = K(x, y)
  local t, s = T[k], S[k]
  if not t or bias[k] then return end
  local i = idx[k]
  local rib = abs((s * 3.2) - floor(s * 3.2 + 0.5)) < 0.16
  local cross = ((t * len / 3.4 + s * 0.8) % 1) < 0.24
  if rib or cross then
    if s < 0.3 then put(x, y, i + 1) end
  elseif ((t * len / 3.4 + s * 0.8) % 1) > 0.55 and ((t * len / 3.4 + s * 0.8) % 1) < 0.8 and X.hash(x, y, 5) < 0.5 then
    put(x, y, i - 1)
  end
end)
-- stalk scar at the lower end, dark beak tip, one gloss
A.map(c, { ".a", "ab" }, AX - 2, AY - 1, { a = SH[5], b = SH[3] }, tok)
c:put(BX + 2, BY - 2, SH[2], tok)
c:put(20, 41, "#fff4d6", tok)

-- loose kernel lower right, with peeling skin
local KX, KY = 44, 41
local km, kn = A.oval(KX, KY, 5.6, 3.6, -0.55, 0.9)
local ktok = { r = { name = "kernel" } }
local kv = X.light(kn, { amb = 0.08, wrap = 0.25 })
local peel = {}
km:each(function(x, y) local k = K(x, y)
  local dx, dy = x - KX, y - KY
  if dx + dy * 0.2 > 1.2 + 1.2 * X.hash(x, y, 9) then peel[k] = true end end)
km:each(function(x, y) local k = K(x, y)
  local val = kv[k] or 0.4
  if peel[k] then
    local i = val > 0.7 and 4 or val > 0.45 and 3 or val > 0.22 and 2 or 1
    c:put(x, y, NUT[i], ktok)
  else
    local i = 1 for j, t in ipairs(A.CUTS) do if val >= t then i = j + 1 end end
    c:put(x, y, SKIN[i], ktok)
  end end)
-- skin veins (fine darker lines) on the red part
for _, p in ipairs{ {40, 43}, {41, 42}, {42, 42}, {41, 45}, {42, 44} } do if not peel[K(p[1], p[2])] then c:put(p[1], p[2], SKIN[3], ktok) end end
-- peel edge: a dark rim on the skin side and a curled flake lifting off
km:each(function(x, y) local k = K(x, y)
  if not peel[k] and (peel[K(x + 1, y)] or peel[K(x, y + 1)]) then c:put(x, y, SKIN[2], ktok) end end)
A.map(c, { "ab.", ".cb", "..d" }, KX + 5, KY - 5, { a = SKIN[6], b = SKIN[4], c = SKIN[5], d = SKIN[3] }, ktok)
-- kernel gloss
c:put(KX - 3, KY - 1, "#fff4d6", ktok) c:put(KX - 2, KY - 2, SKIN[6], ktok)

A.save(c, NAME)
