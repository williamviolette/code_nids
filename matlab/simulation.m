clear all;
close all;
clc;

format short;

cd('/Users/willviolette/Desktop/pstc_work/nids/');

global Y N1 N2 N alpha1 alpha2 e Z2;
Y=[15];
N1=[1];
N2=[1];
N=[10]
alpha1=.7;
alpha2=.7;
e=[0];
Z2=[9];

% c1 c2 z1 z_bar!  n1

N=10

A=[-1 0 0 0;0 -1 0 0; 0 0 -1 0 ; 0 0 0 -1;1 1 1 0];
b=[0 ;0 ;0 ;0 ;Y];
a0=[5 5 5 1]; 
[a] = fmincon(@maxfunction_bound,a0,A,b);
a

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% COMPARING SPLITTING TO NON-SPLITTING AS YOU CHANGE N %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A=[-1 0 0 0;0 -1 0 0; 0 0 -1 0 ; 0 0 0 -1;1 1 1 0];
b=[0 ;0 ;0 ;0 ;Y];
a0=[5 5 5 1];
r=[1:5]';
f=[1:5]';
num=[1:5]';

A1=[-1 0;0 -1;1 1];
b1=[0 ;0 ;Y];
a01=[5 5];
r1=[1:5]';
f1=[1:5]';
num1=[1:5]';

for n = 1:5
   N = n+2;
  [a,c] = fmincon(@maxfunction_bound,a0,A,b);
  f(n,1)=c;
  r(n,1)=a(1,2);
  [a1,c1] = fmincon(@maxfunction_tog,a01,A1,b1);  
  f1(n,1)=c1; 
  r1(n,1)=a1(1,2); 
end

f=f.*-1;
f1=f1.*-1;

clf
scatter(num,f,'g')
hold on
scatter(num,f1,'r')
% excellent graph!!
clf
scatter(num,r,'g')
hold on
scatter(num,r1,'r')
% also pretty interesting: what's going on here?!


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% COMPARING SPLITTING TO NON-SPLITTING AS YOU CHANGE ALPHA %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


a0=[5 5 5 1];
r=[1:8]';
f=[1:8]';
num=[1:8]';

a01=[5 5];
r1=[1:8]';
f1=[1:8]';
num1=[1:8]';

for n = 1:8
   alpha1 = n/10;
   alpha2 = n/10;   
  [a,c] = fmincon(@maxfunction_bound,a0,A,b);
  f(n,1)=c;
  r(n,1)=a(1,2);
  [a1,c1] = fmincon(@maxfunction_tog,a01,A1,b1);  
  f1(n,1)=c1; 
  r1(n,1)=a1(1,2); 
end

f=f.*-1;
f1=f1.*-1;

clf
scatter(num,f,'g')
hold on
scatter(num,f1,'r')
% excellent graph!!
clf
scatter(num,r)
hold on
scatter(num,r1)
% also pretty interesting: what's going on here?!



% c1 c2 z1 z2
A=[-1 0 0 0;0 -1 0 0;0 0 -1 0; 0 0 0 -1;1 1 1 1];
b=[0 ;0 ;0 ;0 ;Y];

a0=[5 5 5 5]; 
[a] = fmincon(@maxfunction,a0,A,b);
a



A=[1 1 1];
b=[Y]

a1=[5 5 5]; 
[a1] = fmincon(@maxfunction_joint,a1,A,b);
a1



%%%%%%%%%%%%%%%%%%%%%%
A=[-1 0 0 0;0 -1 0 0;0 0 -1 0; 0 0 0 -1];
b=[0 ;0 ;0 ;0];
a0=[5 5 5 5];
fmincon(@maxfunction,a0,[],[],[],[],[],[],@confun);

a

