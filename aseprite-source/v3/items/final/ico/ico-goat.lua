-- ico-goat (final, Opus). Side view facing right, standing: slim barrel body with a shaggy fringe under the belly,
-- four thin legs (far pair a step darker) on split hooves, a raised neck, a long wedge head with a pale muzzle,
-- floppy ear, back-swept ridged horn and a goatee. Light per pixel (6-tone cream fur, cool-violet shade).
-- Material: fur strands + shaggy fringe, horn growth ridges with a lit lip, hoof cleft, AO where legs and neck meet
-- the body, contact shadow under the head; goat eye = amber iris with a horizontal ink pupil bar.
-- quirk: a little brass bell on a red collar.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA5_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("ico-goat")
local FUR  = { "#3e2f4a", "#6c5c78", "#a1909e", "#cdbdba", "#ebdfd2", "#fdf4e6" }
local HORN = { "#3a2c38", "#5c4a52", "#83706f", "#ab9888", "#cfbea6", "#efe3cc" }
local HOOF = { "#2f2230", "#4a3542", "#6e5058" }
local NOSE = { "#7d2c5e", "#c26a86", "#e89aac" }
local RED  = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local ftok, htok = { r = { name = "fur" } }, { r = { name = "horn" } }

c:groundShadow(28, 50, 15, 1)

-- legs (far pair first, a step darker)
local function leg(x0, y0, y1, far, lean)
  local m = HP.mask()
  for y = y0, y1 do
    local t = (y - y0) / (y1 - y0)
    local dx = floor((lean or 0) * t + 0.5)
    local w = (t > 0.45 and t < 0.6) and 3 or 3   -- 3 px shaft
    for x = x0 + dx, x0 + dx + w - 1 do m:set(x, y) end
    if t > 0.42 and t < 0.56 then m:set(x0 + dx + w, y) end      -- knobbly knee / hock
  end
  local n = select(1, A.X.pillow(m, 1.4))
  local bias = {}
  if far then m:each(function(x, y) bias[K(x, y)] = -1 end) end
  local idx = A.shade(c, m, n, FUR, { tok = ftok, bias = bias, amb = 0.1, wrap = 0.3 })
  -- hoof: bottom 3 rows, cleft line on the front
  local hx0 = x0 + floor((lean or 0) + 0.5)
  for y = y1 - 2, y1 do for x = hx0, hx0 + 2 do
    local i = (x == hx0 and y < y1) and 3 or ((y == y1) and 1 or 2)
    if far then i = max(1, i - 1) end
    c:put(x, y, HOOF[i])
  end end
  c:put(hx0 + 1, y1, A.INK)
  return m, idx
end
local lFarB = leg(23, 36, 49, true, 0)
local lFarF = leg(33, 36, 49, true, 1)

-- tail (up-flicked tuft)
local tail, tn = A.oval(14.5, 26.5, 1.6, 3.0, -0.55)
A.shade(c, tail, tn, FUR, { tok = ftok, amb = 0.12, wrap = 0.3 })

-- body + shaggy belly fringe
local body, bn = A.oval(27.5, 31.5, 12.5, 6.2, -0.04)
for _, p in ipairs{ { 19, 37, 39 }, { 23, 38, 40 }, { 27, 38, 40 }, { 31, 38, 39 } } do
  for y = p[2], p[3] do local w = p[3] - y body:set(p[1], y) bn[K(p[1], y)] = { 0.2, 0.7, 0.68 }
    if w >= 1 then body:set(p[1] + 1, y) bn[K(p[1] + 1, y)] = { 0.3, 0.7, 0.65 } end end
end
local bbias = {}
local bidx = A.shade(c, body, bn, FUR, { tok = ftok, bias = bbias, amb = 0.08, wrap = 0.3 })
-- fur strands: short dark/light pairs following the coat (down-back diagonal)
for _, p in ipairs{ { 18, 31 }, { 22, 34 }, { 26, 32 }, { 30, 35 }, { 34, 33 }, { 21, 28 }, { 29, 29 }, { 24, 36 }, { 33, 30 }, { 17, 35 } } do
  if body:has(p[1], p[2]) and body:has(p[1] + 1, p[2] + 1) then
    A.step(c, bidx, FUR, p[1], p[2], -1, ftok) A.step(c, bidx, FUR, p[1] + 1, p[2] + 1, -1, ftok)
    if body:has(p[1] - 1, p[2]) then A.step(c, bidx, FUR, p[1] - 1, p[2], 1, ftok) end
  end
end
-- near legs (over the fringe), AO at the top where they leave the body
local lNearB, iB = leg(19, 36, 49, false, -1)
local lNearF, iF = leg(37, 35, 49, false, 1)
for _, L in ipairs{ { lNearB, iB }, { lNearF, iF } } do
  local bb = L[1]:bbox()
  L[1]:each(function(x, y) if y <= 39 and y >= 37 then A.step(c, L[2], FUR, x, y, -1, ftok) end end)
end

