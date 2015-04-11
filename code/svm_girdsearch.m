function [bestacc bestc bestg] = svm_girdsearch(label, data, ...
    cbound, gbound, cgstep, svm_cmd, v, opts_t, ker_func)
% 对参数c和gamma寻找最优
% cmin:cstep:cmax  :: cost 
% gmin:gstep:gmax  :: gamma
% cgstep = [cstep gstep]
% 
% v                :: cross validation n, default 5
% t                :: '-t' for svmtrain
% ker_func         :: function handle, used only if opts_t==4
%                     ker_func(tr_data, gamma)
% 作者：夏侯佐鑫
% 日期：2013.04

if nargin < 8
    opts_t = 2;
elseif opts_t == 4 && nargin < 9
    error('none of @ker_func.\n');
end
if nargin < 7
    v = 5;
end
if nargin < 6
    svm_cmd = '';
end
if nargin < 5
    cstep = 0.8;
    gstep = 0.8;   
else
    cstep = cgstep(1);
    gstep = cgstep(2);
end
if nargin < 4
    gmax = 8;
    gmin = -8;   
else
    gmax = gbound(2);
    gmin = gbound(1);
end
if nargin < 3
    cmax = 8;
    cmin = -8;
else
    cmax = cbound(2);
    cmin = cbound(1);
end

[C, G] = meshgrid(cmin:cstep:cmax, gmin:gstep:gmax);
[m n] = size(C);
acc = zeros(m,n);

eps = 10^(-2);
basenum = 2;
bestacc = 0;
bestc = 1;
bestg = 0.1;
for i = 1:m
    for j = 1:n 
        tmp_gamma = basenum^G(i,j);
        tmp_C = basenum^C(i,j);
%         cmd = [svm_cmd ' -v ',num2str(v),' -c ',num2str(tmp_C), ' -g ',...
%             num2str(tmp_gamma), ' -t ', num2str(opts_t), ' -q '];
        cmd = [svm_cmd, ' -c ',num2str(tmp_C), ' -g ',...
            num2str(tmp_gamma), ' -t ', num2str(opts_t), ' -q '];        
        if opts_t ~= 4
%             acc(i,j) = svmtrain(label, data, cmd);
            acc(i,j) = cross_validation(label, data, cmd, v, 'svmtrain');
        else
            ker = ker_func(data, basenum^G(i,j));
%             acc(i,j) = svmtrain(label, ker, cmd);
            acc(i,j) = cross_validation(label, ker, cmd, v, 'svmtrain');            
        end
        
        % 精度太低，加快搜索速度
        if acc(i,j) < 50
            if acc(i,j) < 30  
                acc(i,j+1) = acc(i,j);
                j = j + 1;
                if acc(i,j) < 20
                    acc(i,j+1) = acc(i,j);
                    j = j + 1;
                end
            end
            continue;
        end
        
        if acc(i,j) > bestacc
            bestacc = acc(i,j);
            bestg = tmp_gamma;
            bestc = tmp_C;
        end
        
        % 在保证预测精度差别不大时，越小的C值越好
        if abs(bestacc - acc(i,j)) < eps && tmp_C < bestc
            bestacc = acc(i,j);
            bestg = tmp_gamma;
            bestc = tmp_C;            
        end
        
        fprintf('\n');
        fprintf('cross validation (g=%s,C=%s) finished %d%%.\n', ...
            num2str(tmp_gamma), num2str(tmp_C), floor(100*((i-1)*n+j)/(m*n)) );
    end
end

% plot relationship bwtween g/c and acc

figure;
% meshc(C,G,acc);
mesh(C,G,acc);
% surf(C,G,acc);
axis([cmin,cmax,gmin,gmax,30,100]);
xlabel('log2c','FontSize',10);
ylabel('log2g','FontSize',10);
zlabel('Accuracy(%)','FontSize',10);
firstline = 'SVC参数选择结果图(3D视图)[GridSearchMethod]'; 
secondline = ['Best c=',num2str(bestc),' g=',num2str(bestg), ...
    ' CVAccuracy=',num2str(bestacc),'%'];
title({firstline;secondline},'Fontsize',10);

end