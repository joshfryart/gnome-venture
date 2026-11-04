-- pigeon-pea (final, Opus C34-5). A slim, flat pigeon-pea pod lying on the diagonal (stalk lower-left, beaked tip
-- upper-right), swelling over four seeds with pinched waists between them, maroon streaks on green; two loose
-- seeds below it, tan-cream with maroon speckles and a pale hilum eye.
-- Material: per-pixel tube light (6-tone green), seed swellings lit as bumps with AO in the waists, a raised suture
-- seam (dark groove + lit lip) along the upper edge, a fine bloom of pale specks, waxy specular, cool reflected light
-- lower-right; calyx of pointed sepals at the stalk with AO; seeds as lit spheres with a contact shadow.
-- quirk: a tiny pod-borer caterpillar peeks out of a hole in the pod.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("pigeon-pea")

local POD  = { "#1c3e34", "#28583c", "#3a7442", "#56924a", "#7cb256", "#a8cc6c" }
local MAR  = { "#3e1830", "#62203c", "#8a3448" }
local SEED = { "#5a3a2c", "#866044", "#b08a5e", "#d0ac7a", "#e8cc9c", "#f8e6c2" }
local CAL  = { "#1a3a30", "#2a5438", "#3e7040", "#5a8e48" }
local SPEC, BOUNCE = "#f4ffe0", "#6e9aa8"

-- pod
local p = { { 15, 45 }, { 21, 31 }, { 34, 20 }, { 50, 15 } }
local SEEDS = { 0.2, 0.4, 0.6, 0.79 }
local function hw(t)
  local b = 0
  for _, s in ipairs(SEEDS) do local d = (t - s) / 0.095 if abs(d) < 1 then b = max(b, cos(d * pi / 2) ^ 2) end end
  local base = 2.6 + 1.5 * b
  if t < 0.07 then base = base * (0.55 + t / 0.07 * 0.45) end
  if t > 0.88 then base = base * max(0.12, 1 - (t - 0.88) / 0.12) ^ 0.8 end
  return base
end
local pm, pn, PT, PS, samp = A.tube(p, hw)
-- bump normals over each seed
for k, n in pairs(pn) do
  local t = PT[k]
  for _, s in ipairs(SEEDS) do
    local d = (t - s) / 0.095
    if abs(d) < 1 then
      local i = floor(t * 160) + 1
      local tx, ty = samp[i].tx, samp[i].ty
      local a = -sin(d * pi) * 0.45
      pn[k] = { A.norm(n[1] + tx * a, n[2] + ty * a, n[3]) }
    end
  end
end
local bias = {}
for k, _ in pairs(pn) do
  local t, s = PT[k], PS[k]
  local nearest = 1
  for _, q in ipairs(SEEDS) do nearest = min(nearest, abs(t - q)) end
  if nearest > 0.085 and t > 0.1 and t < 0.86 and s > -0.2 then bias[k] = -1 end -- waist AO
end
local ptok = { r = { name = "pod" } }
local idx = A.lit(c, pm, pn, POD, { tok = ptok, bias = bias, cuts = { 0.2, 0.37, 0.54, 0.7, 0.86 } })
-- suture seam along the upper (lit) edge: groove + lip
pm:each(function(x, y) local k = K(x, y) local s, t = PS[k], PT[k]
  if t > 0.05 and t < 0.9 then
    if s > -0.66 and s < -0.46 then c:put(x, y, POD[max(1, idx[k] - 2)], ptok)
    elseif s <= -0.8 then c:put(x, y, POD[min(6, idx[k] + 1)], ptok) end
  end
end)
-- maroon streaks: short slanted strokes across the pod
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i - 1].x) ^ 2 + (samp[i].y - samp[i - 1].y) ^ 2) end
pm:each(function(x, y) local k = K(x, y) local s, t = PS[k], PT[k]
  for _, st in ipairs{ 0.13, 0.31, 0.47, 0.52, 0.69, 0.84 } do
    local d = (t - st) * LEN - s * 1.6
    if d > -0.5 and d < 0.5 and s > -0.35 and s < 0.75 then c:put(x, y, MAR[idx[k] >= 4 and 3 or (idx[k] >= 2 and 2 or 1)], ptok) end
  end
end)
-- bloom specks
pm:each(function(x, y) local k = K(x, y) if X.hash(x, y, 3) > 0.93 and idx[k] >= 3 and idx[k] <= 5 and PS[k] > -0.4 then c:put(x, y, POD[min(6, idx[k] + 1)], ptok) end end)
-- cool reflected light lower-right edge
local rim = X.rim(pn)
pm:edge():each(function(x, y) local k = K(x, y) if PS[k] > 0.8 and rim[k] > 0.6 and PT[k] > 0.15 and PT[k] < 0.85 then c:put(x, y, BOUNCE, ptok) end end)
-- specular on the second seed bump
do local s = samp[floor(0.4 * 160) + 1]
  c:put(floor(s.x + s.px * s.w * -0.3 + .5), floor(s.y + s.py * s.w * -0.3 + .5), SPEC, ptok)
  c:put(floor(s.x + s.px * s.w * -0.3 + 1.5), floor(s.y + s.py * s.w * -0.3 + .5), POD[6], ptok) end
