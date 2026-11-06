-- pickled-turnips (final, Opus C34-5). A round-bellied clip-top jar: domed glass lid, orange rubber seal with its
-- pull tab, and a steel wire bail with hinge loops. Inside, beet-dyed magenta turnip batons (paler cut ends) lean in
-- rosy brine with a dark beet slice, a garlic clove and a bay leaf.
-- Material: per-pixel lit brine (surface of revolution), glass wall, thick base, streaks, meniscus, domed lid with its
-- own rim light; batons as lit rods with cut faces; beet slice with growth rings; bay leaf midrib; wire bevel with a
-- bright edge; rubber with a dull sheen; AO where batons cross and on the base.
-- quirk: a little paper tag on string hangs from the bail, a tiny turnip doodled on it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.max, math.min, math.sqrt
local c = A.new("pickled-turnips")

local GL    = { "#33405e", "#566c92", "#8aa6c2", "#bcd8e0", "#ddf0f0", "#f2fbf8" }
local BRINE = { "#7c2c5e", "#a2427a", "#c2629a", "#da86b2", "#eaaac8", "#f6cede" }
local AIR   = { "#808ca8", "#a4b2c8", "#c6d4de", "#dce8ea", "#ebf4f2", "#f4faf6" }
local MAG   = { "#3e0e3a", "#661650", "#92206a", "#ba3484", "#dc5aa0", "#f28cc0" }
local CUT   = { "#b0487e", "#d070a0", "#ec9cc0", "#fac4da" }
local BEET  = { "#2a0a24", "#4a1036", "#6e1846", "#922a58" }
local GARL  = { "#9a8070", "#c4aa92", "#e2ceb4", "#f4e6cc", "#fff4e0" }
local BAY   = { "#283a24", "#3e5430", "#58703a", "#788e48", "#9aaa5c" }
local WIRE  = { "#3c3e58", "#6a6c86", "#a2a2b6", "#d4d4de", "#f0f0f4" }
local RUB   = { "#7a2a14", "#b84a1c", "#e2702a", "#f89a48", "#ffc078" }
local TAG   = { "#8a7a68", "#c2b096", "#e6d8bc", "#f8eed6" }

c:groundShadow(32, 56, 13, 1)
-- body: neck then round belly
local J = A.jar(32, 24, 56, function(y)
  if y <= 26 then return 9.2 end
  local t = (y - 40.5) / 16.2
  return max(9.2, 14.2 * sqrt(max(0, 1 - t * t)) ^ 0.85)
end)
A.back(c, J, BRINE, AIR, 30)
local IN = J.inner:copy()
local tok = { r = { name = "turnip" } }
local tint = function(r) return A.tint(r, "#f0a8c8", 0.08) end
local M2, C2 = tint(MAG), tint(CUT)

-- bay leaf at the back, leaning
do
  local m, n, T, S = A.rod(c, 22, 50, 29, 31, 1.9, tint(BAY), IN, { tok = tok })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.25 and T[k] > 0.08 and T[k] < 0.9 then c:put(x, y, BAY[5], tok) end end)
end
-- baton: lit rod + pale cut face at the top end
local function baton(ax, ay, bx, by, w)
  local m, n, T, S = A.rod(c, ax, ay, bx, by, w, M2, IN, { tok = tok })
  m:each(function(x, y) local k = K(x, y)
    if T[k] > 0.93 then c:put(x, y, C2[S[k] < 0 and 4 or 3], tok) elseif T[k] > 0.88 then c:put(x, y, C2[1], tok) end
    if T[k] < 0.06 then c:put(x, y, M2[2], tok) end
  end)
  return m
end
local b1 = baton(38, 53, 40, 30, 2.1)
local b2 = baton(26, 53, 31, 29, 2.1)
-- beet slice: dark disc with rings, seen at an angle
do
  local m = c:ellipse(39, 47, 4.6, 3.6) m:clip(IN)
  local n = X.sphere(38.7, 46.7, 4.6, m)
  local idx = A.lit(c, m, n, { BEET[1], BEET[2], BEET[2], BEET[3], BEET[4], "#b04070" }, { tok = tok })
  m:each(function(x, y) local d = sqrt(((x + 0.5 - 39) / 4.6) ^ 2 + ((y + 0.5 - 47) / 3.6) ^ 2)
    if abs(d - 0.55) < 0.12 then c:put(x, y, "#c04e80", tok) end end)
  c:put(39, 47, "#c04e80", tok)
end
local b3 = baton(33, 54, 34, 27, 2.3)
local b4 = baton(29, 54, 24, 34, 2.0)
local b5 = baton(42, 54, 44, 37, 1.8)
-- AO where batons cross: front baton casts a 1px shadow on what is behind it to the lower right
local function shadowOn(front)
  front:shift(1, 0):each(function(x, y) if not front:has(x, y) and IN:has(x, y) and c:get(x, y) then
    local h = c:get(x, y)
    for i = 2, 6 do if M2[i] == h then c:put(x, y, M2[i - 1], tok) end end
  end end)
