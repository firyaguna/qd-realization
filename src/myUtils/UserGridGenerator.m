pos_x = 0.5:1:24.5;
pos_y = 0.5:1:24.5;
pos_z = 1.2;

pos = PositionGenerator(pos_x(1),pos_y(1),pos_z);

for i = 2:length(pos_x)
for j = 2:length(pos_y)
    pos.nextPos(pos_x(i),pos_y(j),pos_z);
end
end

pos.savefile(1);