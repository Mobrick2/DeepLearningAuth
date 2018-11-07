N0 = 784 ; N1 = 512 ; N2 = 10;
%trust score (log2 value) at each layer
layer0 = -1 * ones(1,N0);
layer1 = -1 * ones(1,N1);
layer2 = -1 * ones(1,N2);


%parameters of cheating and verification process 
cheat_ratio = 0.1;
verify_ratio = 0.1;
validation_t = 2;
catch_time = 0;
number_of_verication = 0;

prevP = 0; layerP = 0; theta = 0;

% parameters to calculate the number of neuron choose to verify
layer0_verify_acc = zeros(1,N0);
layer1_verify_acc = zeros(1,N1);
layer2_verify_acc = zeros(1,N2);

initial_trust0 = -N0;
initial_trust1 = -N1;
initial_trust2 = -N2;


for i = 1 : validation_t
    
    %%%%%%%%%%%%%%SIMULATION OF THE LAYER 0 %%%%%%%%%%%%%%%%%%%%%%%
    theta = theta - (1-verify_ratio) * N0;
    
    %decide how many neurons to verify according the following formula
    % x = N - log(theta/layerP)/log(Smin)
    Smin = min(layer0);
    layerP = prevP + (sum(layer0) - initial_trust0);
        
    x = ceil(N0- (theta-layerP) / Smin);
    if x > N0 || x < 0
        x = N0;
    end
    
    %when go to the next layer's verification, we need somehow substruct
    %this part
    %initial_trust = layerP;
    
    %call the function to simulate the verification and cheating process 
    cheat_n = ceil(N0 * cheat_ratio);
    %simulatecatchProb(cheat_n,x, N0);
    
    
    
    [flag, results] = layerVerify( cheat_n, x, N0);

    %update the neurons probability during the verification
    nuerons_p = layer0;
    
    for j = 1 : N0
        layer0_verify_acc(j) = layer0_verify_acc(j) + results(j);
        
        %for those neruons that are verified correctly, probability is 1
        %log2(1) = 0, we store the log2 value
        if results(j) == 1
            nuerons_p(j) = 0;
        end  
    end
    
    %If attacker's cheating is caught, go another round checking and the 
    % attacker will be honest in the second round, so just update the 
    % verification accumulation
    if flag == 1
        rng('shuffle');
        verify_index = randi(N0,1,cheat_n);
    
        for j = 1 : cheat_n
            layer0_verify_acc(verify_index(j)) = ...
                layer0_verify_acc(verify_index(j)) + 1;
        end
    end
    
    %update the neruons probability because the trust score may be changed
    for j = 1 : N0
        if nuerons_p(j) < 0
            %neruon probability = trustScore * prevP
            nuerons_p(j) = log2(1 / (1 + exp(-layer0_verify_acc(j)))); 
            layer0(j) = log2(1 / (1 + exp(-layer0_verify_acc(j))));
        end
    end
    
    %%%%%%%%%%%%%%SIMULATION OF THE LAYER 1 %%%%%%%%%%%%%%%%%%%%%%%
    %update the previous layer's probability
    prevP = prevP + (sum(nuerons_p)-initial_trust0);
    theta = theta - (1-verify_ratio) * N1;
    
    %decide how many neurons to verify according the following formula
    Smin = min(layer1);
    layerP = prevP + (sum(layer1)-initial_trust1);
    
    x = ceil(N1- (theta-layerP) / Smin);
    if x > N1 || x < 0
        x = N1;
    end
    
    
    cheat_n = ceil(N1 * cheat_ratio);
    %simulatecatchProb(cheat_n,x, N1);
    
    [flag, results] = layerVerify( cheat_n, x, N1);
    
    nuerons_p = layer1;
    for j = 1 : N1
        layer1_verify_acc(j) = layer1_verify_acc(j) + results(j);
        
        %for those neruons that are verified correctly, probability is 1
        if results(j) == 1
            nuerons_p(j) = 0;
        end  
    end
    
    if flag == 1
        rng('shuffle');
        verify_index = randi(N1,1,cheat_n);
    
        for j = 1 : cheat_n
            layer1_verify_acc(verify_index(j)) = ...
                layer1_verify_acc(verify_index(j)) + 1;
        end
    end
    
    for j = 1 : N1
        if nuerons_p(j) < 0
            %neruon probability = trustScore * prevP
            nuerons_p(j) = log2(1 / (1 + exp(-layer1_verify_acc(j)))); 
            layer1(j) = log2(1 / (1 + exp(-layer1_verify_acc(j))));
        end
    end
    
    
    %%%%%%%%%%%%%%SIMULATION OF THE LAYER 2 %%%%%%%%%%%%%%%%%%%%%%%
    prevP = prevP + (sum(nuerons_p)-initial_trust1);

    theta= initial_trust - (1-verify_ratio) * N2;
    
    %decide how many neurons to verify according the following formula
    Smin = min(layer2);
    layerP = prevP + sum(layer1);
    
    
    initial_trust = layerP;
    x = ceil(N2- (theta-layerP) / Smin);
    if x > N2 || x < 0
        x = N2;
    end
    
    cheat_n = ceil(N2 * cheat_ratio);
    %simulatecatchProb(cheat_n,x, N2);
    
    [flag, results] = layerVerify( cheat_n, x, N2);
    
    nuerons_p = layer2;
    for j = 1 : N2
        layer2_verify_acc(j) = layer2_verify_acc(j) + results(j);
        
        %for those neruons that are verified correctly, probability is 1
        if results(j) == 1
            nuerons_p(j) = 0;
        end  
    end
    
    if flag == 1
        rng('shuffle');
        verify_index = randi(N2,1,cheat_n);
    
        for j = 1 : cheat_n
            layer2_verify_acc(verify_index(j)) = ...
                layer2_verify_acc(verify_index(j)) + 1;
        end
    end
    
    for j = 1 : N2
        if nuerons_p(j) < 0
            %neruon probability = trustScore * prevP
            nuerons_p(j) = log2(1 / (1 + exp(-layer2_verify_acc(j)))); 
            layer2(j) = log2(1 / (1 + exp(-layer2_verify_acc(j))));
        end
    end
    
    %%%%%%%%%%%%%%SIMULATION OF THE LAYER 2 (BACK) %%%%%%%%%%%%%%%%%%%%%%%
    prevP = prevP + sum(nuerons_p);
    
    theta = initial_trust - (1-verify_ratio) * N2;
    %decide how many neurons to verify according the following formula
    Smin = min(layer2);
    layerP = prevP + sum(layer2);
    
    initial_trust = layerP;
    x = ceil(N2- (theta-layerP) / Smin);
    if x > N2 || x < 0
        x = N2;
    end
    
    cheat_n = ceil(N2 * cheat_ratio);
    %simulatecatchProb(cheat_n,x, N1);
    
    [flag, results] = layerVerify( cheat_n, x, N2);
    
    nuerons_p = layer2;
    for j = 1 : N2
        layer2_verify_acc(j) = layer2_verify_acc(j) + results(j);
        
        %for those neruons that are verified correctly, probability is 1
        if results(j) == 1
            nuerons_p(j) = 0;
        end  
    end
    
    if flag == 1
        rng('shuffle');
        verify_index = randi(N2,1,cheat_n);
    
        for j = 1 : cheat_n
            layer2_verify_acc(verify_index(j)) = ...
                layer2_verify_acc(verify_index(j)) + 1;
        end
    end
    
    for j = 1 : N2
        if nuerons_p(j) < 0
            %neruon probability = trustScore * prevP
            nuerons_p(j) = log2(1 / (1 + exp(-layer2_verify_acc(j)))); 
            layer2(j) = log2(1 / (1 + exp(-layer2_verify_acc(j))));
        end
    end
    
    %%%%%%%%%%%%%%SIMULATION OF THE LAYER 1 (BACK) %%%%%%%%%%%%%%%%%%%%%%%
    %update the previous layer's probability
    prevP = prevP + sum(nuerons_p);

    theta = initial_trust - (1-verify_ratio) * N1;
    %decide how many neurons to verify according the following formula
    Smin = min(layer1);
    layerP = prevP + sum(layer1);
    
    
    initial_trust = layerP;
    
    x = ceil(N1- (theta-layerP) / Smin);
    if x > N1 || x < 0
        x = N1;
    end
    
    
    cheat_n = ceil(N1 * cheat_ratio);
    %simulatecatchProb(cheat_n,x, N1);
    
    [flag, results] = layerVerify( cheat_n, x, N1);
    
    nuerons_p = layer1;
    for j = 1 : N1
        layer1_verify_acc(j) = layer1_verify_acc(j) + results(j);
        
        %for those neruons that are verified correctly, probability is 1
        if results(j) == 1
            nuerons_p(j) = 0;
        end  
    end
    
    if flag == 1
        rng('shuffle');
        verify_index = randi(N1,1,cheat_n);
    
        for j = 1 : cheat_n
            layer1_verify_acc(verify_index(j)) = ...
                layer1_verify_acc(verify_index(j)) + 1;
        end
    end
    
    for j = 1 : N1
        if nuerons_p(j) < 0
            %neruon probability = trustScore * prevP
            nuerons_p(j) = log2(1 / (1 + exp(-layer1_verify_acc(j)))); 
            layer1(j) = log2(1 / (1 + exp(-layer1_verify_acc(j))));
        end
    end
    
    %%%%%%%%%%%%%%SIMULATION OF THE LAYER 0 (BACK) %%%%%%%%%%%%%%%%%%%%%%%
    %update the theta
    prevP = prevP + sum(nuerons_p);
    theta= initial_trust - (1-verify_ratio) * N0;
    
    %decide how many neurons to verify according the following formula
    % x = N - log(theta/layerP)/log(Smin)
    Smin = min(layer0);
    layerP = prevP + sum(layer0);
        
    x = ceil(N0- (theta-layerP) / Smin);
    if x > N0
        x = N0;
    end
    
    %when go to the next layer's verification, we need somehow substruct
    %this part
    initial_trust = layerP;
    
    %call the function to simulate the verification and cheating process 
    cheat_n = ceil(N0 * cheat_ratio);
    %simulatecatchProb(cheat_n,x, N0);
   
    [flag, results] = layerVerify( cheat_n, x, N0);

    %update the neurons probability during the verification
    nuerons_p = layer0;
    
    for j = 1 : N0
        layer0_verify_acc(j) = layer0_verify_acc(j) + results(j);
        
        %for those neruons that are verified correctly, probability is 1
        %log2(1) = 0, we store the log2 value
        if results(j) == 1
            nuerons_p(j) = 0;
        end  
    end
    
    %If attacker's cheating is caught, go another round checking and the 
    % attacker will be honest in the second round, so just update the 
    % verification accumulation
    if flag == 1
        rng('shuffle');
        verify_index = randi(N0,1,cheat_n);
    
        for j = 1 : cheat_n
            layer0_verify_acc(verify_index(j)) = ...
                layer0_verify_acc(verify_index(j)) + 1;
        end
    end
    
    %update the neruons probability because the trust score may be changed
    for j = 1 : N0
        if nuerons_p(j) < 0
            %neruon probability = trustScore * prevP
            nuerons_p(j) = log2(1 / (1 + exp(-layer0_verify_acc(j)))); 
            layer0(j) = log2(1 / (1 + exp(-layer0_verify_acc(j))));
        end
    end
    
end