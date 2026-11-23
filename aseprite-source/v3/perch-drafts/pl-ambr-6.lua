-- pl-ambr-6-perch : chibi squirrel pal on its little wooden perch (36x36)
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ambr-6-perch-20261120-162008/gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1, cres = 2, deep = 1 }

local fur    = GV.ramp("#f08c48", { shade = "#cf612f", deep = "#983f42" })
local cream  = GV.ramp("#f4e5bc", { shade = "#c9a48b" })
local wood   = GV.ramp("#9f7052", { shade = "#704438", deep = "#2b1c26" })

local p = c:build{
  { "tail",  c:mask():ellipse(27.5, 16, 3, 6):ellipse(26.5, 9.5, 3, 2.2), fur,
    { gloss = { 27, 10 } } },
  { "body",  c:rrect(11, 16, 22, 27, 4),  fur,     { gloss = false } },
  { "belly", c:ellipse(16.5, 23.5, 4, 3.5), cream, { gloss = false } },
  { "head",  c:ellipse(16.5, 12, 7, 6.5), fur,     { gloss = { 13, 7 } } },
  { "earL",  c:poly({{10,8},{12,3},{14,8}}), fur,  { flat = true } },
  { "earR",  c:poly({{19,8},{21,3},{23,8}}), fur,  { flat = true } },
  { "perch", c:rrect(10, 26, 24, 31, 1),  wood,    { gloss = false } },
}
-- inner ears (dark plum), tail stripes (dark bands curving with the tail)
c:fill(c:poly({{11,7},{12,4},{13,7}}), "#2b1c26")
c:fill(c:poly({{20,7},{21,4},{22,7}}), "#2b1c26")
local tm = p.tail.m
for _, s in ipairs({ { 24, 13, 31, 13 }, { 25, 17, 32, 17 }, { 24, 21, 31, 21 } }) do
  c:fill(c:rect(s[1], s[2], s[3], s[4]):clip(tm), "#704438")
end
-- TEXTURE: wood grain + plank seam dash; sparse fur flecks; crescent-border dither
c:px(13, 28, "#704438"); c:px(22, 29, "#704438"); c:px(12, 30, "#2b1c26"); c:px(23, 27, "#704438")
local bm = p.body.m
for _, d in ipairs({ { 14, 22 }, { 20, 24 }, { 18, 26 }, { 12, 25 } }) do c:px(d[1], d[2], "#cf612f") end
for _, d in ipairs({ { 12, 10 }, { 14, 8 }, { 21, 15 }, { 13, 14 } }) do c:px(d[1], d[2], "#cf612f") end
local hm = p.head.m
c:px(13, 12, "#f08c48"); c:px(14, 13, "#f08c48"); c:px(17, 13, "#f08c48") -- dither into head shade
c:px(15, 24, "#f4e5bc"); c:px(18, 25, "#f4e5bc")                          -- dither into belly shade
-- DETAIL: face + acorn accent
c:eye(10, 9); c:eye(19, 9)
c:px(16, 14, "#2b1c26"); c:px(17, 14, "#2b1c26")                          -- tiny mouth
c:px(11, 14, "#983f42"); c:px(22, 14, "#983f42")                          -- cheeks
local acorn = c:part(c:ellipse(29, 28.5, 2, 1.6), GV.R.gold,
  { cres = 1, gloss = false, deep = 1 })
c:part(c:rrect(26, 25, 30, 27, 1), GV.ramp("#704438"), { flat = true, cres = 1 })
c:px(28, 24, "#704438")                                                   -- stem
c:px(28, 28, "#fff1c8")                                                   -- acorn glint
c:ground(19, 32, 10, 1.2)

local t = c:save(
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ambr-6-perch-20261120-162008/out/pl-ambr-6-perch.aseprite",
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ambr-6-perch-20261120-162008/out/pl-ambr-6-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 1)