end
shadowOn(b3) shadowOn(b4)
-- garlic clove at the bottom front
do
  local m = c:ellipse(28.5, 51.5, 3, 2.2) m:clip(IN)
  local n = X.sphere(28.2, 51.2, 3, m)
  A.lit(c, m, n, { GARL[1], GARL[2], GARL[3], GARL[4], GARL[5], "#fffaf0" }, { tok = tok })
  c:put(30, 50, GARL[3], tok) c:put(31, 50, GARL[2], tok)
end

local GT = A.front(c, J, GL, { menisc = { BRINE[6], BRINE[5] }, s0 = 29, s1 = 51, gaps = { [44] = true }, r0 = 31, r1 = 37, wide = 10 })
-- neck rim bead
for x = 22, 42 do if J.m:has(x, 26) then c:put(x, 26, x < 32 and GL[5] or GL[3], GT) end end

-- domed glass lid
local lid = HP.mask()
for y = 16, 23 do local h = (y >= 21) and 10.4 or 10.4 * sqrt(max(0, 1 - ((21 - y) / 5.6) ^ 2)) + 0.4
  for x = floor(32 - h), floor(32 + h) do if abs(x + 0.5 - 32) <= h then lid:set(x, y) end end end
local ln = X.pillow(lid, 4)
local ltok = { r = { name = "lid" } }
local li = A.lit(c, lid, ln, AIR, { tok = ltok, cuts = { 0.15, 0.32, 0.5, 0.68, 0.84 }, amb = 0.2, wrap = 0.4 })
lid:edge():each(function(x, y) c:put(x, y, x < 30 and GL[5] or GL[2], ltok) end)
for x = 22, 42 do if lid:has(x, 23) then c:put(x, 23, x < 32 and GL[4] or GL[2], ltok) end end
c:put(26, 18, GL[6], ltok) c:put(27, 18, GL[6], ltok) c:put(25, 19, GL[6], ltok)
-- rubber seal ring + pull tab (left)
local rtok = { r = { name = "rubber" } }
for x = 21, 43 do c:put(x, 24, RUB[x < 28 and 4 or (x > 38 and 2 or 3)], rtok) c:put(x, 25, RUB[x < 30 and 3 or 2], rtok) end
c:put(21, 24, RUB[3], rtok) c:put(43, 24, RUB[2], rtok)
c:paint({ "edd", "cccb", "bba" }, 17, 24, { e = RUB[5], d = RUB[4], c = RUB[3], b = RUB[2], a = RUB[1] })
c:put(18, 24, RUB[5])
-- wire bail: over the lid top, down both sides to hinge loops on the neck
local wtok = { r = { name = "wire" } }
local function wire(pts, lit) local m = c:line(pts, 1) m:each(function(x, y) c:put(x, y, WIRE[lit], wtok) end) return m end
wire({ { 26, 15 }, { 38, 15 } }, 4)
wire({ { 25, 16 }, { 23, 18 }, { 23, 22 } }, 3) wire({ { 39, 16 }, { 41, 18 }, { 41, 22 } }, 2)
c:put(26, 15, WIRE[5]) c:put(27, 15, WIRE[5]) c:put(38, 15, WIRE[3])
-- lever + hinge loops below the seal
wire({ { 22, 26 }, { 22, 29 } }, 3) wire({ { 42, 26 }, { 42, 29 } }, 2)
c:paint({ "ab", "cd" }, 21, 26, { a = WIRE[4], b = WIRE[3], c = WIRE[2], d = WIRE[1] })
c:paint({ "ba", "dc" }, 42, 26, { a = WIRE[2], b = WIRE[3], c = WIRE[1], d = WIRE[1] })
c:put(22, 30, WIRE[2]) c:put(42, 30, WIRE[1])
-- glint on the belly
c:put(23, 37, "#fbfff8")

-- quirk: paper tag on a string from the right bail, a tiny turnip doodle
local qtok = { r = { name = "tag" } }
c:put(42, 19, TAG[2], qtok) c:put(43, 20, TAG[2], qtok) c:put(44, 21, TAG[2], qtok) c:put(45, 22, TAG[1], qtok)
c:paint({
  ".bccb.",
  "bdddcb",
  "bdgdcb",
  "bdpdcb",
  "bdddca",
  "bcccca",
  ".aaaa.",
}, 43, 23, { a = TAG[1], b = TAG[2], c = TAG[3], d = TAG[4], g = "#5aa04a", p = "#9a4ea8" })
c:put(45, 23, "#6a5a4c")
A.fin(c)
