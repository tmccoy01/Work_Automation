
function out = Process_Table_Dashboard(DashBoard,end_Time, Decision, Reason, class, Pending, fontsize)      

        start_Time = '12/31/2019 00:00';
        TimeCreatedSinceDeploy = datenum(DashBoard.TS_Created) - datenum(start_Time);
        Departure_UTC_SinceDeploy = datenum(DashBoard.Departure_UTC) - datenum(start_Time);
            Departure_from_Deploy = datenum(DashBoard.Departure_UTC) - datenum(start_Time);
        %end_Time = '02/23/2020 23:59';
        today = datenum(end_Time)-datenum(start_Time);
        lastDay = ceil(today);
        periods = 11;  % set to 11 for 'last 10 days'
        %periods = 45;
        %periods = 16;  % Jan 15 set to 16
        %Filter_Time = 0:1:11;  

        Filter_Time_1 = [(lastDay - 10) lastDay];
        Filter_Time_2 = [0 lastDay];
        %Filter_Time = [(lastDay - 11) lastDay];  % Use '11' to grab the last 10 days worth of data


inds_Total_last10 = find(TimeCreatedSinceDeploy > Filter_Time_1(1) & TimeCreatedSinceDeploy < Filter_Time_1(2));
    n_Total_last10 = length(inds_Total_last10);
inds_Approved_last10 = find(TimeCreatedSinceDeploy > Filter_Time_1(1) & TimeCreatedSinceDeploy < Filter_Time_1(2) & Decision' == 1);
    n_Approved_last10 = length(inds_Approved_last10);
inds_Denied_last10 = find(TimeCreatedSinceDeploy > Filter_Time_1(1) & TimeCreatedSinceDeploy < Filter_Time_1(2) & (Decision' == 2 | Decision' == 3));
    n_Denied_last10 = length(inds_Denied_last10);

inds_AAA_Total_last10 = find(TimeCreatedSinceDeploy > Filter_Time_1(1) & TimeCreatedSinceDeploy < Filter_Time_1(2) & Pending' == 1);
    n_AAA_Total_last10 = length(inds_AAA_Total_last10);
inds_AAA_Approved_last10 = find(TimeCreatedSinceDeploy > Filter_Time_1(1) & TimeCreatedSinceDeploy < Filter_Time_1(2) & Pending' == 1 & Decision' == 1);
    n_AAA_Approved_last10 = length(inds_AAA_Approved_last10);
inds_AAA_Denied_last10 = find(TimeCreatedSinceDeploy > Filter_Time_1(1) & TimeCreatedSinceDeploy < Filter_Time_1(2) & Pending' == 1 & Decision' == 2);
    n_AAA_Denied_last10 = length(inds_AAA_Denied_last10);
inds_AAA_Expired_last10 = find(TimeCreatedSinceDeploy > Filter_Time_1(1) & TimeCreatedSinceDeploy < Filter_Time_1(2) & Pending' == 1 & Decision' == 3);
    n_AAA_Expired_last10 = length(inds_AAA_Expired_last10);

inds_Auto_Total_last10 = find(TimeCreatedSinceDeploy > Filter_Time_1(1) & TimeCreatedSinceDeploy < Filter_Time_1(2) & Pending' == 0);
    n_Auto_Total_last10 = length(inds_Auto_Total_last10);
inds_Auto_Approved_last10 = find(TimeCreatedSinceDeploy > Filter_Time_1(1) & TimeCreatedSinceDeploy < Filter_Time_1(2) & Pending' == 0 & Decision' == 1);
    n_Auto_Approved_last10 = length(inds_Auto_Approved_last10);
inds_Auto_Denied_last10 = find(TimeCreatedSinceDeploy > Filter_Time_1(1) & TimeCreatedSinceDeploy < Filter_Time_1(2) & Pending' == 0 & Decision' == 2);
    n_Auto_Denied_last10 = length(inds_Auto_Denied_last10);
inds_Auto_Expired_last10 = find(TimeCreatedSinceDeploy > Filter_Time_1(1) & TimeCreatedSinceDeploy < Filter_Time_1(2) & Pending' == 0 & Decision' == 3);
    n_Auto_Expired_last10 = length(inds_Auto_Expired_last10);

inds_Total_SinceDeploy = find(TimeCreatedSinceDeploy > Filter_Time_2(1) & TimeCreatedSinceDeploy < Filter_Time_2(2));
    n_Total_SinceDeploy = length(inds_Total_SinceDeploy);


    % figure(500); close(500); figure(500);
% figure(090);close(090);figure(090)
% %LastName = {'Smith';'Johnson';'Williams';'Jones';'Brown'};
%Day = {'Total';'AAA';'Auto'};
Day = {'Approved','Denied','Expired','10D Totals','Total'};
% 
% %Age = [38;43;38;40;49];
% CA = [CA_count_F; CA_count_S; CA_count_M];
Approved = [n_Approved_last10; n_AAA_Approved_last10 ; n_Auto_Approved_last10 ];
Denied = [n_Denied_last10; n_AAA_Denied_last10; n_Auto_Denied_last10 ];
%Expired = ['N/A'; n_AAA_Expired_last10 ; 'N/A'];
Expired = [NaN; n_AAA_Expired_last10 ; NaN];
Totals = [Approved(1) + Denied(1);Approved(2) + Denied(2) + Expired(2);Approved(3) + Denied(3) ];
SinceDeploy = [n_Total_SinceDeploy; NaN;NaN];
% 
Total = [Approved(1); Denied(1); Expired(1); Totals(1);SinceDeploy(1)];
AAA = [Approved(2); Denied(2); Expired(2); Totals(2);SinceDeploy(2)];
Auto = [Approved(3); Denied(3); Expired(3); Approved(3)+Denied(3);SinceDeploy(3)];
% %Height = [71;69;64;67;64];
% TX = [TX_count_F; TX_count_S; TX_count_M];
% 
% %Weight = [176;163;131;133;119];
% FL = [FL_count_F; FL_count_S; FL_count_M];
% 
% %T = table(Age,Height,Weight,'RowNames',LastName);
% T = table(CA,TX, FL,'RowName',Day);
T = table(Total,AAA,Auto,'RowName',Day);  % Column Names; 'Day' contains row names
% 
% 

writetable(T, 'table.csv');

% out = uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
%     'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1],'ColumnWidth',{40 40 40});

% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, .3, .130, 0.19]);
aaa = 1;




    
aaa = 1;