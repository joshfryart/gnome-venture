-- miner-s-lantern (final, Opus single pass). Slim tall hurricane lantern: wire bail, domed brass cap with vent holes
-- and a knob, two iron posts caging a glass chimney lit from inside by a teardrop flame (glow banded by distance),
-- brass fount with a raised ring and specular streak, iron foot, ground shadow.
-- Material: brass + iron per-pixel cylinder/sphere light (6 tones), glass bright rim and pale streak, AO under cap and
-- above the collar. quirk: a pale moth has settled on the warm cap, drawn to the light.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_4.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
local c = A.new("miner-s-lantern")
local IRON  = { "#2f2838", "#463a50", "#5e5068", "#7c6c84", "#a194a6", "#d2c8d0" }
local BRASS = { "#4a2a1e", "#7a4626", "#a8682c", "#d09838", "#ecc45a", "#fbe79a" }
local SPEC = "#fff1cf"

c:groundShadow(32, 56, 13, 1.5)

-- bail: 2px wire half-ellipse
local bail = HP.mask()
for y = 6, 20 do for x = 19, 45 do
  local a, b = (x - 32) / 11.4, (y - 20) / 13.4
  local q = sqrt(a*a + b*b)
  if q <= 1 and q >= 0.84 then bail:set(x, y) end
end end
local itok = { r = { name = "iron" } }
bail:each(function(x, y)
  local a, b = (x - 32), (y - 20)
  local outer = sqrt((a / 11.4)^2 + (b / 13.4)^2) > 0.92
  local lit = (x < 32 and outer) or (x >= 32 and y < 12 and outer)
  c:put(x, y, lit and IRON[5] or (x > 34 and IRON[2] or IRON[3]), itok)
end)
c:put(26, 8, IRON[6], itok)

-- vent knob
local knob = c:rect(30, 13, 34, 16):add(c:rect(31, 12, 33, 12))
A.shade(c, knob, A.vcylN(knob, 30, 34, 0.3), IRON, { tok = itok })
c:put(31, 13, IRON[6], itok)

-- dome cap
local dome = A.ell(32, 21, 8.6, 5.2) dome:clip(c:rect(0, 0, 63, 20))
local dbias = {}
c:rect(30, 16, 34, 16):each(function(x, y) dbias[K(x, y)] = -1 end) -- AO under knob
local btok = { r = { name = "brass" } }
local didx = A.shade(c, dome, A.ellN(31.3, 21.5, 8.6, 5.5, dome, 0.8), BRASS, { tok = btok, bias = dbias })
for _, hx in ipairs{ 27, 31, 35 } do c:put(hx, 19, BRASS[1], btok) c:put(hx + 1, 19, BRASS[2], btok) c:put(hx, 18, BRASS[3], btok) end
c:put(27, 17, BRASS[6], btok) c:put(28, 17, SPEC, btok)
-- skirt
local skirt = c:rect(23, 21, 41, 23)
local sb = {}
c:rect(23, 23, 41, 23):each(function(x, y) sb[K(x, y)] = -1 end)
c:rect(23, 21, 41, 21):each(function(x, y) sb[K(x, y)] = 1 end)
A.shade(c, skirt, A.vcylN(skirt, 23, 41), BRASS, { tok = btok, bias = sb })
-- bail ears (rivets)
for _, ex in ipairs{ 21, 42 } do c:put(ex, 20, IRON[4], itok) c:put(ex + 1, 20, IRON[2], itok) c:put(ex, 21, IRON[3], itok) end

