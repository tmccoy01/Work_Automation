
function out = Process_Slide_2_Tx_by_Day(DashBoard,end_Time, Decision, Reason, Class, Pending, fontsize)      

        start_Time = '12/31/2019 00:00';
        TimeCreatedSinceDeploy = datenum(DashBoard.TS_Created) - datenum(start_Time);
        Departure_UTC_SinceDeploy = datenum(DashBoard.Departure_UTC) - datenum(start_Time)- 1e-13;
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

Class_Data(:,k1) = [length(find(class(inds) == 1)) length(find(class(inds) == 2)) length(find(class(inds) == 3)) length(find(class(inds) == 4))]';
aaa = 1;
end

Approvals = T_Top-T_Middle;
Denials = T_Middle-T_Bottom;
Expired = T_Bottom;
                    
        
% Trend chart for Method of transaction
figure(002); close(002);figure(002)
fh = figure(002);
[m,n] = size(Approvals);  % m = 3, n = # days
subplot(311); % Total Transactions
plot(1:n,Approvals(1,:),'go:','LineWidth',2,'Markersize',10); hold on; grid on
plot(1:n,Denials(1,:),'ro:','LineWidth',2,'Markersize',10)
plot(1:n,Approvals(1,:)+Denials(1,:),'bo:','LineWidth',2,'Markersize',10)

ylabel('Total Transactions')
legend('Approvals','Denials','Total','Location','Northwest')
xticklabels('')
set(gca,'FontSize', 16)
title(sprintf('Transactions Last 10 Days for ADAPT Data File: %1s',DashBoard.Filename),'Interpreter','None','FontSize',fontsize);


subplot(312); % Total Transactions
plot(1:n,Approvals(3,:),'go:','LineWidth',2,'Markersize',10); hold on; grid on
plot(1:n,Denials(3,:),'ro:','LineWidth',2,'Markersize',10)
plot(1:n,Approvals(3,:)+Denials(3,:),'bo:','LineWidth',2,'Markersize',10)

ylabel('Auto Transactions')
legend('Approvals','Denials','Total','Location','Northwest')
xticklabels('')
set(gca,'FontSize', 16)

subplot(313); % Total Transactions
plot(1:n,Approvals(2,:),'go:','LineWidth',2,'Markersize',10); hold on; grid on
plot(1:n,Denials(2,:),'ro:','LineWidth',2,'Markersize',10)
plot(1:n,Expired(2,:),'ko:','LineWidth',2,'Markersize',10)
plot(1:n,Approvals(2,:)+Denials(2,:)+Expired(2,:),'bo:','LineWidth',2,'Markersize',10)
xlabel('Day')
ylabel('AAA Transactions')
legend('Approvals','Denials','Expired','Total','Location','Northwest')
xticklabels(date_Labels);
xticks(1:length(xticklabels)); xtickangle(45);
set(gca,'FontSize', 16)
fh.WindowState = 'maximized';

saveas(gca, 'slide_2.png')
close(gcf)
aaa = 1;