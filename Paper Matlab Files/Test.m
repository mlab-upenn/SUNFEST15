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

len = length(Y);
% training length = 80% of the dataset. We will train on 80% of the data dn
% use the remaining 20% for validation.
trlen = floor(0.8*len);

% construct the training inputs. The traiing feature matrix and the
% training response.
Xtrain = X(1:trlen,:);
Ytrain = Y(1:trlen);

% store the remaining data as a test-set: test inputs and outputs.
Xtest = X(trlen+1:end,:);
Ytest = Y(trlen+1:end);

sigmah = 2.5;
sigmal = 2;

[CleanX,CleanY,len,loss] = newCleanXY(X,Y,sigmah,sigmal);

% interpolates over 0s
[PostX,PostY] = InterPenn (CleanX,CleanY);

CleanHum = PostX(:,10);

% plot the training data features.
figure(2);
    
    subplot(1,2,1);
    plot(hum);
  
    title('Before Processing','FontSize',22);
    xlabel('Time(hour)','FontSize',26)
    ylabel('Humidity(%)','FontSize',26)
    grid on;
    subplot(1,2,2);
    plot(CleanHum)
    title('After Processing','FontSize',22)
    xlabel('Time(hour)','FontSize',26)
    ylabel('Humidity(%)','FontSize',26)
    grid on
    
%              annotation('textbox', [0 0.9 1 0.1], ...
%             'String', 'Humidity before and after outlier removal and interpolation', ...
%             'EdgeColor', 'none', ...
%             'HorizontalAlignment', 'center')
%             



figure(3);
    title('kW before and After outlier detection and interpolation');
    subplot(1,2,1);
    plot(kw);
    title('Before Processing','FontSize',22);
    xlabel('Time(hour)','FontSize',26)
    ylabel('Power Consumption(kW)','FontSize',26)
    grid on;
    subplot(1,2,2);
    plot(PostY)
    title('After Processing','FontSize',22)
    xlabel('Time(hour)','FontSize',26)
    ylabel('Power Consumption(kW)','FontSize',26)
    grid on
    
%                     annotation('textbox', [0 0.9 1 0.1], ...
%             'String', 'Power Consumption before and after outlier removal and interpolation', ...
%             'EdgeColor', 'none','FontSize',15,'HorizontalAlignment', 'center')
%         
 
 