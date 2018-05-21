close all;clc;clear;
close all;clear all;clc;  
test=imread('img/2.jpg');%含模板的图像 
target=imread('img/1.jpg'); %模板图像

% 把图像二值化
test = im2bw(test,graythresh(test));
target = im2bw(target,graythresh(target));

%size(test);
%size(target);

%去除白边框
i = 1;
while i <= size(target,1)
    if(sum(target(i,:)) == size(target,2))
        target(i,:)=[];
    else
        i = i+1;
    end
end
i = 1;
while i <= size(target,2)
    if(sum(target(:,i)) == size(target,1))
        target(:,i)=[];
    else
        i = i+1;
    end
end

%去除多余的黑边， 减少干扰
target = cut_pic_black(target);
%imshow(target)

%% 旋转360°分成 多个递增的角度
ang = 15;
figure(1);
for z=1:360/ang
%旋转 不同角度
target_B=imrotate(target,z*ang,'bicubic','crop');
target_B=cut_pic_black(target_B); %去黑边

[m,n]=size(test);  
[m0,n0]=size(target_B);  ang
result=zeros(m-m0+1,n-n0+1);  
vec_sub = double( target_B(:) );  
norm_sub = norm( vec_sub );   
 for i=1:m-m0+1  
    for j=1:n-n0+1  
        subMatr=test(i:i+m0-1,j:j+n0-1);  
        vec=double( subMatr(:) );  
        result(i,j)=vec'*vec_sub / (norm(vec)*norm_sub+eps);  
    end 
 end
%找到最大相关位置
[iMaxPos,jMaxPos]=find( result==max( result(:)));
MaxPos(z,:)=[iMaxPos(1),jMaxPos(1)]; 

%找到最大相关的子图，保存角度跟相似度
best_pic = test(iMaxPos:iMaxPos+m0-1,jMaxPos:jMaxPos+n0-1);
accuracy(1,z) = 1.0*(m0*n0 - sum(sum(abs(best_pic - target_B)))) / (m0*n0);
angle(1,z) = z*ang;

%显示24个旋转后的图片
subplot(ceil(sqrt(360/ang)),ceil(sqrt(360/ang)),z);
imshow(target_B);
title([int2str(z*ang),' Degree']);
end

%输出角度跟相似度
angle
accuracy

%获取最相似的子图的度数 跟 下标
[best_accuracy,best_index] = max(accuracy);
angle(best_index);
%获取最相似的子图的坐标

iMax = MaxPos(best_index,1);
jMax = MaxPos(best_index,2);


%画图
figure(2);
subplot(121);
imshow(target);
title('target');  
subplot(122);  
imshow(test);  
title('test'); 
hold on;
plot(jMax,iMax,'c*');%绘制最大相关点  
%用矩形框标记出匹配区域  
plot([jMax,jMax+n0-1],[iMax,iMax],'y-');  
plot([jMax+n0-1,jMax+n0-1],[iMax,iMax+m0-1],'g-');  
plot([jMax,jMax+n0-1],[iMax+m0-1,iMax+m0-1]),'b-';  
plot([jMax,jMax],[iMax,iMax+m0-1],'r-');