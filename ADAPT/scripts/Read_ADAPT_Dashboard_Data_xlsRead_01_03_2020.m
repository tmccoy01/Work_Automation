function DashBoard = Read_ADAPT_Dashboard_Data_xlsRead_01_03_2020(file_name)
% Read SBS ADAPT Dashboard Spreadsheet and generate figures

%pathname = 'D:\RegulusMain\06_SBS\007.DeviationRequest\15.ADAPT_Data_Dashboard\MATLAB';
% [filename, pathname] = uigetfile( ...
%        {'*.*'}, ...
%         'Select ADAPT Dashboard .csv File to load'); 
% [num,txt,raw] = xlsread([pathname filename]); 
[num, txt, raw] = xlsread(file_name);
DashBoard.Filename = file_name;
    
%     %textcol=[2:16 18:22 25:40];
%     textcol = 1:40;
%     no_param = 40;
%     columns = no_param;           % Number of columns in .csv file
% 
%     %build format string
%     nfmt='%n';  % format for numeric data
%     tfmt='%s';  % format for text data
%     fmt=[];
%     
%     for i=1:no_param
%         if ismember(i,textcol)==1
%             fmt=[fmt tfmt];
%         else
%             fmt=[fmt nfmt];
%         end
%     end
%     
%     fmt=[fmt '%*[^\n]'];
%     
%     amat = '[a1';
%     for k = 2:columns
%         amat = [amat [', a' num2str(k)]];
%     end
%     amat = [amat ']'];
%         
%     eval([amat '=textread([pathname filename], fmt ,''delimiter'','','',  ''headerlines'',1);']) %read the data
%     
%     
    % Change code here after **************************************************
[RecordsA,Fields] = size(raw);    
nR = RecordsA - 1;  % Don't count the header row
    
    % LEFT OFF HERE - NEED TO INGEST REMAINDER OF TRIMBLE DATA
