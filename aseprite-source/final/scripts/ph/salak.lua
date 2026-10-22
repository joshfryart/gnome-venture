local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:ellipse(32, 39, 16, 15)
body:add(c:ellipse(32, 31, 11, 10))
body:add(c:poly({ {22, 32}, {43, 32}, {33, 11}, {32, 11} }))

local leaf = c:poly({ {33, 13}, {37, 8}, {43, 6}, {47, 6}, {44, 10}, {38, 13} })

local p = c:build{
  { "stem", c:rect(30, 7, 33, 14), "wood", { gloss = false } },
  { "leaf", leaf, "moss", { gloss = false } },
  { "body", body, "#a4b86a" },
}
-- diamond scale grid, offset rows
local e, b = "#6a9a3a", "#7ab55c"
local rows = { { 22, 30 }, { 28, 26 }, { 34, 22 }, { 40, 18 }, { 46, 22 } }
for i, r in ipairs(rows) do
  local y, x0 = r[1], r[2]
  for x = x0 + ((i % 2 == 0) and 0 or 0), 46, 8 do
    local ok = true
    for dy = -2, 4 do for dx = -2, 6 do
      if not body:has(x + dx, y + dy) then ok = false end
    end end
    -- keep the lit gloss area clean
    if x < 26 and y < 34 then ok = false end
    if ok then
      c:paint({ "..e..", ".ebe.", "ebbbe", ".ebe.", "..e.." }, x - 2 + 2, y, { e = e, b = b })
    end
  end
end

local t = c:save(O .. "aseprite/ph/salak.aseprite", O .. "png/ph/salak.png")
print(GV.report(t))
