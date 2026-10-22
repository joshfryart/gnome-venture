local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- body: tapered tube along a smile-shaped quadratic curve, cap end upper right, tip lower left
local body = c:mask()
local P0, P1, P2 = {45, 20}, {44, 46}, {11, 51}
local N = 60
for i = 0, N do
  local t = i / N
  local a, b, d = (1 - t) ^ 2, 2 * (1 - t) * t, t * t
  local x = a * P0[1] + b * P1[1] + d * P2[1]
  local y = a * P0[2] + b * P1[2] + d * P2[2]
  local r = 6.5 - 5.3 * t ^ 1.3
  if r < 1.2 then r = 1.2 end
  body:add(c:ellipse(x, y, r, r))
end

-- calyx: scalloped green cap
local cap = c:ellipse(45.5, 18, 7.5, 3.5)
cap:add(c:ellipse(39.5, 20, 2.5, 2.5))
cap:add(c:ellipse(45.5, 21, 2.5, 2.5))
cap:add(c:ellipse(51, 20, 2.5, 2.5))

local stem = c:line({ {46, 15}, {47, 11}, {49, 8}, {52, 6} }, 3)

c:build{
  { "body", body, "red", { gloss = { 36, 27 } } },
  { "stem", stem, GV.ramp("#2f5a2a"), { flat = true } },
  { "cap", cap, "moss" },
}

-- wrinkle across the middle of the body
c:paint({ "ww....", "..www.", ".....w" }, 34, 34, { w = "#b8452f" })
c:paint({ "w...", ".ww." }, 22, 43, { w = "#b8452f" })

local t = c:save(O .. "aseprite/ph/chili-pepper.aseprite", O .. "png/ph/chili-pepper.png")
print(GV.report(t))
