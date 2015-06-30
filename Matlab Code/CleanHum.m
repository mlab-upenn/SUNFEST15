function [Clean_hum] = CleanHum(X,sigmah,sigmal)
% Clean the training data of missing data nd outliers.

Xbar = mean(X);
Xdev = std(X);
Xlimh = Xbar+(sigmah*Xdev);
Xliml = Xbar-(sigmal*Xdev);

Xidx = find((X>=Xlimh & X~=1)|(X<=Xliml & X~=1));

X(Xidx)=[];

Clean_hum = X;


end
