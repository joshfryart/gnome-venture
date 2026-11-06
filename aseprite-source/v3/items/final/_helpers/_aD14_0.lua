-- _aD14_0.lua: private helper for sakura-seed / salak / salak-seed / salsa-verde (artist D14_0).
-- Wraps batch2/_b2g1.lua (read-only) and adds serrated-leaf, petal and line helpers.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
G.out = app.params.out or (DIR .. "/../ph/")

function G.ln(c, pts, hex) c:line(pts, 1):each(function(x, y) c:px(x, y, hex) end) end

-- serrated / veined leaf. o: ramp(6), per (tooth period px), depth (0..1 tooth depth), veins, vein (hex lit), tok,
-- tmin/tmax (teeth span), fold, amb, wrap, cuts, rib (midrib on/off), coolEdge hex
function G.sleaf(c, ax, ay, cx, cy, bx, by, wfn, o)
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, wfn, { fold = o.fold or 0.4 })
  local per = o.per or 4.6
  if per > 0 then
    local cut = {}
    m:each(function(x, y) local k = K(x, y)
      local t, s = T[k], S[k]
      local ph = t * len / per + (s > 0 and 0.5 or 0) + 0.25
      local f = abs((ph - floor(ph)) - 0.5) * 2
      local lim = 0.98 - (1 - f) ^ 2.2 * (o.depth or 0.5)
      if t > (o.tmin or 0.1) and t < (o.tmax or 0.93) and abs(s) > lim then cut[#cut + 1] = k end
    end)
    for _, k in ipairs(cut) do m.s[k] = nil end
  end
  return m, n, T, S, len
end
function G.paintLeaf(c, m, n, T, S, len, o)
  local R = o.ramp
  local tok = o.tok or { r = { name = "leaf" } }
  local bias = o.bias or {}
  G.toneN(c, m, n, R, { bias = bias, tok = tok, cuts = o.cuts or { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = o.amb or 0.18, wrap = o.wrap or 0.3 })
  local per = o.per or 4.6
  m:each(function(x, y) local k = K(x, y)
    if bias[k] then return end
    local s, t = S[k], T[k]
    if o.rib ~= false and abs(s) < 0.15 and t > 0.03 and t < 0.94 then c:put(x, y, s <= 0 and (o.vein or R[6]) or R[3], tok) return end
    if o.veins and per > 0 then
      local ph = (t * len - abs(s) * (o.sweep or 3.4)) / per + (s > 0 and 0.5 or 0) + 0.25
      local f = abs((ph - floor(ph)) - 0.5) * 2
      if f > 0.86 and abs(s) > 0.16 and abs(s) < 0.78 and t > 0.06 and t < 0.9 then c:put(x, y, s < 0 and R[5] or R[2], tok) end
    end
  end)
  if o.cool then
    m:edge():each(function(x, y) local k = K(x, y)
      if not bias[k] and S[k] > 0.6 and T[k] > 0.1 and T[k] < 0.88 then c:put(x, y, o.cool, tok) end end)
  end
  return tok
end
return G
