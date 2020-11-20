
function out = Process_Slide_9_Dashboard_Rollup(DashBoard,end_Time, Decision, Reason, Class, Pending, fontsize)      

        start_Time = '12/31/2019 00:00';
        TimeCreatedSinceDeploy = datenum(DashBoard.TS_Created) - datenum(start_Time);
        Departure_UTC_SinceDeploy = datenum(DashBoard.Departure_UTC) - datenum(start_Time)- 1e-13;
        %end_Time = '02/23/2020 23:59';
        today = datenum(end_Time)-datenum(start_Time);
        lastDay = ceil(today);
        %periods = 11;  % set to 11 for 'last 10 days'
        %periods = 45;
        %periods = 16;  % Jan 15 set to 16
        %Filter_Time = 0:1:11;  

        %Filter_Time = (lastDay - periods+1):1:lastDay;
        Filter_Time = [(lastDay - 10) lastDay];  % Use '11' to grab the last 10 days worth of data
        nPeriods = length(Filter_Time);
        
        %dates = datenum({start_Time,end_Time});
        %Out = datevec(dates(1):dates(2));
        %date_Labels_Raw = datestr(Out,'ddd mm/dd');

        %date_Labels = date_Labels_Raw((lastDay - periods+2):end,:);
            
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
            
            fontsize = 20;

figure(009); close(009); figure(009);
fh = figure(009);

    patch(1,0,'g'); hold on;
    patch(1,0,'r')
    patch(1,0,'k')
    hb1 = bar(T_Top,'g','barwidth',0.5); hold on
    hb2 = bar(T_Middle,'r','barwidth',0.5); grid on
    hb3 = bar(T_Bottom,'k','barwidth',0.5);

    xticks(1:3);
    xticklabels({'Total', 'AAA', 'Auto'})
    %xlabel('Decision Source')
    ylabel('Number of Requests')
    title(sprintf('Ten Day Transaction History - Data File: %1s',DashBoard.Filename),'Interpreter','None');
    legend('Approved','Denied','Expired')
    
       
set(gca,'FontSize', fontsize)
    ax = axis;
    
    x1 = ax(1) + (ax(2)-ax(1))/13;
    x2 = ax(1) + 2*(ax(2)-ax(1))/9;
    y1 = ax(3) + (ax(4)-ax(3))/9;
    y2 = y1;    
    x1 = hb1(1).XData(1);
    
    aaa = 1;
    
    % Add text showing numbers for each bar
    
    if 0 
        for k2 = 1:1:nPeriods-1   % generate strings showing dates
    %         dates1 = [Filter_Time(2*k2-1, [3 1 2]) 0 0 0];
    %         dates2 = [Filter_Time(2*k2, [3 1 2]) 0 0 0];
            xtxt = hb1(1).XData(1) + hb1(k2).XOffset;

    %         txt = [datestr(dates1,'mm/dd/yy') ' - ' datestr(dates2,'mm/dd/yy')];
            %cd = text(xtxt,y1,txt,'Rotation',90,'color','b','Fontsize',10);

            % 'Total' Bar Group Numerical Text Data
                txt_Num_Total_Top = sprintf('%1.0f',T_Top(1,k2)-T_Middle(1,k2));  % Text for nth period top - total
                txt_Num_Total_Denied = sprintf('%1.0f',T_Middle(1,k2));
                ytext2 = T_Top(1,k2) + (ax(4)-ax(3))/50;
                ytext1 = T_Top(1,k2) + 2*(ax(4)-ax(3))/50;
                cd2 = text(xtxt-.008*length(txt_Num_Total_Top),ytext1,txt_Num_Total_Top);
                cd3 = text(xtxt-.008*length(txt_Num_Total_Denied),ytext2,txt_Num_Total_Denied);

            % 'AAA' Bar Group Numerical Text Data
                xtxt2 = hb1(1).XData(2) + hb1(k2).XOffset;
                txt_Num_AAA_Top = sprintf('%1.0f',T_Top(2,k2)-T_Middle(2,k2));
                txt_Num_AAA_Denied = sprintf('%1.0f',T_Middle(2,k2) - T_Bottom(2,k2));
                txt_Num_AAA_Expired = sprintf('%1.0f',T_Bottom(2,k2));
                ytext3 = T_Top(2,k2) + (ax(4)-ax(3))/50;
                ytext2 = T_Top(2,k2) + 2*(ax(4)-ax(3))/50;
                ytext1 = T_Top(2,k2) + 3*(ax(4)-ax(3))/50;
                cd4 = text(xtxt2-.008*length(txt_Num_AAA_Top),ytext1,txt_Num_AAA_Top);
                cd5 = text(xtxt2-.008*length(txt_Num_AAA_Denied),ytext2,txt_Num_AAA_Denied);
                cd6 = text(xtxt2-.008*length(txt_Num_AAA_Expired),ytext3,txt_Num_AAA_Expired);

             % 'Auto' Bar Group Numerical Text Data
                xtxt3 = hb1(1).XData(3) + hb1(k2).XOffset;
                txt_Num_Total_Top = sprintf('%1.0f',T_Top(3,k2)-T_Middle(3,k2));  % Text for nth period top - total
                txt_Num_Total_Denied = sprintf('%1.0f',T_Middle(3,k2));
                ytext2 = T_Top(3,k2) + (ax(4)-ax(3))/50;
                ytext1 = T_Top(3,k2) + 2*(ax(4)-ax(3))/50;
                cd7 = text(xtxt3-.008*length(txt_Num_Total_Top),ytext1,txt_Num_Total_Top);
                cd8 = text(xtxt3-.008*length(txt_Num_Total_Denied),ytext2,txt_Num_Total_Denied);



    %         cd = text(xtxt,y1,txt,'Rotation',90,'color','b','Fontsize',12)
            %cd.BackgroundColor = [1 1 1];
           % cd.EdgeColor = [0 0 1];       
           aaa = 1;
        end
    end % End conditional on plotting text
    
   
    fh.WindowState = 'maximized';
   
    saveas(gca, 'slide_9.png')
    close(gcf)
