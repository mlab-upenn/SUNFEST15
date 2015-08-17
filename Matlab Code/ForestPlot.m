function[Bin] = ForestPlot(NumberTrees,EnsembleTree,number_bins,EnsembletrainX,Ymin_interval,Ymax_interval)


for h = 1:number_bins;

    % Creates empty cells that will be filled with values of each feature
            EnsembleTotalcell_dom = {};
            EnsembleTotalcell_tod = {};
            EnsembleTotalSum_tempC = 0;
            EnsembleTotalcell_tempC = {};
            EnsembleTotalSum_sol = 0;
            EnsembleTotalcell_sol = {};
            EnsembleTotalcell_occ={};
            EnsembleTotalcell_mon = {};
            EnsembleTotalSum_winspeed = 0;
            EnsembleTotalcell_winspeed ={};
            EnsembleTotalSum_windir = 0;
            EnsembleTotalcell_windir = {};
            EnsembleTotalSum_gusts = 0;
            EnsembleTotalcell_gusts = {};
            EnsembleTotalSum_hum = 0;
            EnsembleTotalcell_hum={};
            EnsembleTotalSum_dew = 0;
            EnsembleTotalcell_dew={};
            EnsembleTotalSum_hdd = 0;
            EnsembleTotalcell_hdd={};
            EnsembleTotalSum_cdd = 0;
            EnsembleTotalcell_cdd = {};


        %iterates through leaves and sums values for each feature
        % It is the total sum of values for each feature in data points that lie within the
        % specified bin range 
        % Also adds all the values for each feature into a cell
        
    Total_Points = 0; 
    
        for i = 1: NumberTrees;
     
            EnsembleTotalcell_dom = [EnsembleTotalcell_dom,{EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_domarray } ];
           
            EnsembleTotalcell_tod = [EnsembleTotalcell_tod,{EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_todarray }] ;

            EnsembleTotalSum_tempC = sum([EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_tempC]) + EnsembleTotalSum_tempC ;
            EnsembleTotalcell_tempC = [EnsembleTotalcell_tempC,{EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_tempC }];

            EnsembleTotalSum_sol = sum([EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_sol]) + EnsembleTotalSum_sol ;
            EnsembleTotalcell_sol = [EnsembleTotalcell_sol,{EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_sol }];

            EnsembleTotalcell_occ = [EnsembleTotalcell_occ,{EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_occarray}];
            
            EnsembleTotalcell_mon = [EnsembleTotalcell_mon,{EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_monarray}];

            EnsembleTotalSum_winspeed = sum([EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_winspeed]) + EnsembleTotalSum_winspeed;
            EnsembleTotalcell_winspeed = [EnsembleTotalcell_winspeed,{EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_winspeed }];

            EnsembleTotalSum_windir = sum([EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_windir]) + EnsembleTotalSum_winspeed ; 
            EnsembleTotalcell_windir = [EnsembleTotalcell_windir,{EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_windir}];

            EnsembleTotalSum_gusts = sum([EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_gusts]) + EnsembleTotalSum_gusts ;
            EnsembleTotalcell_gusts = [EnsembleTotalcell_gusts,{EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_gusts}];

            EnsembleTotalSum_hum = sum([EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_hum]) +EnsembleTotalSum_hum ; 
            EnsembleTotalcell_hum = [EnsembleTotalcell_hum,{EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_hum}];

            EnsembleTotalSum_dew = sum([EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_dew]) + EnsembleTotalSum_dew ;
            EnsembleTotalcell_dew = [EnsembleTotalcell_dew,{EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_dew}];

            EnsembleTotalSum_hdd = sum([EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_hdd]) + EnsembleTotalSum_hdd  ;
            EnsembleTotalcell_hdd = [EnsembleTotalcell_hdd,{EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_hdd}];

            EnsembleTotalSum_cdd = sum([EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_cdd]) + EnsembleTotalSum_cdd ;
            EnsembleTotalcell_cdd = [EnsembleTotalcell_cdd,{EnsembleTree.TreeNumber(i).T.bin(h).TotalSum_array_cdd}];
             
            Total_Points = sum(EnsembleTree.TreeNumber(i).Total_PointsStr.bin(1,h) + (Total_Points));
            
                
                    
        end         

  
  Total_PointsStr.bin(h) = Total_Points;

  % Converts cells into arrays,
        TotalSum_domarray = cell2mat(EnsembleTotalcell_dom);
        TotalSum_todarray = cell2mat(EnsembleTotalcell_tod);
        TotalSum_occarray = cell2mat(EnsembleTotalcell_occ);
        TotalSum_monarray = cell2mat(EnsembleTotalcell_mon);

        TotalSum_array_tempC = cell2mat(EnsembleTotalcell_tempC);
        TotalSum_array_sol= cell2mat(EnsembleTotalcell_sol);
        TotalSum_array_winspeed = cell2mat(EnsembleTotalcell_winspeed);
        TotalSum_array_windir = cell2mat(EnsembleTotalcell_windir);
        TotalSum_array_gusts = cell2mat(EnsembleTotalcell_gusts);
        TotalSum_array_hum = cell2mat (EnsembleTotalcell_hum);
        TotalSum_array_dew= cell2mat (EnsembleTotalcell_dew);
        TotalSum_array_hdd= cell2mat(EnsembleTotalcell_hdd);
        TotalSum_array_cdd=cell2mat(EnsembleTotalcell_cdd);

        % Creates box plots for each feature in each bin
        %Each figure contains one box plot for each bin for a given feature
        
        tempC_figure = figure(2);
        subplot(1,number_bins,h);
        boxplot(TotalSum_array_tempC,'labels',sprintf('%.0f - %.0f', Ymin_interval.bin(h), Ymax_interval.bin(h)));
       
         
         
         sol_figure = figure(3);
         subplot(1,number_bins,h);
         boxplot(TotalSum_array_sol,'labels',sprintf('%.0f - %.0f', Ymin_interval.bin(h), Ymax_interval.bin(h)));
         
        
         winspeed_figure = figure(4);
        subplot(1,number_bins,h);
        boxplot(TotalSum_array_winspeed,'labels',sprintf('%.0f - %.0f', Ymin_interval.bin(h), Ymax_interval.bin(h)));
        
        
        windir_figure = figure(5);
        subplot(1,number_bins,h);
        boxplot(TotalSum_array_windir,'labels',sprintf('%.0f - %.0f', Ymin_interval.bin(h), Ymax_interval.bin(h)));
        
         
        gusts_figure = figure(6);
         subplot(1,number_bins,h);
         boxplot(TotalSum_array_gusts,'labels',sprintf('%.0f - %.0f', Ymin_interval.bin(h), Ymax_interval.bin(h)));
        
         
         hum_figure = figure(7);
         subplot(1,number_bins,h);
          boxplot(TotalSum_array_hum,'labels',sprintf('%.0f - %.0f', Ymin_interval.bin(h), Ymax_interval.bin(h)));
         
         
          dew_figure = figure(8);
           subplot(1,number_bins,h);
         boxplot(TotalSum_array_dew,'labels',sprintf('%.0f - %.0f', Ymin_interval.bin(h), Ymax_interval.bin(h)));
        
         
         hdd_figure = figure(9);
        subplot(1,number_bins,h);
         boxplot(TotalSum_array_hdd,'labels',sprintf('%.0f - %.0f', Ymin_interval.bin(h), Ymax_interval.bin(h)));
         
         cdd_figure = figure(10);
          subplot(1,number_bins,h);
         boxplot(TotalSum_array_cdd,'labels',sprintf('%.0f - %.0f', Ymin_interval.bin(h), Ymax_interval.bin(h)));
         


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
            
             Bin(h).avg_tempC = (EnsembleTotalSum_tempC ./ Total_PointsStr.bin(h));
             ts = ([-2 2]);
             Bin(h).tempC_CI = mean(TotalSum_array_tempC)+ ts;
            
             Bin(h).avg_sol = (EnsembleTotalSum_sol ./ Total_PointsStr.bin(h));
             ts = ([-2 2]);
             Bin(h).sol_CI  = mean(TotalSum_array_sol)+ ts;
             
             Bin(h).occ_mode = Most_occ.number(1);
             
             Bin(h).mon_mode =  [Most_mon.number(1),Most_mon.number(2),Most_mon.number(3)];
             
             Bin(h).avg_winspeed = (EnsembleTotalSum_winspeed ./ Total_PointsStr.bin(h));
             ts = ([-2 2]);
             Bin(h).winspeed_CI = mean(TotalSum_array_winspeed)+ ts;
             
             Bin(h).avg_windir = (EnsembleTotalSum_windir ./ Total_PointsStr.bin(h));
             ts = ([-2 2]);
             Bin(h).windir_CI = mean(TotalSum_array_windir)+ ts;
             
             Bin(h).avg_gusts = (EnsembleTotalSum_gusts ./ Total_PointsStr.bin(h));
             ts =([-2 2]);
             Bin(h).gusts_CI = mean(TotalSum_array_gusts)+ ts;
             
             Bin(h).avg_hum = (EnsembleTotalSum_hum ./ Total_PointsStr.bin(h)); 
             ts = ([-2 2]);
             Bin(h).hum_CI = mean(TotalSum_array_hum)+ ts;
             
             Bin(h).avg_dew = (EnsembleTotalSum_dew ./ Total_PointsStr.bin(h));
             ts = ([-2 2]);
             Bin(h).dew_CI = mean(TotalSum_array_dew)+ ts;
             
             Bin(h).avg_hdd = (EnsembleTotalSum_hdd ./ Total_PointsStr.bin(h));
             ts = ([-2 2]);
             Bin(h).hdd_CI = mean(TotalSum_array_hdd)+ ts;
             
             Bin(h).avg_cdd = (EnsembleTotalSum_cdd ./ Total_PointsStr.bin(h));
             ts = ([-2 2]);
             Bin(h).cdd_CI = mean(TotalSum_array_cdd)+ ts;
            
             
            % Calculates support by dividing total data points in specified range
            % by total number of points in all training data 
            Bin(h).support = Total_PointsStr.bin(h) ./ (length(EnsembletrainX));
            
      
