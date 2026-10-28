-- wonder-the-mirror-salt-flat.lua : after rain the salt flat mirrors the dawn sky; a glint on the ground is not in the sky.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 66
local NP = { gloss = false, rim = false, bounce = false, outline = false }
local function my(y) return 2 * HOR + 1 - y end -- mirror row

local dawn = L.SKY.dawn
local rev = {}
for i = #dawn, 1, -1 do rev[#rev + 1] = dawn[i] end
-- sky (the lightest band sits at the horizon) and its reflection
c:bands(c:rect(0, 0, W - 1, HOR), dawn, { dir = "v" })
c:bands(c:rect(0, HOR + 1, W - 1, H - 1), rev, { dir = "v" })
-- sun glow disc at the horizon and its reflection
local function sun(cy, dir)
  c:fill(c:ellipse(150, cy, 12, 12):clip(dir < 0 and c:rect(0, 0, W, HOR) or c:rect(0, HOR + 1, W, H)), "#fbe0a8")
  c:fill(c:ellipse(150, cy, 8, 8):clip(dir < 0 and c:rect(0, 0, W, HOR) or c:rect(0, HOR + 1, W, H)), "#fff1c8")
end
sun(HOR, -1); sun(HOR + 1, 1)
-- stars (top only, soft in the mirror)
for _, s in ipairs({ {20,8},{50,16},{84,6},{110,18},{200,10},{230,22},{176,5},{34,26} }) do c:px(s[1], s[2], "#fff1c8"); c:px(s[1], my(s[2]), "#c3b2ea") end
-- mountains: andean range and a snow-capped volcano on the right (top + mirror)
local function mount(mirror)
  local function Y(y) return mirror and my(y) or y end
  local function poly(pts) local q = {}; for _, p in ipairs(pts) do q[#q + 1] = { p[1], Y(p[2]) } end; return c:poly(q) end
  local top = mirror and (HOR + 1) or 0
  local function clipped(m) return m end
  local m1 = poly({ {0,HOR+1},{0,56},{14,50},{30,56},{46,46},{64,54},{84,60},{98,56},{110,HOR+1} })
  c:part(m1, GV.ramp("#8a78b8"), { cres = 4, deep = 6, gloss = false, rim = false, outline = false })
  local m2 = poly({ {170,HOR+1},{184,48},{196,38},{206,32},{214,38},{226,48},{240,56},{240,HOR+1} })
  c:part(m2, GV.ramp("#7a6aa8"), { cres = 6, deep = 9, gloss = false, rim = false, outline = false })
  c:fill(poly({ {196,38},{206,32},{214,38},{210,40},{206,37},{202,41} }), "#f5e8e0")
  c:fill(poly({ {46,46},{40,52},{44,51},{48,54},{52,50},{54,52} }), "#f5e8e0")
end
mount(false); mount(true)
-- clouds top + mirrored
for _, cl in ipairs({ {40,30,18}, {120,22,14}, {190,18,18}, {80,44,12}, {232,40,10} }) do
  L.cloud(c, cl[1], cl[2], cl[3], "#f8d8c8", "#f0aa98")
  -- mirrored: swap the two tones (lit side is now below)
  local cx, cy, rx = cl[1], my(cl[2]), cl[3]
  local m = c:ellipse(cx, cy, rx, 2.2); m:add(c:ellipse(cx - rx * 0.4, cy + 1.5, rx * 0.5, 2.2)); m:add(c:ellipse(cx + rx * 0.3, cy + 2, rx * 0.45, 2.4))
  c:fill(m, "#f0aa98"); c:fill(m:copy():clip(c:rect(0, cy + 1, W, H)), "#f8d8c8")
end
-- the shimmer: thin horizontal streaks across the mirror (breeze lines) and a few ripple rings
for i = 0, 12 do local x = (i * 61 + 9) % (W - 20); local y = HOR + 4 + (i * 17) % 58; c:fill(c:rect(x, y, x + 8 + i % 6, y), "#fbe0a8") end
-- horizon line of very thin white salt edge
c:fill(c:rect(0, HOR, W - 1, HOR), "#f1ece0"); c:fill(c:rect(0, HOR + 1, W - 1, HOR + 1), "#c9c5bc")
-- distant flamingos (tiny) on the horizon strip
for _, x in ipairs({ 120, 126, 134 }) do c:px(x, HOR - 1, "#e46a9b"); c:px(x, HOR - 2, "#f6b8cf") end

-- foreground salt crust: hexagon-cracked white, wavy top
local crust = L.below(c, function(x) return 114 + 3 * math.sin(x / 22 + 1) + 2 * math.sin(x / 8) end)
c:part(crust, GV.ramp("#f1ece0"), { cres = 5, deep = 8, gloss = false, rim = false, outline = false, pale = true })
-- hex crack pattern (staggered rows of short crack segments)
for r = 0, 4 do
  local y = 116 + r * 4
  for x = (r % 2) * 7, W, 14 do
    if crust:has(x, y) then c:px(x, y, "#c9c5bc"); c:px(x + 1, y + 1, "#c9c5bc"); c:px(x + 2, y + 1, "#c9c5bc"); c:px(x + 3, y, "#c9c5bc"); c:px(x + 3, y - 1, "#c9c5bc"); c:px(x, y - 1, "#c9c5bc") end
  end
end
-- raised salt lip along the shore edge (a line of tiny pale crests)
for x = 0, W - 1, 3 do local y = math.floor(114 + 3 * math.sin(x / 22 + 1) + 2 * math.sin(x / 8)); c:px(x, y, "#ffffff" == "" and "#fff" or "#fff3c8") end

-- flamingos wading, with reflections (left): chibi
local function flamingo(x, y, flip)
  local f = flip and -1 or 1
  -- reflection first (a flipped paler copy below the feet)
  c:fill(c:ellipse(x, y + 8, 7, 4), "#f0aa98")
  c:fill(c:rect(x - 1, y + 2, x, y + 7), "#e39a86")
  c:fill(c:rect(x + 3 * f, y + 9, x + 3 * f + 1, y + 16), "#e39a86"); c:fill(c:ellipse(x + 4 * f, y + 18, 3, 2), "#f0aa98")
  -- legs
  c:fill(c:rect(x - 2, y, x - 1, y - 9), "#e46a9b"); c:fill(c:rect(x + 2, y, x + 3, y - 7), "#e46a9b")
  c:part(c:ellipse(x, y - 13, 8, 6), GV.ramp("#f08aa8"), { cres = 3, deep = 5 })
  c:part(c:poly({ {x + 5 * f - 1, y - 14}, {x + 7 * f - 1, y - 24}, {x + 9 * f + 1, y - 24}, {x + 8 * f + 1, y - 14} }), GV.ramp("#f08aa8"), { cres = 2, deep = 3, gloss = false })
  c:part(c:ellipse(x + 8 * f, y - 26, 5, 4.5), GV.ramp("#f08aa8"), { cres = 2, deep = 3, gloss = false })
  c:part(c:poly({ {x + 11 * f, y - 28}, {x + 17 * f, y - 25}, {x + 15 * f, y - 22}, {x + 11 * f, y - 24} }), GV.ramp("#2a1a10", { rim = "#5a4a40" }), { flat = true, gloss = false, outline = false })
  c:fill(c:rect(x + 11 * f - (f < 0 and 5 or 0), y - 26, x + 13 * f - (f < 0 and 5 or 0), y - 25), "#f2e4c0")
  c:eye(x + 6 * f - 2, y - 29, true)
  c:part(c:poly({ {x - 7, y - 12}, {x - 13, y - 14}, {x - 9, y - 8} }), GV.ramp("#e46a9b"), { cres = 2, deep = 3, gloss = false })
  c:fill(c:rect(x - 1, y - 13, x + 3, y - 12), "#ffc27a")
end
flamingo(52, 110, false)
flamingo(78, 106, true)
flamingo(34, 104, false)

-- the glint: something golden on a little salt island in the shallows, not in the sky
local gx, gy = 170, 100
c:part(c:ellipse(gx, gy + 6, 14, 4), GV.ramp("#f1ece0"), { cres = 3, deep = 4, gloss = false, pale = true })
c:part(c:ellipse(gx, gy + 3, 4, 3), GV.ramp("#e8a317"), { cres = 2, deep = 3, gloss = false })
c:part(c:rect(gx + 5, gy + 2, gx + 8, gy + 5), GV.ramp("#e8a317"), { flat = true, gloss = false })
c:part(c:ring and c:ellipse(gx - 7, gy + 5, 3, 2) or c:ellipse(gx - 7, gy + 5, 3, 2), GV.ramp("#e8a317"), { flat = true, gloss = false })
c:px(gx - 1, gy + 1, "#fff1c8"); c:px(gx, gy + 1, "#fff1c8")
-- glint star: a 4-point cross
local function star(x, y, r) c:fill(c:rect(x - r, y, x + r, y), "#fff1c8"); c:fill(c:rect(x, y - r, x, y + r), "#fff1c8"); c:px(x, y, "#ffffff" == "" and "#fff" or "#f5cf6a") end
star(gx - 1, gy - 5, 4); star(gx + 8, gy - 1, 2); star(gx - 9, gy + 1, 2)
-- ripples around the island and the flamingos
for _, r in ipairs({ {gx - 20, gy + 11, 8}, {gx + 14, gy + 12, 6}, {52, 124, 14}, {78, 118, 8} }) do c:fill(c:rect(r[1], r[2], r[1] + r[3], r[2]), "#fff3c8") end
L.finish(c, "wonder-the-mirror-salt-flat")
