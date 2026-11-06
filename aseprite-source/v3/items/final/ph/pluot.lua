-- pluot (aC35_3 final, Opus single pass). One slightly tall pluot (plum x apricot): per-pixel sphere light on a
-- 6-tone chartreuse skin with a dappled rosy-red blush washing over the lit shoulder, pale lenticel freckles on the
-- blush, a shallow suture crease down the left cheek, waxy bloom specks on the shade side, cool reflected light on the
-- lower-right rim and one glossy specular. Slim woody stalk set into a dark stem cavity (AO), one serrated plum leaf
-- with midrib and veins. History: Sonnet draft replaced.
-- quirk: a tiny ladybird is walking along the leaf.
local NAME = "pluot"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, cos, pi, atan = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi, math.atan
local c = A.new(NAME)
local GRN  = { "#2c4a3a", "#3f6e3c", "#5f9640", "#8cba48", "#b8d65c", "#e2ee8a" }
local RED  = { "#3a1236", "#621c48", "#8e2a58", "#bb3c62", "#e0607a", "#f8949a" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM = { "#3a2622", "#5b3e2e", "#81603f", "#a8844f" }
local BLOOM, COOL = "#b9c6c8", "#6c7fa8"

local CX, CY, RX, RY = 31.5, 37.5, 11.5, 13.5
-- stalk (behind the fruit top)
local stok = A.tok("stalk")
A.stem(c, { { 32, 27 }, { 32, 22 }, { 33, 19 }, { 35, 16 } }, function(t) return 1.2 - 0.3 * t end, STEM, { tok = stok })
c:put(35, 15, STEM[3], stok) c:put(36, 15, STEM[4], stok)          -- pale snapped end

-- leaf off the stalk, up and to the right
local ltok = A.tok("leaf")
local lm, LT, LS, lidx = A.leaf(c, 35, 17, 44, 8, 56, 11, 4.0, LEAF, { tok = ltok, vs = 2.6, pw = 0.7 })
-- serration: notch every 3 px along the upper edge
lm:edge():each(function(x, y) local k = K(x, y)
  if LS[k] and LS[k] < -0.6 and LT[k] > 0.15 and LT[k] < 0.9 and (x % 3 == 0) then c:put(x, y, LEAF[min(6, (lidx[k] or 4) + 1)], ltok) end end)

-- body: slightly tall sphere with a cleft at the stem end
local body = HP.ellipse(CX, CY, RX, RY)
for _, p in ipairs{ { 31, 23 }, { 32, 23 }, { 30, 23 }, { 33, 23 } } do body.s[K(p[1], p[2])] = nil end
local n = X.sphere(CX - 0.8, CY - 0.8, max(RX, RY), body)
local v = X.light(n, { amb = 0.05, wrap = 0.2 })
local bias = {}
-- stem cavity AO + suture crease (left cheek, curving down)
for _, p in ipairs{ { 30, 24 }, { 31, 24 }, { 32, 24 }, { 33, 24 }, { 31, 25 }, { 32, 25 } } do bias[K(p[1], p[2])] = -2 end
local sut = {}
for i = 0, 40 do local t = i / 40
  local x, y = A.bez({ { 30, 25 }, { 24, 29 }, { 22, 38 }, { 26, 47 } }, t)
  local xi, yi = floor(x + .5), floor(y + .5)
  sut[K(xi, yi)] = true bias[K(xi + 1, yi)] = (bias[K(xi + 1, yi)] or 0) + 1
end
for k in pairs(sut) do bias[k] = (bias[k] or 0) - 2 end
local idx = X.tone(c, body, v, GRN, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, bias = bias })
-- blush: dappled region over the upper-left / centre, fading in patches toward the lower right
local btok = A.tok("skin")
body:each(function(x, y) local k = K(x, y)
  local dx, dy = (x - CX) / RX, (y - CY) / RY
  local f = 0.55 - 0.55 * dx - 0.35 * dy + 0.45 * sin(x * 0.9 + y * 0.4) * cos(y * 0.7 - x * 0.3)
  local h = X.hash(x, y, 7)
  local i = idx[k] or 3
  if f + (h - 0.5) * 0.5 > 0.5 then
    c:put(x, y, RED[i], btok)
    if h < 0.07 and i >= 3 and i <= 5 and not sut[k] then c:put(x, y, GRN[min(6, i + 2)], btok) end   -- lenticel freckle
  else
    c:put(x, y, GRN[i], btok)
    if h > 0.95 and i <= 4 and i >= 2 then c:put(x, y, RED[i], btok) end                           -- stray dapple
    if h < 0.06 and i <= 3 then c:put(x, y, BLOOM, btok) end                                        -- waxy bloom
  end
end)
-- cool reflected light lower-right rim
local rim = X.rim(n)
body:edge():each(function(x, y) if (rim[K(x, y)] or 0) > 0.72 then c:put(x, y, COOL, btok) end end)
-- specular + halo
local sx, sy = 24, 30
c:put(sx, sy, "#fff4d6", btok) c:put(sx + 1, sy, "#fff4d6", btok) c:put(sx, sy + 1, "#ffd8b8", btok)

-- quirk: ladybird on the leaf
local lb = {
  ".k.",
  "rkr",
  "rrr",
}
local LB = { k = "#2b1c26", r = "#e8493b" }
for j, row in ipairs(lb) do for i = 1, #row do local ch = row:sub(i, i)
  if LB[ch] then c:put(47 + i, 6 + j, LB[ch], ltok) end end end
c:put(48, 8, "#ff9a7c", ltok) c:put(50, 9, "#2b1c26", ltok)
A.save(c, NAME)
