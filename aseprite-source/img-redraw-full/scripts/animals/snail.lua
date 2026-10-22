local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"
local body = GV.ramp("#cdbb8f")
local stalkR = GV.ramp("#b9a678")
local shellR = GV.ramp("#c47a3a")
-- stalks (behind head), tilting apart
local stalks = c:line({ {45, 32}, {43, 17} }, 3):add(c:line({ {50, 32}, {53, 17} }, 3))
stalks:add(c:ellipse(43, 15, 3)):add(c:ellipse(53, 15, 3))
-- foot + rising head at right
local foot = c:rrect(10, 43, 53, 51, 4)
foot:add(c:poly({ {10, 46}, {7, 51}, {10, 52} }))       -- tapered tail
local head = c:rrect(40, 28, 53, 50, 6)
foot:add(head)
local shell = c:ellipse(27.5, 31.5, 17)
c:build{
  { "stalks", stalks, stalkR, { flat = true } },
  { "body", foot, body, { gloss = { 45, 31 } } },
  { "shell", shell, shellR, { gloss = { 17, 20 } } },
}
-- spiral groove, three turns out from the centre
local pts = {}
local a = 13 / (2.6 * 2 * math.pi)
for i = 0, 120 do
  local th = i * (2.6 * 2 * math.pi) / 120
  local r = 1.2 + a * th
  pts[#pts + 1] = { math.floor(28 + r * math.cos(th + 1.6) + 0.5), math.floor(32 + r * math.sin(th + 1.6) + 0.5) }
end
local sp = c:line(pts, 2):clip(shell:shrink(2))
c:fill(sp, "#7a4a1f")
c:gloss(shell, shellR, { 17, 20 })
-- eyes at stalk tips
c:eye(42, 14, true); c:eye(52, 14, true)
-- tiny smile
c:paint({ "u..u", ".uu." }, 46, 40, { u = "umber" })
c:ground(31, 53, 20, 1.5)
local t = c:save(O .. "aseprite/animals/snail.aseprite", O .. "png/animals/snail.png")
print(GV.report(t))
