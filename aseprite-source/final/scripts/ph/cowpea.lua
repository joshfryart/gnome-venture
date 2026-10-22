local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- banana-arched pod: circles along a curve, swelling to the right, pointed tip
local function q(t) -- (13,45) ctrl (24,20) -> (54,20)
  local a, b = (1-t)^2, 2*(1-t)*t
  return a*13 + b*26 + t*t*54, a*46 + b*22 + t*t*22
end
local pod = c:mask()
for i = 0, 60 do
  local t = i / 60
  local r
  if t < 0.7 then r = 3 + 3.5 * (t / 0.7) else r = 6.5 * (1 - (t - 0.7) / 0.3) ^ 0.75 + 0.5 end
  local x, y = q(t)
  pod:add(c:ellipse(x, y, r, r))
end
-- three bumps on top of the arch, bigger to the right
local bumps = { {0.32, 4.5}, {0.52, 5.0}, {0.72, 5.5} }
local peaM = {}
for _, b in ipairs(bumps) do
  local x, y = q(b[1])
  local m = c:ellipse(x - 1, y - 5, b[2], b[2])
  pod:add(m); peaM[#peaM+1] = m
end
c:build{
  { "stalk", c:line({ {14, 44}, {7, 49} }, 3), GV.ramp("#2e5a2c"), { flat = true } },
  { "pod", pod, "moss" },
}
for i, m in ipairs(peaM) do local x0,y0,x1,y1 = m:bbox(); local cx,cy=(x0+x1)/2,(y0+y1)/2; local r=bumps[i][2]-2; c:fill(c:ellipse(cx+0.5,cy+0.5,r,r),"#58a03e"); c:fill(c:ellipse(cx-0.5,cy-0.5,r-1,r-1),"#7ab55c"); c:px(math.floor(cx-r+1.5),math.floor(cy-r+1.5),"#c8d77a") end
-- seam along the belly side
c:seam({ {16, 44}, {22, 38}, {30, 34}, {40, 31}, {50, 28} })
local t = c:save(O .. "aseprite/ph/cowpea.aseprite", O .. "png/ph/cowpea.png")
print(GV.report(t))
