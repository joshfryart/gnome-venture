-- eggplant (Opus single pass). Slim Japanese-style aubergine lying on the diagonal, calyx upper-right, gently
-- curved, swelling toward the blossom end. Material: per-pixel tube light on a 6-tone glossy violet ramp with cool
-- shade, a long waxy specular streak + one cream glint on the lit shoulder, faint bloom flecks, magenta reflected
-- light on the lower-right edge, small blossom-end scar. Calyx: five spiky sepals clasping the neck (dark AO row and
-- contact shadow under them), green-felted with vein lines; woody stem with pale cut end grain.
-- quirk: a single water droplet sliding down the belly, with its own glint and a shadow.
local NAME = "eggplant"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB25_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local PU = { "#24153f", "#3d1f5e", "#5c2c86", "#7d3fae", "#a466d0", "#d2a8ef" }
local GR = { "#173f36", "#24593f", "#3a7a46", "#5c9c4e", "#8cc062", "#c2e08a" }
local STEM = { "#2a4a34", "#4f7a46", "#7ea45a", "#b7cf86" }
local CUT = "#e6dca0"
local SPEC, BOUNCE, BLOOM = "#fff4e8", "#b0508e", "#8e6cc0"

-- body: tube from calyx (t=0, upper-right) to blossom end (t=1, lower-left)
local p = { { 45, 17 }, { 40, 26 }, { 30, 36 }, { 18, 47 } }
local function hw(t)
  local w = 3.4 + 4.4 * t ^ 1.25
  if t > 0.8 then w = w * sqrt(max(0, 1 - ((t - 0.8) / 0.205) ^ 2)) end
  if t < 0.05 then w = w * (0.8 + t * 4) end
  return max(w, 0)
end
local bm, bn, BT, BS, samp = G.tube(p, hw)
local btok = { r = { name = "body" } }
local bias = {}
-- calyx mask (sepals) first so the body gets AO under it
local cx, cy = 45, 18
local sep = HP.mask()
local sepals = {
  { 42, 22, 38, 25 }, { 45, 23, 43, 27 }, { 41, 20, 36, 21 }, { 47, 21, 48, 26 }, { 43, 18, 38, 17 },
}
local sepS = {}
for i, q in ipairs(sepals) do
  local m, n, T, S = G.blade(cx, cy, q[1], q[2], q[3], q[4], function(t)
    if t > 0.99 then return -1 end
    return max(0.35, 2.4 * (1 - t) ^ 0.8)
  end, { fold = 0.3 })
  sepS[i] = { m = m, n = n, T = T, S = S }
  sep:add(m)
end
sep:add(G.rell(cx, cy + 1, 0.6, 0.8, 3.4, 2.6))
X.ao(bias, bm, sep, 1, -2)
G.cast(bias, bm, sep, 1, 1, -1)
local idx = G.shade(c, bm, bn, PU, { 0.3, 0.46, 0.62, 0.77, 0.92 }, { amb = 0.0, wrap = 0.1, bias = bias, tok = btok })
-- waxy bloom flecks on the mid tones
bm:each(function(x, y) local k = K(x, y)
  if (idx[k] == 3 or idx[k] == 4) and X.hash(x, y, 7) > 0.93 and not bias[k] then c:put(x, y, BLOOM, btok) end end)
-- cool/magenta reflected light along the lower-right edge
local rim = X.rim(bn)
bm:edge():each(function(x, y) local k = K(x, y)
  if BS[k] and BS[k] > 0.7 and BT[k] > 0.25 and BT[k] < 0.96 and rim[k] > 0.55 then c:put(x, y, BOUNCE, btok) end end)
-- long specular streak along the lit side
for i = 0, 26 do local t = 0.26 + i * 0.022
  local s = samp[floor(t * 160) + 1]
  local w = s.w * -0.5
  c:put(floor(s.x + s.px * w + .5), floor(s.y + s.py * w + .5), i % 9 == 4 and PU[5] or PU[6], btok)
end
do local s = samp[floor(0.4 * 160) + 1]
  local x, y = floor(s.x + s.px * s.w * -0.5 + .5), floor(s.y + s.py * s.w * -0.5 + .5)
  c:put(x, y, SPEC, btok) c:put(x, y - 1, SPEC, btok) end
-- blossom-end scar
do local s = samp[#samp]
  local x, y = floor(s.x - s.tx * 1.5 + .5), floor(s.y - s.ty * 1.5 + .5)
  c:put(x, y, PU[1], btok) c:put(x + 1, y, PU[2], btok) c:put(x, y - 1, PU[3], btok) end

-- calyx: sepals with vein and AO at the base
local gtok = { r = { name = "calyx" } }
local cap = G.rell(cx, cy + 1, 0.6, 0.8, 3.4, 2.6)
G.shade(c, cap, X.pillow(cap, 2), GR, { 0.2, 0.36, 0.52, 0.68, 0.84 }, { tok = gtok })
for _, s in ipairs(sepS) do
  local m = s.m:copy()
  local sb = {}
  G.shade(c, m, s.n, GR, { 0.2, 0.36, 0.52, 0.68, 0.84 }, { tok = gtok, bias = sb, amb = 0.1 })
  m:each(function(x, y) local k = K(x, y)
    if abs(s.S[k]) < 0.18 and s.T[k] > 0.15 and s.T[k] < 0.8 then c:put(x, y, GR[2], gtok) end end)
end
-- prickly felt flecks on the cap
cap:each(function(x, y) if X.hash(x, y, 3) > 0.9 then c:put(x, y, GR[6], gtok) end end)
-- stem: woody, curving up-right, with a pale cut end
local stok = { r = { name = "stem" } }
local sp = { { 45, 16 }, { 46, 12 }, { 49, 9 }, { 52, 8 } }
local sm, sn = G.tube(sp, function(t) return 1.6 - 0.2 * t end)
sm:cut(cap)
G.shade(c, sm, sn, STEM, { 0.3, 0.55, 0.8 }, { tok = stok, amb = 0.1 })
-- end grain on the cut tip (squared off)
for _, q in ipairs{ { 53, 7 }, { 53, 8 }, { 54, 8 }, { 53, 9 } } do c:put(q[1], q[2], q[1] == 54 and STEM[2] or CUT, stok) end
c:put(53, 8, "#c8b878", stok)
-- fibre lines on the stem
for _, q in ipairs{ { 47, 11 }, { 49, 9 } } do c:put(q[1], q[2], STEM[2], stok) end

-- quirk: water droplet on the belly
local dtok = { r = { name = "drop" } }
local ds = samp[floor(0.6 * 160) + 1]
local dx, dy = floor(ds.x + ds.px * ds.w * 0.05 + .5), floor(ds.y + ds.py * ds.w * 0.05 + .5)
for _, q in ipairs{ { 1, 4 }, { 2, 3 }, { 2, 4 }, { 3, 2 } } do c:put(dx + q[1], dy + q[2], PU[1], btok) end
local drop = { { 0, 0, "#d9c8fa" }, { 1, 0, "#b89ae8" }, { 0, 1, "#f2eaff" }, { 1, 1, "#c4a8f0" }, { 2, 1, "#8a6cc8" },
  { 0, 2, "#c4a8f0" }, { 1, 2, "#9c80d8" }, { 2, 2, "#6a4ca8" }, { 1, 3, "#6a4ca8" }, { -1, 1, "#b89ae8" }, { -1, 2, "#a68ae0" } }
for _, q in ipairs(drop) do c:put(dx + q[1], dy + q[2], q[3], dtok) end
c:put(dx, dy + 1, SPEC, dtok)
G.save2(c, NAME)
