N0 = 784 ; N1 = 512 ; N2 = 10;
%trust score (log2 value) at each layer
layer0 = 0.8 * ones(1,N0);
layer1 = 0.8 * ones(1,N1);
layer2 = 0.8 * ones(1,N2);
P = zeros(1,9);
min_ratios = zeros(1,9);
realLayerP = zeros(1,9);
catch_P = zeros(1,9);
realtheta = zeros(1,9);

%parameters of cheating and verification process 
cheat_ratio = 0.1;
validation_t = 1;
catch_time = 0;

theta = 0.85;

% parameters to store the number times neuron selected to verify
layer0_verify_acc = zeros(1,N0);
layer1_verify_acc = zeros(1,N1);
layer2_verify_acc = zeros(1,N2);


for i = 1 : validation_t
    
    %%%%%%%%%%%%%%SIMULATION OF THE LAYER 0 %%%%%%%%%%%%%%%%%%%%%%
    
    L = 1;
    %decide how many neurons to verify according the following formula
    %xx = ceil( N0 * (L - (1*log(theta)-layerP)/log(Smin)));
    Smin = min(layer0);
    
    %x = findX(Smin,N0,prevP,1,theta);
    x = ceil( N0 * (1 - log2(theta)/log2(Smin)));
    if x > N0
        x = N0;
        disp('x > N0');
    elseif x < 0
        x = 0;
    end
    min_ratios(L) = x/N0;
    
    %test the robustness of the layer correctness probability
    realtheta(L) = correctPsimulate2( layer0, N0, x);
    
    %results are used to mark those neurons that have been picked for
    %verification
    
    cheat_n = ceil(N0 * cheat_ratio);
    [flag, results] = layerVerify2(cheat_n, x, N0);

    %initial the neurons temperary trust score
    nuerons_ts = log2(nthroot(layer0,N0));
    
    for j = 1 : N0
        layer0_verify_acc(j) = layer0_verify_acc(j) + results(j);
        
        %for those neruons that are verified correctly, probability is 1
        if results(j) == 1
            nuerons_ts(j) = log2(1);
        end  
    end
    
    %If attacker's cheating is caught, go another round checking and the 
    % attacker will be honest in the second round, so just update the 
    % verification accumulation
    if flag == 1
        rng('shuffle');
        verify_index = randperm(N0,cheat_n);
    
        for j = 1 : cheat_n
            layer0_verify_acc(verify_index(j)) = ...
                layer0_verify_acc(verify_index(j)) + 1;
            
            results(verify_index(j)) = 1;
            
            %The neurons that have been verified,the correctness
            %probability becomes 1
            nuerons_ts(verify_index(j)) = log2(1);
        end
    end
    
    %update the neruons' trust score
    for j = 1 : N0
        if nuerons_ts(j) ~= 1 && results(j) == 0
            layer0(j) = 1 / (1 + exp(-layer0_verify_acc(j)));
            nuerons_ts(j) = log2( nthroot(layer0(j), N0) );
        end
    end
    
    realLayerP(L) = pow2( sum(nuerons_ts));
    L = L + 1;
    
    %%%%%%%%%%%%%%SIMULATION OF THE LAYER 1 %%%%%%%%%%%%%%%%%%%%%%%
    %update the previous layer's probability
    
    
    %decide how many neurons to verify according the following formula
    Smin = min(layer1);  
    x = ceil( N1 * (1 - log2(theta)/log2(Smin)));
    if x > N1
        x = N1;
        disp('overflow');
    elseif x < 0
        x = 0;
    end
    min_ratios(L) = x/N1;
    
    realtheta(L) = correctPsimulate2( layer1, N1, x);
    
    cheat_n = ceil(N1 * cheat_ratio);
    [flag, results] = layerVerify( cheat_n, x, N1);
    
    nuerons_ts = log2(nthroot(layer1,N1));
    
    for j = 1 : N1
        layer1_verify_acc(j) = layer1_verify_acc(j) + results(j);
        
        %for those neruons that are verified correctly, probability is 1
        if results(j) == 1
            nuerons_ts(j) = log2(1);
        end  
    end
    
    if flag == 1
        rng('shuffle');
        verify_index = randperm(N1,cheat_n);
    
        for j = 1 : cheat_n
            layer1_verify_acc(verify_index(j)) = ...
                layer1_verify_acc(verify_index(j)) + 1;
            
            results(verify_index(j)) = 1;
            
            %The neurons that have been verified,the correctness
            %probability becomes 1
            nuerons_ts(verify_index(j)) = log2(1);
        end
    end
    
    for j = 1 : N1
        if nuerons_ts(j) ~= 1 && results(j) == 0
            %neruon probability = trustScore * prevP
            layer1(j) = 1 / (1 + exp(-layer1_verify_acc(j)));
            nuerons_ts(j) = log2( nthroot(layer1(j), N1) );
        end
    end
    
    realLayerP(L) = pow2( sum(nuerons_ts));
    L = L + 1;
    
    
    %%%%%%%%%%%%%%SIMULATION OF THE LAYER 2 %%%%%%%%%%%%%%%%%%%%%%%
    %decide how many neurons to verify according the following formula
    Smin = min(layer2);
    
    x = ceil( N2 * (1 - log2(theta)/log2(Smin)));
    if x > N2
        x = N2;
        disp('overflow');
    elseif x < 0
        x = 0;
    end
    min_ratios(L) = x/N2;
    realtheta(L) = correctPsimulate2(layer2, N2, x);
    
    
    cheat_n = ceil(N2 * cheat_ratio);
    [flag, results] = layerVerify( cheat_n, x, N2);
    
    nuerons_ts = log2(nthroot(layer2,N2));
    
    for j = 1 : N2
        layer2_verify_acc(j) = layer2_verify_acc(j) + results(j);
        
        %for those neruons that are verified correctly, probability is 1
        if results(j) == 1
            nuerons_ts(j) = log2(1);
        end  
    end
    
    if flag == 1
        rng('shuffle');
        verify_index = randperm(N2,cheat_n);
    
        for j = 1 : cheat_n
            layer1_verify_acc(verify_index(j)) = ...
                layer1_verify_acc(verify_index(j)) + 1;
            
            results(verify_index(j)) = 1;
            
            %The neurons that have been verified,the correctness
            %probability becomes 1
            nuerons_ts(verify_index(j)) = log2(1);
        end
    end
    
    for j = 1 : N2
        if nuerons_ts(j) ~= 1 && results(j) == 0
            %neruon probability = trustScore * prevP
            layer2(j) = 1 / (1 + exp(-layer2_verify_acc(j)));
            nuerons_ts(j) = log2( nthroot(layer2(j), N2) );
        end
    end
    
    realLayerP(L) = pow2( sum(nuerons_ts));
    L = L + 1;
    %%%%%%%%%%%%%%SIMULATION OF THE LAYER 2 (BACK) %%%%%%%%%%%%%%%%%%%%%%%
    
    %decide how many neurons to verify according the following formula
    Smin = min(layer2);
    
   
    x = ceil( N2 * (1 - log2(theta)/log2(Smin)));
    if x > N2
        x = N2;
        disp('overflow');
    elseif x < 0
        x = 0;
    end
    min_ratios(L) = x/N2;
    realtheta(L) = correctPsimulate2( layer2, N2, x);
    
    
    cheat_n = ceil(N2 * cheat_ratio);
    [flag, results] = layerVerify( cheat_n, x, N2);
    
    nuerons_ts = log2(nthroot(layer2,N2));
    
    for j = 1 : N2
        layer2_verify_acc(j) = layer2_verify_acc(j) + results(j);
        
        %for those neruons that are verified correctly, probability is 1
        if results(j) == 1
            nuerons_ts(j) = log2(1);
        end  
    end
    
    if flag == 1
        rng('shuffle');
        verify_index = randperm(N2,cheat_n);
    
        for j = 1 : cheat_n
            layer1_verify_acc(verify_index(j)) = ...
                layer1_verify_acc(verify_index(j)) + 1;
            
            results(verify_index(j)) = 1;
            
            %The neurons that have been verified,the correctness
            %probability becomes 1
            nuerons_ts(verify_index(j)) = log2(1);
        end
    end
    
    for j = 1 : N2
        if nuerons_ts(j) ~= 1 && results(j) == 0
            %neruon probability = trustScore * prevP
            layer2(j) = 1 / (1 + exp(-layer2_verify_acc(j)));
            nuerons_ts(j) = log2( nthroot(layer2(j), N2) );
        end
    end
    
    realLayerP(L) = pow2( sum(nuerons_ts));
    L = L + 1;
    %%%%%%%%%%%%%%SIMULATION OF THE LAYER 1 (BACK) %%%%%%%%%%%%%%%%%%%%%%%
    %update the previous layer's probability
    Smin = min(layer1);
    
    x = ceil( N1 * (1 - log2(theta)/log2(Smin)));
    if x > N1
        x = N1;
        disp('overflow');
    elseif x < 0
        x = 0;
    end
    min_ratios(L) = x/N1;
    realtheta(L) = correctPsimulate2( layer1, N1, x);
    
    
    
    cheat_n = ceil(N1 * cheat_ratio);
    [flag, results] = layerVerify( cheat_n, x, N1);
    
    nuerons_ts = log2(nthroot(layer1,N1));
    
    for j = 1 : N1
        layer1_verify_acc(j) = layer1_verify_acc(j) + results(j);
        
        %for those neruons that are verified correctly, probability is 1
        if results(j) == 1
            nuerons_ts(j) = log2(1);
        end  
    end
    
    if flag == 1
        rng('shuffle');
        verify_index = randperm(N1,cheat_n);
    
        for j = 1 : cheat_n
            layer1_verify_acc(verify_index(j)) = ...
                layer1_verify_acc(verify_index(j)) + 1;
            
            results(verify_index(j)) = 1;
            
            %The neurons that have been verified,the correctness
            %probability becomes 1
            nuerons_ts(verify_index(j)) = log2(1);
        end
    end
    
    for j = 1 : N1
        if nuerons_ts(j) ~= 1 && results(j) == 0
            %neruon probability = trustScore * prevP
            layer1(j) = 1 / (1 + exp(-layer1_verify_acc(j)));
            nuerons_ts(j) = log2( nthroot(layer1(j), N1) );
        end
    end
    
    realLayerP(L) = pow2( sum(nuerons_ts));
    L = L + 1;
    %%%%%%%%%%%%%%SIMULATION OF THE LAYER 0 (BACK) %%%%%%%%%%%%%%%%%%%%%%%
    %update the theta
    Smin = min(layer0);
    
    x = ceil( N0 * (1 - log2(theta)/log2(Smin)));
    if x > N0
        x = N0;
        disp('overflow');
    elseif x < 0
        x = 0;
    end
    min_ratios(L) = x/N0;
    realtheta(L) = correctPsimulate2( layer0, N0, x);
   
    cheat_n = ceil(N0 * cheat_ratio);
    
    %results are used to mark those neurons that have been picked for
    %verification
    [flag, results] = layerVerify2(cheat_n, x, N0);

    %initial the neurons temperary trust score
    nuerons_ts = log2(nthroot(layer0,N0));
    
    for j = 1 : N0
        layer0_verify_acc(j) = layer0_verify_acc(j) + results(j);
        
        %for those neruons that are verified correctly, probability is 1
        if results(j) == 1
            nuerons_ts(j) = log2(1);
        end  
    end
    
    %If attacker's cheating is caught, go another round checking and the 
    % attacker will be honest in the second round, so just update the 
    % verification accumulation
    if flag == 1
        rng('shuffle');
        verify_index = randperm(N0,cheat_n);
    
        for j = 1 : cheat_n
            layer0_verify_acc(verify_index(j)) = ...
                layer0_verify_acc(verify_index(j)) + 1;
            
            results(verify_index(j)) = 1;
            
            %The neurons that have been verified,the correctness
            %probability becomes 1
            nuerons_ts(verify_index(j)) = log2(1);
        end
    end
    
    %update the neruons' trust score
    for j = 1 : N0
        if nuerons_ts(j) ~= 1 && results(j) == 0
            layer0(j) = 1 / (1 + exp(-layer0_verify_acc(j)));
            nuerons_ts(j) = log2( nthroot(layer0(j), N0) );
        end
    end
    
    realLayerP(L) = pow2( sum(nuerons_ts));
    L = L + 1;
    
    %%%%%%%%%%%SIMULATION OF THE LAYER 0 (Second Rround) %%%%%%%%%%%%%%
    
    %decide how many neurons to verify according the following formula
    % x = N(1 - log(theta/layerP)/log(Smin))
    Smin = min(layer0);
     
    x = ceil( N0 * (1 - log2(theta)/log2(Smin)));
    if x > N0
        x = N0;
        disp('overflow');
    elseif x < 0
        x = 0;
    end
    min_ratios(L) = x/N0;
    realtheta(L) = correctPsimulate2( layer0, N0, x);
    
   
    
    %call the function to simulate the verification and cheating process 
    cheat_n = ceil(N0 * cheat_ratio);
    
    %results are used to mark those neurons that have been picked for
    %verification
    [flag, results] = layerVerify2(cheat_n, x, N0);

    %initial the neurons temperary trust score
    nuerons_ts = log2(nthroot(layer0,N0));
    
    for j = 1 : N0
        layer0_verify_acc(j) = layer0_verify_acc(j) + results(j);
        
        %for those neruons that are verified correctly, probability is 1
        if results(j) == 1
            nuerons_ts(j) = log2(1);
        end  
    end
    
    %If attacker's cheating is caught, go another round checking and the 
    % attacker will be honest in the second round, so just update the 
    % verification accumulation
    if flag == 1
        rng('shuffle');
        verify_index = randperm(N0,cheat_n);
    
        for j = 1 : cheat_n
            layer0_verify_acc(verify_index(j)) = ...
                layer0_verify_acc(verify_index(j)) + 1;
            
            results(verify_index(j)) = 1;
            
            %The neurons that have been verified,the correctness
            %probability becomes 1
            nuerons_ts(verify_index(j)) = log2(1);
        end
    end
    
    %update the neruons' trust score
    for j = 1 : N0
        if nuerons_ts(j) ~= 1 && results(j) == 0
            layer0(j) = 1 / (1 + exp(-layer0_verify_acc(j)));
            nuerons_ts(j) = log2( nthroot(layer0(j), N0) );
        end
    end
    
    realLayerP(L) = pow2( sum(nuerons_ts));
    L = L + 1;
    
    
    %%%%%%%%%%%SIMULATION OF THE LAYER 1 (Second Rround) %%%%%%%%%%%%%%
    %update the previous layer's probability
    
    %decide how many neurons to verify according the following formula
    Smin = min(layer1);
    
   
    x = ceil( N1 * (1 - log2(theta)/log2(Smin)));
    if x > N1
        x = N1;
        disp('overflow');
    elseif x < 0
        x = 0;
    end
    min_ratios(L) = x/N1;
    realtheta(L) = correctPsimulate2( layer1, N1, x);
    
    
    cheat_n = ceil(N1 * cheat_ratio);
    [flag, results] = layerVerify( cheat_n, x, N1);
    
    nuerons_ts = log2(nthroot(layer1,N1));
    
    for j = 1 : N1
        layer1_verify_acc(j) = layer1_verify_acc(j) + results(j);
        
        %for those neruons that are verified correctly, probability is 1
        if results(j) == 1
            nuerons_ts(j) = log2(1);
        end  
    end
    
    if flag == 1
        rng('shuffle');
        verify_index = randperm(N1,cheat_n);
    
        for j = 1 : cheat_n
            layer1_verify_acc(verify_index(j)) = ...
                layer1_verify_acc(verify_index(j)) + 1;
            
            results(verify_index(j)) = 1;
            
            %The neurons that have been verified,the correctness
            %probability becomes 1
            nuerons_ts(verify_index(j)) = log2(1);
        end
    end
    
    for j = 1 : N1
        if nuerons_ts(j) ~= 1 && results(j) == 0
            %neruon probability = trustScore * prevP
            layer1(j) = 1 / (1 + exp(-layer1_verify_acc(j)));
            nuerons_ts(j) = log2( nthroot(layer1(j), N1) );
        end
    end
    
    realLayerP(L) = pow2( sum(nuerons_ts));
    L = L + 1;
    
    
   %%%%%%%%%%%SIMULATION OF THE LAYER 2 (Second Rround) %%%%%%%%%%%%%%
    %decide how many neurons to verify according the following formula
    Smin = min(layer2);
    
    x = ceil( N2 * (1 - log2(theta)/log2(Smin)));
    if x > N2
        x = N2;
        disp('overflow');
    elseif x < 0
        x = 0;
    end
    min_ratios(L) = x/N2;
    realtheta(L) = correctPsimulate2( layer2,N2, x);
    
    cheat_n = ceil(N2 * cheat_ratio);    
    [flag, results] = layerVerify( cheat_n, x, N2);
    
    nuerons_ts = log2(nthroot(layer2,N2));
    
    for j = 1 : N2
        layer2_verify_acc(j) = layer2_verify_acc(j) + results(j);
        
        %for those neruons that are verified correctly, probability is 1
        if results(j) == 1
            nuerons_ts(j) = log2(1);
        end  
    end
    
    if flag == 1
        rng('shuffle');
        verify_index = randperm(N2,cheat_n);
    
        for j = 1 : cheat_n
            layer1_verify_acc(verify_index(j)) = ...
                layer1_verify_acc(verify_index(j)) + 1;
            
            results(verify_index(j)) = 1;
            
            %The neurons that have been verified,the correctness
            %probability becomes 1
            nuerons_ts(verify_index(j)) = log2(1);
        end
    end
    
    for j = 1 : N2
        if nuerons_ts(j) ~= 1 && results(j) == 0
            %neruon probability = trustScore * prevP
            layer2(j) = 1 / (1 + exp(-layer2_verify_acc(j)));
            nuerons_ts(j) = log2( nthroot(layer2(j), N2) );
        end
    end
    
    realLayerP(L) = pow2( sum(nuerons_ts));
end