-- neck (tube rising to the head), AO where it joins the shoulder
local nm, nn, NT, NS = A.tube({ { 36, 30 }, { 38, 27 }, { 40, 24 }, { 42.5, 21 } }, function(t) return 4.2 - t * 1.2 end)
local nb = {}
nm:each(function(x, y) local k = K(x, y) if NT[k] < 0.12 then nb[k] = -1 end end)
local nidx = A.shade(c, nm, nn, FUR, { tok = ftok, bias = nb, amb = 0.08, wrap = 0.3 })

-- ear behind the head (floppy, pointing back-down)
local ear, en = A.oval(39.4, 19.8, 3.6, 1.6, 0.38)
local eidx = A.shade(c, ear, en, FUR, { tok = ftok, amb = 0.14, wrap = 0.35 })
for _, p in ipairs{ { 37, 20 }, { 38, 20 }, { 39, 20 }, { 39, 21 }, { 40, 21 } } do if ear:has(p[1], p[2]) then c:put(p[1], p[2], NOSE[2], ftok) end end

-- horn (behind head top): back-swept, ridged
local hm, hn, HT, HS = A.tube({ { 43.5, 17.5 }, { 42.5, 11 }, { 38, 8 }, { 34.5, 10.5 } }, function(t) return 1.9 - t * 1.05 end)
local hidx = A.shade(c, hm, hn, HORN, { tok = htok, amb = 0.1, wrap = 0.3 })
local HL = 0 do local px, py for i = 0, 40 do local x, y = A.bez({ { 43.5, 17.5 }, { 42.5, 11 }, { 38, 8 }, { 34.5, 10.5 } }, i / 40) if px then HL = HL + sqrt((x - px)^2 + (y - py)^2) end px, py = x, y end end
hm:each(function(x, y) local k = K(x, y)
  local d = (HT[k] * HL) % 2.6
  if HT[k] > 0.12 and HT[k] < 0.85 then
    if d < 0.9 then A.step(c, hidx, HORN, x, y, -2, htok) elseif d < 1.8 then A.step(c, hidx, HORN, x, y, 1, htok) end
  end
end)

-- head: long wedge, muzzle at the lower-right tip
local head, hdn = A.oval(45.3, 21.3, 5.4, 3.5, 0.58)
local mz, mzn = A.oval(49.2, 25.0, 2.6, 2.3, 0.4)
head:add(mz) for k, v in pairs(mzn) do hdn[k] = v end
local hb = {}
-- contact shadow on the neck under the jaw
local hidx2 = A.shade(c, head, hdn, FUR, { tok = ftok, bias = hb, amb = 0.2, wrap = 0.5 })
A.aoRing(c, eidx, FUR, ear, head, -2, ftok)
head:shift(0, 1):each(function(x, y) if nm:has(x, y) and not head:has(x, y) then A.step(c, nidx, FUR, x, y, -1, ftok) end end)
-- horn base sits in the skull: dark socket row
for _, p in ipairs{ { 42, 18 }, { 43, 18 }, { 44, 17 } } do if head:has(p[1], p[2]) then A.step(c, hidx2, FUR, p[1], p[2], -2, ftok) end end
-- muzzle: soft pink nose pad + ink nostril, mouth line
c:put(51, 24, NOSE[2]) c:put(51, 25, NOSE[1]) c:put(50, 24, NOSE[3])
c:put(52, 24, A.INK) c:put(51, 23, A.CREAM)
c:put(50, 27, FUR[2]) c:put(49, 27, FUR[2]) c:put(51, 26, FUR[3])
-- goatee (hangs from the chin)
local beard = c:poly{ { 46, 26 }, { 49, 27 }, { 47.5, 33 } }
local brn = X.pillow(beard, 1.2)
local bdx = A.shade(c, beard, brn, FUR, { tok = ftok, amb = 0.22, wrap = 0.45 })
for y = 28, 32 do if beard:has(47, y) then A.step(c, bdx, FUR, 47, y, -1, ftok) end end
-- eye: amber iris, horizontal ink pupil bar, cream glint, heavy lid above
A.map(c, { "lll", "gaa", "KKa", "aab" }, 44, 18, { l = FUR[3], g = A.CREAM, a = "#eaa82a", b = "#b8761c", K = A.INK })

-- collar (red band across the neck) + brass bell, quirk
nm:each(function(x, y) local k = K(x, y)
  if NT[k] > 0.3 and NT[k] < 0.46 then
    local i = NS[k] < -0.4 and 4 or (NS[k] < 0.3 and 3 or (NS[k] < 0.75 and 2 or 1))
    c:put(x, y, RED[i])
  end end)
A.map(c, {
  ".k.",
  "hgb",
  "gbs",
  "bsd",
  ".K.",
}, 40, 28, { k = GOLD[1], h = GOLD[4], g = GOLD[3], b = GOLD[2], s = GOLD[2], d = GOLD[1], K = A.INK })
c:put(41, 32, GOLD[1])

A.save(c, "ico-goat")
