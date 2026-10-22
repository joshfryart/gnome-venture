local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-hybrid/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- bell body: dome on top, concave flare to a wide base
local body = c:mask()
for y = 14, 52 do
  local hw
  if y <= 30 then
    local t = (30 - y) / 16
    hw = 15 * math.sqrt(math.max(0, 1 - t * t))
  else
    local t = (y - 30) / 22
    hw = 15 - 1.5 * math.sin(t * math.pi) + 7 * t * t
  end
  if y >= 51 then hw = hw - (y - 50) end
  local x0 = math.floor(31.5 - hw + 0.5); local x1 = math.floor(31.5 + hw + 0.5) + 1
  if x1 >= x0 then body:add(c:rect(x0, y, x1, y)) end
end
local head = c:ellipse(32.5, 29, 8.5, 8.5)
c:build{
  { "body", body, "moss", { gloss = { 21, 24 } } },
  { "head", head, GV.ramp("#4a8a3e") },
}
-- carved groove across lower body (gentle smile)
c:fill(c:line({ {14, 40}, {22, 42}, {32, 43}, {42, 42}, {50, 40} }, 2), "#2f5a2a")
-- gold beak pointing right
c:paint({ "gg..", "gggg", "gg.." }, 41, 27, { g = "#e8a317" })
c:px(41, 27, "#f5cf6a")
c:eye(34, 25, true)
c:ground(32, 53, 20, 1.5)
local t = c:save(O .. "aseprite/ph/carved-heron.aseprite", O .. "png/ph/carved-heron.png")
print(GV.report(t))
