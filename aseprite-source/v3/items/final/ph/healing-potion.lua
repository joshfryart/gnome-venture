-- healing-potion (dC11 first draft): round-bellied flask of bright green liquid, cork stopper, thin neck, glassy rim, white-heart label.
-- quirk: a little heart-shaped bubble floats out of the neck.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("healing-potion")
local P = D.P
c:groundShadow(32, 57, 15, 3)
local GLASS = D.r4("#f0fbff", "#b6f0e0", "#5fc4c8", "#2a4a7a")
local flask = D.ell(32, 43, 16, 14):add(c:rect(28, 21, 36, 32))
D.part(c, flask, GLASS, 4)
local liq = D.ell(32, 44, 14, 12):clip(c:rect(0, 34, 63, 63))
D.part(c, liq, D.r4("#d8f57a", "#6cd045", "#2f9a4d", "#1f5a4a"), 5)
-- surface line
for x = 21, 43 do if liq:has(x, 34) then c:px(x, 34, "#e8ffb0") end end
-- label heart
c:paint({
  ".rr.rr.",
  "rRRrRRr",
  "rRRRRRr",
  ".rRRRr.",
  "..rRr..",
  "...r...",
}, 28, 40, { r = "ember.deep", R = "ember.base" })
c:px(29, 41, P.ember.hi)
-- neck rim + cork
c:fillMask(c:rect(26, 20, 38, 22), GLASS[5]) c:px(26, 20, GLASS[6])
local cork = c:rrect(28, 12, 36, 21, 1)
D.part(c, cork, D.r4("#f0d0a0", "#cf9c62", "#9a6a3e", "#5a3a2e"), 2)
for _, p in ipairs{ {30,15},{33,17},{31,19} } do c:px(p[1], p[2], "#9a6a3e") end
-- heart bubble
c:paint({
  "h.h",
  "hHh",
  ".h.",
}, 43, 8, { h = "petal.base", H = "petal.hi" })
c:px(40, 4, P.sea.hi) c:px(41, 4, P.cream)
D.fin()
