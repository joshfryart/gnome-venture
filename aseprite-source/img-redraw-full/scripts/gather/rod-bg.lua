local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 100, h = 100, mode = "scene", out = 2 }
-- half-size grid: 100x100
local W, H = 100, 100

local function wave(y0, amp, per, ph, ybot)
  local pts = {}
  for x = 0, W, 2 do
    pts[#pts + 1] = { x, math.floor(y0 + amp * math.sin((x + ph) / per) + 0.5) }
  end
  pts[#pts + 1] = { W, ybot }; pts[#pts + 1] = { 0, ybot }
  return c:poly(pts)
end

-- water: hard bands
local bands = { {14, 30, "#86d6cf", "#b4ece2"}, {31, 50, "#46a6b4", "#86d6cf"},
                {51, 70, "#25708c", "#46a6b4"}, {71, 99, "#143d57", "#25708c"} }
for _, b in ipairs(bands) do c:fill(c:rect(0, b[1], W - 1, b[2]), b[3]) end
-- light shafts: one lighter band step
local shafts = c:poly({ {15,14}, {31,14}, {56,100}, {28,100} })
shafts:add(c:poly({ {48,14}, {60,14}, {88,100}, {70,100} }))
shafts:add(c:poly({ {75,14}, {81,14}, {100,100}, {94,100} }))
for _, b in ipairs(bands) do c:fill(shafts:copy():clip(c:rect(0, b[1], W - 1, b[2])), b[4]) end

-- sky
c:fill(c:rect(0, 0, W - 1, 7), "#f4ecc8")
c:fill(c:rect(0, 8, W - 1, 13), "#cfe6c6")
c:fill(c:ellipse(80, 5.5, 3.5, 3.5), "#fff6c9")
-- far shore hills
c:fill(wave(9, 2, 6, 0, 14), "#9fc99a")
c:fill(wave(12, 1.5, 4, 3, 14), "#7fb085")
-- surface line
c:fill(c:line({ {0,14}, {12,13}, {25,14}, {38,13}, {50,14}, {63,13}, {75,14}, {88,13}, {99,14} }, 1), "#f1fff4")

-- lily pads with notch, lit top
local function pad(cx, cy, rx)
  local m = c:ellipse(cx, cy, rx, 2):cut(c:poly({ {cx, cy}, {cx + 3, cy + 3}, {cx + 5, cy + 3} }))
  c:part(m, GV.ramp("#4c9a56", { rim = "#78c06e", gloss = "#a6d98a" }), { flat = true })
  c:fill(c:rect(cx - rx + 2, cy - 2, cx + rx - 3, cy - 2):clip(m), "#78c06e")
end
pad(17, 14, 10.5); pad(79, 14.5, 8.5)
local function flower(x, y)
  c:paint({ ".p.p.", "ppypp", ".ppp." }, x - 2, y - 1, { p = "#f5a9bf", y = "#fff3a8" })
end
flower(22, 12); flower(82, 12)

-- bank
c:part(wave(89, 1.5, 5, 0, 100), GV.ramp("#8c7a58"), { flat = true })
c:part(wave(93, 1.5, 4, 7, 100), GV.ramp("#a8946c"), { flat = true })
for _, pb in ipairs({ {20,96}, {41,95}, {58,97}, {73,95} }) do
  c:fill(c:rect(pb[1], pb[2], pb[1] + 2, pb[2] + 1), "#c9b78f")
end

-- reeds framing both sides
local stem = GV.ramp("#5f8a3e")
local function reed(x, top, lean)
  c:part(c:line({ {x, 99}, {x + lean, top} }, 2), stem, { flat = true })
end
local function blade(pts) c:part(c:line(pts, 2), GV.ramp("#7fae4c"), { flat = true }) end
reed(5, 25, 0); reed(9, 34, 1); reed(12, 45, 0)
blade({ {7,99}, {3,70}, {0,58} }); blade({ {13,99}, {17,78}, {20,70} })
reed(93, 26, 0); reed(96, 34, -1); reed(89, 30, 0)
blade({ {94,99}, {98,72}, {99,62} }); blade({ {88,99}, {84,80}, {81,72} })
-- cattails
c:part(c:rrect(4, 31, 6, 39, 1), GV.ramp("#7a5230"), { flat = true })
c:part(c:rrect(88, 26, 90, 34, 1), GV.ramp("#7a5230"), { flat = true })

local t = c:save(O .. "aseprite/gather/rod-bg.aseprite", O .. "png/gather/rod-bg.png")
print(GV.report(t))
