-- heron-plume (aC11_5, Opus single pass). A long, slim grey-heron plume on a gentle S-curve from a bare ivory quill
-- (lower-left) to a fine slate-black crest tip (upper-right). Asymmetric vanes (narrow leading vane on the lit side),
-- barbs as slanted grooves, two splits where the barbs have parted, a ragged wispy outer edge and downy afterfeather
-- at the base. Material: flat gently-cupped vane light (6 tones), ivory rachis with a shade side, hollow quill with a
-- darker pith core.
-- quirk: a single water bead from the heron's pond still clings to the shade-side vane.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, sqrt, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.sqrt, math.max, math.min
local c = G.new2("heron-plume")
local V  = { "#2a2c48", "#43486c", "#626b92", "#8590b6", "#afbad6", "#dbe4f2" }
local VD = { "#1c1828", "#2a2640", "#3a3858", "#504f74", "#6e7196", "#99a0c0" }
local QU = { "#6a5656", "#a48e80", "#d6c4a8", "#f4e8cc" }
local p = { { 13, 56 }, { 19, 42 }, { 33, 23 }, { 53, 7 } }
local Q = 0.17 -- quill length (t)
local function wl(t) if t < Q then return 0 end local u = (t - Q) / (1 - Q) return 4.2 * sin(pi * min(1, u * 0.98 + 0.02)) ^ 0.6 * (1 - 0.35 * u) + 0.2 end
local function wr(t) if t < Q then return 0 end local u = (t - Q) / (1 - Q) return 6.6 * sin(pi * min(1, u * 0.98 + 0.02)) ^ 0.55 * (1 - 0.3 * u) + 0.2 end
local m0, n0, T, S, samp = G.tube(p, function(t) return max(1.2, wl(t), wr(t)) end)
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
local vane, quill = HP.mask(), HP.mask()
local D, PH = {}, {}
m0:each(function(x, y)
  local k = K(x, y)
  local t, s = T[k], S[k]
  local W = max(1.2, wl(t), wr(t))
  local d = s * (W + 0.5)
  if t < Q then
    if abs(d) <= 1.0 and t > 0.005 then quill:set(x, y) end
    return
  end
  local lim = d < 0 and wl(t) or wr(t)
  if abs(d) > lim then return end
  local ph = t * LEN - abs(d) * 1.1
  -- ragged wispy outer edge
  if abs(d) > lim - 1.1 and (ph % 3) >= 2.0 then return end
  -- two splits where barbs have parted
  if d > 1.6 and abs(ph - 24) < 0.6 then return end
  if d < -1.4 and abs(ph - 36) < 0.6 then return end
  vane:set(x, y) D[k], PH[k] = d, ph
end)
-- light: flat vane with a gentle cup across the rachis
local n = {}
vane:each(function(x, y) local k = K(x, y)
  local s = max(-1, min(1, D[k] / 7))
  local ss = samp[floor(T[k] * 160) + 1]
  n[k] = { G.norm(ss.px * s * 0.75, ss.py * s * 0.75, 1) }
end)
local v = X.light(n, { amb = 0.12, wrap = 0.3 })
local bias = {}
vane:each(function(x, y) local k = K(x, y)
  -- barb grooves
  if (PH[k] % 3) < 1 then bias[k] = -1 end
  -- ambient next to the rachis
  if abs(D[k]) < 1.6 and D[k] > 0 then bias[k] = (bias[k] or 0) - 1 end
end)
-- split ramp: pale grey body, slate-black crest toward the tip (ragged boundary)
local vmA, vmB = HP.mask(), HP.mask()
vane:each(function(x, y) local k = K(x, y)
  if T[k] + (G.hash(x, y, 5) - 0.5) * 0.06 - abs(D[k]) * 0.006 > 0.74 then vmB:set(x, y) else vmA:set(x, y) end end)
local cuts = { 0.24, 0.42, 0.58, 0.74, 0.88 }
X.tone(c, vmA, v, V, { cuts = cuts, bias = bias })
X.tone(c, vmB, v, VD, { cuts = cuts, bias = bias })
-- downy afterfeather tufts at the base of the vane
for _, w in ipairs{ { Q + 0.01, 1, 4, 1 }, { Q + 0.03, 1, 3, 0.3 }, { Q + 0.0, -1, 3, -0.2 }, { Q + 0.025, -1, 2, 0.6 } } do
  local ss = samp[floor(w[1] * 160) + 1]
  local dx, dy = G.rot(ss.px * w[2], ss.py * w[2], w[4] * w[2])
  for i = 1, w[3] do
    c:put(floor(ss.x + dx * (i + 1) - ss.tx * i * 0.6 + .5), floor(ss.y + dy * (i + 1) - ss.ty * i * 0.6 + .5), i == w[3] and V[6] or V[5])
  end
end
-- rachis: ivory, lit line + shade line
for i = 0, 160 do
  local ss = samp[i + 1]
  if ss.t >= Q and ss.t < 0.97 then
    local x, y = floor(ss.x + .5), floor(ss.y + .5)
    c:put(x, y, ss.t > 0.8 and QU[2] or QU[4])
    if ss.t < 0.7 then c:put(floor(ss.x + ss.px + .5), floor(ss.y + ss.py + .5), QU[2]) end
  end
end
-- quill: hollow ivory tube with a darker pith core
local qn = {}
quill:each(function(x, y) local k = K(x, y) local s = S[k] * 0.9
  local ss = samp[floor(T[k] * 160) + 1]
  qn[k] = { ss.px * s, ss.py * s, sqrt(max(0.05, 1 - s * s)) } end)
X.tone(c, quill, X.light(qn, { amb = 0.15, wrap = 0.3 }), QU, { cuts = { 0.3, 0.55, 0.8 } })
for i = 0, 160 do local ss = samp[i + 1]
  if ss.t > 0.06 and ss.t < Q - 0.03 and i % 2 == 0 then c:put(floor(ss.x + ss.px * 0.4 + .5), floor(ss.y + ss.py * 0.4 + .5), QU[2]) end end
do local ss = samp[floor(0.1 * 160) + 1] c:put(floor(ss.x - ss.px * 0.6 + .5), floor(ss.y - ss.py * 0.6 + .5), "#fff4d6") end
-- quirk: water bead on the shade-side vane, with contact shadow
do
  local ss = samp[floor(0.5 * 160) + 1]
  local bx, by = floor(ss.x + ss.px * 3.6 + .5), floor(ss.y + ss.py * 3.6 + .5)
  c:put(bx + 2, by + 1, V[2]) c:put(bx + 1, by + 2, V[2]) c:put(bx + 2, by + 2, V[1])
  G.stamp(c, bx - 1, by - 1, { ".ab", "acd", "bde" }, { a = "#8fd8e8", b = "#5fb0d0", c = "#fff4d6", d = "#3a86b0", e = "#2a5a8a" })
end
-- one soft glint on the lit vane
do local ss = samp[floor(0.36 * 160) + 1]
  c:put(floor(ss.x - ss.px * 2 + .5), floor(ss.y - ss.py * 2 + .5), "#f4f8ff") end
G.save2(c, "heron-plume")
