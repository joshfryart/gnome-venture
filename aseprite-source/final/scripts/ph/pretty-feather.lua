local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local vane = c:poly({ {18,50}, {13,43}, {12,34}, {17,24}, {27,15}, {38,10}, {50,8}, {49,17}, {46,26}, {41,35}, {33,43}, {24,48} })
-- notches in right edge
vane:cut(c:poly({ {48,22}, {43,25}, {47,28} }))
vane:cut(c:poly({ {40,37}, {35,38}, {38,42} }))
local quill = c:line({ {19,48}, {13,57} }, 3)
local p = c:build{
  { "quill", quill, "gold", { flat = true } },
  { "vane", vane, "moss" },
}
-- barbs
for _, b in ipairs({ { {16,40},{21,36} }, { {19,32},{25,28} }, { {25,25},{31,21} }, { {31,42},{28,38} }, { {38,35},{35,31} }, { {43,26},{40,22} } }) do
  for i = 0, 4 do
    local x = math.floor(b[1][1] + (b[2][1]-b[1][1]) * i / 4 + 0.5)
    local y = math.floor(b[1][2] + (b[2][2]-b[1][2]) * i / 4 + 0.5)
    c:px(x, y, "#4a8a3e")
  end
end
-- spine
for i = 0, 40 do
  local x = math.floor(18 + 29 * i / 40 + 0.5)
  local y = math.floor(48 - 36 * i / 40 + 0.5)
  if vane:shrink(1):has(x, y) then c:px(x, y, "#e8f0a8"); if vane:has(x+1, y) then c:px(x+1, y, "#c8d77a") end end
end
local t = c:save(O .. "aseprite/ph/pretty-feather.aseprite", O .. "png/ph/pretty-feather.png")
print(GV.report(t))
