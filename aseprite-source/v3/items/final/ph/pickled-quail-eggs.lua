-- pickled-quail-eggs (C34, Opus artist pass). Squat, wide-shouldered jar under a turned wooden lid (grain lines,
-- paler end-grain top, bevelled rim, round knob on a waisted neck). Inside, peeled quail eggs in golden turmeric
-- brine: some pearly cream, some blushed beet-pink, all 6-tone ellipsoid light with one wet glint; one halved egg
-- shows its yolk; peppercorns and a dill frond between them.
-- quirk: a speckled quail feather has been tucked under the lid, sticking out jauntily on the left.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_4.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("pickled-quail-eggs")

local EGG  = { "#6a5462", "#9c8890", "#c8b8b0", "#e8dcc8", "#f8f0de", "#fffbf0" }
local EGGB = { "#5c4858", "#86747e", "#ae9e9c", "#d0c4b4", "#e8dece", "#f4ecdc" }
local BEET = { "#5a1c48", "#8a2c62", "#b8467c", "#d86c98", "#f096b6", "#ffc4d8" }
local YOLK = { "#8a4a1a", "#c8781e", "#f0a82a", "#ffcc44", "#ffe27a", "#fff2b0" }
local BRINE = { "#8a5a2a", "#b88236", "#dcaa48", "#f0c866", "#f8e08e", "#fff2c0" }
local WOOD = { "#4a2a26", "#6e3e2c", "#94583a", "#b97a4a", "#d89c62", "#ecc490" }
local FEA  = { "#3e2622", "#5e3a2a", "#86553a", "#a8744c", "#c8966a", "#e6bc90" }
local DILL = { "#1c4a3a", "#2e6a44", "#4a8c4c", "#6aac58", "#90c86a", "#b8e08a" }

A.shadow(32, 56, 15, 1.5)
local J = A.jar{ pts = { { 26, 10 }, { 29, 10.5 }, { 33, 14 }, { 36, 14.5 }, { 51, 14.5 }, { 54, 13 } }, level = 34, brine = BRINE }
local IN = J.inside

-- dill frond and peppercorns behind
for _, f in ipairs{ { 37, 50, 41, 38 }, { 39, 44, 43, 41 }, { 38, 47, 35, 43 }, { 40, 41, 42, 37 } } do
  A.ln(f[1], f[2], f[3], f[4], DILL[4], IN) c:put(f[3], f[4], DILL[6])
end
for _, p in ipairs{ { 20, 38 }, { 27, 51 }, { 44, 49 } } do
  if IN:has(p[1], p[2]) and IN:has(p[1] + 1, p[2] + 1) then A.map({ "ab", "bd" }, p[1], p[2], { a = "#7a5a4e", b = "#4a3038", d = "#2e1e26" }) end
end

local function egg(cx, cy, ramp, ang)
  local rx, ry = 3.3, 4.2
  local m = A.ell(cx, cy, rx, ry, ang or 0)
  local mm = A.part(m, A.ellN(m, cx - .3, cy - .5, rx, ry, ang or 0), ramp, { clip = IN, edge = 2, amb = 0.1, wrap = 0.3 })
  local gx, gy = floor(cx - 1.4), floor(cy - 2.2)
  if mm:has(gx, gy) then c:put(gx, gy, A.SPEC) end
  return mm
end
-- back row
egg(24, 38, EGGB, 0.3) egg(32, 37, EGGB, -0.1) egg(40, 38, EGGB, -0.3)
-- middle
egg(20, 45, BEET, 0.2) egg(28, 44, EGG, -0.15) egg(44, 45, BEET, -0.2)
-- halved egg: white with a yolk, cut face toward us
do
  local cx, cy = 36, 44
  local m = A.ell(cx, cy, 3.4, 4.2, 0.15)
  A.part(m, A.ellN(m, cx, cy, 3.4, 4.2, 0.15), EGG, { clip = IN, edge = 2, amb = 0.4, wrap = 0.4 })
  local y = A.ell(cx + .2, cy + .4, 1.9, 2.2)
  A.part(y, A.ellN(y, cx - .2, cy, 1.9, 2.2), YOLK, { clip = IN, nocontact = true })
  c:put(cx - 1, cy - 1, YOLK[6])
end
-- front row
egg(24, 51, EGG, 0.4) egg(32, 51, BEET, 0) egg(40, 51, EGG, -0.4)

A.glassFront(J, { top = 6, gaps = { { 42, 44 } }, wide = 8 })

-- wooden lid: turned disc with bevelled rim and grain, round knob on a waisted neck
local lid = HP.mask()
for y = 20, 26 do local w = (y == 20) and 11 or 12 for x = 32 - w, 31 + w do lid:set(x, y) end end
local _, lidx = A.vband(lid, 20, 43, WOOD, { nocontact = true, round = function(x, y) return y <= 21 and -0.75 or (y >= 26 and 0.6 or 0) end })
-- grain: wavy vertical lines on the side band
for _, gx in ipairs{ 23, 27, 33, 38, 41 } do
  for y = 22, 25 do local x = gx + ((y + gx) % 3 == 0 and 1 or 0) A.darken(x, y, 1) end
end
-- end-grain top band (paler) with growth rings hint
for x = 22, 41 do c:put(x, 20, (x == 27 or x == 35) and WOOD[5] or WOOD[6]) end
for x = 21, 42 do if (x % 5) ~= 0 then A.set(x, 21, 5) end end
c:put(23, 22, "#fff4d6") c:put(24, 22, "#fff4d6")
-- knob
local neck = HP.rect(30, 18, 33, 19)
A.vband(neck, 30, 33, WOOD, { nocontact = true })
local knob = A.ell(31.5, 15.5, 3.3, 2.8)
A.part(knob, A.ellN(knob, 31, 15, 3.3, 2.8), WOOD, { nocontact = true, edge = 1 })
c:put(30, 14, WOOD[6]) c:put(30, 18, WOOD[1]) c:put(33, 18, WOOD[2])
-- dark seat line where lid meets glass
for x = 21, 42 do c:put(x, 27, WOOD[1]) end

-- quirk: quail feather tucked under the lid on the left, tip sweeping up and out
do
  local m, n, T, S = X.cyl(22, 25, 11, 12, function(t) if t > 0.97 then return -1 end return max(0.6, 2.6 * math.sin(math.pi * min(1, t * 0.95 + 0.1)) ^ 0.6) end)
  m:cut(lid)
  A.part(m, n, FEA, { nocontact = true, edge = 1 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.2 and t < 0.92 then c:put(x, y, FEA[6]) end            -- pale shaft
    if abs(s) > 0.35 and ((t * 18 + abs(s) * 2) % 3) < 0.9 then c:put(x, y, FEA[1]) end -- dark bars
    if abs(s) > 0.3 and X.hash(x, y, 7) > 0.8 then c:put(x, y, "#f4e6c8") end -- cream speckles
  end)
end
A.fin()
