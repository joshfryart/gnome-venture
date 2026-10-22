local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local pink = GV.ramp("#e04a72")
local red  = GV.ramp("#b8243a")
local moss = GV.ramp("#58a03e", { shade = "#2f5a2a" })

-- squat dome body (wider than tall)
local body = c:ellipse(31.5, 40, 19, 14)
local parts = { { "body", body, red, { gloss = false } } }

-- bead rows: 4 / 5 / 4, offset, scalloping the edge
local rows = {
  { y = 30, xs = { 20, 27.5, 35.5, 43 } },
  { y = 38, xs = { 15.5, 23.5, 31.5, 39.5, 47.5 } },
  { y = 46, xs = { 19.5, 27.5, 35.5, 43.5 } },
}
local all = body:copy()
for _, r in ipairs(rows) do for _, x in ipairs(r.xs) do all:add(c:ellipse(x, r.y, 4.5, 4.5)) end end
local i = 0
for ri, r in ipairs(rows) do
  for _, x in ipairs(r.xs) do
    i = i + 1
    local ramp = ((i + ri) % 2 == 0) and pink or red
    table.insert(parts, { "b" .. i, c:ellipse(x, r.y, 4.5, 4.5), ramp,
      { light = all, gloss = (i == 1) and { 17, 27 } or false, cres = 2, deep = 1 } })
  end
end
-- base dimple
table.insert(parts, { "dimple", c:ellipse(31.5, 52, 5, 1.5), "#6b1b2c", { flat = true } })

-- flat star calyx
local star = {}
for k = 0, 9 do
  local a = -math.pi / 2 + k * math.pi / 5
  local rr = (k % 2 == 0) and 12 or 4.5
  star[#star + 1] = { 31.5 + math.cos(a) * rr * 1.25, 25 + math.sin(a) * rr * 0.55 }
end
table.insert(parts, { "calyx", c:poly(star), moss, { cres = 2, gloss = { 26, 23 } } })
table.insert(parts, { "stem", c:rrect(30, 13, 33, 22, 1), "moss", { gloss = false } })
c:build(parts)

local t = c:save(O .. "aseprite/ph/raspberry.aseprite", O .. "png/ph/raspberry.png")
print(GV.report(t))
