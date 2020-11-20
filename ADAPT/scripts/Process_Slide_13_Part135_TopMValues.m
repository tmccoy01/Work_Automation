
function out = Process_Slide_13_Part135_TopMValues(DashBoard,end_Time, Decision, Reason, class, Pending, fontsize,NDays)      

        start_Time = '12/31/2019 00:00';
        TimeCreatedSinceDeploy = datenum(DashBoard.TS_Created) - datenum(start_Time);
        Departure_UTC_SinceDeploy = datenum(DashBoard.Departure_UTC) - datenum(start_Time)- 1e-13;
        %end_Time = '02/23/2020 23:59';
        today = datenum(end_Time)-datenum(start_Time);
        %lastDay = ceil(today);
        lastDay = ceil(max(Departure_UTC_SinceDeploy));
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

        Departure_from_Deploy = datenum(DashBoard.Departure_UTC) - datenum(start_Time)- 1e-13;  % Departure times of requests

        inds_135 = find(class == 4 & Decision == 1 & Departure_from_Deploy' > (lastDay - 11));   % Part 135 Approvals in last 10 days (only show if any approvals in last 10 days)
        n_135 = length(inds_135);
                 CallSigns = [];
                for k = inds_135;
                    if length(DashBoard.TailNumber{k}) > 2
                        CallSigns = [CallSigns {char(DashBoard.TailNumber{k})}];
                    else
                        CallSigns = [CallSigns {char(DashBoard.SICAO{k})}];
                    end
                    %CallSigns = [CallSigns {char(DashBoard.Aircraft_ID{k})}];
                end

                [CallSign_List_TN Indices] = unique(CallSigns);
                nCall_TN = length(CallSign_List_TN);  % number of unique part 135 call signs
                CallSignDist_TN = zeros(1,nCall_TN);  % Set up initial count vector

                for k4 = 1:nCall_TN
                    for k5 = 1:n_135;
                        if strcmp(char(CallSign_List_TN(k4)),char(CallSigns(k5)))
                            CallSignDist_TN(k4) = CallSignDist_TN(k4) + 1;
                        end
                    end
                end    
        
        
       
        figure(013); close(013); figure(013)
        fh = figure(013);
        plot(0,0,'ko'); hold on
        plot(0,0,'md')
        plot(0,0,'b*')
        plot(0,0,'g+')

        Departure_from_Deploy = datenum(DashBoard.Departure_UTC) - datenum(start_Time)-1e-13;
        %lastDay = floor(max(Departure_from_Deploy));
        CallSgn = [];
        %for m = 1
        xt1 = lastDay - 12 + 0.25;
        CounterValue = 0;
        CallCollect = {};
        for m = 1:nCall_TN  % Loop through each call sign that had at least one part 135 approval in the last 10 days
            inds = find(strcmp(CallSign_List_TN{m},DashBoard.TailNumber) & Decision == 1 & class == 4);  % Total number of approved Part 135 requests from current Tail Number (
            if length(inds) == 0
                inds = find(strcmp(CallSign_List_TN{m},DashBoard.SICAO) & Decision == 1);  % If no Tail Number, then use ICAO
                         
            end
            inds_135 = find(class(inds) == 4 & (Departure_from_Deploy(inds)' > lastDay - NDays));  % Number of approved applications in last NDays (NDays is current M history window)

%             inds_135 = find(class(inds) == 3 & (Departure_from_Deploy(inds)' > lastDay - NDays));
%                 plot(Departure_from_Deploy(inds(inds_135)),m*ones(1,length(inds_135)),'md')
%             inds_91 = find(class(inds) == 1 & (Departure_from_Deploy(inds)' > lastDay - NDays));
%                 plot(Departure_from_Deploy(inds(inds_91)),m*ones(1,length(inds_91)),'b*')        
%             inds_135 = find(class(inds) == 4 & (Departure_from_Deploy(inds)' > lastDay - NDays));
%                 plot(Departure_from_Deploy(inds(inds_135)),m*ones(1,length(inds_135)),'g+')         
                
            n_Days_135 = length(unique(floor(Departure_from_Deploy(inds(inds_135)))));
            
            
            if n_Days_135 >= 3
                CounterValue = CounterValue + 1;
                CallCollect{CounterValue} = CallSign_List_TN{m};
                plot(Departure_from_Deploy(inds(inds_135)),CounterValue*ones(1,length(inds_135)),'ko');
                plot([0 lastDay],[CounterValue CounterValue],'k:')   
                
    %             n_Days_135 = length(unique(floor(Departure_from_Deploy(inds(inds_135)))));
    %             n_Days_91 = length(unique(floor(Departure_from_Deploy(inds(inds_91)))));
    %             n_Days_135 = length(unique(floor(Departure_from_Deploy(inds(inds_135)))));
                %text(0.5,m,[num2str(length(inds)) '/' num2str(n_Days)],'BackgourndColor','g');
                text(xt1,CounterValue-.2,[num2str(length(inds)) ' /' num2str(n_Days_135)],'Fontsize',14);
    %             inds_135
    %             inds_91
            end

            aaa = 1;
            % Approvals, 
        end
        %for k = 1:(lastDay)
        for k = (lastDay - 11):lastDay
            if k ~= (lastDay)
                plot([k k],[0 CounterValue+1],'g:','Linewidth',2)
            else
                plot([k k],[0 CounterValue+1],'g:','Linewidth',4)
            end
              
        end
        yticklabels(CallCollect);
        

        
        yticks(1:CounterValue);
        set(gca,'FontSize', 14)
        xlabel('ADAPT-Approved UTC Departure Time','FontSize',fontsize)
        ylabel('Tail Number / ICAO','FontSize',fontsize)
        %legend('Part 135','Part 135','Part 91','Part 135')
        %title('Approved Transaction History for Part 135 Aircraft')
        title(sprintf('Part 135 10-Day Transaction History with %1.0f-Day M Totals: %1s',NDays,DashBoard.Filename),'Interpreter','None','FontSize',fontsize);

        
        ax = axis;
        axis([(lastDay-12) (lastDay+1.5) ax(3:4)]);
        
        tickEnd = floor(max(Departure_from_Deploy)); 
        
        xt = xticks;
        xticklabels(date_Labels);
          %ticks = (xt(1)+1):1:(xt(1)+10);
          ticksR = tickEnd:-1:(tickEnd - 9);
          ticks = ticksR(end:-1:1);
%           difference = lastDay - ticks(end);
%           ticks = ticks - difference;
        xticks(ticks(1:length(date_Labels))); xtickangle(45); 
        
        if CounterValue == 0
            ax = axis;
            text(mean(ax(1:2)),mean(ax(3:4)), 'No Data for this 10-day period','FontSize',16,'Color',[1 0 0]);
            aaa = 1;
        end        
        
        
         fh.WindowState = 'maximized';
         
         saveas(gca, 'slide_13.png')
         close(gcf)
     
        
        aaa = 1;
        