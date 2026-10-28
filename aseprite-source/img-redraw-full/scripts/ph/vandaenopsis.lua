local GV = dofile("/home/user/gnome-venture/aseprite-source/gvlib/gvlib.lua")
local O = "/home/user/gnome-venture/aseprite-source/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local petal = GV.ramp("#e46a9b", { shade = "#b4487a", deep = "#7a2c52", gloss = "#ffc0d8", dot = "#fff1c8" })
local stake = GV.ramp("#d9a660", { shade = "#b07a45" })
local moss = GV.ramp("#6a9a3a", { shade = "#4a8a3e" })
local gold = GV.ramp("#e8a317", { rim = "#f5cf6a", shade = "#b8661a" })

local blooms = { {23.5, 18, 7}, {34, 13.5, 6.5}, {43.5, 17, 5.5}, {49, 25, 5}, {51.5, 33, 4} }
local function bloom(cx, cy, r)
  local m = c:ellipse(cx, cy, r * 0.45)
  for i = 0, 4 do
    local a = math.rad(-90 + 72 * i)
    m:add(c:ellipse(cx + math.cos(a) * r * 0.55, cy + math.sin(a) * r * 0.55, r * 0.5))
  end
  return m
end

local parts = {
  { "leaf", c:poly({ {19, 55}, {23, 50}, {28, 47}, {32, 46}, {29, 50}, {23, 54}, {20, 56} }), moss, { flat = true } },
  { "stake", c:rect(17, 18, 18, 55), stake, { flat = true } },
  { "stem", c:line({ {19, 42}, {19, 30}, {20, 23}, {23, 18}, {28, 14}, {34, 13}, {40, 15}, {45, 20}, {48, 26}, {50, 32}, {51, 38}, {51, 44} }, 2), moss, { flat = true } },
  { "bud1", c:ellipse(51, 40, 1.5), "moss", { flat = true } },
  { "bud2", c:ellipse(50, 45.5, 1.5), "moss", { flat = true } },
}
for i = #blooms, 1, -1 do
  local b = blooms[i]
  parts[#parts + 1] = { "b" .. i, bloom(b[1], b[2], b[3]), petal, { cres = 2, deep = 1, gloss = (i == 1) and { 19, 14 } or nil } }
end
parts[#parts + 1] = { "clip", c:rrect(15, 37, 21, 42, 1), gold }
local p = c:build(parts)

-- bud tips
c:px(51, 38, "#e46a9b"); c:px(50, 43, "#e46a9b"); c:px(51, 43, "#f6b8cf")
-- lips + centres
for i, b in ipairs(blooms) do
  local cx, cy, r = math.floor(b[1]), math.floor(b[2]), b[3]
  local lr = (r >= 5) and 1 or 0
  c:fill(c:ellipse(cx + 0.5, cy + r * 0.5 + 0.5, 1 + lr * 0.5, 1):clip(p["b" .. i].m), "#f6b8cf")
  if r >= 5 then
    c:paint({ "aa", "as" }, cx, cy - 1, { a = "#a894dc", s = "#3e2f66" })
    c:px(cx - 1, cy, "#a894dc"); c:px(cx + 2, cy, "#a894dc")
  else
    c:paint({ "aa", "as" }, cx, cy - 1, { a = "#a894dc", s = "#3e2f66" })
  end
end
c:button(16, 38)
local t = c:save(O .. "aseprite/ph/vandaenopsis.aseprite", O .. "png/ph/vandaenopsis.png")
print(GV.report(t))
