N1 = 784 ; N2 = 512 ; N3 = 10;

%layer0 (input) 
layer0 = 0.5 * ones(1,N1);
layer0_verify_acc = zeros(1,N1);

%layer1
layer1 = 0.5 * ones(1,N2);
layer1_verify_acc = zeros(1,N2);

%layer2
layer2 = 0.5 * ones(1,N3);
layer2_verify_acc = zeros(1,N3);

%parameters of cheating and verification process 
cheat_ratio = 0.1;
verify_ratio = 0.1;
validation_t = 1;
catch_time = 0;
number_of_verication = 0;

% parameters to calculate the number of neuron choose to verify
prevP = 0;
layerP = 0;
theta = 0;



for i = 1 : validation_t
    
    %update the theta
    theta= ceil(theta - N1 - (1-verify_ratio) * N1);
    
    %decide how many neurons to verify according the following formula
    % x = N - log(theta/layerP)/log(Smin)
    Smin = ceil(log2(min(layer0)));
    layerP = ceil(prevP + sum(log2(layer0)));
        
    x = ceil(N1- (theta-layerP) / Smin);
    if x > N1
        x = N1;
    end
    
    %when go to the next layer's verification, we need somehow substruct
    %this part
    initial_trust = layerP;
    
    %call the function to simulate the verification and cheating process 
    cheat_n = ceil(N1 * cheat_ratio);
    [flag, results] = layerVerify( cheat_n, x, N1);
    

    %update the neurons probability during the verification
    nuerons_p = layer0;
    
    for j = 1 : N1
        layer0_verify_acc(j) = layer0_verify_acc(j) + results(j);
        
        %for those neruons that are verified correctly, probability is 1
        if results(j) == 1
            nuerons_p(j) = 1;
        end  
    end
    
    %If attacker's cheating is caught, go another round checking and the 
    % attacker will be honest in the second round, so just update the 
    % verification accumulation
    if flag == 1
        rng('shuffle');
        verify_index = randi(N1,1,cheat_n);
    
        for j = 1 : cheat_n
            layer0_verify_acc(verify_index(j)) = ...
                layer0_verify_acc(verify_index(j)) + 1;
        end
    end
    
    %update the neruons probability because the trust score may be changed
    for j = 1 : N1
        if nuerons_p(j) < 1
            %neruon probability = trustScore * prevP
            nuerons_p(j) =  1 / (1 + exp(layer0_verify_acc(j))); 
        end
    end
    
    %update the previous layer's probability
    prevP = ceil(sum(log2(nuerons_p)));
    
    verify_ratio = 0.2;
    theta = theta - initial_trust - N2 - ceil((1-verify_ratio) * N2);
    %decide how many neurons to verify according the following formula
    Smin = ceil(log2(min(layer1)));
    layerP = ceil(prevP + sum(log2(layer1)));
    initial_trust = layerP;
    
    x = N2- (theta-layerP) / Smin;
    if x > N2
        x = N2;
    end
    
    
    catch_props = zeros(1,10);
    catch_ratios = zeros(1,10);
    catch_count = 0;
    
    for k = 1 : 10
        
        cheat_ratio = k / 100;
        catch_ratios(k) = cheat_ratio;
        catch_count = 0 ;
        cheat_n = ceil(N2 * cheat_ratio);
    
        for j = 1 : 1000
            [flag, results] = layerVerify(cheat_n, x, N2);
        
            if flag == 1
                catch_count = catch_count + 1;
            end
        
            catch_props(k) = catch_count / 1000;
        end
    end    
    
    plot(catch_ratios,catch_props);
    
    
end