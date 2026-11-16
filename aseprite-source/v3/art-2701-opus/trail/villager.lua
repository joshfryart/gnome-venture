-- villager (32x32 trail map marker, Opus pass). A gnome villager, head and shoulders: tall red hat that
-- flops over to the left with a rolled brim, small pill eyes peeking under it, a big designed nose (lit
-- tip, dark underside), rosy cheeks, a curly moustache and a cream beard with cool strands, blue tunic.
-- quirk: puffing a little wooden pipe, and the smoke comes out as a tiny ring.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("villager")

local function rows(t, f) for y, r in pairs(t) do for x = r[1], r[2] do f(x, y, r) end end end

-- tunic shoulders
local TU = { "#2a4a7a", "#3a6fa8", "#4a90c0", "#7cc0dc" }
rows({ [25] = { 4, 27 }, [26] = { 3, 28 }, [27] = { 2, 29 }, [28] = { 2, 29 }, [29] = { 2, 29 }, [30] = { 2, 29 } }, function(x, y, r)
  local col = TU[3]
  if x <= r[1] + 1 or y == 25 then col = TU[4] end
  if x >= r[2] - 2 or y == 30 then col = TU[2] end
  c:put(x, y, col)
end)
c:put(6, 27, TU[1]) c:put(25, 27, TU[1]) -- arm creases

-- face
local SK = { hi = "#ffe0bd", base = "#f0b98d", sh = "#c98462", dp = "#7a4036" }
rows({ [13] = { 9, 21 }, [14] = { 9, 21 }, [15] = { 9, 21 }, [16] = { 9, 21 }, [17] = { 10, 21 }, [18] = { 10, 20 } }, function(x, y, r)
  c:put(x, y, (x >= r[2] - 1) and SK.sh or (x == r[1] and SK.hi or SK.base))
end)

-- beard (behind moustache), cool strands
local BD = { "#6f6680", "#9e93a0", "#c8bfb4", "#e6dccb", "#fff4d6" }
local bd = { [18] = { 8, 22 }, [19] = { 7, 23 }, [20] = { 7, 23 }, [21] = { 7, 23 }, [22] = { 7, 23 }, [23] = { 7, 23 }, [24] = { 8, 22 },
  [25] = { 8, 22 }, [26] = { 9, 21 }, [27] = { 10, 20 }, [28] = { 11, 19 }, [29] = { 13, 17 }, [30] = { 14, 16 } }
rows(bd, function(x, y, r)
  local col = BD[4]
  if x <= r[1] + 1 then col = BD[5] end
  if x >= r[2] - 2 then col = BD[3] end
  if x == r[2] or y == 30 then col = BD[2] end
  c:put(x, y, col)
end)
-- strands (diagonal waves)
for _, l in ipairs{ { { 10, 21 }, { 11, 25 }, { 13, 28 } }, { { 14, 22 }, { 14, 27 } }, { { 18, 21 }, { 17, 26 }, { 16, 29 } }, { { 21, 21 }, { 20, 25 } } } do
  c:line(l, 1):each(function(x, y) if c:get(x, y) then c:put(x, y, BD[3]) end end)
end
c:put(9, 22, BD[5]) c:put(12, 23, BD[5]) c:put(16, 24, BD[5])

-- moustache: two curls either side of the nose
T.grid(c, 7, 18, {
  ".ccbbbb.bbbbcc..",
  "cbBBBBbbbbbbbbbc",
  "c.cbbbc..cbbbc.c",
}, { B = BD[5], b = BD[4], c = BD[2] })

-- nose (designed: warm, lit tip, dark underside, nostril shadow)
T.grid(c, 13, 14, {
  ".NNN.",
  "NnNNN",
  "NnnNM",
  "NNNNM",
  ".uuu.",
}, { N = "#f29c74", n = "#ffd2b0", M = "#c9704e", u = "#a8503c" })
-- eyes (2x3 pill + glint) and cheeks
for _, ex in ipairs{ 10, 19 } do
  c:put(ex, 14, "#2b1c26") c:put(ex + 1, 14, "#2b1c26") c:put(ex, 15, "#2b1c26") c:put(ex + 1, 15, "#2b1c26") c:put(ex, 16, "#2b1c26") c:put(ex + 1, 16, "#2b1c26")
  c:put(ex, 14, "#fff4d6")
end
c:put(10, 17, "#f5809f") c:put(11, 17, "#f5809f") c:put(19, 17, "#f5809f") c:put(20, 17, "#f5809f")

-- hat: cone flopping over to the left, rolled brim
local HT = { hi = "#ff8a5c", base = "#e8493b", sh = "#b52e3f", dp = "#6e2038" }
local hat = { [1] = { 4, 6 }, [2] = { 4, 9 }, [3] = { 6, 12 }, [4] = { 9, 14 }, [5] = { 11, 15 }, [6] = { 11, 17 }, [7] = { 11, 18 },
  [8] = { 10, 19 }, [9] = { 9, 20 }, [10] = { 8, 21 }, [11] = { 7, 23 } }
rows(hat, function(x, y, r)
  local col = HT.base
  if x <= r[1] then col = HT.hi end
  if x >= r[2] - 1 then col = HT.sh end
  c:put(x, y, col)
end)
-- fold crease where the tip bends over, and a highlight streak on the cone
for _, p in ipairs{ { 10, 4 }, { 11, 4 }, { 12, 5 }, { 13, 5 } } do c:put(p[1], p[2], HT.sh) end
for _, p in ipairs{ { 13, 7 }, { 12, 8 }, { 12, 9 }, { 11, 10 } } do c:put(p[1], p[2], HT.hi) end
c:put(5, 1, HT.hi) c:put(4, 2, HT.base) -- tip
rows({ [12] = { 6, 24 } }, function(x, y) c:put(x, y, x <= 8 and HT.hi or (x >= 22 and HT.sh or HT.base)) end)
rows({ [13] = { 7, 23 } }, function(x, y) c:put(x, y, HT.dp) end)
for x = 9, 21, 4 do c:put(x, 12, HT.sh) end -- brim ribs

-- pipe from the right corner of the moustache, bowl up, smoke ring above
T.grid(c, 19, 17, {
  "....WeeW",
  "....WooW",
  "....WeeW",
  "ddddWWWd",
  "eeeedddd",
}, { W = "#864c33", e = "#b97a4a", o = "#f5b82e", d = "#51302b" })
c:put(24, 18, "#ff8a5c")
T.grid(c, 24, 9, {
  ".mmm.",
  "mM.Mm",
  "m...m",
  "mM.Mm",
  ".mMm.",
  "..M..",
  "..m..",
}, { m = "#e2e0e6", M = "#aaa9b8" })
c:put(26, 15, "#aaa9b8")

T.done(c)
