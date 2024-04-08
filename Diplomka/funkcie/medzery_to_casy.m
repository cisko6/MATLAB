

function sampled_data = medzery_to_casy(data, slot_window)
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