-- giant-seed-pod (final pass, Opus single pass). A long slim crescent pod lying on its back, split open along the seam:
-- glossy green shell with faint diagonal veins and waxy bloom, a pale cut lip on the near valve, a shadowed far valve,
-- a concave cream-green lining, and four round tan seeds in a row (sphere-lit, dark hilum eye, contact AO in their
-- cups). A brown stalk with a starry calyx and a pigtail tendril at the top end; a pointed beak at the bottom end.
-- quirk: a tiny ladybird is walking along the outside of the shell.
local NAME = "giant-seed-pod"
local B = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_0.lua")
local HP, X, K = B.HP, B.X, B.K
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local c = B.new(NAME)
local POD = { "#173f36", "#245a40", "#347848", "#4f9a4e", "#79bd5c", "#b2dc7c" }
local LIN = { "#34442a", "#56703c", "#88a45a", "#bccf8a", "#e6eebc" }
local SEED = { "#4a2c24", "#6e442e", "#97663c", "#bf8f50", "#e0b978", "#f8e0a8" }
local STALK = { "#3e2c22", "#5e4430", "#86663e", "#b08e5a" }
local BLOOM, COOL = "#cde6b0", "#3a6a6e"

local pts = { { 8, 45 }, { 20, 59 }, { 44, 52 }, { 53, 24 } }
local sm, sn, ST, SS, samp = B.tube(pts, function(t) return max(0.3, 6.0 * sin(pi * (0.03 + 0.94 * t)) ^ 0.6) end)

-- opening: lens in (t, s) space, offset toward the lit side
local function inOpen(t, s) return ((t - 0.5) / 0.37) ^ 2 + ((s + 0.28) / 0.5) ^ 2 <= 1 end
local open = HP.mask()
sm:each(function(x, y) local k = K(x, y) if inOpen(ST[k], SS[k]) then open:set(x, y) end end)
local shell = sm:copy():cut(open)

-- shell
local ptok = { r = { name = "pod" } }
local sbias = {}
local idx = B.shade(c, shell, sn, POD, { amb = 0.1, wrap = 0.3, tok = ptok, bias = sbias })
shell:each(function(x, y) local k = K(x, y)
  local t, s = ST[k], SS[k]
  -- faint diagonal veins on the outer belly
  if s > 0.3 and ((t * 70 + s * 4) % 5.5) < 0.8 and t > 0.06 and t < 0.94 then B.step(c, idx, POD, x, y, -1, ptok) end
  -- waxy bloom speckles on the lit far valve
  if s < -0.55 and X.hash(x, y, 17) > 0.8 then c:put(x, y, BLOOM, ptok) end
end)
-- far valve inner wall (just above the opening) in shadow; near valve cut lip pale
local og = open:grow(1)
shell:each(function(x, y) local k = K(x, y)
  if og:has(x, y) then
    if SS[k] < -0.28 then c:put(x, y, POD[2], ptok) else c:put(x, y, LIN[5], ptok) end
  end
end)
-- cool reflected light along the lower-right rim
sm:edge():each(function(x, y) local k = K(x, y) if SS[k] > 0.8 and ST[k] > 0.1 and ST[k] < 0.92 then c:put(x, y, COOL, ptok) end end)

