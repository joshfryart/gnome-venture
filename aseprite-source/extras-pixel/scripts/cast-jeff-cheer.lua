-- Jeff cheer (win pose): both arms thrown up, mouth wide open, confetti bits in the air. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dy = 4
local body = K.jeffBody(c, 0, dy)

-- both arms up in a V, fists at the ends
local armL = c:line({ {18, 36}, {12, 28}, {11, 21} }, 4); armL:add(c:ellipse(10, 18, 3.5, 3.5))
armL:cut(body:grow(1))
local armR = c:line({ {44, 34}, {50, 26}, {50, 20} }, 4); armR:add(c:ellipse(51, 17, 3.5, 3.5))
armR:cut(body:grow(1))

-- confetti: small flat bits, red / gold / purple / water
local function dia(x, y) return c:ascii({ ".x.", "xxx", ".x." }, x, y) end
local conf = {
  { dia(18, 8), "#dd3a2a" }, { dia(43, 7), "#8a5fd0" },
  { dia(6, 27), "#3f8fb0" }, { dia(54, 26), "#e8a317" },
}
local parts = { K.jeffArm("armL", armL), K.jeffArm("armR", armR), K.jeffBodyPart(body) }
for i, b in ipairs(conf) do parts[#parts+1] = { "c"..i, b[1], GV.ramp(b[2]), { flat = true, contact = false } } end
c:build(parts)
K.jeffFace(c, 0, dy, "shout")                                        -- eyes wide, brows up, mouth wide open
K.save(c, "jeff-cheer")
