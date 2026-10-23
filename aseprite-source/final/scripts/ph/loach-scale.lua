-- ph/loach-scale : one round grey-green fish scale from the Stone Loach, tilted,
-- pale embedded root with radial grooves, mottled exposed edge with growth rings
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- local shape (u right, v down), rotated by A about (CX,CY)
local CX, CY, A = 32, 32, math.rad(-24)
local function rot(u, v)
  local ca, sa = math.cos(A), math.sin(A)
  return { CX + u * ca - v * sa, CY + u * sa + v * ca }
end
local function outline(scaleR)
  local pts = {}
  -- scalloped root edge (top), three shallow bumps, left to right
  for i = 0, 24 do
    local u = -15 + i * 30 / 24
    local v = -17 - 1.6 * math.abs(math.sin((u + 15) / 30 * 3 * math.pi))
    pts[#pts + 1] = rot(u * scaleR, v * scaleR)
  end
  -- right shoulder down into the big round free edge, back up the left
  for i = 0, 36 do
    local a = -math.pi / 2 + i * (2 * math.pi) / 36 * 0.5 + math.pi / 2 * 0 -- placeholder
  end
  for i = 0, 40 do
    local t = i / 40 * math.pi -- 0..pi : right side to left side through the bottom
    local u = 18 * math.cos(t)
    local v = 1 + 18 * math.sin(t)
    if i == 0 then pts[#pts + 1] = rot(17 * scaleR, -12 * scaleR) end
    pts[#pts + 1] = rot(u * scaleR, v * scaleR)
    if i == 40 then pts[#pts + 1] = rot(-17 * scaleR, -12 * scaleR) end
  end
  return pts
end
local scale = c:poly(outline(1))

-- growth rings follow the free edge (1 px arcs, shaded tone), only on the lower part
local function arc(r)
  local m = c:mask()
  for i = 0, 120 do
    local t = 0.15 * math.pi + i / 120 * 0.7 * math.pi
    local p = rot(r * math.cos(t), 1 + r * math.sin(t))
    m:set(math.floor(p[1] + 0.5), math.floor(p[2] + 0.5))
  end
  return m
end

-- root band: the paler embedded part of the scale
local root = c:poly({ rot(-19, -22), rot(19, -22), rot(19, -6), rot(-19, -6) }):clip(scale)

local body = GV.ramp("#8d9a90")
local p = c:build{
  { "scale", scale, body, { gloss = false } },
}
-- paler root zone with radial grooves fanning from the scale centre
local pale = root:shrink(2)
c:fill(pale, "#b4c0b2")
for _, u in ipairs({ -10, -4, 2, 8 }) do
  local g = c:line({ rot(u * 0.5, -4), rot(u, -18) }, 1):clip(pale)
  c:fill(g, "#8d9a90")
end
-- boundary between root and exposed part: a darker wavy line
local edge = c:mask()
for i = 0, 60 do
  local u = -16 + i * 32 / 60
  local p2 = rot(u, -6 + math.floor(math.sin(u / 2.2) + 0.5))
  edge:set(math.floor(p2[1] + 0.5), math.floor(p2[2] + 0.5))
end
c:fill(edge:clip(scale:shrink(2)), "#5f6a62")

-- growth rings on the exposed part
for _, r in ipairs({ 7, 11 }) do
  c:fill(arc(r):clip(scale:shrink(3)), "#74827a")
end
-- loach mottle diamonds
local dia = { ".x.", "xxx", ".x." }
for _, d in ipairs({ { -7, 3 }, { 3, 8 }, { 9, 0 }, { -2, 13 } }) do
  local q = rot(d[1], d[2])
  c:spot(c:ascii(dia, math.floor(q[1]) - 1, math.floor(q[2]) - 1), "#5f6a62")
end
-- enamel gloss on the lit upper-left of the root
c:gloss(scale, body, { 17, 22 })

local t = c:save(D .. "final/aseprite/ph/loach-scale.aseprite", PNG .. "loach-scale.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
