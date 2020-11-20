
function out = Process_Slide_6_Top40_M(DashBoard,end_Time, Decision, Reason, class, Pending, fontsize, NDays)      

        start_Time = '12/31/2019 00:00';
        TimeCreatedSinceDeploy = datenum(DashBoard.TS_Created) - datenum(start_Time);
        Departure_UTC_SinceDeploy = datenum(DashBoard.Departure_UTC) - datenum(start_Time)- 1e-13;
            Departure_from_Deploy = datenum(DashBoard.Departure_UTC) - datenum(start_Time)- 1e-13;
        %end_Time = '02/23/2020 23:59';
        today = datenum(end_Time)-datenum(start_Time);
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

 % Call signs used 10 or more times
    % Build the list
    nApps = length(DashBoard.Status);
   CallSigns_All = [];
   
% Step 1 - get list of call signs
    for k6 = 1:nApps  % Loop over all transactions
%         CallSigns_All = [CallSigns_All {char(DashBoard.TailNumber{k6})}];
            if length(DashBoard.TailNumber{k6}) > 2
                CallSigns_All = [CallSigns_All {char(DashBoard.TailNumber{k6})}];
            else
                CallSigns_All = [CallSigns_All {char(DashBoard.SICAO{k6})}];
            end
    end
    
CallSigns_All_Unique = unique(CallSigns_All);

nC = length(CallSigns_All_Unique);  % Number of unique call signs

% End of step 1 - have call signs and number of call signs
 
% For each call sign, determine M in last 60 days

for k1 = 1:nC
    Mask_CS = strcmp(CallSigns_All_Unique(k1), CallSigns_All);   % indices for current call sign
    inds_91 = find(class == 1 & Decision == 1 & (Departure_from_Deploy' > (lastDay - NDays)) & Mask_CS);
       M_91(k1) = length(unique(floor(Departure_from_Deploy(inds_91))));
    inds_121 = find(class == 2 & Decision == 1 & (Departure_from_Deploy' > (lastDay - NDays)) & Mask_CS);
       M_121(k1) = length(unique(floor(Departure_from_Deploy(inds_121))));   
    inds_129 = find(class == 3 & Decision == 1 & (Departure_from_Deploy' > (lastDay - NDays)) & Mask_CS);
       M_129(k1) = length(unique(floor(Departure_from_Deploy(inds_129))));  
    inds_135 = find(class == 4 & Decision == 1 & (Departure_from_Deploy' > (lastDay - NDays)) & Mask_CS);
       M_135(k1) = length(unique(floor(Departure_from_Deploy(inds_135))));   
       
end
m_count = [M_91' M_121' M_129' M_135'];
[data_M inds] = sort(max(m_count'),'descend');



% Master M figure
figure(006); close(006); figure(006)
fh = figure(006);
        plot(0,0,'ko'); hold on
        plot(0,0,'md')
        plot(0,0,'b*')
        plot(0,0,'g+')
n2Do = 40;
count = 0;
        xt1 = lastDay - 12 + 0.25;
for m = inds(n2Do:-1:1)
    count = count + 1;
    Call = CallSigns_All_Unique(m);
    inds_121 = find(strcmp(CallSigns_All_Unique{m},CallSigns_All) & Decision == 1 & class == 2 & (Departure_from_Deploy' > (lastDay - NDays)));  % Part 121 Approved records from current Call Sign
    inds_129 = find(strcmp(CallSigns_All_Unique{m},CallSigns_All) & Decision == 1 & class == 3 & (Departure_from_Deploy' > (lastDay - NDays)));  % Part 129 Approved records from current Call Sign
    inds_91 = find(strcmp(CallSigns_All_Unique{m},CallSigns_All) & Decision == 1 & class == 1 & (Departure_from_Deploy' > (lastDay - NDays)));  % Part 121 Approved records from current Call Sign
    inds_135 = find(strcmp(CallSigns_All_Unique{m},CallSigns_All) & Decision == 1 & class == 4 & (Departure_from_Deploy' > (lastDay - NDays)));  % Part 121 Approved records from current Call Sign
    
    plot(Departure_from_Deploy(inds_121),count*ones(1,length(inds_121)),'ko');
    plot(Departure_from_Deploy(inds_129),count*ones(1,length(inds_129)),'md');
    plot(Departure_from_Deploy(inds_91),count*ones(1,length(inds_91)),'b*');
    plot(Departure_from_Deploy(inds_135),count*ones(1,length(inds_135)),'g+');
    plot([0 lastDay],[count count],'k:')
    ax = axis;  xlim = 0.07*(ax(2) - ax(1));
    
    
            n_Days_121 = length(unique(floor(Departure_from_Deploy(inds_121))));
            n_Days_129 = length(unique(floor(Departure_from_Deploy(inds_129))));
            n_Days_91 = length(unique(floor(Departure_from_Deploy(inds_91))));
            n_Days_135 = length(unique(floor(Departure_from_Deploy(inds_135))));

            %text(0.5,m,[num2str(length(inds)) '/' num2str(n_Days)],'BackgourndColor','g');
            tot = sum([length(inds_121) length(inds_129) length(inds_91) length(inds_135)]);
            text(xt1,count-.2,[num2str(tot) ' /' num2str(n_Days_121) '/' num2str(n_Days_129)...
                '/' num2str(n_Days_91) '/' num2str(n_Days_135)],...
                'Fontsize',12);    
    % Place dot to indicate largest M value
    [val, M_type] = max([n_Days_121 n_Days_129 n_Days_91 n_Days_135]);
    switch M_type
        case 1
            plot(xt1 + 1,count,'ko','Markersize',10)
        case 2
            plot(xt1 + 1,count,'md','Markersize',10)
        case 3
            plot(xt1 + 1,count,'b*','Markersize',10)
        case 4
            plot(xt1 + 1,count,'g+','Markersize',10)
    end
    
    
end
        for k = 1:(lastDay)
            if k ~= (lastDay)
                plot([k k],[0 n2Do],'g:','Linewidth',2)
            else
                plot([k k],[0 n2Do],'g:','Linewidth',4)
            end
        end
        set(gca,'FontSize', 14)
        ax = axis  ;     
        %axis([(lastDay - 12) ax(2) ax(3) ax(4)]);
        axis([(lastDay - 12) (lastDay+1.5) ax(3) ax(4)]);
        yticklabels(char(CallSigns_All_Unique{inds(n2Do:-1:1)}));
        yticks(1:n2Do);
        xlabel('ADAPT-Approved UTC Departure Time','FontSize',fontsize)
        ylabel('Tail Number / ICAO','FontSize',fontsize)
        legend('Part 121','Part 129','Part 91','Part 135','FontSize',fontsize)
        title(sprintf('Top 40 M with %1.0f-Day History; Showing Approvals Over Last 10 Days; %1s : %1s',NDays,DashBoard.Filename),'Interpreter','None','FontSize',fontsize);
        

        tickEnd = floor(max(Departure_from_Deploy)); 
        
        xt = xticks;
        xticklabels(date_Labels);
          %ticks = (xt(1)+1):1:(xt(1)+10);
          ticksR = tickEnd:-1:(tickEnd - 9);
          ticks = ticksR(end:-1:1);
%           difference = lastDay - ticks(end);
%           ticks = ticks - difference;
         xticks(ticks(1:length(date_Labels))); xtickangle(45); 
        
%             
             aaa = 1;
fh.WindowState = 'maximized';

saveas(gca, 'slide_6.png')
close(gcf)
        