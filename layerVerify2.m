function [ flag, results] = layerVerify2( cheat_num, verify_num, input_num )
%LAYER0 Summary of this function goes here
%   simulate a cheating and verification operation

    flag = 0 ;
    
    rng('shuffle');
    cheat_index =  randperm(input_num,cheat_num);
    
    rng('shuffle');
    verify_index = randperm(input_num,verify_num);
    
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

