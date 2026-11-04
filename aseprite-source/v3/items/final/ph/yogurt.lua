-- yogurt (lean D3o_16)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w=64, h=64, scale=1, name="yogurt" }
local GLASS = { "#4a6f94", "#7aa6c8", "#a9d0e2", "#d2ecf1", "#eef9f6", "#f2fafa" }
local MILK  = { "#9a95b8", "#c3bfd6", "#e2deea", "#f3efee", "#fcf8ef", "#fffdf6" }
local LID   = { "#1f3f6b", "#2b5e93", "#3a80b4", "#58a2cf", "#8cc6e4", "#c4e6f2" }
local GOAT  = { "#3f5f7c", "#5b86a6", "#e8e2d2", "#fdf8ec" }
c:groundShadow(32, 56, 15, 2)
-- jar body (slim shoulders, wide belly)
local body = c:rrect(16, 20, 47, 54, 6)
body:add(c:rect(22, 14, 41, 22))
local inner = c:rrect(19, 24, 44, 52, 4)
inner:add(c:rect(24, 18, 39, 24))
local glass = body:copy():cut(inner)
local n1 = X.pillow(body, 12)
G.toneN(c, glass, n1, GLASS, { amb=0.15, wrap=0.3 })
-- yogurt fill, fill line below neck
local fill = inner:copy():cut(c:rect(0,0,63,22))
local n2 = X.pillow(fill, 10)
G.toneN(c, fill, n2, MILK, { amb=0.2, wrap=0.35 })
-- rim of the fill: slight lip
c:fillMask(c:rect(21, 23, 42, 23), MILK[6])
-- lid
local lid = c:rrect(20, 8, 43, 17, 2)
G.toneN(c, lid, X.pillow(lid, 6), LID, { amb=0.12, wrap=0.3 })
for x = 23, 41, 3 do c:put(x, 16, LID[1]) end
c:fillMask(c:rect(22, 17, 41, 17), "#e0a93a")
for x = 22, 41, 2 do c:put(x, 17, "#f5d46b") end
-- goat label (round)
local lab = c:ellipse(32, 41, 9, 9)
c:fillMask(lab, GOAT[2])
c:fillMask(c:ellipse(32, 41, 7, 7), GOAT[1])
-- goat face
c:fillMask(c:ellipse(32, 42, 4, 5), GOAT[4])
c:fillMask(c:rect(31, 46, 33, 47), GOAT[3])
c:put(30,41,"#2b1c26") c:put(34,41,"#2b1c26") c:put(32,47,"#c47a7a")
c:fillMask(c:rect(26, 39, 28, 40), GOAT[3]) c:fillMask(c:rect(36, 39, 38, 40), GOAT[3])  -- ears
c:line({{29,36},{27,33},{26,33}}, 1) c:line({{35,36},{37,33},{38,33}}, 1)
c:put(27,33,"#e8c27a") c:put(37,33,"#e8c27a")
-- glass spec streak upper-left, rim
for y = 27, 38 do c:put(19, y, GLASS[6]) end
c:put(20,26,GLASS[6]) c:put(20,39,GLASS[5])
c:put(23,10,LID[6]) c:put(24,10,LID[6]) c:put(23,11,LID[5])
-- quirk: yogurt drip on the lid
c:put(33,17,MILK[5]) c:put(33,18,MILK[5]) c:put(33,19,MILK[4]) c:put(34,17,MILK[4]) c:put(33,20,MILK[3])
c:sparkle(44, 30)
G.save(c, "yogurt")
