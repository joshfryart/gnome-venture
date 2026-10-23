-- creature-dew-leech : a pale leech coiled round a clean dew drop it keeps for itself
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local pale = GV.ramp("#d8e6de", { dot = "#f8fcf4" })            -- pale sea-glass felt (cream-safe ramp)
local rose = GV.ramp("#c98f8f")            -- sucker lip

-- Catmull-Rom tube through control points, radius tapers r0 -> r1
local function cr(p0, p1, p2, p3, t)
  local t2, t3 = t * t, t * t * t
  local function f(a, b, cc, d) return 0.5 * ((2*b) + (-a+cc)*t + (2*a-5*b+4*cc-d)*t2 + (-a+3*b-3*cc+d)*t3) end
  return f(p0[1], p1[1], p2[1], p3[1]), f(p0[2], p1[2], p2[2], p3[2])
end
local function path(P, n)
  local pts = {}
  for i = 1, #P - 1 do
    local p0 = P[math.max(1, i-1)]; local p1 = P[i]; local p2 = P[i+1]; local p3 = P[math.min(#P, i+2)]
    for s = 0, n - 1 do pts[#pts+1] = { cr(p0, p1, p2, p3, s / n) } end
  end
  pts[#pts+1] = P[#P]
  return pts
end
local function tube(pts, r0, r1)
  local m = c:mask()
  for i, p in ipairs(pts) do
    local r = r0 + (r1 - r0) * (i - 1) / math.max(1, #pts - 1)
    m:add(c:ellipse(p[1], p[2], r))
  end
  return m
end

-- back of the coil, passing behind the drop (its tail end hides behind the neck)
local backP = path({ {51, 43}, {45, 35}, {35, 33}, {24, 37} }, 10)
local back = tube(backP, 4.5, 3.5)
-- the dew drop it hoards, sitting inside the coil
local drop = c:ellipse(37, 39, 7.5, 7.5):add(c:poly({ {31, 37}, {36, 24}, {38, 24}, {44, 37} }))
-- neck drops from the head, loops round the front of the drop and back up the right
local coilP = path({ {21, 26}, {16, 36}, {19, 46}, {33, 50}, {46, 48}, {52, 41} }, 10)
local coil = tube(coilP, 6.5, 4.5)
local head = c:ellipse(21.5, 18, 12.5, 10.5)

local p = c:build{
  { "back", back, pale, { gloss = false, cres = 5 } },
  { "drop", drop, "water", { gloss = { 33, 34 } } },
  { "coil", coil, pale, { gloss = { 13, 36 }, cres = 6 } },
  { "head", head, pale, { gloss = { 12, 12 }, cres = 6 } },
}

-- body rings: dashed seams where the felt segments join
c:seam({ {11, 44}, {17, 41} })
c:seam({ {29, 46}, {28, 55} })
c:seam({ {44, 45}, {47, 53} })

-- dorsal beans along the front loop
local bean = { ".xxx", "xxx." }
c:spot(c:ascii(bean, 20, 47), "#8a86b8", "#b0abcd")
c:spot(c:ascii(bean, 35, 48), "#8a86b8", "#b0abcd")
c:spot(c:ascii({ ".xx", "xx.", "x.." }, 12, 37), "#8a86b8", "#b0abcd")

-- oral sucker, puckered toward the drop
c:part(c:ellipse(25, 25.5, 3.5, 2.5), rose, { flat = true })
c:paint({ ".uuu.", "uuuuu", ".uuu." }, 23, 24, { u = "umber" })
c:px(24, 24, "#5e2a3a")

-- wet shine: glints along the slick back
for _, q in ipairs({ {47, 37}, {24, 46}, {41, 47} }) do c:px(q[1], q[2], "#fff3c8") end

c:eye(13, 13); c:eye(25, 13)

c:ground(33, 56, 19, 1.5)
local t = c:save(D .. "final/aseprite/ph/creature-dew-leech.aseprite", PNG .. "creature-dew-leech.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
