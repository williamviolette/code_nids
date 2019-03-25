
clear all;
close all;
clc;
format short;
cd('/Users/willviolette/Desktop/pstc_work/nids/');

global Y N1 N2 N alpha1 alpha2 e Z2 h2 beta k;

alpha1=[.5];
beta=[.5];
Y=[10];
H=[1];
N1=[2];
N2=[2];

h2=[3];

A=[-1 0;0 -1 ;  1 1];
b=[0 ;0 ;Y];
a0=[2 2];
N=11;
[a,c] = fmincon(@ho,a0,A,b)

A1=[-1 0 0 ;0 -1 0 ; 0 0 -1 ;  1 .5 1];
b1=[0 ;0 ;0 ;Y];
a01=[2 2 2];
N=11;
[a1,c1] = fmincon(@hj,a01,A1,b1)

r=[1:10]';
f=[1:10]';
num=[1:10]';
r1=[1:10]';
f1=[1:10]';
num1=[1:10]';
z=ones(10,2);
z1=ones(10,2);

for n = 1:10
   N1 = n;
   N2 = n;
  [a,c] = fmincon(@ho,a0,A,b);
  f(n,1)=c;
  r(n,1)=a(1,2);
%  z(n,:)=a(1,:);
  [a1,c1] = fmincon(@hj,a01,A1,b1);
  f1(n,1)=c1;
  r1(n,1)=a1(1,2);
%  z1(n,:)=a1(1,:);  
end

f=f.*-1;
f1=f1.*-1;

clf
scatter(num,f,'g')
hold on
scatter(num,f1,'r')
% JOIN IS RED: SPLIT IS GREEN




