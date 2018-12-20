function [prob] = simulatecatchProb2( cheat_num, verify_num, input_num )
%SIMULATECATCHPROB Summary of this function goes here
%   Detailed explanation goes here
    catch_count = 0 ;
    N = 1000;
    
    for i = 1 : N
        
        [flag, ~] = layerVerify2(cheat_num, verify_num, input_num);
        if flag == 1
            catch_count = catch_count + 1;
        end       
    end
    
    prob = catch_count / N;

end

