local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local bowlR = GV.ramp("#3f8fb0", { shade = "#2f6290", deep = "#2a3c6c" })
local rice  = GV.ramp("#f1ece0", { shade = "#c9a96e" })
local fishR = GV.ramp("#5a86b8", { shade = "#2f6290", deep = "#2a3c6c" })

-- chopsticks (behind the rice, poking out top right)
local sticks = c:line({ { 36, 25 }, { 51, 12 } }, 2):add(c:line({ { 40, 28 }, { 52, 17 } }, 2))
-- bowl body + rim
local bowl = c:ellipse(31, 31, 21, 21):cut(c:rect(0, 0, 63, 32))
local rim = c:rrect(10, 29, 52, 33, 2)
-- rice dome
local dome = c:ellipse(31, 30, 17, 13):cut(c:rect(0, 30, 63, 63))
-- fish fillet: tapered body along a diagonal, tail at the right
local fish = c:mask()
for i = 0, 10 do
  local tt = i / 10
  local x = 17 + 22 * tt
  local y = 26 - 6 * tt
  local r = 4.4 - 1.8 * math.abs(tt - 0.35)
  fish:add(c:ellipse(x, y, r, r))
end
fish:add(c:poly({ { 38, 20 }, { 45, 14 }, { 46, 22 } }))

local p = c:build{
  { "sticks", sticks, "#d9a660", { flat = true } },
  { "dome", dome, rice, { gloss = { 19, 22 } } },
  { "bowl", bowl, bowlR, { gloss = { 16, 36 } } },
  { "rim", rim, rice, { gloss = false, cres = 1, deep = 0 } },
  { "fish", fish, fishR, { gloss = { 18, 23 } } },
}
-- silver belly along the lower edge of the fillet
local belly = fish:copy():cut(fish:shift(-1, -2)):cut(c:poly({ { 37, 10 }, { 50, 10 }, { 50, 26 }, { 37, 26 } }))
c:fill(belly, "#c8ecdc")
-- tiger stripes on the back
c:paint({ "s.", ".s", ".s", "s." }, 23, 20, { s = "#2a3c6c" })
c:paint({ "s.", ".s", ".s", "s." }, 28, 18, { s = "#2a3c6c" })
c:paint({ "s.", ".s", ".s", "s." }, 33, 17, { s = "#2a3c6c" })
-- rice grain ticks
for _, g in ipairs({ { 22, 27 }, { 41, 25 }, { 45, 28 }, { 30, 28 }, { 18, 28 }, { 36, 15 }, { 26, 15 } }) do
  c:px(g[1], g[2], "#c9a96e")
end
-- green onion rounds
for _, o in ipairs({ { 24, 15 }, { 41, 23 }, { 33, 25 } }) do
  c:paint({ ".gg.", "gllg", "gllg", ".gg." }, o[1], o[2], { g = "#4a8a3e", l = "#a4b86a" })
end
-- thread-gold foot line
c:seam({ { 20, 48 }, { 42, 48 } })

local t = c:save(O .. "aseprite/ph/mackerel-rice.aseprite", O .. "png/ph/mackerel-rice.png")
print(GV.report(t))
