local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local function kernel(cx, cy, dir)
  -- tilted oval: stack of offset rows
  local m = c:mask()
  for dy = -5, 5 do
    local hw = math.floor(3.6 * math.sqrt(math.max(0, 1 - (dy / 5.6) ^ 2)) + 0.5)
    local off = math.floor(dir * dy * 0.45 + 0.5)
    if hw >= 1 then m:add(c:rect(cx + off - hw + 1, cy + dy, cx + off + hw - 1, cy + dy)) end
  end
  return m
end
local gold = GV.ramp("#dcb06a", { shade = "#b8661a" })
local parts = {
  { "stem", c:rect(29, 30, 31, 55), GV.ramp("#b8893f"), { flat = true } },
  { "leaf", c:line({ {31, 48}, {35, 43}, {40, 38}, {45, 33} }, 4):add(c:line({ {33, 47}, {39, 42} }, 3)), "moss" },
}
local L = { {23, 42}, {23, 34}, {23, 26}, {23, 19} }
for i, p in ipairs(L) do
  parts[#parts + 1] = { "l" .. i, kernel(p[1], p[2], 1), gold }
  parts[#parts + 1] = { "r" .. i, kernel(60 - p[1], p[2], -1), gold }
end
parts[#parts + 1] = { "top", c:ellipse(30, 12, 3.5, 5.5), gold }
c:build(parts)
local t = c:save(O .. "aseprite/ico/ico-grain.aseprite", O .. "png/ico/ico-grain.png")
print(GV.report(t))
