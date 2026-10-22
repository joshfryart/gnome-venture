local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-hybrid/"
local c = GV.canvas{ w = 120, h = 80, mode = "scene", out = 2 }

-- card + table
local card = c:rrect(0, 0, 119, 79, 7)
c:fill(card, "#f6e3b0")
local tpts = { {0, 80} }
for x = 0, 120, 4 do tpts[#tpts + 1] = { x, 58 + math.floor(1.5 * math.sin(x / 9) + 0.5) } end
tpts[#tpts + 1] = { 120, 80 }
local table_ = c:poly(tpts):clip(card)
c:fill(table_, "#dcb06a")
c:fill(c:poly({{0,63},{120,63},{120,64},{0,64}}):clip(card), "#c9a96e")
c:fill(c:poly({{0,71},{120,71},{120,72},{0,72}}):clip(card), "#c9a96e")
c:fill(c:ellipse(60, 68, 27, 3), "#b8661a")

-- coins
c:part(c:ellipse(20, 22, 7), "gold", { gloss = false })
c:paint({ "...g...", "...g...", "...g...", "ggggggg", "...g...", "...g...", "...g..." }, 17, 19, { g = "#b8661a" })
c:part(c:ellipse(103, 22, 7, 5), GV.ramp("#e8a317"), {})
c:fill(c:rect(99, 20, 107, 20), "#f5cf6a")

-- steam
local stone = GV.ramp("#6a6070")
local stoneL = GV.ramp("#968f96")
for i, x in ipairs({ 49, 60, 71 }) do
  local ph = 1
  local pts = {}
  for y = 12, 27, 1 do pts[#pts + 1] = { x + math.floor(1.5 * math.sin(y / 2.4) + 0.5), y } end
  c:part(c:line(pts, 2), GV.ramp("#f1ece0"), { flat = true })
end

-- handles (behind pot)
c:part(c:line({ {42, 40}, {37, 40}, {36, 41}, {36, 46}, {37, 47}, {42, 47} }, 2), stoneL, { flat = true })
c:part(c:line({ {78, 40}, {83, 40}, {84, 41}, {84, 46}, {83, 47}, {78, 47} }, 2), stoneL, { flat = true })

-- pot body
local body = c:rect(43, 35, 77, 50):add(c:rrect(43, 35, 77, 67, 14))
local pot = c:part(body, stone, { gloss = { 47, 42 } })
-- rim
c:part(c:rrect(39, 31, 81, 37, 2), stoneL, { gloss = { 43, 33 } })
c:fill(c:rect(42, 31, 78, 31), "#d6c9b6")

-- tomato
c:part(c:ellipse(19, 61, 6.5, 6), GV.ramp("#d6322b"), {})
c:part(c:ellipse(27, 64, 5.5, 5), GV.ramp("#e0501f"), {})
c:paint({ ".s..", "llsl", "l..l" }, 17, 53, { s = "#2e5a2c", l = "#58a03e" })
c:paint({ ".s..", "llsl" }, 26, 57, { s = "#2e5a2c", l = "#58a03e" })

-- spoon
local sp = c:line({ {84, 64}, {92, 42} }, 3)
c:part(sp, GV.ramp("#a8703c"), { flat = true })
c:part(c:ellipse(94, 37, 3.5, 4.5), GV.ramp("#c48e55"), {})

-- carrot
c:part(c:line({ {101, 57}, {99, 52} }, 2), "moss", { flat = true })
c:part(c:line({ {104, 57}, {104, 50} }, 2), "moss", { flat = true })
c:part(c:line({ {107, 57}, {109, 52} }, 2), "moss", { flat = true })
c:part(c:poly({ {98, 57}, {111, 57}, {106, 74}, {103, 74} }), GV.ramp("#f08a24"), {})
c:fill(c:rect(101, 62, 103, 62), "#b8452f"); c:fill(c:rect(105, 66, 107, 66), "#b8452f"); c:fill(c:rect(102, 69, 103, 69), "#b8452f")

-- hem stitch
c:seam({ {7, 2}, {112, 2} }, { free = true })
c:seam({ {7, 77}, {112, 77} }, { free = true })

local t = c:save(O .. "aseprite/landing/cook.aseprite", O .. "png/landing/cook.png")
print(GV.report(t))
