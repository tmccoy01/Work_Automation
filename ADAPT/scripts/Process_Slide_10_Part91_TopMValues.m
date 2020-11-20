
function out = Process_Slide_10_Part91_TopMValues(DashBoard,end_Time, Decision, Reason, class, Pending, fontsize, NDays)      

        start_Time = '12/31/2019 00:00';
        TimeCreatedSinceDeploy = datenum(DashBoard.TS_Created) - datenum(start_Time);
        Departure_UTC_SinceDeploy = datenum(DashBoard.Departure_UTC) - datenum(start_Time)- 1e-13;
            Departure_from_Deploy = datenum(DashBoard.Departure_UTC) - datenum(start_Time)- 1e-13;
        %end_Time = '02/23/2020 23:59';
        today = datenum(end_Time)-datenum(start_Time);
        %lastDay = ceil(max(Departure_UTC_SinceDeploy)) +1;  %  Check this
        
        lastDay = ceil(max(Departure_UTC_SinceDeploy));  %  Check this
        
        periods = 11;  % set to 11 for 'last 10 days'
        %periods = 45;
        %periods = 16;  % Jan 15 set to 16
        %Filter_Time = 0:1:11;  

        Filter_Time = (lastDay - periods+1):1:lastDay;
        %Filter_Time = [(lastDay - 11) lastDay];  % Use '11' to grab the last 10 days worth of data
        nPeriods = length(Filter_Time);
        
        %dates = datenum({start_Time,end_Time});
        dates = datenum({start_Time,DashBoard.Departure_UTC{1}});
        Out = datevec(dates(1):dates(2));

        
        date_Labels_Raw = datestr(Out,'ddd mm/dd');

        date_Labels = date_Labels_Raw((lastDay - periods+2):end,:);
            
        [nWa, mWa] = size(Filter_Time);  
        nW = nWa/2;                 % Number of time filters (bars in a bar family)

