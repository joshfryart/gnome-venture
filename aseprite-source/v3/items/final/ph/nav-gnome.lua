-- nav-gnome (final pass, Opus). A gnome's head: tall slim felt hat whose tip flops over to the right, rolled
-- felt cuff, rosy face with small pill eyes and a big round lit nose, moustache curls and a long pointed beard
-- with twisted strand lines. Per-pixel light: cone tube for the hat (felt weave diagonals), cylinder cuff, sphere
-- nose, pillow face and beard; ambient dark under the cuff and under the nose.
-- quirk: a little brass bell hangs from the drooping hat tip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_2.lua")
local HP, X, K = A.HP, A.X, A.K
local abs, max, min, floor = math.abs, math.max, math.min, math.floor
local c = A.new("nav-gnome")
local RED  = { "#5e1a34", "#8e2438", "#c2333c", "#e8493b", "#ff7350", "#ffa070" }
local SKIN = { "#7a4036", "#a8604a", "#c98462", "#f0b98d", "#ffd2a8", "#ffe6c8" }
local NOSE = { "#7a3438", "#a84a4a", "#d26a5e", "#f08a78", "#ffb09a", "#ffd6c0" }
local BRD  = { "#4a4260", "#7a7392", "#a9a4bc", "#d2cfdc", "#ebe8ee", "#fbf8f0" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local tk = function(n) return { r = { name = n } } end

-- beard (behind face): pointed, slim, with a slight sway
local beard = c:poly{ { 18, 36 }, { 46, 36 }, { 44, 44 }, { 39, 51 }, { 33, 57 }, { 30, 55 }, { 24, 48 }, { 19, 42 } }
local bn = A.body(beard, 32, 40, 14, 4, 0.5)
local bidx = A.shade(c, beard, bn, BRD, { tok = tk("beard"), amb = 0.14 })
-- twisted strands: curved diagonal grooves
beard:each(function(x, y)
  local s = (x - 32) * 0.55 + (y - 36) * 0.9 + abs(x - 32) * 0.35
  if y > 39 and (floor(s) % 4 == 0) and (x + y) % 3 ~= 0 then A.step(c, bidx, BRD, x, y, -1, tk("beard")) end
end)

-- face
local face = c:ellipse(32, 33, 11, 6)
local fbias = {}
local fidx = A.shade(c, face, A.body(face, 31, 32, 11, 4, 0.5), SKIN, { tok = tk("face"), amb = 0.1 })
-- cheeks
for _, p in ipairs{ { 23, 35 }, { 39, 35 } } do c:put(p[1], p[2], "#f5809f", tk("face")) c:put(p[1] + 1, p[2], "#f5809f", tk("face")) end
c:eyeSmall(26, 31) c:eyeSmall(37, 31)

-- moustache: two curls from under the nose
local function curl(pts)
  local m, n = HP.mask(), nil
  local mm = c:line(pts, 2)
  A.shade(c, mm, A.slab(mm, 1.2, 0, 0, 1), BRD, { tok = tk("mous"), amb = 0.2 })
  return mm
end
local mous = curl{ { 31, 38 }, { 27, 39 }, { 23, 38 }, { 22, 36 } }
mous:add(curl{ { 33, 38 }, { 37, 39 }, { 41, 38 }, { 42, 36 } })
-- ambient under moustache onto beard
beard:each(function(x, y) if mous:has(x, y - 1) and not mous:has(x, y) then A.step(c, bidx, BRD, x, y, -2, tk("beard")) end end)

-- nose: sphere
local nose = c:ellipse(32, 35, 3.5, 3)
local nn = X.sphere(31.6, 34.6, 3.5, nose)
local nidx = A.shade(c, nose, nn, NOSE, { tok = tk("nose"), amb = 0.1, wrap = 0.1 })
c:put(31, 33, "#fff4d6", tk("nose"))
-- nostril shade under nose
c:put(31, 38, NOSE[1], tk("nose")) c:put(33, 38, NOSE[1], tk("nose"))
-- face shade under the cuff
face:each(function(x, y) if y <= 29 then A.step(c, fidx, SKIN, x, y, -2, tk("face")) end end)

-- hat cone: tube from cuff up, tip flops to the right
local hp = { { 32, 27 }, { 31, 16 }, { 32, 8 }, { 43, 7 } }
local hm, hn, HT, HS, hidx = A.stem(c, hp, function(t)
  if t < 0.05 then return 14 end
  return 14 * (1 - t) ^ 1.25 + 0.6
end, RED, { tok = tk("hat"), amb = 0.1, wrap = 0.25, cut = c:rect(0, 26, 63, 63) })
-- felt weave: faint diagonal lines
hm:each(function(x, y) if (x + 2 * y) % 5 == 0 and HT[K(x, y)] > 0.12 and HT[K(x, y)] < 0.8 then A.step(c, hidx, RED, x, y, -1, tk("hat")) end end)
-- fold crease where the tip bends
for _, p in ipairs{ { 33, 12 }, { 34, 12 }, { 35, 13 } } do if hm:has(p[1], p[2]) then A.step(c, hidx, RED, p[1], p[2], -2, tk("hat")) end end
c:put(26, 20, RED[6], tk("hat")) c:put(26, 21, RED[6], tk("hat")) c:put(27, 18, RED[6], tk("hat"))

-- cuff: rolled band
local cuff = c:rrect(16, 24, 48, 29, 2)
local cn = {}
cuff:each(function(x, y) local s = (y - 26.5) / 3.6 cn[K(x, y)] = { A.norm(0, s, math.sqrt(math.max(0.05, 1 - s * s))) } end)
local pb = X.pillow(cuff, 3)
for k, v in pairs(cn) do local p = pb[k] cn[k] = { A.norm(v[1] * 0.6 + p[1] * 0.4, v[2] * 0.6 + p[2] * 0.4, v[3] * 0.6 + p[3] * 0.4) } end
local cidx = A.shade(c, cuff, cn, RED, { tok = tk("cuff"), amb = 0.12 })
-- seam line between cone and cuff
for x = 17, 47 do A.step(c, hidx, RED, x, 23, -2, tk("hat")) end
-- stitch on cuff hem (gold, 2 on 1 off)
c:stitch{ { 19, 28 }, { 45, 28 } }

-- quirk: bell on the floppy tip
local bell = c:ellipse(45, 10, 2, 2)
local bidx2 = A.shade(c, bell, X.sphere(44.6, 9.6, 2, bell), { "#6a3a1a", GOLD[1], GOLD[2], GOLD[3], GOLD[4], "#fff4d6" }, { tok = tk("bell") })
c:put(45, 12, "#51302b", tk("bell"))
c:put(44, 7, GOLD[1], tk("bell"))

A.save(c, "nav-gnome")
