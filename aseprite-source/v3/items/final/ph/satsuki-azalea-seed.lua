-- satsuki-azalea-seed (first draft, Sonnet). A brown five-valve azalea capsule split open like a star, dust-fine
-- dark seeds spilling onto a small hairy lanceolate leaf scrap; a sprout with a whorl of tiny leaves and a pink bud.
-- quirk: the capsule is split into a star and spills seeds in a tiny trail.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("satsuki-azalea-seed")
local floor, pi, cos, sin = math.floor, math.pi, math.cos, math.sin
local LF = A.R("#5f8f4a")
A.scrap(c, 6, 56, 54, 54, 7, LF, { 6, 11, 16, 21, 26, 31, 36, 41, 46 })
-- hairy edge flecks
for x = 10, 50, 5 do c:px(x, 50 + (x % 3), "#cfe2a0") end
-- capsule: five valves fanning from a base ring
local cx, cy = 20, 46
local cap = A.R("#8a5a36")
for i = 0, 4 do
  local a = -pi / 2 + i * 2 * pi / 5
  A.eLit(c, cx + cos(a) * 4.2, cy + sin(a) * 4.2, 4.2, 1.7, a, cap, 1.4)
end
A.sph(c, cx, cy, 2, "#3a2418", { nospec = true })
-- dust seeds spilling
local seed = { "#2b1c26", "#5a3a2a", "#8a5a36" }
local n = 0
for x = 27, 50, 1 do
  local y = 51 + floor((x - 27) * .05) + ((x * 7) % 3) - 1
  if (x * 5) % 3 ~= 0 then c:px(x, y, seed[1 + (x % 3)]) n = n + 1 end
end
c:px(26, 49, "#d9b99a")
-- sprout
A.sprout(c, { { 38, 48 }, { 38, 40 }, { 39, 32 }, { 39, 26 } }, "#a06a4a", {
  { 38, 42, 28, 38, 2.2, "#5f8f4a", { 3 } }, { 38, 42, 49, 39, 2.2, "#5f8f4a", { 3 } },
  { 39, 34, 30, 28, 2.2, "#79a85a", { 3 } }, { 39, 34, 49, 28, 2.2, "#79a85a", { 3 } } })
A.sph(c, 39, 21, 3.4, "#f5809f", {})
c:px(39, 19, "#ffc4d8") c:px(40, 22, "#c94f84") c:px(38, 22, "#c94f84")
A.fin()
