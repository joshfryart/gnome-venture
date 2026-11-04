-- hat-brewroot (dC11 first draft): tall violet brewer's hat with a stiff crooked tip, broad band with a glass flask badge.
-- quirk: three bubbles drift up from the tip.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("hat-brewroot")
local P = D.P
local brim = D.ell(32, 52, 19, 5)
D.part(c, brim, "dusk", 3)
local m, T = D.H.sweep({ {32,50},{33,36},{29,20},{36,12} }, function(t) return 11 * (1 - t) ^ 0.7 + 0.8 end, 90)
m:clip(c:rect(0, 0, 63, 52))
D.part(c, m, "dusk", 4)
local bm = D.HP.mask() m:each(function(x, y) if y >= 41 and y <= 49 then bm:set(x, y) end end)
D.part(c, bm, D.r4("#a8e2e8", "#4f9fb0", "#2f6684", "#1f3354"), 2)
-- flask badge
c:paint({
  "..bb..",
  "..bb..",
  ".bBBb.",
  "bBGGBb",
  "bGGGGb",
  ".bbbb.",
}, 29, 42, { b = "stone.deep", B = "sea.hi", G = "moss.base" })
c:px(31, 46, P.cream)
-- brew stains on brim
c:px(20, 54, P.moss.shade) c:px(44, 53, P.moss.base) c:px(43, 54, P.moss.shade)
-- bubbles
for _, b in ipairs{ {39,8,2}, {43,4,1}, {35,4,1} } do
  c:fillMask(D.ell(b[1], b[2], b[3] + .6, b[3] + .6), P.sea.base)
  c:px(b[1] - 1, b[2] - 1, P.cream)
end
D.fin()
