local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local pink = GV.ramp("#e9b8d0")
local body = c:rrect(12, 14, 42, 51, 4)
local topcap = c:rrect(8, 9, 46, 16, 3)
local botcap = c:rrect(8, 49, 46, 56, 3)
local tail = c:line({ {41, 31}, {48, 32}, {52, 36}, {53, 41}, {50, 45}, {46, 46} }, 3)

c:build{
  { "body", body, pink },
  { "tail", tail, pink, { flat = true } },
  { "topcap", topcap, GV.ramp("#9a6b3f") },
  { "botcap", botcap, GV.ramp("#9a6b3f") },
}
-- three sagging winding lines across the spool
local wind = "#c98aab"
for _, y in ipairs({ 22, 31, 40 }) do
  local l = c:line({ {12, y}, {19, y + 2}, {27, y + 3}, {35, y + 2}, {42, y} }, 1)
  l:each(function(x, yy) if body:has(x, yy) then c:px(x, yy, wind) end end)
end
-- spindle hole on the top cap
c:paint({ ".hh.", "hhhh" }, 25, 11, { h = "#5e2f1e" })

local t = c:save(O .. "aseprite/animals/item-silk-thread.aseprite", O .. "png/animals/item-silk-thread.png")
print(GV.report(t))
