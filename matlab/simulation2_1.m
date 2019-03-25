

clear all;
close all;
clc;
format short;
cd('/Users/willviolette/Desktop/pstc_work/nids/');

global Y N1 N2 N alpha1 alpha2 Z2 h2 beta;
beta=[.5];
Y=[15];
N1=[5];
N2=[5];
N=[10];
alpha1=.5;
alpha2=.9;
Z2=[12];
h2=[4];

Y=[12];
alpha1=.9;
alpha2=.5;

A=[-1 0 0;0 -1 0; 0 0 -1;  1 2 1];
b=[0 ;0 ;0 ;Y];
a0=[5 5 5];
N=11;
[a,c] = fmincon(@opt_split1,a0,A,b)

A1=[-1 0 ;0 -1 ; 1 1];
b1=[0 ;0 ;Y];
a01=[5 5];
N=11;
[a1,c1] = fmincon(@opt_join1,a01,A1,b1)

r=[1:10]';
f=[1:10]';
num=[1:10]';
r1=[1:10]';
f1=[1:10]';
num1=[1:10]';
z=ones(10,3);
z1=ones(10,2);

for n = 1:10
   N1 = n;
   N2 = n;
  [a,c] = fmincon(@opt_split1,a0,A,b);
  f(n,1)=c;
  r(n,1)=a(1,2);
  z(n,:)=a(1,:);
  [a1,c1] = fmincon(@opt_join1,a01,A1,b1);
  f1(n,1)=c1;
  r1(n,1)=a1(1,2);
  z1(n,:)=a1(1,:);  
end

f=f.*-1;
f1=f1.*-1;

clf
scatter(num,f,'g')
hold on
scatter(num,f1,'r')


% clf
% scatter(num,r,'g')
% hold on
% scatter(num,r1,'r')




N1=[5];
N2=[5];

A2=[-1 0 0 0 ;0 -1 0 0  ; 0 0 -1 0  ; 0 0 0 -1 ; 1 1 1 1];
b2=[0 ;0 ;0;0 ;Y];
a02=[5 5 5 5];
[a2,c2] = fmincon(@opt_reg1,a02,A2,b2)

% c1 h1 x1 c2 (h2) x2
