function[ST,Total_PointsStr,T] = ForestAnalyticsFunction(Tree, node,EnsembleTreeX,EnsembleTreeY, number_bins,Ymin_interval,Ymax_interval)

leaf_index = find((Tree.Children(:,1)==0)&(Tree.Children(:,2)==0)); % index of node that is a leaf
numleafs = length(leaf_index); % number of leaf nodes 
fprintf('The tree has %d leaf nodes \n',numleafs);


Y_mean = zeros(1,numleafs);

% Training Data that the tree uses
%Different than Ytrain because does not use all data points to train model
TreeY = EnsembleTreeY;
TreeX = EnsembleTreeX;

for i=1:numleafs
    
    % find indices of data points that end up in this leaf
    ST(i).leaves = {find(node==leaf_index(i))};
    
    % prediction at the leaf
    ST(i).mean = Tree.NodeMean(leaf_index(i));
    Y_mean(i) = ST(i).mean;
    % find the training samples which contribute to this leaf (support)
    
    ST(i).xdata = {TreeX(ST(i).leaves{1,1},:)};
    ST(i).xlength = length(cell2mat(ST(i).xdata));
    
    % find the training labels which contribute to this leaf
    ST(i).ydata = {TreeY(ST(i).leaves{1,1})};
    ST(i).ylength = length(cell2mat(ST(i).ydata));
    
    % finds the confidence interval for data points in each leaf
    ydata_array = cell2mat(ST(i).ydata);
    ts = ([-2 2]);
    ST(i).CI = mean(ydata_array)+ ts;

end
%Creates a Scatterplot with Y mean value at each leave on the X axis and
% the leaf index on the Y axis
% figure(1)
% Xaxis = linspace (1,numleafs,numleafs);
% Scatterplot = scatter(Y_mean,Xaxis,10);
% xlabel 'Y mean for each leaf';
% ylabel 'leaf index';


                                                                                                                                                                                                                        
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
            Data_index(ii) = ii;  % array with leafs that lie within 
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

        % Converts cells into arrays, and stores values in T data
        % structure, which gets passed as output 
        T.bin(h).TotalSum_domarray = cell2mat(Totalcell_dom);
        T.bin(h).TotalSum_todarray = cell2mat(Totalcell_tod);
        T.bin(h).TotalSum_occarray = cell2mat(Totalcell_occ);
        T.bin(h).TotalSum_monarray = cell2mat(Totalcell_mon);

        T.bin(h).TotalSum_array_tempC = cell2mat(Totalcell_tempC);
        T.bin(h).TotalSum_array_sol= cell2mat(Totalcell_sol);
        T.bin(h).TotalSum_array_winspeed = cell2mat(Totalcell_winspeed);
        T.bin(h).TotalSum_array_windir = cell2mat(Totalcell_windir);
        T.bin(h).TotalSum_array_gusts = cell2mat(Totalcell_gusts);
        T.bin(h).TotalSum_array_hum = cell2mat (Totalcell_hum);
        T.bin(h).TotalSum_array_dew= cell2mat (Totalcell_dew);
        T.bin(h).TotalSum_array_hdd= cell2mat(Totalcell_hdd);
        T.bin(h).TotalSum_array_cdd=cell2mat(Totalcell_cdd);
        
        % number of points in each bin
        % I chose to count number of tempC points, but you can use any
        % feature because they will always have the same number of points
        Total_PointsStr.bin(h) = length(T.bin(h).TotalSum_array_tempC);
end
       

