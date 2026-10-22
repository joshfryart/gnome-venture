local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- knobbly oblong cluster: core ellipse + scalloped bumps around the edge
local body = c:ellipse(29.5, 36, 10, 14)
local bumps = { {21,25},{19,33},{20,41},{23,48},{29.5,51},{36,48},{39,41},{40,33},{38,25},{29.5,22} }
for _, b in ipairs(bumps) do body:add(c:ellipse(b[1], b[2], 4, 4)) end

-- leaf: pointed teardrop tilted up-right
local leaf = c:poly({ {32,21},{36,15},{42,11},{50,9},{47,15},{43,19},{36,21} })
leaf:add(c:ellipse(40, 16, 5, 3.5))

local p = c:build{
  { "stem", c:rrect(28, 12, 31, 21, 1), "#6a9a3a", { flat = true } },
  { "leaf", leaf, "leaf" },
  { "body", body, "dusk", { gloss = { 22, 27 } } },
  { "calyx", c:ellipse(29.5, 20, 5, 2), "#4a8a3e", { flat = true } },
}

-- drupelet bumps: small lighter domes with dark gaps (inside body)
local cols = { 23, 30, 37 }
local rows = { 27, 33, 39, 45 }
for j, y in ipairs(rows) do
  for i, x in ipairs(cols) do
    local xx = x + ((j % 2 == 0) and -2 or 0)
    if j == 4 and i == 3 then xx = xx - 1 end
    if (i + j) % 2 == 0 then
      c:paint({ ".ll.", "lbbl", "lbbs", ".ss." }, xx, y, { l = "#7b66b4", b = "#4e3a8a", s = "#291d4a" })
    else
      c:paint({ ".ss", "s.s", "sss" }, xx, y, { s = "#291d4a" })
    end
  end
end
-- gloss comma on the upper-left drupelets
c:paint({ ".gg", "gg.", "g.." }, 21, 25, { g = "#a894dc" })
c:px(25, 24, "#c8b8ee")
-- leaf vein
c:line({ {35,19},{41,15},{47,11} }, 1):each(function(x, y) c:px(x, y, "#4a8a3e") end)

local t = c:save(O .. "aseprite/ph/mulberry.aseprite", O .. "png/ph/mulberry.png")
print(GV.report(t))
