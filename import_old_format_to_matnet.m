birdnet = matnet(0);

for i=1:BIRDS_DATABASE.birds_number
    fprintf('%d,',i);
    aBird = BIRDS_DATABASE.get_bird_by_index(i);
    
    birdnet.add_node(aBird.ringNo,'tags',aBird.tags,'gender',aBird.gender,'natalbox',aBird.natalbox,...
        'natalyear',aBird.natalyear,'breedbox',aBird.breedbox,'breedyear',aBird.breedyear,...
        'first_appearance_date',aBird.first_appearance_date,'first_appearance_location',aBird.first_appearance_location,...
        'last_appearance_date',aBird.last_appearance_date,'last_appearance_location',aBird.last_appearance_location);
end

fprintf('\n');

parfor t=1:length(Cframes_full)
    Wtemp = output(t).Wframes_before_sign_test;
    [x, y] = find(Wtemp);
    
    fprintf('t: %d, %d edges\n',t,length(x));
    
    for k=1:length(x)
        i = x(k);
        j = y(k);
        
        bi = BIRDS_DATABASE.get_bird_by_index(i);
        bj = BIRDS_DATABASE.get_bird_by_index(j);
        
        birdnet.add_edge(bi.ringNo,bj.ringNo,strcat('day_',num2str(t)),'weight',Wtemp(i,j));
    end
end