           
            [filename, path]=uigetfile('*.pcap');

            %citanie PCAP suboru a rozparsovanie do tabulky
            pcapReaderObj = pcapReader(fullfile(path, filename),OutputTimestampFormat='microseconds');
            decodedPackets = readAll(pcapReaderObj);
            %pcapLength = length(decodedPackets);
            pcapAsTable = struct2table(decodedPackets);

            % ulozime si stlpec z tabulky pcapAsTable do vektoru Time
            Timestamp = pcapAsTable(:,2);
            Time = table2array(Timestamp);
            % ulozime si stlpec z tabulky pcapAsTable do vektoru Packet
            PacketLength = pcapAsTable(:,5);
            Packet = table2array(PacketLength);       

            %ulozime si nase vektory: cas a velkost paketov
            save('TimestampSkuska','Time');
            save('PacketSkuska',"Packet");
        
            %naimportujeme si casy a pakety pre rychlejsiu pracu
            %[TimestampFile, path]=uigetfile('*.mat');
            %Timestamp = importdata(fullfile(path, TimestampFile));
            %[PacketsFile, path]=uigetfile('*.mat');
            %PacketLength = importdata(fullfile(path, PacketsFile));
            Timestamp = importdata('TimestampSkuska.mat');
            PacketLength = importdata("PacketSkuska.mat");
    
            % T2 je vektor s nasimi casmi z PCAP suboru
            % v N je ulozena velkost PCAP suboru
            % v meanOfTimes je priemer casov
            % v stdOfTimes je standardna odchylka
            T2 = Timestamp;
            N = length(T2);
            meanOfTimes = mean(T2);
            stdOfTimes = std(T2);

            % counting delta from data
            % funkcia diff robi deltu medzi casmi
            te = diff(T2);

            %Length of data
            NumberOfRows = N;

            d = 1000;%app.EditField_SampleWindow.Value; %timeslot
            T = 0;
            I = 0;
            a = 0;  % prirastky casu
            for i=1:N-1
                T=T+te(i);
                if mod(i,1000)==0
                   i
                end
                if T>d
                   a = [a , I];
                   I=1;
                   T=T-d;
                   if T>d
                      I=0;
                   end
                else
                   I = I+1;
                end
            end

            plot(a);


            
            