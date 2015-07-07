%{

In this code, we will learn a regression tree on historical data. 
Then we will use elements of the tree object to identify the indices of
different nodes and leaves in the tree. 
We will obtain the prediction using NodeMean. 


Variables:

DateTime     clgsetp      gfplenum     outwet       perimid2zat  peritop4zat  
basezat      corebzat     htgsetp      peribot1zat  perimid3zat  tod          
boiler1      coremzat     hwsetp       peribot2zat  perimid4zat  topplenum    
chws1        coretzat     mfplenum     peribot3zat  peritop1zat  tpower       
chws2        dom          outdry       peribot4zat  peritop2zat  windir       
chwsetp      dow          outhum       perimid1zat  peritop3zat  winspeed     


%}

clc 
clear 
close all


%%  Usual Training procedure

%Prepare Training data, i.e from 2012
disp('Preparing data..');

load dr_functional_test_july2k12_wlight.mat

XDR = [BASEMENTZoneAirTemperatureCTimeStep(2:end),...
    HEATSYS1BOILERBoilerOutletTemperatureCTimeStep(2:end),...
    COOLSYS1CHILLER1ChillerEvaporatorOutletTemperatureCTimeStep(2:end),...
    COOLSYS1CHILLER2ChillerEvaporatorOutletTemperatureCTimeStep(2:end),...
    CORE_BOTTOMZoneAirTemperatureCTimeStep(2:end),...
    CORE_MIDZoneAirTemperatureCTimeStep(2:end),...
    CORE_TOPZoneAirTemperatureCTimeStep(2:end),...
    EMScurrentDayOfWeekTimeStep(2:end),...
    GROUNDFLOOR_PLENUMZoneAirTemperatureCTimeStep(2:end),...
    HTGSETP_SCHScheduleValueTimeStep(2:end),...
    HWLOOPTEMPSCHEDULEScheduleValueTimeStep(2:end),...
    MIDFLOOR_PLENUMZoneAirTemperatureCTimeStep(2:end),...
    EnvironmentSiteOutdoorAirDrybulbTemperatureCTimeStep(2:end),...
    EnvironmentSiteOutdoorAirRelativeHumidityTimeStep(2:end),...
    EnvironmentSiteOutdoorAirWetbulbTemperatureCTimeStep(2:end),...
    PERIMETER_BOT_ZN_1ZoneAirTemperatureCTimeStep(2:end),...
    PERIMETER_BOT_ZN_2ZoneAirTemperatureCTimeStep(2:end),...                   
    PERIMETER_BOT_ZN_3ZoneAirTemperatureCTimeStep(2:end),...                   
    PERIMETER_BOT_ZN_4ZoneAirTemperatureCTimeStep(2:end),...                   
    PERIMETER_MID_ZN_1ZoneAirTemperatureCTimeStep(2:end),...                   
    PERIMETER_MID_ZN_2ZoneAirTemperatureCTimeStep(2:end),...                   
    PERIMETER_MID_ZN_3ZoneAirTemperatureCTimeStep(2:end),...                   
    PERIMETER_MID_ZN_4ZoneAirTemperatureCTimeStep(2:end),...                   
    PERIMETER_TOP_ZN_1ZoneAirTemperatureCTimeStep(2:end),...                   
    PERIMETER_TOP_ZN_2ZoneAirTemperatureCTimeStep(2:end),...                   
    PERIMETER_TOP_ZN_3ZoneAirTemperatureCTimeStep(2:end),...                   
    PERIMETER_TOP_ZN_4ZoneAirTemperatureCTimeStep(2:end),... 
    EMScurrentTimeOfDayTimeStep(2:end),...
    TOPFLOOR_PLENUMZoneAirTemperatureCTimeStep(2:end),...
    EnvironmentSiteWindDirectiondegTimeStep(2:end),...
    EnvironmentSiteWindSpeedmsTimeStep(2:end)];

YDR = WholeBuildingFacilityTotalElectricDemandPowerWTimeStep(2:end);

XDRctrl = [CLGSETP_SCHScheduleValueTimeStep(2:end), ...
    CWLOOPTEMPSCHEDULEScheduleValueTimeStep(2:end),...
    BLDG_LIGHT_SCHScheduleValueTimeStep(2:end)];

% Column names and indicies of the columns which are categorical

colnames={'basezat','boiler','chws1','chws2','corebzat','coremzat'...
    ,'coretzat','dow','gfplenum','htgsetp','hwsetp','mfplenum','outdry','outhum'...
    ,'outwet','peribot1zat','peribot2zat','peribot3zat','peribot4zat','perimid1zat'...
    ,'perimid2zat','perimid3zat','perimid4zat','peritop1zat','peritop2zat'...
    ,'peritop3zat','peritop4zat','tod','topplenum','windir','winspeed'};
catcol = [11,28];


disp('Done.');

%% Start Tree Regression
disp('Learning Regression Tree');

minleaf = 50;   % minimium number of leaf node observations
tic
drtree12 = fitrtree(XDR,YDR,'PredictorNames',colnames,'ResponseName','Total Power','CategoricalPredictors',catcol,'MinLeafSize',minleaf);
toc

% predict on training and testing data and plot the fits
[Yfit,node] = resubPredict(drtree12);

% RMSE
% [a,b]=rsquare(YDR,Yfit);
% fprintf('Training RMSE(W): %.2f, R2: %.3f, RMSE/peak: %.4f, CV: %.2f \n\n'...
%     ,b,a,(b/max(YDR)),(100*b/mean(YDR)));

% Need to find the indices of the nodes of the tree which are
% leaves i.e zero children in the left and right branches of the node.
% Tree.children is a Nx2 matrix with indices of left and right branch nodes
% for each node. 

leaf_index = find((drtree12.Children(:,1)==0)&(drtree12.Children(:,2)==0));
numleafs = length(leaf_index);
fprintf('The tree has %d leaf nodes \n',numleafs);

%{
    For each leaf of the tree:
        1) Obtain and store the indices and hence the values of the data points in the
        partition
        2) Obtain and store the prediction from tree 1 ( use NodeMean)
        3) support
        4) response variables
        5) linear model
%}


for ii=1:numleafs
    
    % find indices of nodes which end up in this leaf
    dr12(ii).leaves = {find(node==leaf_index(ii))};
    
    % prediction at the leaf
    dr12(ii).mean = drtree12.NodeMean(leaf_index(ii));
    
    % find the training samples which contribute to this leaf (support)
    dr12(ii).xdata = {XDRctrl(dr12(ii).leaves{1,1},:)};
    
    % find the training labels which contribute to this leaf
    dr12(ii).ydata = {YDR(dr12(ii).leaves{1,1})};
    
    % train a linear model 
    dr12(ii).mdl = {LinearModel.fit(dr12(ii).xdata{1,1},dr12(ii).ydata{1,1})};  
    
end

