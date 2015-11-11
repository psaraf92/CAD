clc;
clear all;

img=imread('CTcase6.pgm');
figure(1);
imshow(img);
title('original image');
[m l]=size(img);
N=m*l; %total number of pixels in the image

[num graylevel]=imhist(img);
figure(2);
stem(graylevel,num);
L=length(graylevel);
p=num/N;
%display(p);
w0=zeros(1,L);
u0=zeros(1,L);
u1=zeros(1,L);
for k=1:L
    for i=1:k
        w0(k)=w0(k)+p(i);
    end
    w1(k)=1-w0(k);      
end

for k=1:L
    for i=1:k
        u0(k)=u0(k)+(i*p(i));
    end
    u0(k)=u0(k)/w0(k);
    for i=k+1:L
        u1(k)=u1(k)+(i*p(i));
    end
    u1(k)=u1(k)/w1(k);
end

uT=0;
for i=1:L
    uT=uT+(i*p(i));
end

% display(uT);
% x=(w0(50)*u0(50))+(w1(50)*u1(50));
% display(x);

var0=zeros(1,L);
var1=zeros(1,L);

for k=1:L
    for i=1:k
        var0(k)=var0(k)+(((i-u0(k))^2)*p(i));
    end
    var0(k)=var0(k)/w0(k);
    for i=k+1:L
        var1(k)=var1(k)+(((i-u1(k))^2)*p(i));
    end
    var1(k)=var1(k)/w1(k);
end

varT=0;
for i=1:L
    varT=varT+(((i-uT)^2)*p(i));
end

varB=zeros(1,L);
for k=1:L
    varB(k)=w0(k)*w1(k)*((u1(k)-u0(k))^2);
    n(k)=varB(k)/varT;
end
    
[C I]=max(varB);
display(I);

for j=1:m
    for q=1:l
        if img(j,q)>I
            img(j,q)=0;
        elseif img(j,q)<=I
            img(j,q)=img(j,q);
        end
    end
end

figure(3);
imshow(img);
title('segmented image');

img1=imfill(img,'holes');
figure(4);
imshow(img1);
img1=imclose(img1,strel('ball',2,2));
figure(5);
imshow(img1);
title('morphologically filtered image');

h=fspecial('log',[5 5],0.8);
img2=imfilter(img1,h);
figure(6);
imshow(img2);
title('edge detected image');
img3=imadd(img2,img1);
figure(7);
imshow(img3);
title('edge enhanced image');

[m1 l1]=size(img3);
N1=m1*l1; %total number of pixels in the image

[num1 graylevel1]=imhist(img3);
figure(8);
stem(graylevel1,num1);
L1=length(graylevel1);
p1=num1/N1;
%display(p);

w10=zeros(1,80);
u10=zeros(1,80);
u11=zeros(1,80);
for k=1:80
    for i=25:25+k
        w10(k)=w10(k)+p1(i);
    end
    w11(k)=1-w10(k);      
end

for k=1:80
    for i=25:25+k
        u10(k)=u10(k)+(i*p1(i));
    end
    u10(k)=u10(k)/w10(k);
    for i=k+25+1:105
        u11(k)=u11(k)+(i*p1(i));
    end
    u11(k)=u11(k)/w11(k);
end

u1T=0;
for i=25:105
    u1T=u1T+(i*p1(i));
end

display(uT);
% x=(w0(50)*u0(50))+(w1(50)*u1(50));
% display(x);

var10=zeros(1,80);
var11=zeros(1,80);

for k=1:80
    for i=25:k+25
        var10(k)=var10(k)+(((i-u10(k))^2)*p1(i));
    end
    var10(k)=var10(k)/w10(k);
    for i=k+25+1:105
        var11(k)=var11(k)+(((i-u11(k))^2)*p1(i));
    end
    var11(k)=var11(k)/w11(k);
end

var1T=0;
for i=25:105
    var1T=var1T+(((i-u1T)^2)*p1(i));
end

var1B=zeros(1,80);
for k=1:80
    var1B(k)=w10(k)*w11(k)*((u11(k)-u10(k))^2);
    n1(k)=var1B(k)/var1T;
end
    
[C1 I1]=max(var1B);
display(I1);

for j=1:m1
    for q=1:l1
        if img3(j,q)>=I1
            img3(j,q)=256;
        elseif img3(j,q)<I1
            img3(j,q)=0;
        end
    end
end

figure(9);
im=bwmorph(img3, 'majority');

imshow(im);
title('nodule detected image');

[l num]=bwlabel(im);
display(num);


% to calculate area
area=zeros(1,num);
for f=1:num
    [r c]=find(l==f);
    area(f)=numel(r);
end
display(area);

%to calculate circularity
%to calculate perimeter

