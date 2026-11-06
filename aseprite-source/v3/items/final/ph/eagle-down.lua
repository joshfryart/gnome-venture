-- eagle-down (ph, Opus single pass). A slim, gently curved eagle feather on the diagonal (quill lower left, tip
-- upper right). Vane: asymmetric (narrow leading edge), soft V-fold lighting, barbs as fine diagonal lines swept to the
-- tip, two natural splits in the vane, cream base turning tawny-brown toward a dark-barred tip (6-tone ramps each).
-- Lower third: loose downy plumes (unzipped barbs) in soft tufts with gaps; pale glassy calamus with a hollow end.
-- quirk: one little puff of down has come loose and is drifting away.
local NAME = "eagle-down"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB25_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local DOWN = { "#6e5260", "#9a7e80", "#c2a894", "#dfc8aa", "#f2e2c2", "#fff2d8" }
local TAW = { "#3c2228", "#5c3428", "#84502e", "#aa723c", "#ca9858", "#e4be84" }
local SHAFT = { "#9a8476", "#d8c6a6", "#f6ead0" }
local COOL = "#6a6a8c"

local A, C, B = { 17, 50 }, { 24, 26 }, { 50, 11 }
local m, n, T, S, len = G.blade(A[1], A[2], C[1], C[2], B[1], B[2], function(t)
  if t > 0.985 then return -1 end
  local w
  if t < 0.12 then w = 2.6 + t * 40 elseif t < 0.76 then w = 7.4 + 0.6 * sin((t - 0.12) * 3) else w = 7.9 * ((1 - t) / 0.24) ^ 0.9 + 0.2 end
  return w
end, { fold = 0.3 })
-- asymmetric: trim the leading (upper-left, s<0) vane
local cut = {}
m:each(function(x, y) local k = K(x, y) if S[k] < -0.78 and T[k] > 0.25 then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do m.s[k] = nil end
-- splits: two narrow gaps running along the barbs from the edge
local function phase(k) if not T[k] then return 0.5 end return (T[k] * len - abs(S[k]) * 7.5) end
local gap = {}
m:each(function(x, y) local k = K(x, y)
  local p = phase(k)
  if S[k] > 0.35 and abs(p - 33) < 1.0 then gap[#gap + 1] = k end
  if S[k] < -0.3 and abs(p - 26) < 0.9 then gap[#gap + 1] = k end
end)
for _, k in ipairs(gap) do m.s[k] = nil end
-- down zone: below t 0.3 the barbs break into tufts
local DZ = 0.3
local downm = HP.mask()
m:each(function(x, y) local k = K(x, y)
  if T[k] < DZ then
    local p = phase(k) / 3.2
    local fr = p - floor(p)
    local reach = 0.55 + 0.45 * X.hash(floor(p), 1, 4)
    if fr < 0.78 and abs(S[k]) < reach + 0.1 then downm:set(x, y) end
  end
end)
local vane = HP.mask()
m:each(function(x, y) if T[K(x, y)] >= DZ then vane:set(x, y) end end)
-- loose wisps beyond the down edge (curling tips), along the barb direction
for i = 0, 5 do
  local t = 0.04 + i * 0.045
  local x, y = G.bez({ A, { (A[1] + C[1]) / 2, (A[2] + C[2]) / 2 }, { (C[1] + B[1]) / 2, (C[2] + B[2]) / 2 }, B }, t)
  local side = (i % 2 == 0) and 1 or -1
  local wx, wy = side * 0.8, side * 0.35 - 0.55
  downm:add(G.rell(x + wx * 7, y + wy * 7, wx, wy, 2.8, 1.5))
end

-- paint vane
local vtok = { r = { name = "vane" } }
local v = X.light(n, { amb = 0.12, wrap = 0.3 })
local tIdx = {}
vane:each(function(x, y) local k = K(x, y) tIdx[k] = true end)
local cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local vi = {}
vane:each(function(x, y) local k = K(x, y)
  local i = 1 for j, ct in ipairs(cuts) do if (v[k] or 0) >= ct then i = j + 1 end end
  vi[k] = i
  -- colour zone boundary follows the barbs (zig-zag)
  local p = phase(k)
  local tz = T[k] + 0.04 * sin(p * 1.3)
  local ramp = tz > 0.62 and TAW or DOWN
  if tz > 0.62 and tz < 0.66 then ramp = TAW i = max(1, i - 1) end
  -- dark bars near the tip
  if tz > 0.8 and (floor(p / 3.6) % 2 == 0) then i = max(1, i - 2) end
  c:put(x, y, ramp[i], vtok)
end)
-- barbs: fine darker lines along the barb direction
vane:each(function(x, y) local k = K(x, y)
  local p = phase(k) / 2.4
  local fr = p - floor(p)
  if fr < 0.2 and abs(S[k]) > 0.12 then
    local tz = T[k] + 0.04 * sin(phase(k) * 1.3)
    local ramp = tz > 0.62 and TAW or DOWN
    c:put(x, y, ramp[max(1, vi[k] - 1)], vtok)
  end
end)
-- cool reflected light along the trailing (lower-right) edge
vane:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.78 and T[k] > 0.35 and T[k] < 0.85 then c:put(x, y, COOL, vtok) end end)

-- down tufts: soft pillow light, strand lines
local dtok = { r = { name = "down" } }
local dn = X.pillow(downm, 1.6)
local di = X.tone(c, downm, X.light(dn, { amb = 0.2, wrap = 0.35 }), DOWN, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = dtok })
downm:each(function(x, y) local k = K(x, y)
  local p = phase(k) / 3.2 if p - floor(p) > 0.62 and di[k] > 2 then c:put(x, y, DOWN[di[k] - 1], dtok) end end)

-- rachis: pale shaft down the middle, darker where the vane meets it (AO), calamus below
local stok = { r = { name = "shaft" } }
local P4 = { A, { (A[1] + 2 * C[1]) / 3, (A[2] + 2 * C[2]) / 3 }, { (B[1] + 2 * C[1]) / 3, (B[2] + 2 * C[2]) / 3 }, B }
for i = 0, 140 do
  local t = i / 140
  if t < 0.95 then
    local x, y = G.bez(P4, t)
    local xi, yi = floor(x + .5), floor(y + .5)
    c:put(xi, yi, t < 0.62 and SHAFT[3] or TAW[6], stok)
    local dk = (t > 0.62) and TAW or DOWN
    if m:has(xi + 1, yi) and not (floor(G.bez(P4, t) + .5) == xi + 1) then c:put(xi + 1, yi, dk[2], stok) end
    if t > DZ and m:has(xi, yi + 1) and not m:has(xi + 1, yi + 1) == false then c:put(xi, yi + 1, dk[3], stok) end
  end
end
local qm, qn = G.tube({ { 18, 51 }, { 17, 53 }, { 16, 55 }, { 14, 57 } }, function(t) return 1.3 - t * 0.3 end)
qm:cut(downm)
local qtok = { r = { name = "calamus" } }
X.tone(c, qm, X.light(qn, { amb = 0.15, wrap = 0.3 }), SHAFT, { cuts = { 0.35, 0.7 }, tok = qtok })
c:put(14, 57, SHAFT[1], qtok) c:put(15, 56, "#fff4d6", qtok)
-- one glint on the vane
c:put(33, 25, "#fff4d6", vtok)

-- quirk: a loose puff of down drifting off to the left
local pm = G.rell(9, 30, 0.8, -0.6, 2.3, 1.7):add(G.rell(11, 28, 0.6, -0.8, 1.4, 1.0))
local pn = X.pillow(pm, 1.4)
local ptok = { r = { name = "puff" } }
X.tone(c, pm, X.light(pn, { amb = 0.25, wrap = 0.35 }), DOWN, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = ptok })
c:put(8, 32, DOWN[2], ptok)
G.save2(c, NAME)