end        

figure(2)
            annotation('textbox', [0 0.9 1 0.1], ...
            'String', 'Temp-C', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center')
        annotation('textbox', [0 0 1 .05], ...
            'String', 'kW', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center','Fontsize',12)   
          annotation('textbox', [0 .5 1 0.1], ...
            'String', '°C', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left','Fontsize',12)  
        
figure(3)
          annotation('textbox', [0 0.9 1 0.1], ...
            'String', 'SOLAR', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center')
        annotation('textbox', [0 0 1 .05], ...
            'String', 'kW', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center','Fontsize',12)   
          annotation('textbox', [0 .5 1 0.1], ...
            'String', 'W/M^2', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left','Fontsize',12)  
         

figure(4)
         annotation('textbox', [0 0.9 1 0.1], ...
            'String', 'WINSPEED', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center')
        annotation('textbox', [0 0 1 0.05], ...
            'String', 'kW', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center','Fontsize',12)   
         annotation('textbox', [0 .5 1 0.1], ...
            'String', 'MPH', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left','Fontsize',12)  
figure(5)
         annotation('textbox', [0 0.9 1 0.1], ...
            'String', 'WINDIR', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center')
        annotation('textbox', [0 0 1 0.05], ...
            'String', 'kW', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center','Fontsize',12)   
          annotation('textbox', [0 .5 1 0.1], ...
            'String', 'Direc', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left','Fontsize',12)  
         
figure(6)
        annotation('textbox', [0 0.9 1 0.1], ...
            'String', 'Gusts', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center')
    annotation('textbox', [0 0 1 0.05], ...
            'String', 'kW', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center','Fontsize',12)   
         annotation('textbox', [0 .5 1 0.1], ...
            'String', '', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left','Fontsize',12)  
figure(7)
         annotation('textbox', [0 0.9 1 0.1], ...
            'String', 'HUMIDITY', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center')
        annotation('textbox', [0 0 1 0.05], ...
            'String', 'kW', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center','Fontsize',12)   
         annotation('textbox', [0 .5 1 0.1], ...
            'String', '%', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left','Fontsize',12)  
figure(8)
          annotation('textbox', [0 0.9 1 0.1], ...
            'String', 'DEW', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center')
        annotation('textbox', [0 0 1 0.05], ...
            'String', 'kW', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center','Fontsize',12)   
         annotation('textbox', [0 .5 1 0.1], ...
            'String', '%', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left','Fontsize',12)  
figure(9)
         annotation('textbox', [0 0.9 1 0.1], ...
            'String', 'HDD', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center')
        annotation('textbox', [0 0 1 0.05], ...
            'String', 'kW', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center','Fontsize',12)   
          annotation('textbox', [0 .5 1 0.1], ...
            'String', 'Days', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left','Fontsize',12)  
         
figure(10)
      annotation('textbox', [0 0.9 1 0.1], ...
            'String', 'CDD', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center')
      annotation('textbox', [0 0 1 0.05], ...
            'String', 'kW', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center','Fontsize',12)   
      annotation('textbox', [0 .5 1 0.1], ...
            'String', 'Days', ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left','Fontsize',12)  

