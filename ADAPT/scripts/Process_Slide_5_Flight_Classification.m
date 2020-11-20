
function out = Process_Slide_5_Flight_Classification(DashBoard,end_Time, Decision, Reason, class, Pending, fontsize)      

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
        length(find(Reason(inds) == 5)) length(find(Reason(inds) == 6)) length(find(Reason(inds) == 7)) length(find(Reason(inds) == 8)) ]';

    Class_Data(:,k1) = [length(find(class(inds) == 1)) length(find(class(inds) == 2)) length(find(class(inds) == 3)) length(find(class(inds) == 4))]';  % # Applications for each class
    
    Class_Appr(:,k1) = [length(find(class(inds) == 1 & Decision(inds) == 1)) length(find(class(inds) == 2 & Decision(inds) == 1))...  % # Approvals for each class
        length(find(class(inds) == 3 & Decision(inds) == 1)) length(find(class(inds) == 4 & Decision(inds) == 1))]';
    aaa = 1;
end

Approvals = T_Top-T_Middle;
Denials = T_Middle-T_Bottom;
Expired = T_Bottom;
                    
 x4 = 0.01;       

figure(005); close(005); figure(005)
fh = figure(005);
%subplot(313)
% set up legend stuff
   xv = [0 0 0];
   yv = [0 0 0];
    for k = 1:4
        plot(1,0,'w'); hold on
    end
    patch(xv,yv,'y');
    patch(xv,yv,'g');

hb3 = bar(Class_Data,'y'); grid on; hold on
bar(Class_Appr,'g')
hb1 = hb3;
abd = legend('1 = Part 91', '2 = Part 121', '3 = Part 129', '4 = Part 135','Transactions','Approvals');

abd.FontSize = 18;
set(gca,'FontSize', fontsize)

xticks([1:4])
%xticklabels({'Part 91','Part 121','Part 129','Part 135'});
xticklabels({'1','2','3','4'});

%xlabel('Flight Classification')
ylabel('Number of Requests')
xlabel('Flight Classification Category')
title(sprintf('Flight Classifications Last 10 Days: %1s',DashBoard.Filename),'Interpreter','None');

ax = axis;
y1 = ax(3)+ (ax(4)-ax(3))/9;

%     for k2 = 1:nW   % generate strings showing dates
%         dates1 = [Filter_Time(2*k2-1, [3 1 2]) 0 0 0];
%         dates2 = [Filter_Time(2*k2, [3 1 2]) 0 0 0];
%         xtxt = hb3(1).XData(1) + hb3(k2).XOffset;
% 
%         txt = [datestr(dates1,'mm/dd/yy') ' - ' datestr(dates2,'mm/dd/yy')];
%         %cd = text(xtxt,y1,txt,'Rotation',90,'color','b','Fontsize',10);
%         %cd.BackgroundColor = [1 1 1];
%         %cd.EdgeColor = [0 0 1];
%     end

% Add text labels to blue bars
for k2 = 1:1:nPeriods-1
    xtxt = hb3(1).XData(1) + hb1(k2).XOffset;
    ytext = Class_Data(1,k2) + (ax(4)-ax(3))/50;
    txt = sprintf('%1.0f', Class_Data(1,k2));
    cd = text(xtxt-x4*length(txt),ytext,txt);
    
    xtxt = hb3(1).XData(2) + hb1(k2).XOffset;
    ytext =  Class_Data(2,k2) + (ax(4)-ax(3))/50;
    txt = sprintf('%1.0f', Class_Data(2,k2));
    cd = text(xtxt-x4*length(txt),ytext,txt);    
    
    xtxt = hb3(1).XData(3) + hb1(k2).XOffset;
    ytext =  Class_Data(3,k2) + (ax(4)-ax(3))/50;
    txt = sprintf('%1.0f', Class_Data(3,k2));
    cd = text(xtxt-x4*length(txt),ytext,txt);     
    
    xtxt = hb3(1).XData(4) + hb1(k2).XOffset;
    ytext =  Class_Data(4,k2) + (ax(4)-ax(3))/50;
    txt = sprintf('%1.0f', Class_Data(4,k2));
    cd = text(xtxt-x4*length(txt),ytext,txt);   
    
  
    
    aaa = 1;
    
end    
    
fh.WindowState = 'maximized';

saveas(gca, 'slide_5.png')
close(gcf)

aaa = 1;
    