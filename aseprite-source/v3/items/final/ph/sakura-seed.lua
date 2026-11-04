-- sakura-seed (first draft, Sonnet). Three round cherry stones (ridge seam, pale scar) on a serrated bronze-green
-- cherry leaf scrap; the right stone sprouted: red-brown stem, two ovate toothed leaves, a second smaller pair, a pink blossom.
-- quirk: one pink petal is stuck on the left stone.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("sakura-seed")
local floor = math.floor
local LF = A.R("#6b9a4a")
A.scrap(c, 5, 57, 55, 42, 9, LF, { 6, 10, 14, 18, 22, 26, 30, 34 })
local pit = A.R("#b57a4e")
for _, s in ipairs{ { 15, 53, 3.1, 2.8 }, { 25, 51, 3.0, 2.7 }, { 36, 47, 3.1, 2.8 } } do
  A.seed(c, s[1], s[2], s[3], s[4], 0, pit, LF[1], "#ffe0b0")
  c:px(s[1] + 1, s[2] - 2, pit[2]) c:px(s[1] + 2, s[2] - 1, pit[2]) c:px(s[1] + 2, s[2], pit[2]) c:px(s[1] + 1, s[2] + 1, pit[2]) -- ridge seam
  c:px(s[1] - 1, s[2] + 2, "#f0d8b0")
end
A.sprout(c, { { 36, 44 }, { 37, 36 }, { 38, 28 }, { 38, 21 } }, "#b5654a", {
  { 37, 37, 25, 32, 3.2, "#6b9a4a", { 3, 6 } },
  { 37, 37, 50, 31, 3.2, "#6b9a4a", { 3, 6 } },
  { 38, 28, 29, 24, 2.4, "#82b256", { 3 } },
  { 38, 28, 47, 23, 2.4, "#82b256", { 3 } } })
A.blossom(c, 38, 16, 3, "#f5809f", "#ffe38a")
-- stray petal on left stone
c:px(14, 50, "#ffc4d8") c:px(15, 50, "#f5809f") c:px(15, 51, "#c94f84")
A.fin()
