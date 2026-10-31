-- ph/hibiscus-cordial, redraw A (2.2.1 leftovers, Opus medium): fatter crown-cap longneck so the body is wide at
-- 16 px, deep magenta cordial, one big five-petal hibiscus on a round cream label.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "hibiscus-cordial", "A"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:rrect(17, 30, 47, 56, 7):add(c:rect(27, 12, 37, 24))
glass:add(c:poly({ {27, 22}, {38, 22}, {42, 25}, {46, 30}, {48, 34}, {16, 34}, {18, 30}, {22, 25} }))
c:build{
  { "glass",  glass, "#d8ecf0", { pale = false } },
  { "liquid", c:rrect(19, 31, 45, 54, 6), GV.ramp("#b0204a", { gloss = "#f6b8cf", rim = "#e46a9b" }), { contour = "#6b1b2c", gloss = false } },
  { "label",  c:ellipse(32, 43, 10, 9), "cream", { gloss = false, contact = false } },
}
c:fill(c:rect(21, 34, 22, 51), "#e46a9b")
c:part(c:rect(25, 7, 39, 12):add(c:ascii({ "x.x.x.x.x.x.x.x" }, 25, 13)), "stone", { gloss = false, cres = 2 })
c:fill(c:rect(26, 8, 38, 8), "#c9c5bc")
-- hibiscus: five big petals, gold centre, stamen
local petal = GV.ramp("#e0302a", { rim = "#ff9158" })
for _, d in ipairs({ {0, -4.5}, {4.5, -1}, {3, 4}, {-3, 4}, {-4.5, -1} }) do
  c:part(c:ellipse(32 + d[1], 43 + d[2], 3.5, 3.5), petal, { flat = true, contact = false, contour = "#8a1a24" })
end
c:fill(c:rect(31, 42, 33, 44), "#f5cf6a")
c:fill(c:line({ {33, 42}, {36, 38} }, 1), "#6b1b2c"); c:px(36, 37, "#f5cf6a")
c:ground(32, 57, 15, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
