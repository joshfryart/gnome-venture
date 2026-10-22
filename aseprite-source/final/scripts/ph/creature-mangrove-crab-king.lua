local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local legC = GV.ramp("#b6814d")
local shell = GV.ramp("#a5663a")
local crownR = GV.ramp("#e6d2ae")
-- legs (back)
local legs = c:line({ {19,42},{14,46},{12,51} }, 3)
legs:add(c:line({ {45,42},{50,46},{52,51} }, 3))
legs:add(c:line({ {23,45},{19,49},{17,53} }, 3))
legs:add(c:line({ {41,45},{45,49},{47,53} }, 3))
-- arms
local arms = c:line({ {19,37},{15,32},{15,26} }, 3)
arms:add(c:line({ {45,37},{49,32},{49,26} }, 3))
-- claws: chunky lobes with a pincer notch (mirrored)
local clawL = c:ellipse(15, 19, 5.5, 7.5):cut(c:poly({ {16,10},{21,10},{21,12},{17,17} }))
local clawR = c:ellipse(49, 19, 5.5, 7.5):cut(c:poly({ {43,10},{48,10},{47,17},{43,12} }))
-- body: widest, flattest
local body = c:ellipse(32, 40, 16.5, 9.5)
local belly = c:ellipse(32, 44, 9, 4.5):clip(body)
-- eyestalks
local stalks = c:rect(23, 22, 24, 31):add(c:rect(39, 22, 40, 31))
-- crown on the shell between the eyes
local crown = c:rect(25, 28, 38, 32)
crown:add(c:poly({ {25,28},{28,20},{31,28} }))
crown:add(c:poly({ {29,28},{32,18},{35,28} }))
crown:add(c:poly({ {33,28},{36,20},{39,28} }))
local p = c:build{
  { "legs",  legs,  legC, { flat = true } },
  { "arms",  arms,  legC, { flat = true } },
  { "clawL", clawL, shell },
  { "clawR", clawR, shell },
  { "body",  body,  shell },
  { "belly", belly, GV.ramp("#dcb06a"), { gloss = false, contact = false } },
  { "stalks", stalks, "#2a1a10", { flat = true, rim = false } },
  { "crown", crown, crownR, { gloss = { 27, 29 } } },
}
-- notch shading inside pincers
c:px(17, 17, "#8c4a1a"); c:px(16, 16, "#8c4a1a")
c:px(47, 17, "#8c4a1a"); c:px(48, 16, "#8c4a1a")
-- jewels on the crown band
c:px(28, 30, "#dd3a2a"); c:px(32, 30, "#3f8fb0"); c:px(36, 30, "#dd3a2a")
-- eyes atop stalks
c:eye(21, 18); c:eye(38, 18)
-- bossy mouth on the shell front
c:paint({ "u....u", ".uuuu." }, 29, 37, { u = "#4a2c1a" })
c:ground(32, 53, 17, 1.5)
local t = c:save(O .. "aseprite/ph/creature-mangrove-crab-king.aseprite", O .. "png/ph/creature-mangrove-crab-king.png")
print(GV.report(t))
