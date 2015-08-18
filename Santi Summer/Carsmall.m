load carsmall.mat

Xtrain = [Weight, Cylinders];
Ytrain = MPG ;

SampleTree =  fitrtree(Xtrain,Ytrain,'PredictorNames',{'Weight','Cylinders'},'ResponseName','MPG','CategoricalPredictors',2,'MinLeaf',10);

leaf_index = find((SampleTree.Children(:,1)==0)&(SampleTree.Children(:,2)==0));
numleafs = length(leaf_index);
fprintf('The tree has %d leaf nodes \n',numleafs);


[Yfit,node] = resubPredict(SampleTree);


for ii=1:numleafs
    
    % find indices of nodes which end up in this leaf
    ST(ii).leaves = {find(node==leaf_index(ii))};
    
    % prediction at the leaf
    ST(ii).mean = SampleTree.NodeMean(leaf_index(ii));
    
    % find the training samples which contribute to this leaf (support)
    ST(ii).xdata = {Xtrain(ST(ii).leaves{1,1},:)};
    ST(ii).xlength = length(cell2mat(ST(ii).xdata));
    
    % find the training labels which contribute to this leaf
    ST(ii).ydata = {Ytrain(ST(ii).leaves{1,1})};
    ST(ii).ylength = length(cell2mat(ST(ii).ydata));
    
    % finds the confidence interval for data points in each leaf
    ydata_array = cell2mat(ST(ii).ydata);
    SEM = std(ydata_array)/sqrt(length(ydata_array));
    ts = tinv([.025 .095],length(ydata_array)-1);
    ST(ii).CI = mean(ydata_array)+ ts*SEM;
    
    
    
end

