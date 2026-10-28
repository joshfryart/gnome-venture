-- wonder-pearl-diver-cove.lua : calm cove, a diver's raft on top, particular oysters waiting below (cutaway).
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, c, W, H = L.GV, L.new(), L.W, L.H
local SLUG = "wonder-pearl-diver-cove"
local SURF = 48

L.sky(c, "day", SURF)
L.cloud(c, 60, 16, 16); L.cloud(c, 170, 12, 14); L.cloud(c, 120, 28, 10)
-- distant sun glow
c:fill(c:ellipse(206, 14, 6, 6), "#fff1c8")
-- water column: surface light band then deepening bands
c:bands(c:rect(0, SURF, W - 1, H - 1), { "#7fd0e0", "#5ab8d4", "#4aa4c8", "#3f8fb0", "#357ca2", "#2c6a92", "#25637d", "#1f5570" }, { dir = "v" })
-- surface ripple dashes
for i = 0, 16 do
  local x = (i * 31 + 7) % 226; local y = SURF + 1 + (i % 3) * 2
  c:fill(c:rect(x, y, x + 5 + (i % 3) * 3, y), "#d8f4f4")
end
-- light rays under the surface
for _, x in ipairs({ 70, 96, 150, 176 }) do
  for y = SURF + 7, SURF + 38 do c:px(x + (y - SURF) // 2, y, "#6cc4dc") end
end

-- cove walls (rock + pines) left and right
local lw = c:poly({ {0,SURF+4},{0,24},{8,18},{22,22},{32,34},{40,SURF-2},{46,SURF+6},{36,H},{0,H} })
c:part(lw, GV.ramp("#8b8f96"), { cres = 6, deep = 9, outline = false })
local rw = c:poly({ {W,SURF+4},{W,20},{226,16},{214,28},{206,SURF-4},{198,SURF+6},{204,H},{W,H} })
c:part(rw, GV.ramp("#8b8f96"), { cres = 6, deep = 9, outline = false })
-- rock cracks
for _, l in ipairs({ { {4,70},{16,66},{24,74} }, { {6,92},{20,90},{30,96} }, { {218,70},{232,66} }, { {212,92},{222,88},{234,94} } }) do c:seam(l, { free = true, on = 3, off = 0, gap = "#2a1a10" }) end
-- pines on the clifftops
local function pine(x, y, h)
  c:fill(c:rect(x, y, x + 1, y + 4), "#4a2c1a")
  for k = 0, 2 do
    local w = 3 + (2 - k) * 2 + (h > 12 and 1 or 0); local yy = y - k * 5
    c:part(c:poly({ {x + 1 - w, yy}, {x + 1, yy - 7}, {x + 1 + w, yy} }), GV.ramp("#2f5a2a"), { cres = 2, deep = 3, gloss = false, flat = true })
  end
end
pine(10, 24, 14); pine(22, 26, 10); pine(218, 20, 14); pine(230, 20, 10)
-- moss on rock edge
for _, p in ipairs({ {4,40},{10,52},{222,44} }) do c:fill(c:rect(p[1], p[2], p[1] + 5, p[2] + 1), "#4f9a45") end

-- seabed
local sand = L.below(c, function(x) return 112 + 3 * math.sin(x / 20) end)
c:part(sand, GV.ramp("#e8d4a0"), { cres = 5, deep = 8, gloss = false, outline = false })
-- seabed pebbles
for _, p in ipairs({ {24,126},{80,124},{150,128},{208,124},{110,130} }) do c:part(c:ellipse(p[1], p[2], 3, 1.5), GV.ramp("#8b8f96"), { flat = true, gloss = false, outline = false }) end
-- seaweed (curvy)
local function weed(x, y, h, col)
  for k = 0, h do
    local dx = math.floor(math.sin(k / 3 + x) * 2 + 0.5)
    c:fill(c:rect(x + dx, y - k, x + dx + 1, y - k), col)
  end
end
for _, w in ipairs({ {80,112,22},{84,114,16},{168,112,20},{172,114,14},{98,118,10},{50,114,12} }) do weed(w[1], w[2], w[3], "#4f9a45") end
-- coral fans
local function coral(x, y, col)
  c:part(c:rect(x, y - 8, x + 2, y), GV.ramp(col), { flat = true, gloss = false, outline = false })
  c:part(c:rect(x - 4, y - 12, x - 2, y - 6), GV.ramp(col), { flat = true, gloss = false, outline = false })
  c:part(c:rect(x + 5, y - 11, x + 7, y - 6), GV.ramp(col), { flat = true, gloss = false, outline = false })
  c:fill(c:rect(x - 3, y - 7, x + 6, y - 6), col)
end
coral(40, 120, "#e46a9b"); coral(196, 118, "#f08a24")

-- oysters (particular!). lower shell + upper shell hinged at the back, a face in the flesh
local function oyster(cx, cy, s, pearl, open)
  local SH = GV.ramp("#8a82a8", { rim = "#c3b2ea" })
  c:part(c:ellipse(cx, cy + 4 * s, 11 * s, 6 * s), SH, { cres = 3, deep = 6, gloss = false })
  -- flesh
  c:part(c:ellipse(cx, cy + 1 * s, 9 * s, 4 * s), GV.ramp("#f6b8cf"), { flat = true, gloss = false, outline = false })
  -- eyes (grumpy)
  c:eye(cx - 6 * s, cy - 3 * s, true); c:eye(cx + 3 * s, cy - 3 * s, true)
  -- frown brows
  for k = 0, 3 do c:px(cx - 7 * s + k, cy - 5 * s + k // 2, "#2a1a10"); c:px(cx + 6 * s - k, cy - 5 * s + k // 2, "#2a1a10") end
  c:fill(c:rect(cx - 2, cy + 2 * s, cx + 1, cy + 2 * s), "#2a1a10")
  c:px(cx - 3, cy + 2 * s + 1, "#2a1a10"); c:px(cx + 2, cy + 2 * s + 1, "#2a1a10")
  -- upper shell, propped open
  local up = c:ellipse(cx, cy - 9 * s, 12 * s, 7 * s); up:cut(c:rect(cx - 14 * s, cy - 11 * s + open, cx + 14 * s, cy + 3 * s))
  c:part(up, SH, { cres = 3, deep = 6, gloss = false })
  for k = -1, 1 do c:fill(c:rect(cx + k * 5 * s, cy - 18 * s, cx + k * 5 * s, cy - 14 * s), "#6a6290") end
  if pearl then
    c:part(c:ellipse(cx + 1, cy + 6 * s, 4, 4), GV.ramp("#f4ecdc", { dot = "#fffaf0", gloss = "#fffaf0" }), { cres = 2, deep = 3, gloss = false })
    c:px(cx, cy + 5 * s, "#fffaf0"); c:px(cx - 1, cy + 5 * s, "#fffaf0")
    for _, d in ipairs({ {-8,0},{10,1},{1,-9} }) do c:px(cx + d[1] + 1, cy + d[2] + 5 * s, "#fff1c8"); c:px(cx + d[1] + 2, cy + d[2] + 5 * s, "#fff1c8") end
  end
  c:ground(cx, cy + 10 * s, 12 * s, 2, "#b8a070")
end
oyster(76, 106, 1, false, 2)
oyster(172, 108, 1, false, 1)
oyster(124, 108, 1.2, true, 2)

-- fish and bubbles
local function fish(x, y, dir, col)
  c:part(c:ellipse(x, y, 5, 3), GV.ramp(col), { flat = true, gloss = false, outline = false })
  c:part(c:poly({ {x - dir * 4, y}, {x - dir * 9, y - 4}, {x - dir * 9, y + 4} }), GV.ramp(col), { flat = true, gloss = false, outline = false })
  c:px(x + dir * 2, y - 1, "#2a1a10")
end
fish(96, 76, 1, "#f08a24"); fish(148, 90, -1, "#e8a317"); fish(44, 100, 1, "#f6b8cf")
for _, b in ipairs({ {116,92},{118,86},{115,80},{138,76},{140,70},{104,98},{187,80},{60,84} }) do
  c:px(b[1], b[2], "#d8f4f4"); c:px(b[1] + 1, b[2], "#d8f4f4"); c:px(b[1], b[2] + 1, "#a9d6ea"); c:px(b[1] + 1, b[2] + 1, "#a9d6ea")
end

-- the raft on the surface
local RX, RY = 120, SURF - 1
c:part(c:rect(RX - 36, RY - 2, RX + 36, RY + 5), GV.ramp("#c9a96e"), { cres = 3, deep = 5, gloss = false })
for x = RX - 30, RX + 30, 10 do c:fill(c:rect(x, RY - 2, x, RY + 4), "#7a4a1f") end
-- float barrels
for _, x in ipairs({ RX - 30, RX + 30 }) do c:part(c:ellipse(x, RY + 6, 5, 3), GV.ramp("#d6322b"), { cres = 2, deep = 3, gloss = false }) end
-- basket + net bag, and a rope down to the seabed
c:part(c:rect(RX + 14, RY - 8, RX + 24, RY - 2), GV.ramp("#b07a45"), { cres = 2, deep = 4, gloss = false })
c:seam({ {RX + 15, RY - 5}, {RX + 23, RY - 5} }, { on = 2, off = 1 })
for y = RY + 6, 100 do c:px(RX + 24, y, (y % 2 == 0) and "#c9a96e" or "#9a6b3f") end
c:part(c:ellipse(RX + 24, 102, 3, 3), GV.ramp("#8b8f96"), { flat = true, gloss = false, outline = false })
-- bamboo pole with a little paper lantern
c:fill(c:rect(RX - 30, RY - 22, RX - 29, RY - 2), "#c9b05a")
c:part(c:ellipse(RX - 29, RY - 24, 4, 4), GV.ramp("#d6322b"), { cres = 2, deep = 3, gloss = false })
-- the diver (sitting on the raft edge, tenugui headcloth, blue-white wrap, cheeks puffed, holding breath)
local DX, DY = RX - 6, RY - 2
c:part(c:ellipse(DX - 4, DY - 1, 4, 3), GV.ramp("#c9966a"), { flat = true, gloss = false })
c:part(c:ellipse(DX + 6, DY - 1, 4, 3), GV.ramp("#c9966a"), { flat = true, gloss = false })
c:part(c:ellipse(DX + 1, DY - 8, 9, 8), GV.ramp("#f4f0e0", { shade = "#c5c9d8", deep = "#9a9fb8" }), { cres = 3, deep = 5, gloss = false })
c:seam({ {DX - 5, DY - 8}, {DX + 7, DY - 8} }, { on = 2, off = 1, gap = "#4a6ea8" })
c:part(c:ellipse(DX + 1, DY - 19, 8, 7), GV.ramp("#c9966a"), { cres = 3, deep = 5, gloss = false })
c:part(c:ellipse(DX + 1, DY - 23, 8, 4), GV.ramp("#f4f0e0", { shade = "#c5c9d8", deep = "#9a9fb8" }), { cres = 2, deep = 3, gloss = false, outline = false, contour = "#2a1a10" })
c:fill(c:rect(DX - 7, DY - 22, DX + 9, DY - 21), "#4a6ea8")
c:part(c:ellipse(DX - 5, DY - 20, 2, 2), GV.ramp("#d8895a"), { flat = true, gloss = false, outline = false })
c:part(c:ellipse(DX + 7, DY - 20, 2, 2), GV.ramp("#d8895a"), { flat = true, gloss = false, outline = false })
c:eye(DX - 4, DY - 21, true); c:eye(DX + 3, DY - 21, true)
c:fill(c:rect(DX - 1, DY - 14, DX + 3, DY - 14), "#2a1a10")
c:part(c:ellipse(DX - 12, DY - 7, 3, 4), GV.ramp("#c9966a"), { flat = true, gloss = false })
c:part(c:ellipse(DX + 14, DY - 7, 3, 4), GV.ramp("#c9966a"), { flat = true, gloss = false })
-- the diver's feet dangling into the water
c:part(c:ellipse(DX - 3, DY + 6, 3, 4), GV.ramp("#c9966a"), { flat = true, gloss = false, outline = false })
c:part(c:ellipse(DX + 5, DY + 6, 3, 4), GV.ramp("#c9966a"), { flat = true, gloss = false, outline = false })

L.finish(c, SLUG)
