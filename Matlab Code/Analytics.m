function[Bin,Interval,Scatterplot,tempC_figure,sol_figure,winspeed_figure,windir_figure,gusts_figure,hum_figure,dew_figure,cdd_figure,hdd_figure] = Analytics(building_csv, number_bins)

Data = csv2matPenn(building_csv,'College_Hall');
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

% returns node, which is the index of of training samples in each leaf
[Yfit,node] = resubPredict(college_hall_tree14); 
Y_mean = zeros(1,numleafs);

% Training Data that the tree uses
%Different than Ytrain because does not use all data points to train model
TreeY = college_hall_tree14.Y;
TreeX = college_hall_tree14.X;

for i=1:numleafs
    
    % find indices of data points that end up in this leaf
    ST(i).leaves = {find(node==leaf_index(i))};
    
    % prediction at the leaf
    ST(i).mean = college_hall_tree14.NodeMean(leaf_index(i));
    Y_mean(i) = ST(i).mean;
    % find the training samples which contribute to this leaf (support)
    
    ST(i).xdata = {TreeX(ST(i).leaves{1,1},:)};
    ST(i).xlength = length(cell2mat(ST(i).xdata));
    
    % find the training labels which contribute to this leaf
    ST(i).ydata = {TreeY(ST(i).leaves{1,1})};
    ST(i).ylength = length(cell2mat(ST(i).ydata));
    
    % finds the confidence interval for data points in each leaf
    ydata_array = cell2mat(ST(i).ydata);
    SEM = std(ydata_array)/sqrt(length(ydata_array));
    ts = tinv([.025 .0975],length(ydata_array)-1);
    ST(i).CI = mean(ydata_array)+ ts*SEM;

end
%Creates a Scatterplot with Y mean value at each leave on the X axis and
% the leaf index on the Y axis
Xaxis = linspace (1,numleafs,numleafs);
Scatterplot = scatter(Y_mean,Xaxis,10);
xlabel 'Y mean for each leaf';
ylabel 'leaf index';

% Gets the range of the Y_means 
Ymax = max(Y_mean);
Ymin= min(Y_mean) ;

% Divides the Y_axis by number_bins to create the number of bins that
% the user specifies
for r = 2:(number_bins);
    Interval = (Ymax - Ymin) ./ number_bins;  %width of each bin   
    
    %edges of each bin
    Ymin_interval.bin(1) = Ymin;
    Ymax_interval.bin(1) = Ymin_interval.bin(1) + Interval;
    Ymin_interval.bin(r) = Ymax_interval.bin(r-1);
    Ymax_interval.bin(r) = Ymin_interval.bin(r) + Interval ;
                                                                                                                                                                                                                        


end

%at each iteration, creates box plots and calculates average values for data points within each bin 
for h = 1:(number_bins); 
   
    
        %creates vector with zeros as long as the number of leafs 
        % Will add leafs that lie within specified Bin range
        % then remove extra zeros
        Data_index = zeros(1,numleafs);

        %Find the index of the leaf which are within specified Bin width and adds
        %them to Data_index
        for ii=1:numleafs
            if (ST(ii).mean >= Ymin_interval.bin(h)) && (ST(ii).mean <= Ymax_interval.bin(h)); 
            Data_index(ii) = ii;  % vector with leafs that lie within 
            end
        end    
        %Removes zeros from Data_index, leaving only list with indeces of leafs
        %within range 
        Data_index = Data_index(Data_index ~= 0);

        % scalar that will count the total number of data points in all the leafs
        % that lie within the specified bin range 
        Total_Points = 0;

        % loops through the vector with leafs
        for j= 1:length(Data_index);    
            leaf_number = Data_index(j); % leaf_number in the node number of the leaf 
            RelData_Points = cell2mat(ST(leaf_number).leaves);% array with Y data points in each leaf



            for jj = 1:length(RelData_Points);  %for loop that will iterate through each data point and take each feature 
                Xtree_index = RelData_Points(jj);% index of X data point
                Train_row = TreeX(Xtree_index,:); % row taken from original Xtrain data with feature information

                % parses Xtrain data and creates data structure with feature
                % information for each data point in each leaf
                Q.Leaf(j).Point(jj).dom = Train_row(1,1);
                Q.Leaf(j).Point(jj).tod = Train_row(1,2);
                Q.Leaf(j).Point(jj).tempC = Train_row(1,3);
                Q.Leaf(j).Point(jj).sol = Train_row(1,4);
                Q.Leaf(j).Point(jj).occ = Train_row(1,5);
                Q.Leaf(j).Point(jj).mon = Train_row(1,6); 
                Q.Leaf(j).Point(jj).winspeed = Train_row(1,7);
                Q.Leaf(j).Point(jj).windir = Train_row(1,8);
                Q.Leaf(j).Point(jj).gusts = Train_row(1,9);
                Q.Leaf(j).Point(jj).hum = Train_row(1,10);
                Q.Leaf(j).Point(jj).dew = Train_row(1,11);
                Q.Leaf(j).Point(jj).hdd = Train_row(1,12);
                Q.Leaf(j).Point(jj).cdd = Train_row(1,13);

                Total_Points =  Total_Points + 1; % Counts that total number of data points that the loop iterates through
            end   
        end
