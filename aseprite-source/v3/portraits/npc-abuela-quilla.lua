local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local out = app.params.out or "./"
local P = HP.P or dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/palette.lua")

local NAME = "npc-abuela-quilla"
local c = HP.canvas{ w = 80, h = 100, scale = 4, name = NAME }
-- backdrop disc (no outline: filled with plain fillMask); 2px shade ring lower right
local disc = c:ellipse(39.5, 44.5, 31, 31)
c:fillMask(disc, P.moss.base)
c:fillMask(disc:copy():cut(disc:copy():shift(-2, -2)), P.moss.shade)
-- braids
c:part(c:poly{ {17,50},{25,50},{26,70},{21,80},{15,76},{16,62} }, "stone")
c:part(c:poly{ {55,50},{63,50},{64,62},{65,76},{59,80},{54,70} }, "stone")
-- poncho (bleeds off bottom)
local pon = c:poly{ {10,99},{14,82},{26,72},{40,76},{54,72},{66,82},{70,99} }
c:part(pon, "ember")
for i, col in ipairs{ P.gold.base, P.sea.base, P.cream } do
  local y = 84 + (i - 1) * 6
  c:fillMask(c:rect(0, y, 79, y + 1):clip(pon), col)
end
-- neck + head
c:part(c:rect(34, 64, 46, 74), "skinB")
c:part(c:ellipse(40, 50, 20, 18), "skinB")
-- face
c:eyeLocked(29, 46) c:eyeLocked(43, 46)
c:cheek(27, 55) c:cheek(50, 55)
c:px(37, 58, P.skinB.deep) c:px(38, 59, P.skinB.deep) c:px(39, 59, P.skinB.deep) c:px(40, 59, P.skinB.deep) c:px(41, 58, P.skinB.deep)
c:px(39, 54, P.skinB.shade) c:px(40, 54, P.skinB.shade)
-- hat
c:part(c:ellipse(40, 33, 26, 5), "wood")
c:part(c:rrect(27, 17, 53, 33, 5):clip(c:rect(0, 0, 79, 33)), "wood")
c:part(c:rect(27, 26, 53, 28), "ember")
c:stitch({ {27, 30}, {53, 30} })
-- feather
c:part(c:poly{ {50,18},{56,10},{62,3},{60,12},{54,19} }, "ember", { band = 1 })
-- cat peeking over poncho (quirk: tiny matching hat)
c:part(c:poly{ {47,80},{49,70},{55,75},{63,75},{69,70},{71,80} }, "gold", { band = 1 })
c:part(c:ellipse(59, 85, 11, 9), "gold")
c:part(c:poly{ {55,64},{63,64},{65,72},{53,72} }, "ember", { band = 1, nopop = true })
c:eyeSmall(54, 82) c:eyeSmall(63, 82)
c:px(58, 87, P.petal.base) c:px(59, 87, P.petal.base) c:px(59, 88, P.ink) c:px(58, 89, P.ink) c:px(60, 89, P.ink)
c:part(c:rect(49, 94, 56, 97), "wood", { band = 1, nopop = true })
c:part(c:rect(62, 94, 69, 97), "wood", { band = 1, nopop = true })
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
c:save{ png = "/tmp/claude-0/-home-user-gnome-venture/24dbc14e-ae34-540a-ac1a-cc6317049307/scratchpad/" .. NAME .. "_x4.png", scale = 4 }