DashBoardRaw.TransID = raw(2:end,1);   % Transaction ID, Numeric
DashBoardRaw.Route_Number = raw(2:end,2);  % Looks numeric, but kept as text
DashBoardRaw.TransID_Public = raw(2:end,3);  % Text
DashBoardRaw.Status = raw(2:end,4);   % Approved, Denied, Pending
DashBoardRaw.Correlated = raw(2:end,5);   % Was the flight found in the surveillance database?
DashBoardRaw.Closed = raw(2:end,6);          % Yes/No indication
DashBoardRaw.TS_Created = raw(2:end,7);      % 3 field date followed by two field time (MO/DA/YEAR HH:MM)
DashBoardRaw.TS_Resolved = raw(2:end,8);     % Time that email indicating 'resolved' by AAA went out; blank in auto approve/deny case
DashBoardRaw.TS_Notified_Pending = raw(2:end,9);  % same format as TS_Created
DashBoardRaw.TS_Notified_Resolved = raw(2:end,10);        % Time that the email went out indicating pending has been resolved
DashBoardRaw.TS_Notified_Resolver = raw(2:end,11);       % Time that email went to AAA indicating presence of Pending request
DashBoardRaw.ResolverUsername = raw(2:end,12);       % Name of AAA resolver (email address in all cases) Blank if auto-decision; blank if expired
DashBoardRaw.Aircraft_ID = raw(2:end,13);
DashBoardRaw.Aircraft_Type = raw(2:end,14);      % Typically Model Number (e.g., C172)
DashBoardRaw.Navigation_Source_TSO = raw(2:end,15);      % equipped/unequipped, e.g.
DashBoardRaw.ADSB_Link_TSO = raw(2:end,16);          % equipped/unequippped inoperable
DashBoardRaw.Mask_Angle = raw(2:end,17);     % Satellite/horizon mask angle; Numeric
DashBoardRaw.Departure_Airport = raw(2:end,18); 
DashBoardRaw.Departure_UTC = raw(2:end,19);   % same time format as previous (a7 through a11)
DashBoardRaw.Arrival_Airport = raw(2:end,20);
DashBoardRaw.Arrival_UTC = raw(2:end,21);        % Same time format as previous
DashBoardRaw.Duration = raw(2:end,22);       % HH:MM  predicted flight duration
DashBoardRaw.Cruise_Speed = raw(2:end,23);  % Numeric field containing projected route speed
DashBoardRaw.Cruise_Altitude = raw(2:end,24);  %  Numeric field with projected cruise altitude (ft, MSL)
DashBoardRaw.Route_of_Flight = raw(2:end,25);   % series of fixes / fix names / lat/lons, etc.
DashBoardRaw.Disposition = raw(2:end,26);   % Alternate Surveillance, Sufficient (need to check on what that means)
DashBoardRaw.Link_To_Coverage_Webpage = raw(2:end,27);  % URL to coverage info
DashBoardRaw.SICAO = raw(2:end,28);   %Not sure what this is (only reported if provided by applicant?
DashBoardRaw.TailNumber = raw(2:end,29);
DashBoardRaw.Flight_Classification = raw(2:end,30);   % Part 91, etc.
DashBoardRaw.ADSB_EQ_Status = raw(2:end,31);     % Difference between ADS-B Equipment status and ADS-B Link TSO
DashBoardRaw.XPonder_Alt_Operational = raw(2:end,32);  
DashBoardRaw.Pilot_In_Command = raw(2:end,33);  % Name of pilot applicant
DashBoardRaw.PIC_Phone_Number = raw(2:end,34);  % 10 digit phone number; may contain hyphens
DashBoardRaw.PIC_Email_Address = raw(2:end,35);
DashBoardRaw.Reason_For_Flight = raw(2:end,36);  % Column of ADT
DashBoardRaw.Requester_Comment = raw(2:end,37);
DashBoardRaw.ATC_Facility_List = raw(2:end,38);
DashBoardRaw.Resolution = raw(2:end,39);  % Reason for denial
DashBoardRaw.Resolver_Comment = raw(2:end,40);   % AAA comment

% Interpret time fields

for k1 = 1: nR
    timeSample = DashBoardRaw.TS_Created{k1};
    inds_Slash = findstr(timeSample,'/');
    inds_Colon = findstr(timeSample,':');
    
    DashBoardRaw.mo(k1) = str2num(timeSample(1:(inds_Slash(1)-1)));
    DashBoardRaw.da(k1) = str2num(timeSample((inds_Slash(1)+1):inds_Slash(2)-1));
    DashBoardRaw.yr(k1) = str2num(timeSample((inds_Slash(2)+1):inds_Slash(2)+4));
    
    DashBoardRaw.hr(k1) = str2num(timeSample((inds_Slash(2)+6):(inds_Colon-1)));
    DashBoardRaw.mn(k1) = str2num(timeSample((inds_Colon+1):end));
    
    aaa = 1;
    
end

testEntry = [];
for k2 = 1:nR
    if (length(strfind(char(DashBoardRaw.Aircraft_ID{k2}),'zzv')) == 0) & (length(strfind(char(DashBoardRaw.Aircraft_ID{k2}),'ZZV')) == 0)
        testEntry = [testEntry k2];  % entries that are NOT test entries
    end
end
counter = 0;
for k3 = testEntry
    counter = counter + 1;
    DashBoard.TransID(counter) = DashBoardRaw.TransID(k3);
    DashBoard.Route_Number(counter) = DashBoardRaw.Route_Number(k3);
    DashBoard.TransID_Public(counter) = DashBoardRaw.TransID_Public(k3);  
    DashBoard.Status(counter) = DashBoardRaw.Status(k3);   % Approved, Denied, Pending
    DashBoard.Correlated(counter) = DashBoardRaw.Correlated(k3);   % Was the flight found in the surveillance database?
    DashBoard.Closed(counter) = DashBoardRaw.Closed(k3);          % Yes/No indication
    DashBoard.TS_Created(counter) = DashBoardRaw.TS_Created(k3);      % 3 field date followed by two field time (MO/DA/YEAR HH:MM)
    DashBoard.TS_Resolved(counter) = DashBoardRaw.TS_Resolved(k3) ;     % Time that email indicating 'resolved' by AAA went out; blank in auto approve/deny case
    DashBoard.TS_Notified_Pending(counter) = DashBoardRaw.TS_Notified_Pending(k3);  % same format as TS_Created
    DashBoard.TS_Notified_Resolved(counter) = DashBoardRaw.TS_Notified_Resolved(k3);        % Time that the email went out indicating pending has been resolved
    DashBoard.TS_Notified_Resolver(counter) = DashBoardRaw.TS_Notified_Resolver(k3);       % Time that email went to AAA indicating presence of Pending request
    
    DashBoard.ResolverUsername(counter) = DashBoardRaw.ResolverUsername(k3);       % Name of AAA resolver (email address in all cases) Blank if auto-decision; blank if expired
    DashBoard.Aircraft_ID(counter) = DashBoardRaw.Aircraft_ID(k3);
    DashBoard.Aircraft_Type(counter) = DashBoardRaw.Aircraft_Type(k3);      % Typically Model Number (e.g., C172)
    DashBoard.Navigation_Source_TSO(counter) = DashBoardRaw.Navigation_Source_TSO(k3);      % equipped/unequipped, e.g.
    DashBoard.ADSB_Link_TSO(counter) = DashBoardRaw.ADSB_Link_TSO(k3) ;          % equipped/unequippped inoperable
    DashBoard.Mask_Angle(counter) = DashBoardRaw.Mask_Angle(k3);     % Satellite/horizon mask angle; Numeric
    DashBoard.Departure_Airport(counter) = DashBoardRaw.Departure_Airport(k3); 
    DashBoard.Departure_UTC(counter) = DashBoardRaw.Departure_UTC(k3);   % same time format as previous (a7 through a11)
    DashBoard.Arrival_Airport(counter) = DashBoardRaw.Arrival_Airport(k3) ;
    DashBoard.Arrival_UTC(counter) = DashBoardRaw.Arrival_UTC(k3);        % Same time format as previous
    DashBoard.Duration(counter) = DashBoardRaw.Duration(k3);       % HH:MM  predicted flight duration
    DashBoard.Cruise_Speed(counter) = DashBoardRaw.Cruise_Speed(k3);  % Numeric field containing projected route speed
    DashBoard.Cruise_Altitude(counter) = DashBoardRaw.Cruise_Altitude(k3);  %  Numeric field with projected cruise altitude (ft, MSL)
    DashBoard.Route_of_Flight(counter) = DashBoardRaw.Route_of_Flight(k3);   % series of fixes / fix names / lat/lons, etc.
    DashBoard.Disposition(counter) = DashBoardRaw.Disposition(k3);   % Alternate Surveillance, Sufficient (need to check on what that means)
    DashBoard.Link_To_Coverage_Webpage(counter) = DashBoardRaw.Link_To_Coverage_Webpage(k3);  % URL to coverage info
    DashBoard.SICAO(counter) = DashBoardRaw.SICAO(k3);   %Not sure what this is (only reported if provided by applicant?
    DashBoard.TailNumber(counter) = DashBoardRaw.TailNumber(k3);
    DashBoard.Flight_Classification(counter) = DashBoardRaw.Flight_Classification(k3);   % Part 91, etc.
    DashBoard.ADSB_EQ_Status(counter) = DashBoardRaw.ADSB_EQ_Status(k3) ;     % Difference between ADS-B Equipment status and ADS-B Link TSO
    DashBoard.XPonder_Alt_Operational(counter) = DashBoardRaw.XPonder_Alt_Operational(k3) ;  
    DashBoard.Pilot_In_Command(counter) = DashBoardRaw.Pilot_In_Command(k3) ;  % Name of pilot applicant
    DashBoard.PIC_Phone_Number(counter) = DashBoardRaw.PIC_Phone_Number(k3) ;  % 10 digit phone number; may contain hyphens
    DashBoard.PIC_Email_Address(counter) = DashBoardRaw.PIC_Email_Address(k3);
    DashBoard.Reason_For_Flight(counter) = DashBoardRaw.Reason_For_Flight(k3);  % Column of ADT
    DashBoard.Requester_Comment(counter) = DashBoardRaw.Requester_Comment(k3);
    DashBoard.ATC_Facility_List(counter) = DashBoardRaw.ATC_Facility_List(k3);
    DashBoard.Resolution(counter) = DashBoardRaw.Resolution(k3) ;  % Reason for denial
    DashBoard.Resolver_Comment(counter) = DashBoardRaw.Resolver_Comment(k3);   % AAA comment
    
    DashBoard.mo(counter) = DashBoardRaw.mo(k3);
    DashBoard.da(counter) = DashBoardRaw.da(k3);
    DashBoard.yr(counter) = DashBoardRaw.yr(k3);
    
    DashBoard.hr(counter) = DashBoardRaw.hr(k3);
    DashBoard.mn(counter) = DashBoardRaw.mn(k3);
end
    

aaa = 1;


    
 
    


        