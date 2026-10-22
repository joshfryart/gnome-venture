local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local flea = GV.ramp("#8c4a1a")

-- five fleas in a loose ring: {cx, cy, dir(1=right,-1=left), hop(legs tucked)}
local F = {
  { 15, 31,  1, false },
  { 30, 19,  1, true  },
  { 49, 22, -1, false },
  { 46, 42, -1, true  },
  { 24, 45,  1, false },
}

-- legs and antennae first (behind bodies)
for _, f in ipairs(F) do
  local x, y, d, hop = f[1], f[2], f[3], f[4]
  -- antenna: rises from head end, curves forward
  c:limb({ { x + d * 4, y - 3 }, { x + d * 6, y - 7 }, { x + d * 9, y - 8 } })
  if hop then
    -- tucked jumping legs, kicked back
    c:limb({ { x - d * 2, y + 3 }, { x - d * 5, y + 6 }, { x - d * 8, y + 5 } })
    c:limb({ { x + d * 2, y + 3 }, { x + d * 1, y + 7 } })
  else
    c:limb({ { x - d * 2, y + 3 }, { x - d * 5, y + 7 } })
    c:limb({ { x + d * 2, y + 3 }, { x + d * 3, y + 7 } })
  end
end

-- bean bodies: humped back, flatter belly, small head bump at the front
for i, f in ipairs(F) do
  local x, y, d = f[1], f[2], f[3]
  local m = c:ellipse(x - d * 0.5, y, 6, 4.5)
  m:add(c:ellipse(x + d * 4, y + 0.5, 3, 3))
  m:cut(c:ellipse(x - d * 0.5, y + 6.5, 2.5, 2))
  c:part(m, flea)
end

-- markings: one bean stripe across each back
for _, f in ipairs(F) do
  local x, y, d = f[1], f[2], f[3]
  c:spot(c:ellipse(x - d * 2, y - 1, 1.5, 1))
end

-- eyes (3x3 locked, top-left corner) at the head end
for _, f in ipairs(F) do
  local x, y, d = f[1], f[2], f[3]
  local ex = (d == 1) and (x + 3) or (x - 5)
  c:eye(ex, y - 2, true)
end

c:ground(31.5, 54, 22, 1.5)
local t = c:save(O .. "aseprite/ph/creature-sand-fleas.aseprite", O .. "png/ph/creature-sand-fleas.png")
print(GV.report(t))
