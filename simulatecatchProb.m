function [] = simulatecatchProb( cheat_num, verify_num, input_num )
%SIMULATECATCHPROB Summary of this function goes here
%   Detailed explanation goes here
    catch_props = zeros(1,10);
    catch_ratios = zeros(1,10);
    
    for k = 1 : 10
        
        cheat_ratio = k / 100;
        catch_ratios(k) = cheat_ratio;
        catch_count = 0 ;
    
        for j = 1 : 500
            [flag, ~] = layerVerify(cheat_num, verify_num, input_num);
        
            if flag == 1
                catch_count = catch_count + 1;
            end
        
            catch_props(k) = catch_count / 500;
        end
    end    
    
    plot(catch_ratios,catch_props);

end

