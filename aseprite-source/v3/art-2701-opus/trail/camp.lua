-- camp (32x32 trail map marker, Opus pass). A red A-frame tent in 3/4 view (lit side roof with canvas
-- folds and a gold hem stitch, front face with a dark door and tied-back flaps, ridge pole poking out)
-- beside a campfire: crossed logs with pale end grain, a ring of stones, a tall flame with a cream core.
-- quirk: a marshmallow on a stick is toasting over the flames (already a little brown on one side).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("camp")

local TS = { "#6e2038", "#9a2a3c", "#c23a3e", "#e2513f", "#f8744c", "#ff9a66" }
-- side roof (faces the light): hi plane, folds in base
local side = c:poly{ { 7, 5 }, { 14, 8 }, { 6, 27 }, { 1, 23 } }
T.fill(c, side, TS[5])
side:edge():each(function(x, y) if not side:has(x - 1, y) or not side:has(x, y - 1) then c:put(x, y, TS[6]) end end)
for _, l in ipairs{ { { 6, 9 }, { 2, 20 } }, { { 9, 9 }, { 4, 23 } }, { { 12, 10 }, { 6, 25 } } } do
  c:line(l, 1):each(function(x, y) if side:has(x, y) then c:put(x, y, TS[4]) end end)
end
-- front face: base, shade band on the right edge, deep at the ground
local front = c:poly{ { 14, 8 }, { 22, 27 }, { 6, 27 } }
T.fill(c, front, TS[3])
front:each(function(x, y) if not front:has(x + 2, y) then c:put(x, y, TS[2]) end end)
front:each(function(x, y) if not front:has(x, y + 1) then c:put(x, y, TS[1]) end end)
c:line({ { 14, 8 }, { 6, 27 } }, 1):each(function(x, y) c:put(x, y, TS[1]) end) -- ridge seam
c:line({ { 14, 9 }, { 8, 25 } }, 1):each(function(x, y) if front:has(x, y) then c:put(x, y, TS[4]) end end) -- lit lip
-- door
local door = c:poly{ { 14, 14 }, { 18, 27 }, { 10, 27 } }
T.fill(c, door, "#2f1d34")
c:poly{ { 14, 18 }, { 17, 27 }, { 14, 27 } }:each(function(x, y) c:put(x, y, "#4d2a3c") end) -- firelight inside
-- tied-back flaps
for _, p in ipairs{ { 13, 15 }, { 12, 18 }, { 11, 21 }, { 10, 24 }, { 15, 15 }, { 16, 18 }, { 17, 21 }, { 18, 24 } } do c:put(p[1], p[2], TS[5]) end
c:put(11, 20, "#f5b82e") c:put(17, 20, "#f5b82e") -- toggles
c:put(14, 6, "#b97a4a") c:put(14, 7, "#864c33") -- ridge pole
c:stitch{ { 1, 23 }, { 6, 27 } }

-- logs: a back log on a slant, a fat front log lying across with a pale ringed end
T.grid(c, 18, 22, {
  "........bWd..",
  "......bWWd...",
  "...ddbWWd....",
  ".gebbbbbbbWd.",
  "gEgbWbbWbbbWd",
  "geWWWWWWWWWWd",
  ".gddddddddddd",
}, { e = "#e8b982", E = "#c9925a", g = "#d8a670", b = "#b97a4a", W = "#864c33", d = "#51302b" })
-- flame
T.grid(c, 19, 9, {
  "....r.....",
  "....rr..r.",
  "...ror..r.",
  "...ooor.or",
  "..rooyo.o.",
  "..royyoor.",
  ".royyyyor.",
  ".oyycyyor.",
  "royyccyyor",
  "roycccyyor",
  "royyccyyor",
  ".ryyyyyyr.",
  "..rooyoor.",
  "...r..r...",
}, { r = "#e2493a", o = "#f88a2e", y = "#fbcf4a", c = "#fff4d6" })

-- marshmallow stick, planted right, leaning over the flame
c:line({ { 30, 26 }, { 28, 8 } }, 1):each(function(x, y) c:put(x, y, "#864c33") end)
c:put(29, 26, "#51302b")
T.grid(c, 25, 5, {
  "pqq.",
  "qqmw",
  "smms",
  ".ss.",
}, { p = "#fff4d6", q = "#f6e6c2", m = "#e3bf8a", s = "#a8683c", w = "#864c33" })

T.done(c)
