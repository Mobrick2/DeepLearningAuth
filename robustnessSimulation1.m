cheat_ratio = 0.1;

%generate a uniformly randomized input
a = 0 ; b = 255;
%input_data = ceil(a + (b-a) * rand(1,28*28));

input_data_trustScore = 0.5 * ones(1,28*28);

prevP = 0;
validation_t = 1;
N1 = 784 ; N2 = 512 ; N3 = 10;

layerP = 0;
theta = 0;

catch_time = 0;
number_of_verication = 0;

for i = 1 : validation_t
    
    %x = N - log(theta/P)/log(Smin)
    
    theta= ceil(theta - N1 - 0.8 * N1);
    Smin = log2(min(input_data_trustScore));
    
    layerP = prevP + sum(log2(input_data_trustScore));
        
    x = N1- (theta-layerP) / Smin;
    
    if x > N1
        x = N1;
    end
    
    cheat_n = ceil(N1 * cheat_ratio);
    %call the function to simulate the verification process and
    %update the neruons' probability
    %flag = 1;
    %while flag == 1
    
    catch_props = zeros(1,10);
    catch_ratios = zeros(1,10);
    catch_count = 0;
    
    for k = 1 : 10
        
        cheat_ratio = k / 100;
        catch_ratios(k) = cheat_ratio;
        catch_count = 0 ;
    
        for j = 1 : 1000
            [flag, results] = layerVerify( ceil(cheat_ratio*length(...
                input_data_trustScore)), x, length(input_data_trustScore));
            number_of_verication = number_of_verication + 1;
        
            if flag == 1
                catch_count = catch_count + 1;
            end
        
            catch_props(k) = catch_count / 1000;
        end
    end    
    
    plot(catch_ratios,catch_props);
    
    
end


