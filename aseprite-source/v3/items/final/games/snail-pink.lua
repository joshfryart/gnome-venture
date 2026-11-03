-- snail-pink (final pass, Opus single pass). Right-facing, stretched up tall to look at something: a broad conical
-- top-shell of four stepped whorls (flat base, sloping sides, leaning back), each whorl a lit ellipsoid with a dark
-- suture where the next sits on it, a plum spiral band and a pale cream band running round every whorl; slim peach
-- foot with skin furrows, frilled sole, a wet glint up the neck, AO + contact shadow under the shell.
-- quirk: its slime trail ends in a tiny glossy pink heart.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA0_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("snail-pink")
local BODY = { "#6a3a46", "#9c5e64", "#c88a82", "#e6b09e", "#f6d0be", "#fff0e2" }
local SHELL = { "#5e1f45", "#8e2e5e", "#c24a7e", "#e8709b", "#f9a2bf", "#ffd3e0" }
local BAND = { "#4a1a42", "#6e2558", "#96336e", "#bc4a86", "#dc6ea2", "#f096be" }
local PALE = { "#8a4a62", "#b8707e", "#e0a0a4", "#f6c8bc", "#ffe2d2", "#fff4e6" }
local btok, stok = { r = { name = "body" } }, { r = { name = "shell" } }

c:groundShadow(32, 57, 21, 1.5)
-- foot: tail lower-left, along the ground, neck rising steeply to a raised head
local foot = { { 16, 54 }, { 30, 56.5 }, { 44, 55 }, { 47, 35 } }
local hw = function(t)
  if t < 0.3 then return 0.6 + 2.6 * (t / 0.3) ^ 0.8 end
  return 3.2 + (t - 0.3) * 0.9
end
local head = c:ellipse(48.5, 32.5, 3.6, 3.6)
local hn = X.sphere(47.6, 31.6, 4.2, head)
local BCUT = { 0.3, 0.48, 0.64, 0.79, 0.92 }
local bm, bn, BT, BS, bidx = A.foot(c, foot, hw, BODY, { tok = btok, add = { { head, hn, 1 } }, cuts = BCUT, amb = 0.05, wrap = 0.2 })
A.skin(c, bm, bidx, BODY, btok, { s1 = 5, s2 = 6 })
A.sole(c, bm, BODY, 15, 49, btok)
-- eye stalks reaching up and forward
A.stalk(c, 47, 30, 47, 18, BODY, btok, 1)
A.stalk(c, 50, 30, 55, 21, BODY, btok, 1)
-- lower feelers + mouth on the front of the head
c:put(53, 34, BODY[3], btok) c:put(54, 35, BODY[2], btok)
c:put(52, 35, BODY[1], btok) c:put(51, 36, BODY[2], btok)
-- wet glint streak up the lit side of the neck
for _, p in ipairs{ { 44, 46 }, { 44, 44 }, { 45, 41 } } do if bm:has(p[1], p[2]) then c:put(p[1], p[2], BODY[6], btok) end end

-- shell: four whorls, base first, each lit as an ellipsoid; upper whorls sit on (and shade) the lower ones
local whorls = {
  { 27.5, 44.5, 11.2, 6.0 },
  { 25.8, 38.2, 8.8, 4.7 },
  { 24.2, 33, 6.4, 3.6 },
  { 22.9, 29.1, 4.0, 2.6 },
  { 22, 26.3, 1.8, 1.5 },
}
local all = HP.mask()
local wm, widx = {}, {}
for i, w in ipairs(whorls) do
  local m, n = A.oval(w[1], w[2], w[3], w[4], -0.12, 1.1)
  local nP = X.pillow(m, 3)
  n = A.blend(n, nP, 0.35)
  -- cone sides face up and out: tilt every normal toward the light-side top
  for k, v in pairs(n) do n[k] = { A.norm(v[1], v[2] * 0.55 - 0.32, v[3]) } end
  local bias = {}
  local idx = A.shade(c, m, n, SHELL, { amb = 0.14, wrap = 0.35, tok = stok, bias = bias })
  -- spiral bands: plum band low on the whorl, pale band just above it
  if i <= 4 then
    m:each(function(x, y) local k = K(x, y)
      local v = (y + 0.5 - w[2]) / (w[4] + 0.5) + (x - w[1]) * 0.12 / w[3]
      if v > 0.5 and v < 0.78 then c:put(x, y, BAND[idx[k]], stok)
      elseif v > 0.05 and v <= 0.22 and i <= 3 then c:put(x, y, PALE[idx[k]], stok) end
    end)
  end
  -- suture + contact shadow on the lower whorl where this one sits
  if i > 1 then
    local below = wm[i - 1]
    m:edge():each(function(x, y)
      if below:has(x, y + 1) and not m:has(x, y + 1) then c:put(x, y + 1, SHELL[1], stok)
        if below:has(x + 1, y + 2) and not m:has(x + 1, y + 2) then A.step(c, widx[i - 1], SHELL, x + 1, y + 2, -1, stok) end end
    end)
  end
  wm[i], widx[i] = m, idx
  all:add(m)
end
-- growth ribs: short slanted lines down the base whorl
wm[1]:each(function(x, y) local k = K(x, y)
  if not wm[2]:has(x, y) and (x * 2 - y) % 5 == 0 and widx[1][k] and widx[1][k] >= 3 and y > 41 then
    local cur = c:get(x, y) if cur then A.step(c, widx[1], SHELL, x, y, 0, stok) end
    c:put(x, y, (y > whorls[1][2] + 1) and BAND[max(1, widx[1][k] - 1)] or SHELL[max(1, widx[1][k] - 1)], stok)
  end end)
-- AO on the foot under the shell
bm:each(function(x, y) if not all:has(x, y) then
  if all:has(x, y - 1) or all:has(x - 1, y - 1) then A.step(c, bidx, BODY, x, y, -2, btok)
  elseif all:has(x, y - 2) or all:has(x - 1, y) then A.step(c, bidx, BODY, x, y, -1, btok) end end end)
-- cool reflected light on the lower-right of the base whorl
wm[1]:edge():each(function(x, y) if x > 32 and y > 45 and not bm:has(x, y + 1) then c:put(x, y, "#a8789c", stok) end end)
-- glossy specular on the second whorl + cream glint
c:put(19, 35, SHELL[6], stok) c:put(20, 35, SHELL[6], stok) c:put(19, 34, A.CREAM, stok)
c:put(17, 42, SHELL[6], stok)

-- quirk: slime trail behind the tail, ending in a little glossy heart
local SL = { a = "#ffc4d8", b = "#f08aa8", c = "#fff4d6", d = "#c95a86" }
A.map(c, {
  "ca.ab",
  "aaabd",
  ".abd.",
  "..d..",
}, 9, 53, SL, { r = { name = "slime" } })
c:put(15, 56, "#b6e6e0", { r = { name = "slime" } })
A.save(c, "snail-pink", "games")