per=zeros(1,num);
per1=zeros(1,num);
cir=zeros(1,num);
for f1=1:num
    [r1 c1]=find(l==f1);
    [u v]=min(c1);
    r2=r1(v); c2=c1(v);
    s=r1(v); t=c1(v);
    w=im(r2,c2);
    a=[];
    b=[];
    g=1;
    a(1)=s;
    b(1)=t;
    d=5;
    count=0;
    while 1
        if d==0
            count=count+1;
            if (c2~=l1 && im(r2,c2+1)==w)
                d=mod((d+7),8);
                g=g+1;
                a(g)=r2;
                b(g)=c2+1;
                r2=r2;
                c2=c2+1;
            else
                d=d+1;
            end
        end
        if d==1
            count=count+1;
            if (r2~=1 && c2~=l1 && im(r2-1,c2+1)==w)
                d=mod((d+7),8);
                g=g+1;
                a(g)=r2-1;
                b(g)=c2+1;
                r2=r2-1;
                c2=c2+1;
            else
                d=d+1;
            end
        end
        if d==2
            count=count+1;
            if (r2~=1 && im(r2-1,c2)==w)
               d=mod((d+7),8);
                g=g+1;
                a(g)=r2-1;
                b(g)=c2;
                r2=r2-1;
                c2=c2; 
            else
                d=d+1;
            end
        end
        if d==3
            count=count+1;
            if (r2~=1 && c2~=1 && im(r2-1,c2-1)==w)
                d=mod((d+7),8);
                g=g+1;
                a(g)=r2-1;
                b(g)=c2-1;
                r2=r2-1;
                c2=c2-1;
            else
                d=d+1;
            end
        end
        if d==4
            count=count+1;
            if (c2~=1 && im(r2,c2-1)==w)
                d=mod((d+7),8);
                g=g+1;
                a(g)=r2;
                b(g)=c2-1;
                r2=r2;
                c2=c2-1;
            else
                d=d+1;
            end
        end
        if d==5
            count=count+1;
            if (r2~=m1 && c2~=1 && im(r2+1,c2-1)==w)
                d=mod((d+7),8);
                g=g+1;
                a(g)=r2+1;
                b(g)=c2-1;
                r2=r2+1;
                c2=c2-1;
            else
                d=d+1;
            end
        end
        if d==6
            count=count+1;
            if (r2~=m1 && im(r2+1,c2)==w)
                d=mod((d+7),8);
                g=g+1;
                a(g)=r2+1;
                b(g)=c2;
                r2=r2+1;
                c2=c2;
            else
                d=d+1;
            end
        end
        if d==7
            count=count+1;
            if (r2~=m1 && c2~=l1 && im(r2+1,c2+1)==w)
                d=mod((d+7),8);
                g=g+1;
                a(g)=r2+1;
                b(g)=c2+1;
                r2=r2+1;
                c2=c2+1;
            else
                d=0;
            end
        end
        if count>8
            if (r2==s && c2==t)
                break
            end
        end
    end
    
    
    for i=1:length(b)-1;
       per(f1)=per(f1)+sqrt((a(i)-a(i+1)).^2+(b(i)-b(i+1)).^2);
    end
    cir(f1)=(4*area(f1)*pi)/per(f1).^2;
end
display(per);
display(cir);

for f1=1:num    
    im=bwboundaries(l==f1);
    c=cell2mat(im(1));
    for i=1:size(c,1)-1
        per1(f1)=per1(f1)+sqrt((c(i,1)-c(i+1,1)).^2+(c(i,2)-c(i+1,2)).^2);
    end
end
display(per1);

figure(10);
scatter(area,cir);
ylim([0 1.5]);
xlim([0 900]);
xlabel('area');
ylabel('circularity');
yL = get(gca,'YLim');
line([25 25],yL,'Color','r');
line([450 450],yL,'Color','r');
xL = get(gca,'XLim');
line(xL,[0.45 0.45],'Color','b');
line(xL,[1 1],'Color','b');

figure(11);
scatter(area, per);
xlabel('area');
ylabel('perimeter');

% to calculate centroid of the objects 
centroidx=zeros(1,num);
centroidy=zeros(1,num);
for j=1:num
    [r2 c2]=find(l==j);
    centroidx(j)=mean(c2);
    centroidy(j)=mean(r2);
end

% to find the true detection using distance formula
casenumber=input('enter the case number:');
centerx=[80 110 57 138 73 78];
centery=[166 233 120 87 182 226];
distance=zeros(1,num);
 for j=1:num
     distance(j)=sqrt((centroidx(j)-centerx(casenumber)).^2+(centroidy(j)-centery(casenumber)).^2);
 end
 display(distance);
 
 [v i]=min(distance);
 area_truenodule=area(i);
 circularity_truenodule=cir(i);
 display(centroidx(i));
 display(centroidy(i));
 display(area_truenodule);
 display(circularity_truenodule);
 



    
    
   
    
        
         
        
         
        
         
        
         
          
       
    
    
    













            
    
    
    