function [paraCfg,nodeCfg] = nodeProfileCfg(rootFolderStr,paraCfg)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

scenarioNameStr = paraCfg.inputScenarioName;
% Input Parameters to be Updated
environmentFileName = paraCfg.environmentFileName;
% scenarioNameStr = paraCfg.scenarioNameStr;
mobilitySwitch = paraCfg.mobilitySwitch;
mobilityType = paraCfg.mobilityType;
numberOfNodes = paraCfg.numberOfNodes;
numberOfTimeDivisions = paraCfg.numberOfTimeDivisions;
switchRandomization = paraCfg.switchRandomization;
paraCfg.referrencePoint = str2num(paraCfg.referrencePoint);
%% Code
nodePosition = [];

%% Random generation of node positions
if switchRandomization == 1    
    xCoordinateRandomizer = rand * 8 + 1;
    yCoordinateRandomizer = rand * 17 + 1;
    zCoordinateRandomizer = 2.5;
    Tx = [xCoordinateRandomizer, yCoordinateRandomizer, zCoordinateRandomizer];
    
    xCoordinateRandomizer = rand * 8 + 1;
    yCoordinateRandomizer = rand * 17 + 1;
    zCoordinateRandomizer = 1.6;
    Rx = [xCoordinateRandomizer, yCoordinateRandomizer, zCoordinateRandomizer];
end

if switchRandomization == 1
   mobilityType = 1; 
end

