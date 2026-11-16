-- rest (32x32 trail map marker, Opus second pass over the Haiku draft). A chunky plank bench seen
-- from the front (two back planks on posts, a lit seat with a dark front edge, splayed legs) on a
-- worn dirt patch with grass tufts. A fat blue quilted pillow leans in the left corner; a cream mug
-- sits at the right end.
-- quirk: the steam rising from the mug curls into a sleepy "z".
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("rest")

local W = { "#51302b", "#6e3d2c", "#864c33", "#b97a4a", "#d8a670", "#e8b982" } -- wood dark..light
local B = { "#2f3a68", "#3f5390", "#5677b8", "#7fa0dc", "#b4cdf2" } -- pillow blue
local MUG = { "#a8683c", "#d9b98a", "#f2deb4", "#fff4d6" }
local STEAM = { "#c9cfe0", "#e9ecf4" }
local function R(x0, y0, x1, y1, hex) for y = y0, y1 do for x = x0, x1 do c:put(x, y, hex) end end end
local function E(x, y) c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end
local function h(x, y) return ((x * 73856093) ~ (y * 19349663)) % 7 end

-- grass tufts at the feet (the bench stands straight on the map)
local function tuft(x, y) c:put(x, y, "#3f9150") c:put(x + 1, y - 1, "#7cc35a") c:put(x + 1, y, "#3f9150") c:put(x + 2, y, "#24544a") end

-- a plank: lit top row, warm body, dark bottom row, lit left end, dark right end, grain dashes
local function plank(x0, y0, x1, y1, seed)
  for y = y0, y1 do for x = x0, x1 do
    local v = W[4]
    if y == y0 then v = W[6] elseif y == y0 + 1 and y1 - y0 >= 3 then v = W[5] elseif y == y1 then v = W[3] end
    if x == x1 and y > y0 then v = W[3] end
    if x == x0 and y < y1 then v = W[5] end
    if y > y0 and y < y1 and x > x0 + 1 and x < x1 - 1 and h(x + seed, y) == 0 then v = W[3] end
    c:put(x, y, v)
  end end
end

-- back posts behind the back plank, running down to the seat
for _, x in ipairs{ 5, 24 } do
  R(x, 5, x, 15, W[4]) R(x + 1, 5, x + 1, 15, W[3]) R(x + 2, 5, x + 2, 15, W[2])
  c:put(x, 5, W[6]) c:put(x + 1, 5, W[5])
end
-- back plank (one wide board, rounded ends)
plank(2, 7, 29, 10, 3)
E(2, 7) E(29, 7)
E(2, 10) E(29, 10)
for _, x in ipairs{ 5, 24 } do c:put(x, 11, W[2]) c:put(x + 1, 11, W[1]) c:put(x + 2, 11, W[1]) end -- plank shadow on posts
c:put(27, 9, W[2]) c:put(4, 9, W[3]) -- nail heads

-- seat: lit top plane, front edge, AO row beneath
R(1, 15, 30, 16, W[5]) R(1, 15, 30, 15, W[6])
for x = 7, 25, 9 do c:put(x, 16, W[4]) end -- board joints on the seat top
R(1, 17, 30, 18, W[4]) R(1, 18, 30, 18, W[3]) c:put(30, 17, W[3]) c:put(1, 17, W[5])
R(3, 19, 28, 19, W[1])
-- legs, splayed out at the feet, with a low stretcher bar
for _, L in ipairs{ { 3, 1 }, { 26, -1 } } do
  local x, s = L[1], L[2]
  for y = 19, 27 do
    local ox = (y >= 24) and -s or 0
    c:put(x + ox, y, W[5]) c:put(x + 1 + ox, y, W[4]) c:put(x + 2 + ox, y, W[2])
    if y == 19 then c:put(x + ox, y, W[3]) c:put(x + 1 + ox, y, W[2]) c:put(x + 2 + ox, y, W[1]) end
  end
  c:put(x - s, 27, W[3]) c:put(x + 1 - s, 27, W[2]) c:put(x + 2 - s, 27, W[1])
end
R(6, 24, 25, 24, W[4]) R(6, 25, 25, 25, W[2]) c:put(6, 24, W[5]) -- stretcher
tuft(7, 28) tuft(21, 28)

-- pillow: puffy blue cushion with pointed corners and bulging sides, leaning in the left corner
T.grid(c, 4, 5, {
  "p........p",
  ".pqqqqqqp.",
  ".qhhqqqqo.",
  "qhhqqqqqoo",
  "qhqqqbqqoo",
  "qqqqbBqooo",
  "qqqqqqooos",
  ".qqqoooos.",
  ".ooooooss.",
  "p.ssssss.p",
}, { p = B[2], q = B[3], h = B[4], o = B[2], s = B[1], b = "#f5b82e", B = "#d98322" })
c:put(6, 7, B[5]) c:put(7, 7, B[5]) -- pop
R(5, 15, 12, 15, W[3]) -- shadow on the lit seat edge under the pillow
-- mug at the right end of the seat: red glaze, cream rim, handle
T.grid(c, 20, 10, {
  "kkkkkk..",
  "errrrdhh",
  "errrrd.h",
  "errrrdhh",
  "dddddd..",
}, { k = "#fff4d6", e = "#f8744c", r = "#c23a3e", d = "#7a2236", h = "#9a2a3c" })
c:put(21, 10, "#f2deb4") c:put(20, 11, "#ff9a66")
R(20, 15, 27, 15, W[3]) -- contact shadow on the seat

-- steam rising and curling into a sleepy "z" (quirk)
T.grid(c, 21, 1, {
  "zzzzz",
  "...z.",
  "..z..",
  ".z...",
  "zzzzz",
  "..s..",
  ".s...",
  "..s..",
  "..s..",
}, { z = STEAM[2], s = STEAM[1] })

T.done(c)
