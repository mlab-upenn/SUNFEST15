
Data = csv2matPenn('1 _College_Hall_2.csv','College_Hall');  
Numdata = Data(2:end,1:end);
Tabledata = cell2mat(Numdata);

% indexes csv file for data 
dom = Tabledata(:,3);
tod = Tabledata(:,4);
tempC = Tabledata(:,5);
sol = Tabledata(:,9);
occ = Tabledata(:,15);
mon = Tabledata(:,2);
winspeed = Tabledata(:,10);
windir = Tabledata(:,12);
gusts = Tabledata(:,11);
hum = Tabledata(:,8);
dew = Tabledata(:,7);
hdd = Tabledata(:,13);
cdd = Tabledata(:,14);
kw = Tabledata (:,17);


% contruct the feature matrix: columns of this matrix are the different
% features and each row is one sample.
X = [dom,tod,tempC,sol,occ,mon,winspeed,windir,gusts,hum,dew,hdd,cdd];
% Y is our response variabel whihc we intend to predict. in this case its
% electricity consumption in kW.
Y = kw;

% Specify names for coluns to keep track of features in the tree instead of
% column numbers.
 colnames={'dom','tod','tempC','sol','occ','mon','wspeed','wdir','gusts','hum','dew','hdd','cdd'};
% catcol = indicies of those columns whihc are categorical. The tree takes this into consideration. 
 catcol = [1,2,6];

% Very primitive outlier detection and removal.
sigmah = 2.5;
sigmal = 2;
% removes any points from X and Y where the values is outside of signalh
% and sigmal standard deviation away from the mean.
[X,Y,len,loss] = newCleanXY(X,Y,sigmah,sigmal);

% interpolates over 0s
[iX,iY] = InterPenn (X,Y);


% training length = 80% of the dataset. We will train on 80% of the data dn
% use the remaining 20% for validation.
trlen = floor(0.8*len);

% construct the training inputs. The traiing feature matrix and the
% training response.
Xtrain = iX(1:trlen,:);
Ytrain = iY(1:trlen);

% store the remaining data as a test-set: test inputs and outputs.
Xtest = iX(trlen+1:end,:);
Ytest = iY(trlen+1:end);

% compute range and mean for the test set. this is used later to compute
% goodness of fit.
range = max(Ytest)-min(Ytest);
bar = mean(Ytest);


% minimium number of leaf node observations. This is a stopping cirtera for
% the recursive partitionioning algorithm used by the tree.
minleaf = 10;  

% In Matlab, you can use tic and toc to measure the time elapsed between
% different points in your code. Here we want to measure how much time does
% it take for the tree to build up.
tic
college_hall_tree14 = RegressionTree.fit(Xtrain,Ytrain,'PredictorNames',colnames,'ResponseName','Total Power','CategoricalPredictors',catcol,'MinLeaf',minleaf);
toc


leaf_index = find((college_hall_tree14.Children(:,1)==0)&(college_hall_tree14.Children(:,2)==0)); % index of node that is a leaf
numleafs = length(leaf_index); % number of leaf nodes 
fprintf('The tree has %d leaf nodes \n',numleafs);


[Yfit,node] = resubPredict(college_hall_tree14);
Y_mean = zeros(1,numleafs);

for i=1:numleafs
    
    % find indices of nodes which end up in this leaf
    ST(i).leaves = {find(node==leaf_index(i))};
    
    % prediction at the leaf
    ST(i).mean = college_hall_tree14.NodeMean(leaf_index(i));
    Y_mean(i) = ST(i).mean;
    % find the training samples which contribute to this leaf (support)
    
    ST(i).xdata = {Xtrain(ST(i).leaves{1,1},:)};
    ST(i).xlength = length(cell2mat(ST(i).xdata));
    
    % find the training labels which contribute to this leaf
    ST(i).ydata = {Ytrain(ST(i).leaves{1,1})};
    ST(i).ylength = length(cell2mat(ST(i).ydata));
    
    % finds the confidence interval for data points in each leaf
    ydata_array = cell2mat(ST(i).ydata);
    SEM = std(ydata_array)/sqrt(length(ydata_array));
    ts = tinv([.025 .095],length(ydata_array)-1);
    ST(i).CI = mean(ydata_array)+ ts*SEM;

end

Xaxis = linspace (1,numleafs,666);
Scatterplot = scatter(Y_mean,Xaxis,10);
xlabel 'Y mean for each leaf';
ylabel 'leaf index';

