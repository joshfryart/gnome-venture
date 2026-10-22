local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local LEG = "#2f5a2a"
local greens = { GV.ramp("#7ab55c"), GV.ramp("#86bf60"), GV.ramp("#6eab56") }
local wingR = GV.ramp("#f8eed2")

-- bodies: back (bottom row) to front (top row); {cx,cy,rx,ry,tone,legs?}
local B = {
  { 18,   43,   7,   6,   1, true },   -- bottom left
  { 45,   43,   7,   6,   3, true },   -- bottom right
  { 31.5, 44.5, 7.5, 6.5, 2, true },   -- bottom middle (front of bottom row)
  { 24.5, 33,   6.5, 5.5, 3 },         -- mid left
  { 38.5, 33,   6.5, 5.5, 1 },         -- mid right
  { 44,   23.5, 4.5, 4 ,  2 },         -- small one perched on the right
  { 31.5, 22.5, 6,   5,   1 },         -- top
}

-- stub legs under the bottom row (behind everything)
for _, b in ipairs(B) do
  if b[6] then
    local by = math.floor(b[2] + b[4])
    for _, dx in ipairs({ -4, 0, 4 }) do
      local x = math.floor(b[1] + dx)
      c:part(c:line({ { x, by - 1 }, { x + (dx < 0 and -1 or (dx > 0 and 1 or 0)), by + 2 } }, 2), GV.ramp(LEG), { flat = true })
    end
  end
end

-- antennae flicks from the top two bodies (behind them)
c:part(c:line({ { 29, 19 }, { 27, 15 }, { 25, 14 } }, 2), GV.ramp(LEG), { flat = true })
c:part(c:line({ { 34, 19 }, { 36, 15 }, { 38, 14 } }, 2), GV.ramp(LEG), { flat = true })
c:part(c:line({ { 46, 21 }, { 48, 18 }, { 50, 17 } }, 2), GV.ramp(LEG), { flat = true })

local bodies = {}
for i, b in ipairs(B) do
  local m = c:ellipse(b[1], b[2], b[3], b[4])
  bodies[i] = c:part(m, greens[b[5]], {})
  -- cream wing lump on the upper-left back
  local w = c:ellipse(b[1] - b[3] * 0.45, b[2] - b[4] * 0.45, math.max(2.5, b[3] * 0.45), 1.6):clip(m:shrink(1))
  c:part(w, wingR, { flat = true, contact = false })
end

-- faces: small locked eyes low on each visible body
local function face(cx, cy, gap)
  local x = math.floor(cx)
  c:eye(x - gap - 2, cy, true); c:eye(x + gap - 0, cy, true)
end
face(17, 44, 2)     -- bottom left
face(46, 44, 2)     -- bottom right
face(31.5, 46, 2)   -- bottom middle
face(24, 34, 2)     -- mid left
face(39, 34, 2)     -- mid right
face(32, 23, 2)     -- top
c:eye(43, 24, true); c:eye(46, 24, true)  -- small perched one (tight)

local t = c:save(O .. "aseprite/ph/creature-aphid-swarm.aseprite", O .. "png/ph/creature-aphid-swarm.png")
print(GV.report(t))
