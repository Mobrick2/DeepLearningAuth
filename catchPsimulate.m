%verifyratio = 0.1:0.1:0.6;
verifyratio = 0.05;
%N0 = ones(1,6)*784;
N0 = ones(1,6)*512;
%N0 = ones(1,6)*10;

%cheat_ratio = 0.01;
cheat_ratio = 0.02:0.02:0.12;

verifynumber = ceil(N0 .* verifyratio);
catch_p = zeros(1,6);
expected_p = zeros(1,6);

for i = 1 : 6
    m = floor(cheat_ratio(i) * N0(i));
    catch_p(i) = simulatecatchProb2(m, verifynumber(1), N0(i));
    expected_p(i) = 1 - ((N0(i)-verifynumber(1))/N0(i))^m;
end