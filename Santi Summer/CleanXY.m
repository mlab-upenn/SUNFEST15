 function [cX,cY,len,loss] = CleanXY(X,Y,sigmah,sigmal)
% Clean the training data of missing data nd outliers.

Ybar = mean(Y);
Ydev = std(Y);
Ylimh = Ybar+(sigmah*Ydev);
Yliml = Ybar-(sigmal*Ydev);

Yidx = find((Y==0)|(Y>=Ylimh)|(Y<=Yliml));

X(Yidx,:)=[];
Y(Yidx) = [];

cX = X;
cY = Y;

len = length(cY);
loss = length(Yidx)/length(Y);

end

