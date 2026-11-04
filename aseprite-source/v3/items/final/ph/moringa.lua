-- moringa: arching pinnate frond of tiny round leaflets. quirk: a green caterpillar munching a leaflet.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local floor = math.floor
local H, HP, B, X = D.H, D.HP, D.B, D.X
local c = D.new("moringa")
local P0 = { {10,56}, {12,36}, {26,26}, {52,10} }
local function bz(t) local u = 1 - t
  return u^3*P0[1][1] + 3*u*u*t*P0[2][1] + 3*u*t*t*P0[3][1] + t^3*P0[4][1],
         u^3*P0[1][2] + 3*u*u*t*P0[2][2] + 3*u*t*t*P0[3][2] + t^3*P0[4][2] end
local pts = {}
for i = 0, 24 do local x, y = bz(i / 24) pts[#pts + 1] = { x, y } end
D.stem(c, pts, 2, "#7a8a48", "#b7c46a")
local R = D.R("#d4f08a", "#8ccb4e", "#3f9150", "#24544a")
for i = 1, 10 do
  local t = 0.1 + i * 0.085
  local x, y = bz(t) local x2, y2 = bz(t + 0.02)
  local dx, dy = x2 - x, y2 - y local l = math.sqrt(dx*dx + dy*dy) dx, dy = dx / l, dy / l
  local s = 3.0 - t * 1.1
  for sg = -1, 1, 2 do
    local nx, ny = -dy * sg, dx * sg
    local lx, ly = x + nx * (s + 1.6), y + ny * (s + 1.6)
    if not (i == 5 and sg == 1) then
      B.lit(c, B.ell(lx, ly, s, s * .72, math.atan(ny, nx)), R, 1.7)
    end
  end
end
local tx, ty = bz(1)
B.lit(c, B.ell(tx, ty, 2.6, 2, -0.5), R, 1.6)
-- nibbled leaflet and caterpillar
local x, y = bz(0.1 + 5 * 0.085)
local cx, cy = floor(x + 5), floor(y + 1)
for i = 0, 3 do
  local cm = c:ellipse(cx + i * 2, cy + (i % 2 == 1 and -1 or 0), 1.2, 1.2)
  c:fillMask(cm, i == 0 and "#f5b82e" or "#b6e05a")
  c:px(cx + i * 2, cy + (i % 2 == 1 and -1 or 0) + 1, "#3f9150")
end
c:px(cx, cy - 1, "#2b1c26")
D.fin()
