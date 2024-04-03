
clear;clc

% vstup nekumulovane medzery - ignoruje nuly

M = importdata("C:\Users\patri\Desktop\diplomka\Zaznamy\záznamy\Real Utoky\Ver_data.txt");
n1 = numel(M);
data = M;
%data = M(1:ceil(n1/10)); %0207
slot_window = 0.01;       %0207

%data = M(500000:ceil(n1/6)); %0402
%slot_window = 0.1;       %0402

%data = M(20000:n1/20); %0504a
%slot_window = 0.01;    %0504a

%data = M(15*n1/40:17*n1/40); %0504b
%slot_window = 0.01;    %0504b

%data = M(27*n1/40:31*n1/40); %0504c
%slot_window = 0.1;    %0504c

%data = M(1:n1/20); %0605a
%slot_window = 0.01;    %0605a

%data = M(6*n1/20:7*n1/20); %0605b
%slot_window = 0.01;    %0605b

%data = M(4*n1/32:6*n1/32); %0701
%slot_window = 0.1;    %0701


sampled_data = medzery_to_casyy(data, slot_window);


lastNonZeroIndex = find(sampled_data, 1, 'last');
sampled_data = sampled_data(1:lastNonZeroIndex);
plot(sampled_data)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sampled_data = medzery_to_casyy(data, slot_window)
    sampled_index = 1;
    sampled_data = zeros(1,length(data));
    pom_sucet = 0;
    
    for i=1:length(data)
        pom_sucet = pom_sucet + data(i);
    
        if pom_sucet < slot_window
            sampled_data(sampled_index) = sampled_data(sampled_index) + 1;
        else
            sampled_index = sampled_index + 1;
            sampled_data(sampled_index) = sampled_data(sampled_index) + 1;
            pom_sucet = 0;
        end
    end
end

