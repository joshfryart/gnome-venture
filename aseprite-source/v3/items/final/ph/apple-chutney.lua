local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local c = D.new("apple-chutney")
-- apple-chutney: squat glass jar of chunky brown-red chutney with a flecked label and a screw lid. quirk: a slow drip has crawled down the outside of the glass.
local G = D.GLASS
D.shadow(32, 56, 17, 3)
-- jar body
local body = c:rrect(14, 24, 50, 54, 5)
D.H.vcyl(c, body, G, 12, 52, {})
-- chutney fill
local fill = c:rrect(16, 28, 48, 52, 4)
D.H.vcyl(c, fill, {"#3a1a1c","#5a2418","#7c3420","#9c4426","#bc6030","#d88642"}, 14, 50, {})
-- chunks
for _, p in ipairs{{20,34},{26,44},{36,32},{40,46},{30,38},{22,48},{43,38}} do D.px(p[1], p[2], "#e8a458") D.px(p[1]+1, p[2], "#c8742e") D.px(p[1], p[2]+1, "#5a2418") end
-- label
local lab = c:rect(21, 36, 43, 47)
D.lit(lab, D.CRM, 1.5)
D.E(32, 41, 3, 3, 0, D.RED, 1.5) D.ln(32, 38, 33, 36, "#3f8a4e")
D.ln(23, 45, 41, 45, "#c9a98a")
-- lid
local lid = c:rrect(16, 14, 48, 24, 3)
D.H.vcyl(c, lid, {"#5a3a14","#8a5a1e","#b4802a","#d4a03a","#eec060","#fbe29a"}, 14, 50, {})
for x = 19, 45, 3 do D.ln(x, 16, x, 22, "#8a5a1e") end
-- drip
D.ln(46, 30, 46, 40, "#9c4426") D.E(46, 42, 1.4, 2, 0, {"#5a2418","#7c3420","#9c4426","#bc6030","#d88642","#e8a458"}, 1)
D.px(18, 30, "#ffffff" and "#fff4d6") D.px(18, 31, "#fff4d6") D.px(18, 32, "#fff4d6")
D.fin()
