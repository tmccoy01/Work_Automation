nApps = length(DashBoard.Status);
for k = 1:nApps
    
    statusString = DashBoard.Status{k};
    %statusString = char(Data{k+1,4});
    switch statusString
        case 'APPROVED'
            Decision(k) = 1;  % 1 = Approved
        case 'DENIED'
            Decision(k) = 2;
        case 'EXPIRED'
            Decision(k) = 3;
        case 'PENDING'    % Status is 'PENDING' if not yet acted upon by AAA and 
            Decision(k) = 4;
        case 'INVALID'
            Decision(k) = 5;
    end
    
    if length(char(DashBoard.ResolverUsername{k})) ~= 1 | Decision(k) == 3 | Decision(k) == 4
        Pending(k) = 1;  % AAA Decision
    else
        Pending(k) = 0;  % AutoDecision
    end
    
    whyString = char(DashBoard.Reason_For_Flight{k});
    switch whyString
        case 'ADS-B Equipment Installation'
            Reason(k) = 1;
        case 'ADS-B Equipment Repair'
            Reason(k) = 2;
        case 'Non-Electrical'
            Reason(k) = 3;
        case 'Agricultural'
            Reason(k) = 4;
        case 'Ferry Aircraft'
            Reason(k) = 5;
        case 'Fringe Operation'
            Reason(k) = 6;
        case 'Insufficient GPS'
            Reason(k) = 7;
        case 'NSAL Verification Flight'
            Reason(k) = 8;
        case 'Other (Explain in Comments Box)'
            Reason(k) = 9;
    end
    
    class_String = char(DashBoard.Flight_Classification{k});
    switch class_String
        case 'PART 91'
            part_class(k) = 1;
        case 'PART 121'
            part_class(k) = 2;
        case 'PART 129'
            part_class(k) = 3;
        case 'PART 135'
            part_class(k) = 4;
    end
    
    % TIme of day of request
    line = char(DashBoard.TS_Created{k});
        indscolon = findstr(line,':');
    TS_Created(k) = str2num([line(indscolon-2:indscolon-1) line(indscolon+1:indscolon+2)]);
    TS_Created_Hours(k) = str2num(line(indscolon-2:indscolon-1));
    TS_Created_Minutes(k) = str2num(line(indscolon+1:indscolon+2));    
    TS_Created_Minutes_Total(k) = TS_Created_Hours(k)*60 + TS_Created_Minutes(k);
    aaa = 1;
    
    % Time of day of flight
     line = char(DashBoard.Departure_UTC{k});
        indscolon = findstr(line,':');
    Departure_UTC(k) = str2num([line(indscolon-2:indscolon-1) line(indscolon+1:indscolon+2)]);
    Departure_Hours(k) = str2num(line(indscolon-2:indscolon-1));
    Departure_Minutes(k) = str2num(line(indscolon+1:indscolon+2));
    Departure_Minutes_Total(k) = Departure_Hours(k) * 60 + Departure_Minutes(k);
    aaa = 1;   
    
    Look_Ahead(k) = (Departure_Minutes_Total(k) - TS_Created_Minutes_Total(k))/60;
    if Look_Ahead(k) < 0;
        Look_Ahead(k) = Look_Ahead(k) + 24;
        aaa = 1;
    end
    
    % Time of day Resolved
     line = char(DashBoard.TS_Notified_Resolved{k});
     if length(line) >= 2
        indscolon = findstr(line,':');
        TS_Resolved(k) = str2num([line(indscolon-2:indscolon-1) line(indscolon+1:indscolon+2)]);
        TS_Resolved_Hours(k) = str2num(line(indscolon-2:indscolon-1));
        TS_Resolved_Minutes(k) = str2num(line(indscolon+1:indscolon+2));
        TS_Resolved_Minutes_Total(k) = TS_Resolved_Hours(k) * 60 + TS_Resolved_Minutes(k);   
     else
        TS_Resolved(k) = 0;
        TS_Resolved_Hours(k) = 0;
        TS_Resolved_Minutes(k) = 0;
        TS_Resolved_Minutes_Total(k) = TS_Resolved_Hours(k) * 60 + TS_Resolved_Minutes(k);          
     end
    
    Time_Process(k) = (TS_Resolved_Minutes_Total(k) - TS_Created_Minutes_Total(k))/60;  % Converted to hours
    
    if Time_Process(k) < 0;
        Time_Process(k) = Time_Process(k) + 24;
        aaa = 1;
    end
    
    Notification_Period(k) = (TS_Resolved_Minutes_Total(k) - Departure_Minutes_Total(k))/60;
    if Notification_Period(k) < 0
        Notification_Period(k) = Notification_Period(k) + 24;
    end
    
%     line = char(DashBoard.Aircraft_ID{k});
%     if length(strfind(line,'ZZV')) > 0 | length(strfind(line,'zzv')) > 0
%         testEntry(k) = 1;
%         aaa = 1;
%     else
%         testEntry(k) = 0;
%         aaa = 1;
%     end
    
    aaa = 1;
    
end

