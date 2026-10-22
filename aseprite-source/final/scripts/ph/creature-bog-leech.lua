local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- Catmull-Rom path through the control points
local P = { {13,45}, {22,34}, {32,43}, {41,47}, {47,33} }
local function cr(p0,p1,p2,p3,t)
  local t2,t3 = t*t, t*t*t
  local function f(a,b,cc,d) return 0.5*((2*b)+(-a+cc)*t+(2*a-5*b+4*cc-d)*t2+(-a+3*b-3*cc+d)*t3) end
  return f(p0[1],p1[1],p2[1],p3[1]), f(p0[2],p1[2],p2[2],p3[2])
end
local pts = {}
for i = 1, #P-1 do
  local p0 = P[math.max(1,i-1)]; local p1 = P[i]; local p2 = P[i+1]; local p3 = P[math.min(#P,i+2)]
  for s = 0, 11 do pts[#pts+1] = { cr(p0,p1,p2,p3,s/12) } end
end
pts[#pts+1] = P[#P]

local body = c:mask()
local stripe = c:mask()
for i, p in ipairs(pts) do
  -- slight taper toward the tail
  local r = 3.6 + 1.0 * math.min(1, i / 14)
  body:add(c:ellipse(p[1], p[2], r))
end
for i = 4, #pts - 6 do
  local p = pts[i]
  stripe:add(c:ellipse(p[1] - 1, p[2] - 1.5, 0.9))
end

local parts = c:build{
  { "body", body, "#8c4a1a", { gloss = { 18, 37 } } },
  { "head", c:ellipse(47.5, 28.5, 6), "#8c4a1a" },
}
-- pale back stripe along the ribbon (behind head)
stripe:clip(parts.body.m:shrink(1)); stripe:cut(parts.head.m:grow(1))
c:fill(stripe, "#d9a660")
-- segment rings
c:seam({ {24,30}, {21,38} }, { on = 2, off = 1 })
c:seam({ {33,38}, {30,47} }, { on = 2, off = 1 })
c:seam({ {41,42}, {41,51} }, { on = 2, off = 1 })
-- sucker mouth
c:part(c:ellipse(51, 32, 2), "red", { flat = true })
c:px(51, 32, "#6b1b2c")
c:eye(45, 25, true)
local t = c:save(B .. "aseprite/ph/creature-bog-leech.aseprite", B .. "png/ph/creature-bog-leech.png")
print(GV.report(t))
