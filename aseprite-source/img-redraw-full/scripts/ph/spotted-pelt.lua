local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- hide: body + four splayed leg flaps, one felt piece
local hide = c:rrect(18, 16, 46, 46, 6)
hide:add(c:poly({ {21, 18}, {13, 10}, {9, 12}, {9, 17}, {17, 25} }))   -- front left
hide:add(c:poly({ {44, 18}, {52, 10}, {56, 12}, {56, 17}, {48, 25} }))  -- front right
hide:add(c:poly({ {17, 38}, {9, 46}, {9, 51}, {13, 53}, {22, 45} }))    -- back left
hide:add(c:poly({ {48, 38}, {56, 46}, {56, 51}, {52, 53}, {43, 45} }))  -- back right
hide = hide:closed(2)

local neck = c:rrect(26, 8, 38, 20, 3)
local tail = c:line({ {32, 44}, {33, 49}, {35, 52}, {37, 55} }, 3)

local p = c:build{
  { "neck", neck, GV.ramp("#e0501f") },
  { "tail", tail, GV.ramp("#e0501f"), { flat = true } },
  { "hide", hide, GV.ramp("#f08a24"), { stitch = true } },
}
c:fill(c:rrect(35, 53, 38, 56, 1), "#35161f")   -- tail tip tuft
c:px(36, 54, "#5e2a3a")

c:seam({ {32, 21}, {32, 43} })

local function bean(x, y, tall)
  if tall then
    c:spot(c:ascii({ ".xx.", "xxxx", "xxxx", "xxxx", "xxxx", ".xx." }, x, y))
  else
    c:spot(c:ascii({ ".xxxx.", "xxxxxx", "xxxxxx", ".xxxx." }, x, y))
  end
end
bean(23, 21, true)
bean(37, 24, false)
bean(26, 32, false)
bean(39, 35, true)
bean(21, 38, false)

local t = c:save(D .. "img-redraw-full/aseprite/ph/spotted-pelt.aseprite",
                 D .. "img-redraw-full/png/ph/spotted-pelt.png")
print(GV.report(t))