for k1 = 1:nPeriods-1



        %     inds = find(datetime(DashBoard.yr,DashBoard.mo,DashBoard.da) >= datetime(Filter_Time((2*k1)-1,3),Filter_Time((2*k1)-1,1),Filter_Time((2*k1)-1,2))...
        %         & datetime(DashBoard.yr,DashBoard.mo,DashBoard.da) <= datetime(Filter_Time((2*k1),3),Filter_Time((2*k1),1),Filter_Time((2*k1),2)));
        inds = find(TimeCreatedSinceDeploy > Filter_Time(k1) & TimeCreatedSinceDeploy < Filter_Time(k1+1));
        nApps = length(inds);

        %inds_AAA = find(Pending(inds) == 1) == 0;
        inds_AAA = find(Pending(inds) == 1);
        n_AAA = length(inds_AAA);  % Number of transactions in this time period
            inds_AAA_sub = inds(inds_AAA);   % indices from DashBoard for this time period, processedby AAA
            n_AAA_Approved = length(find(Decision(inds_AAA_sub) == 1));
            n_AAA_Denied = length(find(Decision(inds_AAA_sub) == 2));
            n_AAA_Expired = length(find(Decision(inds_AAA_sub) == 3));
            n_AAA_Pending = length(find(Decision(inds_AAA_sub) == 4));

        inds_Auto = find(Pending(inds) == 0); 
            inds_Auto_sub = inds(inds_Auto);
            n_Auto_Approved = length(find(Decision(inds_Auto_sub) == 1));
            n_Auto_Denied = length(find(Decision(inds_Auto_sub) == 2));
            n_Auto_Expired = length(find(Decision(inds_Auto_sub) == 3));

        n_Approved = length(find(Decision(inds) == 1));
        n_Denied = length(find(Decision(inds) == 2 | Decision(inds) == 3));

        T_Top(:,k1) = [nApps length(inds_AAA) length(inds_Auto)]';
        T_Middle(:,k1) = [T_Top(:,k1) - [n_Approved (n_AAA_Approved) n_Auto_Approved]'];
        T_Bottom(:,k1) = [0 n_AAA_Expired n_Auto_Expired]';

        Reason_Data(:,k1) = [length(find(Reason(inds) == 1)) length(find(Reason(inds) == 2)) length(find(Reason(inds) == 3)) length(find(Reason(inds) == 4))...
            length(find(Reason(inds) == 5)) length(find(Reason(inds) == 6)) length(find(Reason(inds) == 7)) length(find(Reason(inds) == 8)) ]';

        Class_Data(:,k1) = [length(find(class(inds) == 1)) length(find(class(inds) == 2)) length(find(class(inds) == 3)) length(find(class(inds) == 4))]';
        aaa = 1;
end

Approvals = T_Top-T_Middle;
Denials = T_Middle-T_Bottom;
Expired = T_Bottom;
                    
 x4 = 0.04;       

 % Call signs used 10 or more times
    % Build the list
    nApps = length(DashBoard.Status);
   CallSigns_All = [];
   xt1 = lastDay - 12 + 0.25;

 % Transactions vs time for each tail number - part 91

     inds_91 = find(class == 1 & Decision == 1);  n_91 = length(inds_91);

    % Call sign by column M (Aircraft ID)
        CallSigns_All = [];
        
        
        
        
        for k = inds_91;
   
            if length(DashBoard.TailNumber{k}) > 2
                CallSigns_All = [CallSigns_All {char(DashBoard.TailNumber{k})}];
            else
                CallSigns_All = [CallSigns_All {char(DashBoard.SICAO{k})}];
            end            
            
        end

        [CallSigns Indices] = unique(CallSigns_All);
        nCall = length(CallSigns);  % number of unique part 129 call signs

 


        Departure_from_Deploy = datenum(DashBoard.Departure_UTC) - datenum(start_Time)- 1e-13;
        %lastDay = floor(max(Departure_from_Deploy)) + 1;
        CallSgn = [];
        %for m = 1
        tally = zeros(1,nCall);
        for m1 = 1:nCall
            inds_91 = find(strcmp(CallSigns{m1},DashBoard.TailNumber) & Decision == 1 & class == 1 & (Departure_from_Deploy' > (lastDay - NDays)));  % Approved Part 91 records from current Tail Number
             if length(inds_91) == 0
                inds_91 = find(strcmp(CallSigns{m1},DashBoard.SICAO) & Decision == 1 & class == 1 & (Departure_from_Deploy' > (lastDay - NDays)));
             end
            M_91 = length(unique(floor(Departure_from_Deploy(inds_91))));
            tally(m1) = M_91;
            aaa = 1;
        end
        
        [Call_Top40, inds_40] = sort(tally,'descend');   
        count = 0;
        
        max_per_fig = 30;
        inds_10 = find(Call_Top40 >= 5);  % Number of aircraft with M >=10 (last NDays days)
        
        n_figs = ceil(length(inds_10)/max_per_fig);
        
        figure_numbers = 100:1:(100+n_figs - 1);
        
        counter = 0;
        for k = figure_numbers
            count = 0;  % operation number in this loop
            counter = counter + 1;
            figure(k); close(k); figure(k)
            fh = figure(k);
    %         plot(0,0,'ko'); hold on
    %         plot(0,0,'md')
            plot(0,0,'b*'); hold on
    %         plot(0,0,'g+')
                %for m = inds_40(40:-1:1)
                to_do = ((counter - 1) * max_per_fig + 1):1:(counter * max_per_fig);
                backwards = to_do(end:-1:1);
                for m = backwards
                    count = count + 1;  % operation number in this loop
                    inds_91 = find(strcmp(CallSigns{(inds_40(m))},DashBoard.TailNumber) & Decision == 1 & class == 1 & (Departure_from_Deploy' > (lastDay - NDays)));  % Approved Part 91 records from current Tail Number

                    if length(inds_91) == 0
                        inds_91 = find(strcmp(CallSigns{inds_40(m)},DashBoard.SICAO) & Decision == 1 & class == 1 & (Departure_from_Deploy' > (lastDay - NDays)));  % If no Tail Number, then use ICAO
                    end
        %             inds_121 = find(class(inds) == 2);
        %             plot(Departure_from_Deploy(inds(inds_121)),m*ones(1,length(inds_121)),'ko');
                    plot([0 lastDay],[count count],'k:')
        %             inds_129 = find(class(inds) == 3);
        %                 plot(Departure_from_Deploy(inds(inds_129)),m*ones(1,length(inds_129)),'md')
                    %inds_91 = find(class(inds) == 1);
                        plot(Departure_from_Deploy(inds_91),count*ones(1,length(inds_91)),'b*')        
        %             inds_135 = find(class(inds) == 4);
        %                 plot(Departure_from_Deploy(inds(inds_135)),m*ones(1,length(inds_135)),'g+')         

        %             n_Days_121 = length(unique(floor(Departure_from_Deploy(inds(inds_121)))));
        %             n_Days_129 = length(unique(floor(Departure_from_Deploy(inds(inds_129)))));
                    n_Days_91 = length(unique(floor(Departure_from_Deploy(inds_91))));
        %             n_Days_135 = length(unique(floor(Departure_from_Deploy(inds(inds_135)))));
                    %text(0.5,m,[num2str(length(inds)) '/' num2str(n_Days)],'BackgourndColor','g');
        %             text(0.25,m-.2,[num2str(length(inds)) ' /' num2str(n_Days_121) '/' num2str(n_Days_129)...
        %                 '/' num2str(n_Days_91) '/' num2str(n_Days_135)],...
        %                 'Fontsize',14);
        %             inds_135
        %             inds_91

                    %text(xt1,count-.2,[num2str(length(inds_91)) '/' num2str(n_Days_91)], 'Fontsize',14);
                    text(xt1,count-.2,[num2str(length(inds_91)) '/' num2str(tally(inds_40(m)))], 'Fontsize',14);

                    aaa = 1;
                    % Approvals, 



                end  % end m = backwards

                    ax = axis  ;     
                    %axis([(lastDay - 12) ax(2) ax(3) ax(4)]);
                    axis([(lastDay - 12) (lastDay+1.5) ax(3) ax(4)]);
                    yMax = ax(4);        

                for k = 1:(lastDay)
                    if k ~= (lastDay)
                        plot([k k],[0 yMax],'g:','Linewidth',2)
                    else
                        plot([k k],[0 yMax],'g:','Linewidth',4)
                    end

                end
                set(gca,'FontSize', 14)
%                 yticklabels(CallSigns (inds_40(40:-1:1)));  
                yticklabels(CallSigns(inds_40(backwards)));  
                
                %yticks(1:40);
                yticks(1:max_per_fig);
                xlabel('ADAPT-Approved UTC Departure Time','FontSize',fontsize)
                ylabel('Top 30 M: Tail Number / ICAO','FontSize',fontsize)
                legend('Part 91','FontSize',fontsize)
                title(sprintf('Part 91 10-Day Transaction History with %1.0f-Day M Totals: %1s',NDays,DashBoard.Filename),'Interpreter','None','FontSize',fontsize);
%title(sprintf('Transactions Last 10 Days for ADAPT Data File: %1s',DashBoard.Filename),'Interpreter','None');                


                 tickEnd = floor(max(Departure_from_Deploy)); 

                xt = xticks;
                xticklabels(date_Labels);
                  %ticks = (xt(1)+1):1:(xt(1)+10);
                  ticksR = tickEnd:-1:(tickEnd - 9);
                  ticks = ticksR(end:-1:1);
        %           difference = lastDay - ticks(end);
        %           ticks = ticks - difference;
                 xticks(ticks(1:length(date_Labels))); xtickangle(45);    
                 aaa = 1;
                 fh.WindowState = 'maximized';
        end  % end figure_numbers
        
        saveas(gca, 'slide_10.png')
        close(gcf)
        
        aaa = 1;
        
        
        
        