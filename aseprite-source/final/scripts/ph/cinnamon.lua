local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local ang = math.rad(35)
local ux, uy = math.cos(ang), -math.sin(ang)   -- along the stick (rising right)
local px, py = -uy, ux                           -- perpendicular (down-right)

local function stick(cx, cy, hl, hw)
  return c:poly({
    { cx - ux * hl - px * hw, cy - uy * hl - py * hw },
    { cx + ux * hl - px * hw, cy + uy * hl - py * hw },
    { cx + ux * hl + px * hw, cy + uy * hl + py * hw },
    { cx - ux * hl + px * hw, cy - uy * hl + py * hw },
  })
end
local function oval(cx, cy, ra, rb) -- ra along stick, rb across
  local pts = {}
  for i = 0, 23 do
    local a = i / 24 * 2 * math.pi
    local ca, sa = math.cos(a) * ra, math.sin(a) * rb
    pts[#pts + 1] = { cx + ux * ca + px * sa, cy + uy * ca + py * sa }
  end
  return c:poly(pts)
end

local bx, by = 28.5, 27.5
local fx, fy = bx + px * 10, by + py * 10
local HL, HW = 20, 4.6
local back = stick(bx, by, HL, HW)
local front = stick(fx, fy, HL, HW)
local endB = oval(bx + ux * HL, by + uy * HL, 3, 5.2)
local endF = oval(fx + ux * HL, fy + uy * HL, 3, 5.2)
back:add(oval(bx - ux * HL, by - uy * HL, 3, HW + 0.4))
front:add(oval(fx - ux * HL, fy - uy * HL, 3, HW + 0.4))

-- tie band across both sticks, perpendicular, just left of middle
local mx, my = (bx + fx) / 2 - ux * 2, (by + fy) / 2 - uy * 2
local band = c:poly({
  { mx - ux * 2.5 - px * 11, my - uy * 2.5 - py * 11 },
  { mx + ux * 2.5 - px * 11, my + uy * 2.5 - py * 11 },
  { mx + ux * 2.5 + px * 11, my + uy * 2.5 + py * 11 },
  { mx - ux * 2.5 + px * 11, my - uy * 2.5 + py * 11 },
})
band:clip(back:copy():add(front):grow(1))

c:build{
  { "back", back, GV.ramp("#a8582f") },
  { "endB", endB, GV.ramp("#d9a660"), { gloss = false } },
  { "front", front, "wood" },
  { "endF", endF, GV.ramp("#d9a660"), { gloss = false } },
  { "band", band, "gold", { gloss = false } },
}

-- rolled spiral in each end
local function spiral(cx, cy)
  local x, y = math.floor(cx + 0.5), math.floor(cy + 0.5)
  c:paint({ ".dd.", "d..d", "d.dd", ".d.." }, x - 2, y - 2, { d = "#5e2f1e" })
end
spiral(bx + ux * HL, by + uy * HL)
spiral(fx + ux * HL, fy + uy * HL)

-- seams along the band edges and a button knot
c:seam({ { mx - ux * 2 - px * 10, my - uy * 2 - py * 10 }, { mx - ux * 2 + px * 10, my - uy * 2 + py * 10 } })
c:seam({ { mx + ux * 2 - px * 10, my + uy * 2 - py * 10 }, { mx + ux * 2 + px * 10, my + uy * 2 + py * 10 } })
c:button(math.floor(mx - 1.5 + 0.5), math.floor(my - 1.5 + 0.5))

local t = c:save(O .. "aseprite/ph/cinnamon.aseprite", O .. "png/ph/cinnamon.png")
print(GV.report(t))
