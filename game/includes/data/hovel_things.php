<?php
// The tappable things in the hovel room on the Today tab (includes/home_slim.php: hovel_things(), hovel_room_svg() with 'things' => true).
// One row per thing: id, label, the tap box in room units (the room picture scenes/hovel-room.png is 480 x 270) and what a tap does.
// Boxes are fitted to the painted room: they must stay inside the picture, must not overlap, and are 62 units or more each way
// (44 px on a 390 px phone, where the picture is about 346 px wide); 64 where there is room. tests/hovel_room.php checks all of that.
// act: 'pop' = opens the dialog #hp-<id> (bed, window), 'go' = a plain link (door), 'tea' = the tea kettle's dialog (only drawn while
// tea_open allows it; the box is HOVEL_KETTLE_HIT), 'lamp' = the light on and off, 'say' = the gnome hops and says a line.
// 'out' = the dotted outline drawn around the painted thing [x, y, w, h] (a look only: it hugs the art, so it can differ from the tap box;
// the bed's runs on over its footboard). Outlines must not overlap each other either.
return [
    ['id' => 'window', 'label' => 'The window', 'x' => 48, 'y' => 56, 'w' => 64, 'h' => 64, 'act' => 'pop', 'out' => [52, 58, 56, 60]],
    ['id' => 'bed', 'label' => 'Your bed', 'x' => 66, 'y' => 156, 'w' => 122, 'h' => 66, 'act' => 'pop', 'out' => [68, 158, 132, 62]],
    ['id' => 'gnome', 'label' => 'Your gnome', 'x' => 188, 'y' => 150, 'w' => 62, 'h' => 72, 'act' => 'say', 'out' => [204, 150, 46, 72]],   // 2.7.20: the 48 x 72 gnome (catalogue box 202,150)
    ['id' => 'lamp', 'label' => 'The lamp', 'x' => 250, 'y' => 160, 'w' => 62, 'h' => 64, 'act' => 'lamp', 'out' => [268, 172, 32, 50]],
    ['id' => 'kettle', 'label' => 'The kettle', 'x' => 312, 'y' => 142, 'w' => 64, 'h' => 64, 'act' => 'tea', 'out' => [314, 156, 60, 34]],
    ['id' => 'door', 'label' => 'The door', 'x' => 410, 'y' => 98, 'w' => 64, 'h' => 124, 'act' => 'go', 'out' => [412, 100, 60, 122]],
];
