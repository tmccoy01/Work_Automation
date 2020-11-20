%DashBoard = Read_ADAPT_Dashboard_Data_11_12_2019;
% Load spreadsheet using 'Import' button on MATLAB COmmand Window

% Name = ADAPTExporton20191015
% ImportFile = 'ADAPTExporton20191015';
% Data = ADAPTExporton20191015;
function ADAPT_Main(adapt_file)

DashBoard = Read_ADAPT_Dashboard_Data_xlsRead_01_03_2020(adapt_file);

Process_ADAPT_Data_2020_05_14



        start_Time = '12/31/2019 00:00';
        TimeCreatedSinceDeploy = datenum(DashBoard.TS_Created) - datenum(start_Time);
        Departure_UTC_SinceDeploy = datenum(DashBoard.Departure_UTC) - datenum(start_Time) - 1e-13;
        end_Time = '11/16/2020 23:59';
        NDays = 30;
        today = datenum(end_Time)-datenum(start_Time);
        lastDay = ceil(today);
        periods = 11;  % set to 11 for 'last 10 days'
        %periods = 45;
        %periods = 16;  % Jan 15 set to 16
        %Filter_Time = 0:1:11;  

        Filter_Time = (lastDay - periods+1):1:lastDay;
        nPeriods = length(Filter_Time);
        
        dates = datenum({start_Time,end_Time});
        Out = datevec(dates(1):dates(2));
        date_Labels_Raw = datestr(Out,'ddd mm/dd');

        date_Labels = date_Labels_Raw((lastDay - periods+2):end,:);
            
        [nWa, mWa] = size(Filter_Time);  
        nW = nWa/2;                 % Number of time filters (bars in a bar family)

        T_Top = zeros(3,(nPeriods-1));
        T_Middle = T_Top;
        T_Bottom = T_Top;
        Reason_Data = zeros(8,(nPeriods));
        Class_Data = zeros(4,(nPeriods));

fontsize = 20;
Process_Slide_2_Tx_by_Day(DashBoard,end_Time, Decision, Reason, part_class, Pending, fontsize);
Process_Slide_3_Method_of_Processing(DashBoard,end_Time, Decision, Reason, part_class, Pending,fontsize);
Process_Slide_4_Reason_for_Flight(DashBoard,end_Time, Decision, Reason, part_class, Pending,fontsize);
Process_Slide_5_Flight_Classification(DashBoard,end_Time, Decision, Reason, part_class, Pending,fontsize);
Process_Slide_6_Top40_M(DashBoard,end_Time, Decision, Reason, part_class, Pending,fontsize, NDays);
Process_Slide_7_Weekly_Transaction_Totals_Since_Deployment(DashBoard,end_Time, Decision, Reason, part_class, Pending,fontsize);
Process_Slide_9_Dashboard_Rollup(DashBoard,end_Time, Decision, Reason, part_class, Pending);
Process_Table_Dashboard(DashBoard,end_Time, Decision, Reason, part_class, Pending, fontsize);
Process_Slide_10_Part91_TopMValues(DashBoard,end_Time, Decision, Reason, part_class, Pending,fontsize,NDays);
Process_Slide_11_Part121_TopMValues(DashBoard,end_Time, Decision, Reason, part_class, Pending,fontsize,NDays);
Process_Slide_12_Part129_TopMValues(DashBoard,end_Time, Decision, Reason, part_class, Pending,fontsize,NDays);
Process_Slide_13_Part135_TopMValues(DashBoard,end_Time, Decision, Reason, part_class, Pending,fontsize,NDays);

% movefile('*.png', '/outputs');
% movefile('*.csv', '/outputs');

end


