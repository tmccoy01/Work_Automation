
function out = Process_Slide_4_Reason_for_Flight(DashBoard,end_Time, Decision, Reason, Class, Pending, fontsize)      

        start_Time = '12/31/2019 00:00';
        TimeCreatedSinceDeploy = datenum(DashBoard.TS_Created) - datenum(start_Time);
        Departure_UTC_SinceDeploy = datenum(DashBoard.Departure_UTC) - datenum(start_Time);
        %end_Time = '02/23/2020 23:59';
        today = datenum(end_Time)-datenum(start_Time);
        lastDay = ceil(today);
        periods = 11;  % set to 11 for 'last 10 days'
        %periods = 45;
        %periods = 16;  % Jan 15 set to 16
        %Filter_Time = 0:1:11;  

        Filter_Time = (lastDay - periods+1):1:lastDay;
        %Filter_Time = [(lastDay - 11) lastDay];  % Use '11' to grab the last 10 days worth of data
        nPeriods = length(Filter_Time);
        
        dates = datenum({start_Time,end_Time});
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
        length(find(Reason(inds) == 5)) length(find(Reason(inds) == 6)) length(find(Reason(inds) == 7)) length(find(Reason(inds) == 8)) length(find(Reason(inds) == 9)) ]';
    
    Reason_Appr(:,k1) = [length(find(Reason(inds) == 1 & Decision(inds) == 1)) length(find(Reason(inds) == 2 & Decision(inds) == 1))...
        length(find(Reason(inds) == 3 & Decision(inds) == 1)) length(find(Reason(inds) == 4 & Decision(inds) == 1))...
        length(find(Reason(inds) == 5 & Decision(inds) == 1)) length(find(Reason(inds) == 6 & Decision(inds) == 1))...
        length(find(Reason(inds) == 7 & Decision(inds) == 1)) length(find(Reason(inds) == 8 & Decision(inds) == 1))...
        length(find(Reason(inds) == 9 & Decision(inds) == 1)) ]';

    Class_Data(:,k1) = [length(find(class(inds) == 1)) length(find(class(inds) == 2)) length(find(class(inds) == 3)) length(find(class(inds) == 4))]';
    aaa = 1;
end

Approvals = T_Top-T_Middle;
Denials = T_Middle-T_Bottom;
Expired = T_Bottom;
                    
        

figure(004); close(004); figure(004)
fh = figure(004);
%subplot(312)

% set up legend
   xv = [0 0 0];
   yv = [0 0 0];
for k = 1:9
    plot(1,0,'w'); hold on
end
    patch(xv,yv,'y');
    patch(xv,yv,'g');

hb2 = bar(Reason_Data,'y'); grid on; hold on
bar(Reason_Appr,'g')
hb1 = hb2;

ax = axis;

% hist(Reason,30);

%xlabel('Reason for Flight')
ylabel('Number of Requests')
xlabel('Reason Category')
title(sprintf('Reason for Flight; Last 10 Days: %1s',DashBoard.Filename),'Interpreter','None');

abc = legend('1 = ADS-B Equip Install','2 = ADS-B Equip Repair','3 = Non-Electrical',...
    '4 = Agricultural','5 = Ferry Aircraft','6 = Fringe Operation','7 = Insufficient GPS',...
    '8 = NSAL Verification Flight','9 = Other','Transactions','Approvals');
legend('location','north')
set(abc,'color','none')
abc.FontSize = 18;
abc.NumColumns = 4;

x4 = 0.03;


% Add text labels to blue bars
for k2 = 1:1:nPeriods-1
    xtxt = hb2(1).XData(1) + hb1(k2).XOffset;
    ytext = Reason_Data(1,k2) + (ax(4)-ax(3))/50;
    txt = sprintf('%1.0f',Reason_Data(1,k2));
    cd = text(xtxt-x4*length(txt),ytext,txt);
    
    xtxt = hb2(1).XData(2) + hb1(k2).XOffset;
    ytext = Reason_Data(2,k2) + (ax(4)-ax(3))/50;
    txt = sprintf('%1.0f',Reason_Data(2,k2));
    cd = text(xtxt-x4*length(txt),ytext,txt);    
    
    xtxt = hb2(1).XData(3) + hb1(k2).XOffset;
    ytext = Reason_Data(3,k2) + (ax(4)-ax(3))/50;
    txt = sprintf('%1.0f',Reason_Data(3,k2));
    cd = text(xtxt-x4*length(txt),ytext,txt);     
    
    xtxt = hb2(1).XData(4) + hb1(k2).XOffset;
    ytext = Reason_Data(4,k2) + (ax(4)-ax(3))/50;
    txt = sprintf('%1.0f',Reason_Data(4,k2));
    cd = text(xtxt-x4*length(txt),ytext,txt);   
    
    xtxt = hb2(1).XData(5) + hb1(k2).XOffset;
    ytext = Reason_Data(5,k2) + (ax(4)-ax(3))/50;
    txt = sprintf('%1.0f',Reason_Data(5,k2));
    cd = text(xtxt-x4*length(txt),ytext,txt);   
    
    xtxt = hb2(1).XData(6) + hb1(k2).XOffset;
    ytext = Reason_Data(6,k2) + (ax(4)-ax(3))/50;
    txt = sprintf('%1.0f',Reason_Data(6,k2));
    cd = text(xtxt-x4*length(txt),ytext,txt);  
    
    xtxt = hb2(1).XData(7) + hb1(k2).XOffset;
    ytext = Reason_Data(7,k2) + (ax(4)-ax(3))/50;
    txt = sprintf('%1.0f',Reason_Data(7,k2));
    cd = text(xtxt-x4*length(txt),ytext,txt);  
    
    xtxt = hb2(1).XData(8) + hb1(k2).XOffset;
    ytext = Reason_Data(8,k2) + (ax(4)-ax(3))/50;
    txt = sprintf('%1.0f',Reason_Data(8,k2));
    cd = text(xtxt-x4*length(txt),ytext,txt);     
    
    xtxt = hb2(1).XData(9) + hb1(k2).XOffset;
    ytext = Reason_Data(9,k2) + (ax(4)-ax(3))/50;
    txt = sprintf('%1.0f',Reason_Data(9,k2));
    cd = text(xtxt-x4*length(txt),ytext,txt);       
    
    aaa = 1;
    
end

set(gca,'FontSize', fontsize)

ax = axis;
y1 = ax(3)+ (ax(4)-ax(3))/9;

fh.WindowState = 'maximized';

clear cd
saveas(gca, 'slide_4.png')
close(gcf)