-- seeds positions
local seeds = {}
for _, t in ipairs{ 0.25, 0.42, 0.59, 0.76 } do
  local i = floor(t * (#samp - 1)) + 1
  local s = samp[i]
  local off = -0.28 * (s.w + 0.5)
  local cx, cy = s.x + s.px * off, s.y + s.py * off
  local r = 3.3
  local m = HP.mask()
  for y = floor(cy - r - 1), floor(cy + r + 1) do for x = floor(cx - r - 1), floor(cx + r + 1) do
    if (x - cx) ^ 2 + (y - cy) ^ 2 <= (r + 0.3) ^ 2 then m:set(x, y) end end end
  seeds[#seeds + 1] = { cx = cx, cy = cy, r = r, m = m, px = s.px, py = s.py }
end

-- lining (concave)
local ln, lbias = {}, {}
open:each(function(x, y) local k = K(x, y)
  local t, s = ST[k], SS[k]
  local i = floor(t * (#samp - 1)) + 1
  local sp = samp[i]
  local q = max(-0.95, min(0.95, (s + 0.28) / 0.5))
  ln[k] = { B.norm(-sp.px * q, -sp.py * q, sqrt(1 - q * q) + 0.2) }
end)
for _, s in ipairs(seeds) do X.ao(lbias, open, s.m, 1, -1) B.cast(lbias, open, s.m, 1, 1, -1) end
local ltok = { r = { name = "lining" } }
B.shade(c, open, ln, LIN, { amb = 0.15, wrap = 0.2, tok = ltok, bias = lbias, cuts = { 0.25, 0.45, 0.65, 0.82 } })
-- funicle stubs: tiny pale cords from the far wall to each seed
for _, s in ipairs(seeds) do
  local x, y = floor(s.cx - s.px * (s.r + 1) + .5), floor(s.cy - s.py * (s.r + 1) + .5)
  if open:has(x, y) then c:put(x, y, LIN[4], ltok) end
end

-- seeds
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local m = s.m:copy()
  local n = X.sphere(s.cx, s.cy, s.r, m)
  local b = {}
  if i < #seeds then X.ao(b, m, seeds[i + 1].m, 1, -1) end
  local si = B.shade(c, m, n, SEED, { amb = 0.08, wrap = 0.2, tok = tok, bias = b })
  -- hilum eye (lower-right), pale ring
  local hx, hy = floor(s.cx + 1.2 + .5), floor(s.cy + 1.4 + .5)
  c:put(hx, hy, SEED[1], tok) c:put(hx + 1, hy, SEED[2], tok)
  c:put(hx - 1, hy, SEED[4], tok)
  -- specular
  local gx, gy = floor(s.cx - 1.3 + .5), floor(s.cy - 1.6 + .5)
  c:put(gx, gy, SEED[6], tok)
  if i == 2 then c:put(gx + 1, gy, SEED[6], tok) end
end

-- stalk + calyx + tendril at the top end
local ttok = { r = { name = "stalk" } }
local km, kn = B.tube({ { 53, 24 }, { 53.5, 20 }, { 53, 16 }, { 51, 12 } }, function(t) return 1.3 - 0.3 * t end)
km:cut(sm)
B.shade(c, km, kn, STALK, { amb = 0.15, wrap = 0.3, tok = ttok })
-- calyx: three short sepals hugging the pod top
for _, q in ipairs{ { 50, 24, 3 }, { 51, 24, 4 }, { 55, 25, 2 }, { 56, 26, 1 }, { 52, 23, 3 }, { 54, 23, 2 } } do
  c:put(q[1], q[2], q[3] <= 2 and POD[q[3]] or POD[q[3] + 1], ttok)
end
-- pigtail tendril
local tx, ty = 51, 12
local tend = { { 50, 11 }, { 49, 10 }, { 48, 10 }, { 47, 11 }, { 47, 12 }, { 48, 13 }, { 49, 13 }, { 50, 12 }, { 46, 10 }, { 45, 9 }, { 44, 9 } }
for i, q in ipairs(tend) do c:put(q[1], q[2], i < 3 and POD[4] or (i > 8 and POD[5] or POD[3]), ttok) end
-- AO where stalk meets pod
c:put(52, 25, POD[1], ptok) c:put(54, 26, POD[1], ptok)

-- quirk: ladybird on the outer belly
local lt = { r = { name = "ladybird" } }
B.map(c, {
  ".hh.",
  "rRRr",
  "RrdR",
  "rdrr",
  ".rr.",
}, 21, 55, { h = "#2b1c26", R = "#f2584a", r = "#c42f3a", d = "#2b1c26" }, lt)
c:put(22, 56, "#ff9a7a", lt)

B.save(c, NAME)
