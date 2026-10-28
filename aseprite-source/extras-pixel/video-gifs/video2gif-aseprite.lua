local S, OUT, NAME = os.getenv("GV_S"), os.getenv("GV_OUT"), os.getenv("GV_NAME")
local spr = Sprite(240, 135, ColorMode.RGB)
app.transaction(function()
  for i = 1, 24 do
    local img = Image{ fromFile = string.format("%s/px/f%02d.png", S, i) }
    local fr = (i == 1) and spr.frames[1] or spr:newEmptyFrame()
    fr.duration = 0.1
    spr:newCel(spr.layers[1], fr, img, Point(0, 0))
  end
end)
spr.filename = OUT .. NAME .. ".aseprite"
spr:saveAs(OUT .. NAME .. ".aseprite")
app.command.ExportSpriteSheet{ ui=false } -- noop guard
app.command.SaveFileCopyAs{ ui=false, filename = OUT .. NAME .. ".gif", resizeScale = 2, scale = 2 } 
