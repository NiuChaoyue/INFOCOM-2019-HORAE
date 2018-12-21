%{
@Paper: Making Big Money from Small Sensor: Trading Time-Series Data under
        Pufferfish Privacy, in Proc. of INFOCOM, 2019.       
@Author: Chaoyue Niu
@Email: rvincency@gmail.com
@Function: simulate arbitrage attack in the advanced pricing functions.
%}

clear;
%some preset parameters 
v = 10;
m = 100;
simNum = 10000;

%length of selected chain 
T = 100;

%whether apply tanh function
boundflag = 1;

%record simulation results (percentage)
resPercentage = zeros(101,4);

for usr = 1:4
    %read two fixed parts from file
    twoPartsFilename = sprintf('T_%d_usr_%d_two_fixed_parts', T, usr);
    two_fixed_parts = csvread(twoPartsFilename);
    for sim = 1:simNum
        %vl \in (v, (m^2 - m + 1) * v)
        vecVl = v + (m^2 - m) * v .* rand(m, 1);
        tmp = (m^2 * v) / sum(vecVl);
        vecVl = vecVl .* tmp;
        
        %price for v and attack cost for vl
        price = advanced_pricing(two_fixed_parts, v, boundflag);
        attackCost = 0.0;
        for l = 1:m
            attackCost = attackCost + advanced_pricing(two_fixed_parts, vecVl(l), boundflag);
        end
        
        %ratio between attack cost and original price
        ratio = attackCost/price;
        if ratio < 1
            resPercentage(101,usr) = resPercentage(101, usr) + 1/simNum;
        else
            resPercentage(floor(ratio),usr) = resPercentage(floor(ratio),usr) + 1/simNum;
        end         
    end   
end