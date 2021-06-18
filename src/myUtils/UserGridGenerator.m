pos_x = 0.5:0.5:24.5;
pos_y = 0.5:0.5:24.5;
pos_z = 1.3;

pos = PositionGenerator();

for i = 1:length(pos_x)
for j = 1:length(pos_y)
    pos.nextPos(pos_x(i),pos_y(j),pos_z);
end
end

pos.savefile(1);