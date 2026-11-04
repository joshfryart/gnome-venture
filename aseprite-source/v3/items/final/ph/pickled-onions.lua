-- pickled-onions (C34, Opus artist pass). Round-bellied swing-top jar: domed glass lid, orange rubber seal with its
-- pull tab, a steel wire bail (lit edge + shade pixel) clamped by a lever on the shoulder. Inside, pearl onions in
-- rosy wine brine: 6-tone ellipsoid light, papery layer lines following the curve, pointed tops, rooty bases,
-- one wet glint each; a bay leaf (midrib + veins) and peppercorns tucked behind.
-- quirk: the top onion has bobbed up to the surface and is sprouting a little green curl.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_4.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("pickled-onions")

local ON  = { "#4e3a66", "#7e6496", "#ac94c0", "#d6c8e0", "#f2e8ee", "#fffbf0" }
local ONB = { "#4c3a5a", "#766486", "#9e8eaa", "#c2b8c8", "#dcd4dc", "#eee8ea" } -- back row, a touch dimmer
local TIP = { "#5a4a32", "#86704a", "#ae9a64", "#cdbe84", "#e6dca6", "#f8f2cc" }
local BRINE = { "#7a3a52", "#a85a6a", "#cc7c84", "#e49e9a", "#f2c0b4", "#fcdcd0" }
local BAY = { "#2a3a26", "#3e5630", "#5a7638", "#7a9646", "#9cb45a", "#c2d27c" }
local GLR = { "#3c6a9c", "#5f94c4", "#8cc0e2", "#b6e0f2", "#dcf3fb", "#f6fdff" }
local SEAL = { "#6e2a22", "#a8402a", "#d8602e", "#f08a3a", "#fbb260", "#ffd892" }
local WIRE = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }

A.shadow(32, 56, 15, 1.5)
local J = A.jar{ pts = { { 17, 8 }, { 20, 8 }, { 23, 11 }, { 29, 14.5 }, { 40, 15 }, { 48, 14 }, { 54, 11 } }, level = 31, brine = BRINE }
local IN = J.inside