-- beak: dry tip
do local s = samp[#samp] c:put(floor(s.x + .5), floor(s.y + .5), MAR[2], ptok) c:put(floor(s.x + 1.5), floor(s.y - .5), MAR[1], ptok) end

-- calyx: pointed sepals clasping the base + short stalk with a pale cut end
local ctok = { r = { name = "calyx" } }
local cm = HP.mask()
for _, sp in ipairs{ { 15, 44, 19, 40 }, { 14, 45, 20, 44 }, { 15, 45, 18, 48 } } do cm:add(c:line({ { sp[1], sp[2] }, { sp[3], sp[4] } }, 2)) end
cm:add(c:ellipse(15, 45, 2, 2))
local cn = X.pillow(cm, 1.5)
A.lit(c, cm, cn, { CAL[1], CAL[2], CAL[3], CAL[3], CAL[4], "#7aa858" }, { tok = ctok })
c:put(18, 41, CAL[1], ctok) c:put(19, 44, CAL[1], ctok)
local sm = c:line({ { 13, 47 }, { 11, 49 }, { 10, 51 } }, 2)
sm:each(function(x, y) c:put(x, y, (x + y) % 2 == 0 and CAL[3] or CAL[2], ctok) end)
c:put(10, 52, "#c8d88c", ctok) c:put(11, 52, "#a8c070", ctok)

-- quirk: pod-borer caterpillar peeking from a hole on the 3rd seed bump
do local s = samp[floor(0.6 * 160) + 1]
  local hx, hy = floor(s.x + s.px * s.w * 0.15 + .5), floor(s.y + s.py * s.w * 0.15 + .5)
  c:put(hx, hy, "#1e2a24", ptok) c:put(hx + 1, hy, "#1e2a24", ptok) c:put(hx, hy + 1, "#2a3a2c", ptok)
  -- caterpillar: 2 segments out of the hole + head with eye
  c:paint({
    ".hHh",
    "bbHe",
    "ab..",
  }, hx + 1, hy - 1, { h = "#d8a868", H = "#f0c888", e = "#2b1c26", b = "#b48450", a = "#7c5434" })
end

-- loose seeds (lower right), contact shadow between
local stok = { r = { name = "seed" } }
local function seed(cx, cy, ang)
  local m, n = A.oval(cx, cy, 3.4, 2.9, ang)
  A.lit(c, m, n, SEED, { tok = stok, cuts = { 0.18, 0.36, 0.54, 0.7, 0.86 } })
  m:each(function(x, y) if X.hash(x, y, 11) > 0.84 then c:put(x, y, MAR[X.hash(x, y, 2) > 0.5 and 3 or 2], stok) end end)
  -- hilum: pale eye with a dark rim, on the shade side
  local hx, hy = floor(cx + 1.2 * cos(ang) + 0.5), floor(cy + 1.2 * sin(ang) + 0.5)
  c:put(hx, hy, "#fff2d8", stok) c:put(hx, hy + 1, "#fff2d8", stok) c:put(hx + 1, hy, SEED[2], stok) c:put(hx + 1, hy + 1, SEED[1], stok)
  c:put(floor(cx - 1.6), floor(cy - 1.6), "#fff8e8", stok)
  return m
end
local s1 = seed(43, 46, 0.4)
local s2 = seed(50.5, 42, -0.6)
-- contact shadow: s1 under s2's lower-left
s2:shift(-1, 1):each(function(x, y) if s1:has(x, y) and not s2:has(x, y) then c:put(x, y, SEED[1], stok) end end)
A.fin(c)
