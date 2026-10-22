local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene", bleed = "lr" }

-- soil strip under the hedge
c:part(c:rect(-4, 38, 67, 45), "#7a4a1f", { gloss = false, cres = 2 })

-- hedge body: lumpy band with sharp holly-leaf points on top (period 6.4 px, tiles)
local body = c:rect(-6, 28, 69, 39)
for i = -1, 10 do
  local cx = 3.2 + 6.4 * i
  body:add(c:ellipse(cx, 29, 4, 5))
  -- leaf points: one tall centre spike, two small side spikes
  local x = math.floor(cx + 0.5)
  body:add(c:poly({ { x - 2, 25 }, { x + 0.5, 19 }, { x + 3, 25 } }))
  body:add(c:poly({ { x + 2, 27 }, { x + 4.5, 22 }, { x + 5, 27 } }))
end
c:part(body, GV.ramp("#4a8a3e", { shade = "#2f5a2a", deep = "#24461f" }), { gloss = false, cres = 5 })

-- leaf highlights: small pointed leaf glints on the lit side of each lump
for i = -1, 10 do
  local x = math.floor(3.2 + 6.4 * i + 0.5)
  c:paint({ "..h", ".h.", "h.." }, x - 3, 25, { h = "#7ab55c" })
  c:px(x, 21, "#a4b86a"); c:px(x + 4, 24, "#7ab55c")
  c:paint({ "d.", ".d" }, x + 1, 33, { d = "#2f5a2a" }) -- leaf separations
end

-- berry pairs (signature), pair-gap-pair rhythm
local berry = { "GR.", "RRS", ".SS" }
for _, x in ipairs({ 2, 5, 14, 18, 27, 30, 40, 43, 53, 56 }) do
  local y = (x == 5 or x == 18 or x == 30 or x == 43 or x == 56) and 32 or 30
  c:paint(berry, x, y, { G = "#ff9158", R = "#dd3a2a", S = "#ae2a2a" })
end

local t = c:save(O .. "aseprite/ph/holly-hedge-straight.aseprite", O .. "png/ph/holly-hedge-straight.png")
print(GV.report(t))
