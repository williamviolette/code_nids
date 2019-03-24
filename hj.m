function mf = hj(a)

global Y N1 N2 N alpha1 alpha2 e Z2 h2 beta k;

%a=[2 2 2]
c1=a(1,1);
h1=a(1,2);
%x1=a(1,2);
c2=a(1,3);
%h2=a(1,4);
%x2=a(1,4);

mf1=N1*((c1/N1^2)+log(h1))^alpha1;
mf2=N2*((c2/N2^2)+log(h2))^alpha1;
mf=-1*((mf1+mf2)/(N1+N2))^(1/alpha1);

end



