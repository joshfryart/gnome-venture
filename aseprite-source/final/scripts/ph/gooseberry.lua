local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local red = GV.ramp("#d6322b")
local leafR = GV.ramp("#58a03e")
local stalk = c:line({ {31, 9}, {32, 14}, {32, 22} }, 3)
local leaf = c:poly({ {33, 15}, {36, 9}, {41, 6}, {48, 5}, {47, 10}, {43, 14}, {37, 16} })
local berry = c:ellipse(32, 38, 18, 17)
local p = c:build{
  { "stalk", stalk, "moss", { flat = true } },
  { "leaf", leaf, leafR },
  { "berry", berry, red, { gloss = { 22, 28 } } },
}
-- leaf midrib
c:fill(c:line({ {36, 14}, {41, 10}, {46, 7} }, 1), leafR.shade)
-- meridian veins
local skip = { [red.gloss] = true, [red.dot] = true, [red.rim] = true }
for _, f in ipairs({ -0.62, -0.3, 0.3, 0.62 }) do
  for y = 23, 53 do
    local dy = y - 38
    local hw = math.sqrt(math.max(0, 17 * 17 - dy * dy)) * 1.05
    local x = math.floor(32 + f * hw + 0.5)
    if berry:shrink(2):has(x, y) then
      local cur = c:get(x, y)
      if not skip[cur] then
        if cur == red.shade or cur == red.deep or cur == red.bounce then c:px(x, y, red.deep) else c:px(x, y, red.shade) end
      end
    end
  end
end
for y = 24, 52 do
  if not skip[c:get(32, y)] then
    local cur = c:get(32, y)
    c:px(32, y, (cur == red.shade or cur == red.deep) and red.deep or red.shade)
  end
end
-- dried tuft at bottom
c:paint({ "w.w.w", ".www." , "..w.." }, 30, 52, { w = "#5e2f1e" })
local t = c:save(O .. "aseprite/ph/gooseberry.aseprite", O .. "png/ph/gooseberry.png")
print(GV.report(t))
