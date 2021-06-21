filepath = 'examples/DigitalFactory/Output/Ns3/QdFiles/';
filename = 'Tx0Rx1.txt';
filename = strcat(filepath,filename);
fid = fopen(filename,'r');

rayTrace = cell(0,1);

endOfFile = false;
while ~endOfFile
    try
        rt.paths = str2double(fgetl(fid));
        if rt.paths ~= 0
            rt.delay = str2num(fgetl(fid));
            rt.pgain = str2num(fgetl(fid));
            rt.phase = str2num(fgetl(fid));
            rt.aodel = str2num(fgetl(fid));
            rt.aodaz = str2num(fgetl(fid));
            rt.aoael = str2num(fgetl(fid));
            rt.aoaaz = str2num(fgetl(fid));
        else
            rt.delay = 0;
            rt.pgain = -Inf;
            rt.phase = 0;
            rt.aodel = 0;
            rt.aodaz = 0;
            rt.aoael = 0;
            rt.aoaaz = 0;
        end
        rayTrace{end+1,1} = rt;
    catch
        endOfFile = true;
    end
end

fclose(fid);

%%
tsteps = length(rayTrace);
pathlossdB = zeros(1,tsteps);
freqHz = 60e9;

for t = 1:tsteps
    pgain_lin = 10.^(rayTrace{t}.pgain ./10);
    phase_exp = exp(1i.*rayTrace{t}.phase);
    delay_exp = exp(-2i.*pi.*freqHz.*rayTrace{t}.delay);
    gain_lin = sum(abs(pgain_lin .* phase_exp .* delay_exp));
    pathlossdB(t) = - 10.*log10(gain_lin);
end

% pathlossdB = max(pathlossdB, 0);

%%
filepath = 'examples/DigitalFactory/Input/';

filename = 'NodePosition0.dat';
filename = strcat(filepath,filename);
fid = fopen(filename,'r');
tx_position = importdata(filename);
fclose(fid);

filename = 'NodePosition1.dat';
filename = strcat(filepath,filename);
fid = fopen(filename,'r');
rx_position = importdata(filename);
fclose(fid);

tx_position = repmat(tx_position,[tsteps,1]);
distance = vecnorm(tx_position-rx_position,2,2);

%% 3gpp InF pathloss
freqGHz = 3.6;
pl_L = @(d) 31.84 + 21.50.*log10(d) + 19.*log10(freqGHz);
pl_SH = @(d) 32.4 + 23.*log10(d) + 20.*log10(freqGHz);
pl_DH = @(d) 33.63 + 21.9.*log10(d) + 20.*log10(freqGHz);
%%
figure(1);
clf(1);
plot(distance,pathlossdB,'o');
hold on;
fplot(pl_L,[5,20],'r-');
fplot(pl_SH,[5,20],'b--');
fplot(pl_DH,[5,20],'m-.');
grid on;
xlabel('Distance (m)');
ylabel('Path loss (dB)');
legend('Ray trace','InF LOS','InF NLOS SH','InF NLOS DH',...
    'location','best');
title('Digital Factory 3.6 GHz');
%%

filename = 'examples/DigitalFactory/Output/Visualizer/RoomCoordinates.csv';
roomCoords = readRoomCoordinates(filename);
[Tri,X,Y,Z] = roomCoords2triangles(roomCoords); % triangle vertices
figure(2);
clf(2);
trisurf(Tri,X,Y,Z,...
    'FaceColor',[0.9,0.9,0.9],...
    'FaceAlpha',0,...
    'EdgeColor','k');
Xgrid = .5:.5:24.5;
Ygrid = .5:.5:24.5;
Z = reshape(pathlossdB,[49,49]);
hold on;
image(Xgrid,Ygrid,Z,'CDataMapping','scaled');
view(0,90);
xlabel('x (meter)');
ylabel('y (meter)');
axis equal;
colormap(turbo);
c = colorbar;
caxis([60,160]);
c.Label.String = 'Path loss (dB)';