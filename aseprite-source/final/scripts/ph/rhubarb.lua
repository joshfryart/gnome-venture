local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local A, B = { 18, 43 }, { 42, 25 }               -- stalk axis (B = cut end)
local dx, dy = B[1] - A[1], B[2] - A[2]
local L = math.sqrt(dx * dx + dy * dy)
local ux, uy = dx / L, dy / L                    -- along the stalk
local nx, ny = -uy, ux                           -- toward the underside (down-right)
local function P(t, s) return { A[1] + ux * t + nx * s, A[2] + uy * t + ny * s } end
local function band(t0, t1, s0, s1) return c:poly({ P(t0, s0), P(t1, s0), P(t1, s1), P(t0, s1) }) end
local H = 7.5
local stalk = band(0, L, -H, H):add(c:ellipse(A[1], A[2], H, H))
local strip = band(-H - 1, L, 3.5, H + 2):clip(stalk)
local cap = band(L - 1, L + 7, -H - 0.5, H + 0.5)
c:build{
  { "stalk", stalk, "petal" },
  { "under", strip, GV.ramp("#c66b50", { rim = "#f0d49a" }), { gloss = false } },
  { "cap", cap, GV.ramp("#3f7a36"), { gloss = false } },
}
-- lengthwise string line
local s = c:line({ P(2, -1), P(L - 4, -1) }, 2):clip(stalk)
s:each(function(x, y) local v = c:get(x, y); if v ~= GV.R.petal.gloss and v ~= GV.R.petal.dot then c:px(x, y, "#b04a78") end end)
-- cut face rings on the cap end
c:fill(band(L + 4, L + 5.5, -H + 2, H - 2), "#5e9a4a")
local t = c:save(O .. "aseprite/ph/rhubarb.aseprite", O .. "png/ph/rhubarb.png")
print(GV.report(t))
