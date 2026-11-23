-- pl-flfm-6-perch : chibi pal on its dotted perch dish (36x36)
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-flfm-6-perch-20261120-183932/gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }

-- ramps
local spikeR = { gloss="#ffe893", dot="#fff3c8", rim="#ffe893", base="#e3b66f",
                 shade="#bc4e39", deep="#6c3b5a", bounce="#e3b66f" }
local dishR  = GV.ramp("#384083", { bounce = "#6c3b5a", rim = "#5a6aa8", gloss = "#8fa0d0" })
local bodyR  = GV.R.moss

local flat = { flat = true, gloss = false, rim = false, stitch = false, contact = false }

-- spikes (crown of the pal), back layer; small parts, gentle left-lit shading
local function spike(cx, tip)
  return c:poly({ {cx-1.0, 10}, {cx+1.0, 10}, {cx+0.5, tip}, {cx-0.5, tip} })
end
for _, s in ipairs({ {9.5, 7}, {13.5, 4.5}, {17.5, 3.5}, {21.5, 4.5}, {25.5, 7} }) do
  c:part(spike(s[1], s[2]), spikeR, { cres = 1, deep = 1, bounce = false, gloss = false,
                                      stitch = false, contact = false })
end

-- perch dish (under the ball, shallow bowl + base)
local dish = c:mask()
dish:add(c:ellipse(17.5, 20.5, 11.5, 2.5))
dish:add(c:poly({ {6.5, 20.5}, {28.5, 20.5}, {24.5, 26}, {10.5, 26} }))
dish:add(c:ellipse(17.5, 26, 9, 1.5))
c:part(dish, dishR, { gloss = { 8, 19 }, stitch = false, cres = 2, deep = 1 })

-- head-body ball
c:part(c:ellipse(17.5, 14, 9, 6.5), bodyR, { gloss = { 13, 12 }, stitch = false })

-- TEXTURE: dish dots (the pal's diamonds as a sprinkle on the bowl), ball freckles
c:px(11, 22, "#ffe893")
c:px(16, 23, "#e87d2a"); c:px(17, 23, "#e87d2a"); c:px(16, 24, "#e87d2a"); c:px(17, 24, "#e87d2a")
c:px(22, 22, "#e8688f")
c:px(12, 25, "#ffe893")
c:px(11, 16, "#6a9a3a"); c:px(13, 17, "#6a9a3a")
c:px(20, 13, "#2f5a2a"); c:px(21, 14, "#2f5a2a")

-- ground shadow
c:ground(17.5, 29, 11.5, 1.6)

-- tiny accents: the pal's floating diamonds
c:part(c:poly({ {29, 14.5}, {30.5, 16}, {29.5, 17.5}, {28, 16} }), "#e87d2a",
       { flat = true, gloss = false, stitch = false, contact = false, cres = 1, deep = 1 })
c:part(c:poly({ {5.5, 18.5}, {6.5, 19.5}, {5.5, 20.5}, {4.5, 19.5} }), "#e87d2a",
       { flat = true, gloss = false, stitch = false, contact = false })

-- diamond glints (upper-left catch)
c:px(29, 15, "#ffe893")

-- face (big round eyes, tiny mouth)
c:eye(13, 13, true); c:eye(20, 13, true)
c:px(16, 17, "#2b1c26"); c:px(17, 17, "#2b1c26"); c:px(18, 17, "#2b1c26")

local t = c:save("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-flfm-6-perch-20261120-183932/out/pl-flfm-6-perch.aseprite",
                 "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-flfm-6-perch-20261120-183932/out/pl-flfm-6-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw <= 2 and t.margin >= 2)
