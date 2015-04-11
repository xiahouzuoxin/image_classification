clear all;
close all;
clc

% ���LibSVM����·��
addpath('./libsvm-3.17/matlab');

% ����ͼƬ����ȡ����
if ~exist('data.mat', 'file')
    ftr_size = 16;
    ftr_train = zeros(16, 200);
    ftr_test = zeros(16, 200);
    
    % ѵ������ nature
    figure(1),
    for i=1:100
        s = sprintf('../images/nature/train_nt%3.3d.jpg', i);
        im_nt = imread(s);
        tmp = extractfeature(im_nt, ftr_size);  % ������ȡ
        ftr_train(:, i) = tmp;
    end
    % ѵ������ manmade
    for i=1:100
        s = sprintf('../images/manmade/train_mm%3.3d.jpg', i);
        im_mm = imread(s);
        tmp = extractfeature(im_mm, ftr_size);
        ftr_train(:, i+100) = tmp;
    end
    label_train = [-1*ones(100, 1); ones(100, 1)];

    % �������� nature
    for i=1:100
        s = sprintf('../images/nature/test_nt%3.3d.jpg', i);
        im_nt = imread(s);
        tmp = extractfeature(im_nt, ftr_size);
        ftr_test(:, i) = tmp;
    end
    % �������� manmade
    for i=1:100
        s = sprintf('../images/manmade/test_mm%3.3d.jpg', i);
        im_mm = imread(s);
        tmp = extractfeature(im_mm, ftr_size);
        ftr_test(:, i+100) = tmp;
    end
    label_test = [-1*ones(100, 1); ones(100, 1)];

    save('data.mat', 'ftr_train', 'label_train', ...
        'ftr_test', 'label_test');
else
    load('data.mat');
end

% �������/������֤ ���RFB�˺�����Ѳ���gamma��C
[bestacc bestc bestg] = svm_girdsearch(label_train, ftr_train', ...
    [-5 5], [-5 5], [0.5 0.5],'', 3);  

% SVMѵ��ģ��
cmd = ['-t 2', ' -g ',num2str(bestg), ' -c ', num2str(bestc)];
model = svmtrain(label_train, ftr_train', cmd);

% ��SVMԤ��
[predicted_label, accuracy, decision_values] = ...
    eval_predict(label_test, ftr_test', model, 'libsvm');