-- bay leaf behind
do
  local m, n, T, S = X.cyl(20, 50, 33, 31, function(t) if t > 0.96 then return -1 end return math.max(0.5, 3.2 * math.sin(math.pi * math.min(1, t * 1.02 + 0.04)) ^ 0.75) end)
  A.part(m, n, BAY, { clip = IN, nocontact = true, edge = 1 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.2 and t > 0.05 and t < 0.9 then c:put(x, y, BAY[5]) end
    for _, vt in ipairs{ 5, 9, 13, 17 } do local d = t * 23 - (vt + abs(s) * 2.2)
      if d > -0.5 and d < 0.5 and abs(s) > 0.3 and abs(s) < 0.8 then c:put(x, y, s < 0 and BAY[4] or BAY[2]) end end
  end)
end
-- peppercorns behind
for _, p in ipairs{ { 42, 49 }, { 39, 51 }, { 22, 41 }, { 44, 30 } } do
  if IN:has(p[1], p[2]) then
    A.map({ "ab", "bd" }, p[1], p[2], { a = "#8a6a5a", b = "#4a3038", d = "#2e1e26" })
  end
end

local function onion(cx, cy, r, ramp, sprout)
  local m = A.ell(cx, cy, r, r - 0.4)
  -- pointed papery top and a little root boss
  m:set(cx, floor(cy - r)) m:set(cx - 1, floor(cy - r))
  local n = A.ellN(m, cx - 0.3, cy - 0.3, r, r - 0.4)
  local mm, idx = A.part(m, n, ramp, { clip = IN, edge = 2 })
  -- layer lines: two meridian arcs either side of centre
  mm:each(function(x, y)
    local u = (x + .5 - cx) / (r + .3)
    local v = (y + .5 - cy) / r
    if abs(v) < 0.75 then
      local cu = 0.5 * sqrt(max(0, 1 - v * v))
      if abs(u - cu) < 0.13 or abs(u + cu) < 0.13 then A.darken(x, y, 1) end
    end
  end)
  -- top tip and root
  local tx, ty = cx - 1, floor(cy - r) - 1
  for _, p in ipairs{ { tx, ty, 4 }, { tx + 1, ty, 3 }, { tx, ty - 1, 5 } } do
    if IN:has(p[1], p[2]) or sprout then c:put(p[1], p[2], TIP[p[3]]) A.occ:set(p[1], p[2]) end
  end
  local by = floor(cy + r - 0.4)
  if IN:has(cx - 1, by) then c:put(cx - 1, by, TIP[3]) c:put(cx, by, TIP[2]) end
  if IN:has(cx, by + 1) then c:put(cx, by + 1, TIP[4]) end
  -- wet glint
  c:put(floor(cx - r * 0.45), floor(cy - r * 0.5), A.SPEC)
  return mm
end
-- back row (higher, dimmer), middle, front
onion(22, 36, 4.0, ONB) onion(39, 35, 4.2, ONB)
onion(20, 43, 4.2, ON) onion(29, 40, 4.5, ON) onion(43, 42, 4.0, ON)
onion(25, 49, 4.3, ON) onion(35, 48, 4.5, ON) onion(43, 50, 3.4, ON)

-- quirk: bobbing onion at the surface, half out of the brine, with a green sprout curl
do
  local m = onion(31, 31, 3.8, ON, true)
  local SP = { "#2e6a44", "#5aa04e", "#8cc866", "#c4e88a" }
  A.map({
    "..bcc.",
    ".bb.cc",
    ".ab..c",
    ".ab.bc",
    "..aab.",
    "...a..",
  }, 27, 22, { a = SP[2], b = SP[3], c = SP[4] })
end

A.glassFront(J, { top = 7, gaps = { { 35, 37 } }, wide = 10 })

-- rubber seal ring with a pull tab on the left
local seal = HP.rect(23, 16, 40, 17)
A.vband(seal, 23, 40, SEAL, { nocontact = true })
A.map({ "aab", "bcd", ".dd" }, 20, 16, { a = SEAL[5], b = SEAL[4], c = SEAL[3], d = SEAL[2] })
-- glass lid dome
local lid = HP.mask()
for y = 10, 15 do local w = ({ 5.5, 7, 8, 8.6, 9, 9 })[y - 9] for x = floor(32 - w + .5), floor(31 + w + .5) do lid:set(x, y) end end
A.vband(lid, 23, 40, GLR, { nocontact = true, round = function(x, y) return y <= 11 and -0.6 or 0 end })
for x = 26, 30 do c:put(x, 11, "#f6fdff") end c:put(25, 12, "#f6fdff")
for x = 24, 39 do c:put(x, 15, GLR[3]) end
-- wire bail: arch over the lid top, legs down to hinge loops on the neck, lever on the right shoulder
local function wire(pts)
  for i = 1, #pts - 1 do A.ln(pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2], WIRE[3]) end
end
wire({ { 25, 9 }, { 38, 9 } })
for x = 26, 33 do c:put(x, 9, WIRE[4]) end
wire({ { 24, 10 }, { 22, 14 }, { 22, 20 } }) wire({ { 39, 10 }, { 41, 14 }, { 41, 20 } })
c:put(23, 10, WIRE[3]) c:put(24, 9, WIRE[2]) c:put(39, 9, WIRE[2]) c:put(40, 10, WIRE[2])
for y = 15, 20 do c:put(42, y, WIRE[2]) end
-- neck ring wire and hinge eyes
for x = 22, 41 do c:put(x, 21, (x < 30) and WIRE[4] or WIRE[3]) end
for x = 22, 41 do c:put(x, 22, WIRE[1]) end
A.map({ "ab", "bd" }, 21, 20, { a = WIRE[4], b = WIRE[2], d = WIRE[1] })
A.map({ "ab", "bd" }, 41, 20, { a = WIRE[3], b = WIRE[2], d = WIRE[1] })
-- lever arm angled up on the right
A.ln(43, 21, 46, 15, WIRE[3]) A.ln(44, 21, 47, 15, WIRE[1]) c:put(46, 14, WIRE[4]) c:put(47, 14, WIRE[2])
A.fin()