%% Extracting data from nodes.dat and nodeVelocities.dat file.
% nodes.dat file contains nodes locations and nodeVelocities contains their
% velocities
if switchRandomization == 0 && numberOfNodes >= 2
    cd(strcat(rootFolderStr,'\',scenarioNameStr, '\Input'));
    try
        nodeLoc = csvread('nodes.dat');
        nodeVelocities = csvread('nodeVelocities.dat');
        sizeNode = size(nodeLoc);
        sizeNodeVelocities = size(nodeVelocities);
    catch
        switchRandomization = 1;
    end
    sizeNode = size(nodeLoc);
    if sizeNode(1) ~= sizeNodeVelocities(1) && mobilitySwitch == 1
        error('nodes.dat and nodeVelocities.dat donot have same number of rows. Please check the input files in the Input folder.')
    end
    if numberOfNodes ~= sizeNode(1)
       disp('WARNING:');
       disp('"numberOfNodes" parameter doesnot match the number of');
       disp('nodes given in file. The "numberOfNodes" is adjusted to ');
       disp('the number of nodes given in file'); 
    end
    numberOfNodes = sizeNode(1);
    if mobilitySwitch == 1
        nodeVelocitiesTemp = nodeVelocities;
        clear nodeVelocities;
        nodeVelocities = nodeVelocitiesTemp(1:numberOfNodes, :);
    else
        clear nodeVelocities;
        nodeVelocities = zeros(numberOfNodes, 3);
    end
    if mobilityType == 2
        listing = dir(strcat(rootFolderStr,'\',scenarioNameStr, '\Input'));
        sizeListing = size(listing);
        countListing = 0; 
        for iterateSizeListing = 1:sizeListing(1)
            ln = listing(iterateSizeListing).name;
            %nodePosition = zeros(3, 3, numberOfNodes);
            for iterateNumberOfNodes = 1:numberOfNodes
                if strcmp(ln, strcat('NodePosition', num2str(iterateNumberOfNodes), '.dat'))
                    nodePositionTemp = load(ln);
                    try
                        nodePosition(:, :, iterateNumberOfNodes) = nodePositionTemp;
                        countListing = countListing + 1;
                    catch
                        disp('WARNING:');
                        disp('Node Position input incorrect. Linear');
                        disp('mobility model is chosen');
                        mobilityType = 1;
                    end
                end
            end
        end
        sizeNodePosition = size(nodePosition);
        if mobilityType == 2 && countListing < numberOfNodes
            disp('WARNING:');
            disp('Node Position input incorrect. Linear mobility')
            disp('model is chosen');
            mobilityType = 1;
        elseif mobilityType == 2 && countListing == numberOfNodes
            numberOfTimeDivisions = sizeNodePosition(1) - 2;
        end
    end
end

iterateNumberOfNodes = 1;
%% This part of code generates other parameters of 
nodeAntennaOrientation = zeros(numberOfNodes, 3, 3);
nodePolarization = zeros(iterateNumberOfNodes, 2);
while iterateNumberOfNodes <= numberOfNodes
    nodeAntennaOrientation(iterateNumberOfNodes, :, :) = [1, 0, 0; 0, 1, 0; 0, 0, 1];
    nodePolarization(iterateNumberOfNodes, :) = [1, 0];
    if switchRandomization == 1 && iterateNumberOfNodes > 0
        xCoordinateRandomizer = rand * 8 + 1;
        yCoordinateRandomizer = rand * 17 + 1;
        zCoordinateRandomizer = 1.6;
        nodeLoc(iterateNumberOfNodes, :) = [xCoordinateRandomizer, yCoordinateRandomizer, zCoordinateRandomizer];
        xCoordinateRandomizer = rand * 0.7;
        yCoordinateRandomizer = sqrt((0.7^2) - (xCoordinateRandomizer^2));
        zCoordinateRandomizer = 0;        
        nodeVelocities(iterateNumberOfNodes, :) = [xCoordinateRandomizer, yCoordinateRandomizer, zCoordinateRandomizer];
%     elseif (switchRandomization  == 1 && iterateNumberOfNodes == 2)...
%             || (numberOfNodes == 2 && iterateNumberOfNodes == 2 && switchRandomization  == 1)
%         node(iterateNumberOfNodes, :) = Rx;
%         xCoordinateRandomizer = rand * 0.7;
%         yCoordinateRandomizer = sqrt((0.7^2) - (xCoordinateRandomizer^2));
%         zCoordinateRandomizer = 0;        
%         nodeVelocities(iterateNumberOfNodes, :) = [xCoordinateRandomizer, yCoordinateRandomizer, zCoordinateRandomizer];
%     elseif (switchRandomization == 1 && iterateNumberOfNodes == 1) || ...
%             (numberOfNodes == 2 && iterateNumberOfNodes == 1 && switchRandomization  == 1)
%         node(iterateNumberOfNodes, :) = Tx;
%         xCoordinateRandomizer = rand * 0.7;
%         yCoordinateRandomizer = sqrt((0.7^2) - (xCoordinateRandomizer^2));
%         zCoordinateRandomizer = 0;        
%         nodeVelocities(iterateNumberOfNodes, :) = [xCoordinateRandomizer, yCoordinateRandomizer, zCoordinateRandomizer];
    end
    iterateNumberOfNodes = iterateNumberOfNodes + 1;
end

switchRandomization = 0;
cd(rootFolderStr);

% Check Temp Output Folder
try
    rmdir(strcat(rootFolderStr,'\',scenarioNameStr,'\Output'), 's');
catch
end
mkdir(strcat(rootFolderStr,'\',scenarioNameStr,'\Output'));
mkdir(strcat(rootFolderStr,'\',scenarioNameStr,'\Output\NS3'));
mkdir(strcat(rootFolderStr,'\',scenarioNameStr,'\Output\Visualizer'));

cd(strcat(rootFolderStr,'\',scenarioNameStr,'\Output'));
cd(rootFolderStr);
sizeNode = size(nodeLoc);

try
    cd(strcat(rootFolderStr,'\',scenarioNameStr,'\Output\NS3\NodesPosition'));
catch
    mkdir(strcat(rootFolderStr,'\',scenarioNameStr,'\Output\NS3\NodesPosition'));
    cd(strcat(rootFolderStr,'\',scenarioNameStr,'\Output\NS3\NodesPosition'));
end

csvwrite(strcat('NodesPosition.csv'), nodeLoc);
cd(strcat(rootFolderStr,'\',scenarioNameStr, '\Input'))
copyfile(environmentFileName,strcat(rootFolderStr, '\Raytracer'));

cd(rootFolderStr);
cd(strcat(rootFolderStr, '\Raytracer'))
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')

paraCfg.mobilityType = mobilityType;
paraCfg.numberOfNodes = numberOfNodes;
paraCfg.numberOfTimeDivisions = numberOfTimeDivisions;
paraCfg.switchRandomization = switchRandomization;

nodeCfg.nodeLoc = nodeLoc;
nodeCfg.nodeAntennaOrientation = nodeAntennaOrientation;
nodeCfg.nodePolarization = nodePolarization;
nodeCfg.nodePosition = nodePosition;
nodeCfg.nodeVelocities = nodeVelocities;

end
