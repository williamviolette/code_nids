

clear all;
close all;
clc;
format short;
cd('/Users/willviolette/Desktop/pstc_work/nids/');

global Y N1 N2 N alpha1 alpha2 e Z2 h2 beta k;
beta=[1];
N1=[5];
N2=[5];
N=[10];
alpha1=.5;
alpha2=.3;
e=[0];
Z2=[12];
h2=[10];
k=[.2];

Y=[12];
alpha1=.5;
alpha2=.3;

A=[-1 0 0 0 0;0 -1 0 0 0  ; 0 0 -1 0 0; 0 0 0 -1 0 ; 0 0 0 0 -1 ;  1 1 1 1 1];
b=[0 ;0 ;0 ;0;0 ;Y];
a0=[1 1 1 1 1];
N=11;
[a,c] = fmincon(@opt_split2_3,a0,A,b);

A1=[-1 0 0 0 ;0 -1 0 0;0 0 -1 0 ;0 0 0 -1 ;  1 1 1 1];
b1=[0 ;0;0;0 ;Y];
a01=[1 1 1 1];
N=11;
[a1,c1] = fmincon(@opt_join2_3,a01,A1,b1);

r=[1:10]';
f=[1:10]';
num=[1:10]';
r1=[1:10]';
f1=[1:10]';
num1=[1:10]';
z=ones(10,5);
z1=ones(10,4);

for n = 1:10
  N1 = n;
  N2 = n;
  Y = 4*(n+n);
  b=[0 ;0 ;0 ;0; 0;Y];
  b1=[0 ;0 ;0;0;Y];
  [a,c] = fmincon(@opt_split2_3,a0,A,b);
  f(n,1)=c;
  r(n,1)=a(1,2);
  z(n,:)=a(1,:)./n;
  [a1,c1] = fmincon(@opt_join2_3,a01,A1,b1);
  f1(n,1)=c1;
  r1(n,1)=a1(1,2);
  z1(n,:)=a1(1,:)./n;
end

f=f.*-1;
f1=f1.*-1;

clf
scatter(num,f,'g')
hold on
scatter(num,f1,'r')





