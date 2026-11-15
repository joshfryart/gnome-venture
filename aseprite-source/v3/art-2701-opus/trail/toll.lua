-- toll (32x32 trail map marker, Opus pass). A little plank toll booth with a red gable roof, a dark
-- hatch window and a gold coin plate, a fat red-and-cream striped barrier arm swung across the road from
-- its side and resting on a forked post, all on a strip of dirt road.
-- quirk: a pink-shelled snail is sneaking under the barrier without paying.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("toll")

local MAP = {
  h = "#ff8a5c", r = "#e8493b", s = "#b52e3f", q = "#6e2038",
  e = "#e8b982", b = "#b97a4a", W = "#864c33", d = "#51302b", n = "#35213a", N = "#4d2f45",
  k = "#5a3424", Y = "#ffe38a", y = "#f5b82e", g = "#d98322", G = "#8f4a1f",
  R = "#c4853f", D = "#9a6438", L = "#d9a46a",
}
-- road strip
T.grid(c, 1, 27, {
  "LLLLRRLLLLLLRLLLLLLLLLRLLLLLLL",
  "RRDRRRRRRRRDRRRRRRRDRRRRRRRRDR",
  ".DDDDDDDDDDDDDDDDDDDDDDDDDDDD.",
}, MAP)
-- booth
T.grid(c, 1, 4, {
  ".....hr.....",  -- 4
  "....hrrs....",
  "...hrrrrs...",
  "..hrrrrrrs..",
  ".hrrrrrrrrs.",
  "qqqqqqqqqqqq",  -- 9
  ".edddddddddd",  -- 10 eave shadow
  ".ebbWbbWbbd.",
  ".ebWWWWWWbd.",  -- 12 window
  ".ebWnnnNWbd.",
  ".ebWnnNNWbd.",
  ".eeeeeeeeed.",  -- 15 sill
  ".ebbWbbWbbd.",
  ".ebkkkkkbbd.",  -- 17 coin plate
  ".ebkYyykbbd.",
  ".ebkyyggkbd.",
  ".ebkygGgkbd.",
  ".ebkkggkkbd.",
  ".ebbWkkWbbd.",
  ".ebbWbbWbbd.",
  ".ebbWbbWbbd.",
  ".edddddddddd",  -- 26
}, MAP)
-- fix coin plate to a round coin on a dark plate
T.grid(c, 4, 17, {
  "kkkkk",
  "kYyyk",
  "yYyyg",
  "yyGgg",
  "kgggk",
}, MAP)
-- forked rest post
T.grid(c, 26, 15, {
  "b..b",
  "bWbW",
  ".bW.",
  ".bW.",
  ".bW.",
  ".bW.",
  ".bW.",
  ".bW.",
  ".bW.",
  ".bW.",
  ".dd.",
}, MAP)
-- barrier arm: hinge cap on the booth, stripes 3 on 3 off, rounded tip
local ARM = { red = { "#ff8a5c", "#e8493b", "#b52e3f" }, cream = { "#fff4d6", "#f2e2bc", "#cdb48f" } }
for x = 12, 30 do
  local band = (x - 12) // 3 % 2 == 0 and ARM.red or ARM.cream
  for y = 12, 14 do
    local tone = (y == 12) and 1 or (y == 13 and 2 or 3)
    if not ((x == 30) and (y == 12 or y == 14)) then c:put(x, y, band[tone]) end
  end
end
T.grid(c, 11, 11, {
  "ggg",
  "gYg",
  "gyg",
  "ggG",
}, MAP)

-- snail sneaking under the arm
T.grid(c, 16, 21, {
  "........E.E",
  "..ppp...c.c",
  ".pPPpp..c.c",
  "pPpssp.cccc",
  "ppsPspccccc",
  "cpppppcccc.",
  "zzzzzzzzz..",
}, { p = "#f5809f", P = "#ffc4d8", s = "#c94f84", c = "#cfdaa4", z = "#93a070", E = "#2b1c26" })
T.done(c)
