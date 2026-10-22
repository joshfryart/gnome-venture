local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local function pill(m, pts, r)
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local n = math.ceil(math.max(math.abs(b[1] - a[1]), math.abs(b[2] - a[2])))
    for k = 0, n do
      local t = k / n
      m:add(c:ellipse(a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, r, r))
    end
  end
  return m
end
local chk = pill(c:mask(), { {17, 34}, {28, 45}, {48, 20} }, 4.5)
c:build{
  { "check", chk, GV.ramp("#6a9a3a", { shade = "#4a8a3e", deep = "#2f5a2a" }), { gloss = { 38, 28 } } },
}
local t = c:save(O .. "aseprite/ico/ico-check.aseprite", O .. "png/ico/ico-check.png")
print(GV.report(t))
