local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 48, h = 48, mode = "icon", margin = 3 }

-- curved top beam: tips rise, centre sags a little; 4-5 px thick
local beam = c:mask()
for x = 7, 40 do
  local d = math.abs(x - 23.5) / 16.5           -- 0 centre .. 1 tip
  local top = math.floor(12 - 3 * d * d + 0.5)   -- 12 centre, 9 tips
  if x <= 8 or x >= 39 then top = top - 1 end    -- upturned flick
  local bot = top + 4
  if x <= 9 or x >= 38 then bot = top + 3 end
  beam:add(c:rect(x, top, x, bot))
end

local p = c:build{
  { "posts",    c:rect(13, 15, 16, 37):add(c:rect(31, 15, 34, 37)), "#d6322b" },
  { "plinths",  c:rrect(11, 35, 18, 39, 1):add(c:rrect(29, 35, 36, 39, 1)), "#5b6470", { gloss = false } },
  { "crossbar", c:rect(9, 21, 38, 24), "#d6322b", { gloss = false } },
  { "strut",    c:rect(21, 15, 26, 20), "#ae2a2a", { gloss = false } },
  { "beam",     beam, "dusk" },
}
c:seam({ {11, 12}, {16, 13}, {23, 13}, {31, 13}, {36, 12} })
local t = c:save(O .. "aseprite/stops/shrine.aseprite", O .. "png/stops/shrine.png")
print(GV.report(t))