-- glass chimney with inner glow
local glass = c:rect(26, 24, 38, 40)
local gtok = { r = { name = "glass" } }
local FX, FY = 32, 33
glass:each(function(x, y)
  local d = sqrt((x - FX)^2 + ((y - FY) * 0.8)^2)
  local col = d < 3.6 and "#ffefb4" or d < 5.6 and "#ffd77e" or d < 7.6 and "#f2ad55" or "#d4843f"
  if x >= 36 and d >= 5.6 then col = "#b8683a" end
  if y == 24 then col = "#8a4a34" end            -- AO under the skirt
  if y == 40 then col = "#9a5636" end            -- contact above the collar
  c:put(x, y, col, gtok)
end)
for y = 26, 38 do c:put(26, y, "#fff4d6", gtok) end      -- bright glass rim
for y = 26, 30 do c:put(28, y, "#fffbe8", gtok) end      -- pale streak
c:put(28, 32, "#fffbe8", gtok)
for y = 25, 39 do c:put(38, y, "#8e4c36", gtok) end      -- far rim, shade side
-- flame
local FL = { o = "#e8532a", y = "#ffb02e", Y = "#ffdc66", C = "#fff4d6", w = "#3a2430" }
A.map(c, {
  "..o..",
  "..o..",
  ".oyo.",
  ".oYo.",
  "oyYyo",
  "oyCyo",
  "oyCyo",
  ".oyo.",
  "..w..",
}, 30, 29, FL, { r = { name = "flame" } })
-- wick holder
local wh = c:rect(30, 38, 34, 39)
A.shade(c, wh, A.vcylN(wh, 30, 34), BRASS, { tok = { r = { name = "wick" } } })

-- iron posts (2px each)
for y = 24, 41 do
  c:put(24, y, IRON[5], itok) c:put(25, y, IRON[3], itok)
  c:put(39, y, IRON[3], itok) c:put(40, y, IRON[1], itok)
end
c:put(24, 24, IRON[2], itok) c:put(40, 24, IRON[1], itok) c:put(39, 24, IRON[2], itok)
c:put(24, 27, IRON[6], itok)

-- collar
local col = c:rect(26, 41, 38, 42)
local cb = {} c:rect(26, 41, 38, 41):each(function(x, y) cb[K(x, y)] = -2 end)
A.shade(c, col, A.vcylN(col, 26, 38), BRASS, { tok = btok, bias = cb })

-- fount
local fount = c:rect(24, 43, 40, 51)
fount:cut(c:rect(24, 43, 24, 43)):cut(c:rect(40, 43, 40, 43)):cut(c:rect(24, 51, 24, 51)):cut(c:rect(40, 51, 40, 51))
local fb = {}
c:rect(24, 43, 40, 43):each(function(x, y) fb[K(x, y)] = -1 end) -- AO under collar
c:rect(24, 46, 40, 46):each(function(x, y) fb[K(x, y)] = 1 end)  -- raised ring lip
c:rect(24, 47, 40, 47):each(function(x, y) fb[K(x, y)] = -2 end) -- ring groove
c:rect(24, 51, 40, 51):each(function(x, y) fb[K(x, y)] = -1 end)
A.shade(c, fount, A.vcylN(fount, 24, 40), BRASS, { tok = btok, bias = fb })
for y = 44, 50 do if y ~= 47 then c:put(27, y, BRASS[6], btok) end end
c:put(27, 44, SPEC, btok)
c:put(37, 49, "#9a6a8a", btok) c:put(38, 48, "#9a6a8a", btok) -- cool bounce

-- foot
local foot = c:rect(23, 52, 41, 54)
foot:cut(c:rect(23, 54, 23, 54)):cut(c:rect(41, 54, 41, 54))
local ftb = {} c:rect(23, 52, 41, 52):each(function(x, y) ftb[K(x, y)] = -1 end)
c:rect(23, 53, 41, 53):each(function(x, y) ftb[K(x, y)] = 1 end)
A.shade(c, foot, A.vcylN(foot, 23, 41), IRON, { tok = itok, bias = ftb })

-- quirk: moth resting on the cap
A.map(c, {
  "a...a",
  ".a.a.",
  "WwbwW",
  "Wwbww",
  ".w.w.",
}, 34, 14, { a = "#5a3a32", W = "#f6ead0", w = "#cdb48c", b = "#6a4632" }, { r = { name = "moth" } })

A.save(c, "miner-s-lantern")
