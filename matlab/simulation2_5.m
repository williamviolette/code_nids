
clear all;
close all;
clc;
format short;
cd('/Users/willviolette/Desktop/pstc_work/nids/');

global Y N1 N2 N alpha1 alpha2 e Z2 h2 beta k;
beta=[.8];
N1=[5];
N2=[5];
N=[10];
alpha1=.5;
alpha2=.3;
e=[0];
Z2=[12];
h2=[10];
k=[0];

Y=[12];
alpha1=.5;
alpha2=.3;

N=11;


A3=[-1 0 0 0 0;0 -1 0 0 0 ; 0 0 -1 0 0; 0 0 0 -1 0; 0 0 0 0 -1  ;  1 1 1 1 1];
b3=[0 ;0 ;0 ;0;0 ;Y];
a03=[1 1 1 1 1];
[a3,c3] = fmincon(@opt_none2_5p,a03,A3,b3);

A=[-1 0 0 0 0 0;0 -1 0 0 0 0 ; 0 0 -1 0 0 0; 0 0 0 -1 0  0; 0 0 0 0 -1 0; 0 0 0 0 0 -1 ;  1 1 1 1 1 1];
b=[0 ;0 ;0 ;0;0;0 ;Y];
a0=[1 1 1 1 1 1];
N=11;
[a,c] = fmincon(@opt_split2_5p,a0,A,b);

r=[1:10]';
f=[1:10]';
num=[1:10]';
z=ones(10,5);

r1=[1:10]';
f1=[1:10]';
num1=[1:10]';
z1=ones(10,6);


for n = 1:10
  N1 = n;
  N2 = n;
  Y = 4*(n+n);
  b=[0 ;0 ;0 ;0; 0;0;Y];
  b3=[0 ;0 ;0;0;Y];
  [a,c] = fmincon(@opt_split2_4p,a0,A,b);
  h(n,1)=(N1*(((a(1,1)/(N1))^alpha1))*(((a(1,2)/((N1)^beta)))^(1-alpha1-alpha2))...
      +N2*(((a(1,4)/(N1))^alpha1))*(((h2/(N2)^beta)))^(1-alpha1-alpha2))/(N1+N2);   
  ha(n,1)=((((a(1,4)/(N1))^alpha1))*(((h2/(N1)^beta)))^(1-alpha1-alpha2))/(N1+N2);  
  f(n,1)=c;
  r(n,1)=a(1,2);
  z(n,:)=a(1,:)./n;
  [a3,c3] = fmincon(@opt_none2_4p,a03,A3,b3);
  h3(n,1)=(N1*(((a3(1,1)/(N1))^alpha1))*(((a3(1,5)/((N1+N2)^beta)))^(1-alpha1-alpha2))...
      +N2*(((a3(1,3)/(N1))^alpha1))*(((a3(1,5)/((N1+N2)^beta)))^(1-alpha1-alpha2)))/(N1+N2);
  h1a(n,1)=(((a3(1,1)/(N1))^alpha1))*(((a3(1,5)/((N1+N2)^beta)))^(1-alpha1-alpha2));
  f1(n,1)=c3;
  r1(n,1)=a3(1,2);
  z1(n,:)=a3(1,:)./n;
end
c1=a(1,1);
% h1=a(1,2);
x1=a(1,2);
c2=a(1,3);
x2=a(1,4);
H2=a(1,5);

f=f.*-1;
f1=f1.*-1;

clf
scatter(num,f,'g')
hold on
scatter(num,f1,'r')


clf
scatter(num,h,'g')
hold on
scatter(num,h1,'r')

