-- shared header for the scene overhaul scripts. GV_ROOT = repo root with trailing slash.
local R = os.getenv("GV_ROOT") or "/home/user/gnome-venture/"
local GV = dofile(R .. "aseprite-source/gvlib/gvlib.lua")
local H = { R = R, GV = GV, ASE = R .. "aseprite-source/final/aseprite/scenes/", IMG = R .. "game/assets/img/" }
function H.done(c, name, pngRel, max, opaque)
  local t = c:save(H.ASE .. name .. ".aseprite", H.IMG .. pngRel)
  print(name .. ": " .. GV.report(t))
  assert(t.semi == 0, name .. " has semi-transparent pixels")
  if max then assert(t.colours <= max, name .. " over colour cap " .. max) end
  if opaque then assert(t.opaque == t.w * t.h, name .. " scene has transparent pixels: " .. (t.w * t.h - t.opaque)) end
  return t
end
return H
