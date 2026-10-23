-- ph/loach-scale : one round grey-green fish scale from the Stone Loach, tilted,
-- pale embedded root with radial grooves, mottled exposed edge with growth rings
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- local shape (u right, v down), rotated by A about (CX,CY)
local CX, CY, A = 32, 31, math.rad(-20)
local ca, sa = math.cos(A), math.sin(A)
local function rot(u, v) return { CX + u * ca - v * sa, CY + u * sa + v * ca } end
local function dot(m, u, v)
  local p = rot(u, v); m:set(math.floor(p[1] + 0.5), math.floor(p[2] + 0.5))
end

-- whole scale: scalloped root edge on top, big round free edge below
local pts = {}
for i = 0, 30 do
  local u = -15 + i
  pts[#pts + 1] = rot(u, -16 - 2.2 * math.abs(math.sin((u + 15) / 30 * 3 * math.pi)))
end
pts[#pts + 1] = rot(17, -11)
for i = 0, 40 do
  local t = i / 40 * math.pi
  pts[#pts + 1] = rot(18 * math.cos(t), 1 + 18 * math.sin(t))
end
pts[#pts + 1] = rot(-17, -11)
local scale = c:poly(pts)

-- root: paler embedded band, its lower edge a soft wave
local rp = {}
for i = 0, 40 do
  local u = -20 + i
  rp[#rp + 1] = rot(u, -5 + 1.2 * math.sin(u / 2.5))
end
rp[#rp + 1] = rot(20, -24); rp[#rp + 1] = rot(-20, -24)
local root = c:poly(rp):clip(scale)
local exposed = scale:copy():cut(root)

local body = GV.ramp("#8d9a90", { gloss = "#c8ecdc" })
local pale = GV.ramp("#c9c5bc", { gloss = "#fff3c8", dot = "#f8fcf4", rim = "#e6efe0" })
c:build{
  { "exposed", exposed, body, { light = scale, gloss = false, cres = 6 } },
  { "root", root, pale, { light = scale, gloss = { 18, 22 }, contact = true } },
}

-- radial grooves fanning out across the root
local gr = c:mask()
for _, u in ipairs({ -11, -5, 1, 7, 12 }) do
  for k = 0, 40 do
    local f = k / 40
    dot(gr, u * (0.45 + 0.55 * f), -6 - 10 * f)
  end
end
c:fill(gr:clip(root:shrink(2)), "#a8a49c")

-- growth rings on the exposed part (1 px arcs)
local rings = c:mask()
for _, r in ipairs({ 6, 10, 14 }) do
  for i = 0, 160 do
    local t = 0.08 * math.pi + i / 160 * 0.84 * math.pi
    dot(rings, r * math.cos(t), 1 + r * math.sin(t))
  end
end
c:fill(rings:clip(exposed:shrink(2)):cut(root:grow(1)), "#74827a")

-- silvery sheen streak across the lit side of the exposed part
local sheen = c:mask()
for k = 0, 30 do
  local t = 0.55 * math.pi + k / 30 * 0.35 * math.pi
  dot(sheen, 12 * math.cos(t), 1 + 12 * math.sin(t))
  dot(sheen, 12 * math.cos(t), 2 + 12 * math.sin(t))
end
c:fill(sheen:clip(exposed:shrink(3)), "#b8deee")

-- loach mottle diamonds
local dia = { ".x.", "xxx", ".x." }
for _, d in ipairs({ { -6, 4 }, { 6, 6 }, { 11, -1 }, { 0, 12 }, { -12, -1 } }) do
  local q = rot(d[1], d[2])
  c:spot(c:ascii(dia, math.floor(q[1] + 0.5) - 1, math.floor(q[2] + 0.5) - 1), "#4a5450", "#8d9a90")
end

local t = c:save(D .. "final/aseprite/ph/loach-scale.aseprite", PNG .. "loach-scale.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
