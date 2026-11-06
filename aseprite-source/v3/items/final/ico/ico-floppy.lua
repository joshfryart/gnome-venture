-- ico-floppy (final pass, Opus). A 3.5" diskette face-on: blue plastic shell with a chamfered corner,
-- brushed metal shutter with a dark media window, paper label sitting in a shallow recess.
-- Material: shell = pillow-bevel per-pixel light, glossy specular streak and cool bounce on the lower-right;
-- shutter = bevelled metal, bright top edge, diagonal specular streak, brushed lines, dark window with the
-- brown disk showing; label = 5-tone paper, ruled lines, handwriting, ambient row where it meets the recess.
-- quirk: someone doodled a little red mushroom in the label's corner.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-floppy")
local SHELL = { "#1c2c58", "#244a86", "#2f6aae", "#438ecc", "#6cb4e2", "#b0def2" }
local METAL = { "#3a3c55", "#5c5e78", "#8486a0", "#aaaabd", "#cfd0dc", "#eeeef4" }
local PAPER = { "#a88f74", "#cdb48e", "#e8d4ac", "#f8ead0", "#fff4d6" }
local X0, Y0, X1, Y1 = 10, 9, 53, 54

-- shell with a chamfered top-right corner and softly rounded others
local shell = HP.rrect(X0, Y0, X1, Y1, 2)
for y = Y0, Y0 + 5 do for x = X1 - 5, X1 do if (x - (X1 - 5)) + (Y0 + 5 - y) > 5 then shell.s[K(x, y)] = nil end end end
local stok = A.tok("shell")
local sn = X.pillow(shell, 3)
local sbias = {}
-- recesses: shutter track (left of shutter) and label well get a dark ambient ring
local shut = HP.rect(21, Y0, 42, 27)
local label = HP.rect(17, 33, 46, Y1)
local hole = HP.rect(12, 48, 14, 51)
X.ao(sbias, shell, shut, 1, -1)
X.ao(sbias, shell, label, 1, -1)
local sidx = A.shade(c, shell, sn, SHELL, { amb = 0.08, wrap = 0.22, tilt = { 32, 32, 30, 0.18 }, bias = sbias, tok = stok })
-- shell: moulded grip ridges on the left of the shutter (3 short grooves with a lit lip)
for i = 0, 2 do local y = 13 + i * 4
  for x = 13, 17 do c:put(x, y, SHELL[2], stok) c:put(x, y + 1, SHELL[5], stok) end end
-- glossy streak on the lit upper-left of the shell
for y = Y0 + 4, Y0 + 18 do c:put(X0 + 1, y, SHELL[6], stok) end
c:put(X0 + 1, Y0 + 2, A.CREAM, stok) c:put(X0 + 2, Y0 + 1, A.CREAM, stok)
-- cool bounce on the lower-right edges
for y = Y0 + 20, Y1 - 4 do c:put(X1 - 1, y, "#6b84c4", stok) end
-- write-protect window (dark hole with a lit bottom lip)
for y = 48, 51 do for x = 12, 14 do c:put(x, y, y == 48 and "#0f1a34" or "#16244a", stok) end end
for x = 12, 14 do c:put(x, 52, SHELL[5], stok) end

-- shutter: bevelled metal, top flush with the shell edge
local mtok = A.tok("shutter")
local mn = X.pillow(shut, 1.6)
local midx = A.shade(c, shut, mn, METAL, { amb = 0.15, wrap = 0.3, tilt = { 31, 18, 14, 0.15 }, tok = mtok })
-- brushed lines
for _, y in ipairs{ 12, 16, 20, 24 } do for x = 23, 31 do if (x + y) % 5 ~= 0 then A.step(c, midx, METAL, x, y, -1, mtok) end end end
-- media window: dark slot, the brown disk visible inside with one sheen line
local win = HP.rect(34, 12, 39, 24)
win:each(function(x, y) c:put(x, y, "#2b2232", mtok) end)
for y = 13, 23 do c:put(36, y, "#5a3c40", mtok) c:put(37, y, "#7a5448", mtok) end
for y = 14, 18 do c:put(37, y, "#a77a5e", mtok) end
for y = 12, 24 do c:put(34, y, "#1d1724", mtok) end
for x = 34, 39 do c:put(x, 12, "#1d1724", mtok) end
for y = 12, 25 do c:put(40, y, METAL[6], mtok) end
for x = 34, 40 do c:put(x, 25, METAL[5], mtok) end
-- diagonal specular streak on the metal
for i = 0, 4 do c:put(24 + i, 22 - i, METAL[6], mtok) c:put(25 + i, 22 - i, METAL[6], mtok) end
c:put(25, 13, A.CREAM, mtok)
-- shadow cast by the shutter onto the shell (ambient row below it)
for x = 21, 42 do if sidx[K(x, 28)] then c:put(x, 28, SHELL[1], stok) end end

-- label: paper in the recess
local ltok = A.tok("label")
local ln = X.pillow(label, 1.2)
local lbias = {}
for x = 17, 46 do lbias[K(x, 33)] = -2 end
for y = 33, Y1 do lbias[K(17, y)] = -1 end
local lidx = A.shade(c, label, ln, PAPER, { amb = 0.3, wrap = 0.5, tilt = { 31, 43, 16, 0.2 }, bias = lbias, tok = ltok,
  cuts = { 0.2, 0.42, 0.62, 0.82 } })
-- ruled lines (pale blue) and a red top band
for x = 18, 46 do c:put(x, 35, "#e8493b", ltok) c:put(x, 36, "#b52e3f", ltok) end
for _, y in ipairs{ 41, 46, 51 } do for x = 19, 45 do c:put(x, y, "#a8c0dc", ltok) end end
-- handwriting (ink scribbles sitting on the rules)
local hand = {
  { 20, 39, "##.#.##..#.##.#" },
  { 20, 40, "#.#.#.#.##.#.##" },
  { 20, 44, "##.##.#.#." },
  { 20, 45, ".#.#.##.##" },
}
for _, r in ipairs(hand) do for i = 1, #r[3] do if r[3]:sub(i, i) == "#" then c:put(r[1] + i - 1, r[2], "#3a3a6a", ltok) end end end
-- quirk: tiny mushroom doodle in the corner
A.map(c, {
  ".RRRR.",
  "RcRRcR",
  "RRRRRR",
  "..ss..",
  "..ss..",
}, 38, 46, { R = "#e8493b", c = "#fff4d6", s = "#a88f74" }, ltok)
c:put(38, 47, "#b52e3f", ltok) c:put(43, 47, "#b52e3f", ltok)
-- paper corner lit sparkle
c:put(45, 38, PAPER[5], ltok)
A.save(c, "ico-floppy")
