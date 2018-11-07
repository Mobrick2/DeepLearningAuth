function [ flag, results] = layerVerify( cheat_num, verify_num, input_num )
%LAYER0 Summary of this function goes here
%   simulate a cheating and verification operation

    flag = 0 ;
    
    rng('shuffle');
    cheat_index = randi(input_num,1,cheat_num);
    cheat_index = unique(cheat_index);
    
    while length(cheat_index) < cheat_num
        
        left = cheat_num - length(cheat_index);
        cheat_index2 = randi(input_num,1,left);
        cheat_index = [cheat_index,cheat_index2];
        cheat_index = unique(cheat_index);
    end
    
    
    rng('shuffle');
    if verify_num == input_num
        verify_index = 1:input_num;
        
    else
        verify_index = randi(input_num,1,verify_num);
        verify_index = unique(verify_index);
    
        while length(verify_index) < verify_num
        
            left = verify_num - length(verify_index);
            verify_index2 = randi(input_num,1,left);
            verify_index = [verify_index,verify_index2];
            verify_index = unique(verify_index);
        end
    end
    
    results = zeros(1,input_num);
    for i = 1:verify_num
       
        tmp_flag = sum ( cheat_index == verify_index(i));
        if tmp_flag == 1
            flag = 1;
            results( verify_index(i) ) = -1;
        else
            results( verify_index(i) ) = 1;
        end
    end
    
end

