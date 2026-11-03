local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local out = app.params.out or "./"
local c = HP.canvas{ w = 64, h = 64, scale = 4, name = "ico-key" }
local bow = c:ellipse(25, 15, 6, 6):add(c:ellipse(39, 15, 6, 6)):add(c:poly{ {19,18},{45,18},{32,32} })
bow:cut(c:rect(31, 13, 33, 16))
c:part(c:rect(29, 30, 35, 56):add(c:rect(35,44,43,48)):add(c:rect(35,52,41,56)), "gold")
c:part(bow, "gold")
c:part(c:rect(18, 34, 28, 46), "ember")                  -- quirk: cloth tag
c:stitch({ {20, 44}, {26, 44} })
c:px(23, 36, "#2b1c26") c:px(24, 36, "#2b1c26")
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "ico-key.aseprite", png = out .. "ico-key.png", scale = 1 }
