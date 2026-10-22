local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- packet body with clipped upper-right corner
local body = c:poly({ {13,12}, {45,12}, {52,19}, {52,57}, {13,57} })
-- folded flap: triangle sitting in the clipped corner
local flap = c:poly({ {45,12}, {45,20}, {53,20} })
-- crease band across the top
local band = c:rect(13, 18, 51, 19):clip(body)
local win = c:rrect(18, 24, 46, 50, 6)
local winIn = c:rrect(20, 26, 44, 48, 5)

local p = c:build{
  { "body", body, GV.ramp("#f1ece0"), { stitch = true } },
  { "window", win, GV.ramp("#4e3a8a"), { gloss = false, contact = false } },
  { "inner", winIn, GV.ramp("#f4f0e0"), { gloss = { 22, 28 }, contact = false } },
  { "flap", flap, GV.ramp("#dcb06a"), { gloss = false } },
}
c:fill(band:cut(flap), "#dcb06a")
c:seam({ {14, 18}, {44, 18} }, { free = true })

-- sprig
c:part(c:line({ {32,33}, {32,28} }, 2), GV.ramp("#2e5a2c"), { flat = true })
c:part(c:poly({ {33,29}, {35,25}, {39,24}, {37,28} }), GV.ramp("#58a03e"), { flat = true })

-- berries pyramid
local B = { {32,33}, {28,38}, {36,38}, {24,43}, {32,43}, {40,43} }
local bm = c:mask()
for _, b in ipairs(B) do bm:add(c:ellipse(b[1], b[2], 3.5, 3.5)) end
local berries = c:part(bm, "dusk", { gloss = false, contact = false })
for _, b in ipairs(B) do
  c:px(b[1]-2, b[2]-2, "#a894dc"); c:px(b[1]-1, b[2]-2, "#7b66b4"); c:px(b[1]-2, b[2]-1, "#7b66b4")
  c:px(b[1]+1, b[2]+2, "#291d4a"); c:px(b[1]+2, b[2]+1, "#291d4a")
end

-- three brown dots
for _, x in ipairs({ 26, 32, 38 }) do c:fill(c:rect(x-1, 53, x, 54), "#8c4a1a") end

local t = c:save(O .. "aseprite/ph/acai-seed.aseprite", O .. "png/ph/acai-seed.png")
print(GV.report(t))
