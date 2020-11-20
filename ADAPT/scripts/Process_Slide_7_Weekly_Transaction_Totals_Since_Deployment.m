
function out = Process_Slide_7_Weekly_Transaction_Totals_Since_Deployment(DashBoard,end_Time, Decision, Reason, class, Pending, fontsize)      

        start_Time = '12/31/2019 00:00';
        TimeCreatedSinceDeploy = datenum(DashBoard.TS_Created) - datenum(start_Time);
        Departure_UTC_SinceDeploy = datenum(DashBoard.Departure_UTC) - datenum(start_Time)- 1e-13;
            Departure_from_Deploy = datenum(DashBoard.Departure_UTC) - datenum(start_Time)- 1e-13;
        %end_Time = '02/23/2020 23:59';
        today = datenum(end_Time)-datenum(start_Time);
        
        %lastDay = ceil(max(Departure_UTC_SinceDeploy));
        
            lastDay = ceil(today);
        
        periods = 11;  % set to 11 for 'last 10 days'
        %periods = 45;
        %periods = 16;  % Jan 15 set to 16
        %Filter_Time = 0:1:11;  

%         Filter_Time = (lastDay - periods+1):1:lastDay;
    Filter_Time = -2:7:lastDay;
        
        %Filter_Time = [(lastDay - 11) lastDay];  % Use '11' to grab the last 10 days worth of data
        nPeriods = length(Filter_Time);
        
        %dates = datenum({start_Time,end_Time});
        dates = datenum({start_Time,DashBoard.Departure_UTC{1}});
        Out = datevec(dates(1):dates(2));
        weeks = Out(5:7:end,:);
        
        dateLab = datestr(weeks,'ddd mm/dd');
            
        [nWa, mWa] = size(Filter_Time);  
        nW = nWa/2;                 % Number of time filters (bars in a bar family)

for k1 = 1:nPeriods-1



%     inds = find(datetime(DashBoard.yr,DashBoard.mo,DashBoard.da) >= datetime(Filter_Time((2*k1)-1,3),Filter_Time((2*k1)-1,1),Filter_Time((2*k1)-1,2))...
%         & datetime(DashBoard.yr,DashBoard.mo,DashBoard.da) <= datetime(Filter_Time((2*k1),3),Filter_Time((2*k1),1),Filter_Time((2*k1),2)));
    inds_91 = find(TimeCreatedSinceDeploy > Filter_Time(k1) & TimeCreatedSinceDeploy < Filter_Time(k1+1) & class' == 1);
    inds_121 = find(TimeCreatedSinceDeploy > Filter_Time(k1) & TimeCreatedSinceDeploy < Filter_Time(k1+1) & class' == 2);
    inds_129 = find(TimeCreatedSinceDeploy > Filter_Time(k1) & TimeCreatedSinceDeploy < Filter_Time(k1+1) & class' == 3);
    inds_135 = find(TimeCreatedSinceDeploy > Filter_Time(k1) & TimeCreatedSinceDeploy < Filter_Time(k1+1) & class' == 4);
    
    n_91(k1) = length(inds_91);
    n_121(k1) = length(inds_121);
    n_129(k1) = length(inds_129);
    n_135(k1) = length(inds_135);

end

% figure(14); close(14); figure(14)
% plot(1:nPeriods-1,n_91,'b:*','Markersize',16); hold on
% plot(1:nPeriods-1,n_121,'k:o','Markersize',16); hold on
% plot(1:nPeriods-1,n_129,'m:d','Markersize',16); hold on
% plot(1:nPeriods-1,n_135,'r:x','Markersize',16); hold on
% grid on
% legend('Part 91','Part 121','Part 129','Part 135')
% xlabel('Week Ending')
% ylabel('Total Weekly ADAPT Transactions Ending on Indicated Day')
% title('Weekly Transaction Totals by Part Number')
% 
% 
%         xticklabels(dateLab);
%         xticks(1:nPeriods-1); xtickangle(45);
% set(gca,'FontSize', 14)


figure(007); close(007); figure(007)
fh = figure(007);
subplot(211)
plot(1:nPeriods-1,n_91,'b:*','Markersize',16); hold on

grid on
legend('Part 91')

ylabel('Total Weekly ADAPT Transactions','FontSize',fontsize)
title(sprintf('Weekly Transaction Totals Since Deployment: %1s',DashBoard.Filename),'Interpreter','None','FontSize',fontsize);
        xticklabels({'','','','','','','',''});


%set(gca,'FontSize', 14)

subplot(212)
h44 = plot(1:nPeriods-1,n_121,'k:o','Markersize',16); hold on
plot(1:nPeriods-1,n_129,'m:d','Markersize',16); hold on
plot(1:nPeriods-1,n_135,'r:x','Markersize',16); hold on
xlabel('Week Ending','FontSize',fontsize)
ylabel('Total Weekly ADAPT Transactions','FontSize',fontsize)
legend('Part 121','Part 129','Part 135'); grid on

        xticklabels(dateLab);
        xticks(1:nPeriods-1); xtickangle(45);
        ax = ancestor(h44,'axes');
        yrule = ax.XAxis;
        yrule.FontSize = 14;
        %set(gca,'FontSize', 14)
aaa = 1;
fh.WindowState = 'maximized';

saveas(gca, 'slide_7.png')
close(gcf)