%Specifiy Bin width
Binwidth = 1;
Y_Center = 50;
Ymax = Y_Center+Binwidth ;
Ymin= Y_Center-Binwidth ;
Data_index = zeros(1,numleafs);

for ii=1:numleafs
    if (ST(ii).mean >= Ymin) && (ST(ii).mean <= Ymax);
    Data_index(ii) = ii; % appending to list is time intensive 
    end
end    

Data_index = Data_index(Data_index ~= 0);
    
Total_Points = 0;

for j= 1:length(Data_index);    
    leaf_number = Data_index(j);
    RelData_Points = cell2mat(ST(leaf_number).leaves);
    for jj = 1:length(RelData_Points);  
        Xtrain_index = RelData_Points(jj);
        Train_row = Xtrain(Xtrain_index,:);
        
        Q.Leaf(j).Point(jj).dom = Train_row(1,1);
        Q.Leaf(j).Point(jj).tod = Train_row(1,2);
        Q.Leaf(j).Point(jj).tempC = Train_row(1,3);
        Q.Leaf(j).Point(jj).sol = Train_row(1,4);
        Q.Leaf(j).Point(jj).occ = Train_row(1,5);
        Q.Leaf(j).Point(jj).mon = Train_row(1,5); 
        Q.Leaf(j).Point(jj).winspeed = Train_row(1,6);
        Q.Leaf(j).Point(jj).windir = Train_row(1,8);
        Q.Leaf(j).Point(jj).gusts = Train_row(1,9);
        Q.Leaf(j).Point(jj).hum = Train_row(1,10);
        Q.Leaf(j).Point(jj).dew = Train_row(1,11);
        Q.Leaf(j).Point(jj).hdd = Train_row(1,12);
        Q.Leaf(j).Point(jj).cdd = Train_row(1,13);
        
        Total_Points =  Total_Points + 1;
    end   
end



    TotalSum_dom = 0;
    TotalSum_tod = 0;
    TotalSum_tempC = 0;
    TotalSum_sol = 0;
    TotalSum_occ = 0;
    TotalSum_mon = 0;
    TotalSum_winspeed = 0;
    TotalSum_windir = 0;
    TotalSum_gusts = 0;
    TotalSum_hum = 0;
    TotalSum_dew = 0;
    TotalSum_hdd = 0;
    TotalSum_cdd = 0;
    
for f= 1:length(Data_index);

    TotalSum_dom = sum([Q.Leaf(f).Point(:).dom]) + TotalSum_dom;
    TotalSum_tod = Q.Leaf(j).Point(jj).tod + TotalSum_tod ; 
    TotalSum_tempC = Q.Leaf(j).Point(jj).tempC + TotalSum_tempC ;
    TotalSum_sol = Q.Leaf(j).Point(jj).sol + TotalSum_sol ;
    TotalSum_occ = Q.Leaf(j).Point(jj).occ + TotalSum_occ;
    TotalSum_mon = Q.Leaf(j).Point(jj).mon + TotalSum_mon ;
    TotalSum_winspeed = Q.Leaf(j).Point(jj).winspeed + TotalSum_winspeed;
    TotalSum_windir = Q.Leaf(j).Point(jj).windir + TotalSum_winspeed ; 
    TotalSum_gusts = Q.Leaf(j).Point(jj).gusts + TotalSum_gusts ;
    TotalSum_hum = Q.Leaf(j).Point(jj).hum +TotalSum_hum ; 
    TotalSum_dew = Q.Leaf(j).Point(jj).dew + TotalSum_dew ;
    TotalSum_hdd = Q.Leaf(j).Point(jj).hdd + TotalSum_hdd  ;
    TotalSum_cdd = Q.Leaf(j).Point(jj).cdd + TotalSum_cdd ;
end


    avg_dom = TotalSum_dom / length(Total_Points)
    avg_tod = TotalSum_tod / length(Total_Points)
    avg_tempC = TotalSum_tempC / length(Total_Points)
    avg_sol = TotalSum_sol / length(Total_Points)
    avg_occ =  TotalSum_occ / length(Total_Points)
    avg_mon =  TotalSum_mon / length(Total_Points)
    avg_winspeed = TotalSum_winspeed / length(Total_Points)
    avg_windir = TotalSum_windir / length(Total_Points)
    avg_gusts = TotalSum_gusts / length(Total_Points)
    avg_hum = TotalSum_hum / length(Total_Points)
    avg_dew = TotalSum_dew / length(Total_Points)
    avg_hdd = TotalSum_hdd / length(Total_Points)
    avg_cdd = TotalSum_cdd / length(Total_Points)
   

    