% Creates empty cells that will be filled with values of each feature
            Totalcell_dom = {};
            Totalcell_tod = {};
            TotalSum_tempC = 0;
            Totalcell_tempC = {};
            TotalSum_sol = 0;
            Totalcell_sol = {};
            Totalcell_occ={};
            Totalcell_mon = {};
            TotalSum_winspeed = 0;
            Totalcell_winspeed ={};
            TotalSum_windir = 0;
            Totalcell_windir = {};
            TotalSum_gusts = 0;
            Totalcell_gusts = {};
            TotalSum_hum = 0;
            Totalcell_hum={};
            TotalSum_dew = 0;
            Totalcell_dew={};
            TotalSum_hdd = 0;
            Totalcell_hdd={};
            TotalSum_cdd = 0;
            Totalcell_cdd = {};


        %iterates through leaves and sums values for each feature
        % It is the total sum of values for each feature in data points that lie within the
        % specified bin range 
        % Also adds all the values for each feature into a cell
        for f= 1:length(Data_index);

            Totalcell_dom = [Totalcell_dom,{Q.Leaf(f).Point(:).dom} ];
            Totalcell_tod = [Totalcell_tod,{Q.Leaf(f).Point(:).tod}] ;

            TotalSum_tempC = sum([Q.Leaf(f).Point(:).tempC]) + TotalSum_tempC ;
            Totalcell_tempC = [Totalcell_tempC,{Q.Leaf(f).Point(:).tempC}];

            TotalSum_sol = sum([Q.Leaf(f).Point(:).sol]) + TotalSum_sol ;
            Totalcell_sol = [Totalcell_sol,{Q.Leaf(f).Point(:).sol}];

            Totalcell_occ = [Totalcell_occ,{Q.Leaf(f).Point(:).occ}];
            Totalcell_mon = [Totalcell_mon,{Q.Leaf(f).Point(:).mon}];

            TotalSum_winspeed = sum([Q.Leaf(f).Point(:).winspeed]) + TotalSum_winspeed;
            Totalcell_winspeed = [Totalcell_winspeed,{Q.Leaf(f).Point(:).winspeed}];

            TotalSum_windir = sum([Q.Leaf(f).Point(:).windir]) + TotalSum_winspeed ; 
            Totalcell_windir = [Totalcell_windir,{Q.Leaf(f).Point(:).windir}];

            TotalSum_gusts = sum([Q.Leaf(f).Point(:).gusts]) + TotalSum_gusts ;
            Totalcell_gusts = [Totalcell_gusts,{Q.Leaf(f).Point(:).gusts}];

            TotalSum_hum = sum([Q.Leaf(f).Point(:).hum]) +TotalSum_hum ; 
            Totalcell_hum = [Totalcell_hum,{Q.Leaf(f).Point(:).hum}];

            TotalSum_dew = sum([Q.Leaf(f).Point(:).dew]) + TotalSum_dew ;
            Totalcell_dew = [Totalcell_dew,{Q.Leaf(f).Point(:).dew}];

            TotalSum_hdd = sum([Q.Leaf(f).Point(:).hdd]) + TotalSum_hdd  ;
            Totalcell_hdd = [Totalcell_hdd,{Q.Leaf(f).Point(:).hdd}];

            TotalSum_cdd = sum([Q.Leaf(f).Point(:).cdd]) + TotalSum_cdd ;
            Totalcell_cdd = [Totalcell_cdd,{Q.Leaf(f).Point(:).cdd}];
        end

        % Converts cells into arrays,
        TotalSum_domarray = cell2mat(Totalcell_dom);
        TotalSum_todarray = cell2mat(Totalcell_tod);
        TotalSum_occarray = cell2mat(Totalcell_occ);
        TotalSum_monarray = cell2mat(Totalcell_mon);

        TotalSum_array_tempC = cell2mat(Totalcell_tempC);
        TotalSum_array_sol= cell2mat(Totalcell_sol);
        TotalSum_array_winspeed = cell2mat(Totalcell_winspeed);
        TotalSum_array_windir = cell2mat(Totalcell_windir);
        TotalSum_array_gusts = cell2mat(Totalcell_gusts);
        TotalSum_array_hum = cell2mat (Totalcell_hum);
        TotalSum_array_dew= cell2mat (Totalcell_dew);
        TotalSum_array_hdd= cell2mat(Totalcell_hdd);
        TotalSum_array_cdd=cell2mat(Totalcell_cdd);

        % Creates box plots for each feature in each bin
        %Each figure contains one box plot for each bin for a given feature
        tempC_figure = figure(1);
        title 'TempC-Bin';
        subplot(1,number_bins,h);
         boxplot(TotalSum_array_tempC);
         
         
         sol_figure = figure(2);
         title('solar');
        subplot(1,number_bins,h);
         boxplot(TotalSum_array_sol);
         
        
         winspeed_figure = figure(3);
         title('winspeed');
        subplot(1,number_bins,h);
        boxplot(TotalSum_array_winspeed);
        
        
        windir_figure = figure(4);
        title('windir');
        subplot(1,number_bins,h);
        boxplot(TotalSum_array_windir);
        
         
        gusts_figure = figure(5);
         title('gusts');
        subplot(1,number_bins,h);
         boxplot(TotalSum_array_gusts);
        
         
         hum_figure = figure(6);
          title('hum');
        subplot(1,number_bins,h);
          boxplot(TotalSum_array_hum);
         
         
          dew_figure = figure(7);
           title('dew');
        subplot(1,number_bins,h);
         boxplot(TotalSum_array_dew);
        
         
         hdd_figure = figure(8);
         title('hdd');
        subplot(1,number_bins,h);
         boxplot(TotalSum_array_hdd);
         
         cdd_figure = figure(9);
         title('cdd');
        subplot(1,number_bins,h);
         boxplot(TotalSum_array_cdd);
         


        for b=1:3;
            Most_dom.number(b) = mode(TotalSum_domarray);
            TotalSum_domarray = TotalSum_domarray(TotalSum_domarray ~= Most_dom.number(b));
            Most_tod.number(b) = mode(TotalSum_todarray);
            TotalSum_todarray = TotalSum_todarray(TotalSum_todarray ~= Most_tod.number(b));
            Most_occ.number(b) = mode(TotalSum_occarray);
            TotalSum_occarray = TotalSum_occarray(TotalSum_occarray ~= Most_occ.number(b));
            Most_mon.number(b) = mode(TotalSum_monarray);
            TotalSum_monarray = TotalSum_monarray(TotalSum_monarray ~= Most_mon.number(b));
        end
        % Calculates average by diving the sum off features divided by
        % total number of data points that lie within the Bin
             Bin(h).dom_mode = [Most_dom.number(1),Most_dom.number(2),Most_dom.number(3)];
            
             Bin(h).tod_mode= [Most_tod.number(1),Most_tod.number(2),Most_tod.number(3)];
            
             Bin(h).avg_tempC = (TotalSum_tempC ./ Total_Points);
             SEM = std(TotalSum_array_tempC)/sqrt(length(TotalSum_array_tempC));
             ts = tinv([.025 .0975],length(TotalSum_array_tempC)-1);
             Bin(h).tempC_CI = mean(TotalSum_array_tempC)+ ts*SEM;
            
             Bin(h).avg_sol = (TotalSum_sol ./ Total_Points);
             SEM = std(TotalSum_array_sol)/sqrt(length(TotalSum_array_sol));
             ts = tinv([.025 .0975],length(TotalSum_array_sol)-1);
             Bin(h).sol_CI  = mean(TotalSum_array_sol)+ ts*SEM;
             
             Bin(h).occ_mode = Most_occ.number(1);
             
             Bin(h).mon_mode =  [Most_mon.number(1),Most_mon.number(2),Most_mon.number(3)];
             
             Bin(h).avg_winspeed = (TotalSum_winspeed ./ Total_Points);
             SEM = std(TotalSum_array_winspeed)/sqrt(length(TotalSum_array_winspeed));
             ts = tinv([.025 .0975],length(TotalSum_array_winspeed)-1);
             Bin(h).winspeed_CI = mean(TotalSum_array_winspeed)+ ts*SEM;
             
             Bin(h).avg_windir = (TotalSum_windir ./ Total_Points);
             SEM = std(TotalSum_array_windir)/sqrt(length(TotalSum_array_windir));
             ts = tinv([.025 .0975],length(TotalSum_array_windir)-1);
             Bin(h).windir_CI = mean(TotalSum_array_windir)+ ts*SEM;
             
             Bin(h).avg_gusts = (TotalSum_gusts ./ Total_Points);
             SEM = std(TotalSum_array_gusts)/sqrt(length(TotalSum_array_gusts));
             ts = tinv([.025 .0975],length(TotalSum_array_gusts)-1);
             Bin(h).gusts_CI = mean(TotalSum_array_gusts)+ ts*SEM;
             
             Bin(h).avg_hum = (TotalSum_hum ./ Total_Points); 
             SEM = std(TotalSum_array_tempC)/sqrt(length(TotalSum_array_tempC));
             ts = tinv([.025 .0975],length(TotalSum_array_tempC)-1);
             Bin(h).hum_CI = mean(TotalSum_array_tempC)+ ts*SEM;
             
             Bin(h).avg_dew = (TotalSum_dew ./ Total_Points);
             SEM = std(TotalSum_array_dew)/sqrt(length(TotalSum_array_dew));
             ts = tinv([.025 .0975],length(TotalSum_array_dew)-1);
             Bin(h).dew_CI = mean(TotalSum_array_dew)+ ts*SEM;
             
             Bin(h).avg_hdd = (TotalSum_hdd ./ Total_Points);
             SEM = std(TotalSum_array_hdd)/sqrt(length(TotalSum_array_hdd));
             ts = tinv([.025 .0975],length(TotalSum_array_hdd)-1);
             Bin(h).hdd_CI = mean(TotalSum_array_hdd)+ ts*SEM;
             
             Bin(h).avg_cdd = (TotalSum_cdd ./ Total_Points);
             SEM = std(TotalSum_array_cdd)/sqrt(length(TotalSum_array_cdd));
             ts = tinv([.025 .0975],length(TotalSum_array_cdd)-1);
             Bin(h).cdd_CI = mean(TotalSum_array_cdd)+ ts*SEM;
            
             
             % Calculates support by dividing total data points in specified range
            % by total number of points in all training data 
            Bin(h).support = Total_Points ./ length(TreeX);
            
           

        
        
        
end