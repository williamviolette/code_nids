function mf = opt_reg(a)

global Y N1 N2 N alpha1 alpha2 e Z2 h2 beta;

%a=[5 5 5 5]
%c=a(1,1);
%h=a(1,2);
%x=a(1,3);

c1=a(1,1);
h1=a(1,2);
x1=a(1,3);
c2=a(1,4);
h22=a(1,5);
x2=a(1,6);

mf1=N1*(((c1/N1)^alpha1)*(h1/(N1^2))^(1-alpha1)+(((x1)^alpha2)*(h1)^(1-alpha2))^beta);
mf2=N2*(((c2/N2)^alpha1)*(h22/(N2^2))^(1-alpha1)+(((x2)^alpha2)*(h22)^(1-alpha2))^beta);
mf=-1*(mf1+mf2)/(N1+N2);


%%% Doesn't Super Work %%%
% mf1=N1*(((c1/(N1+N2))^alpha1)*(h2/((N1+N2)^2))^(1-alpha1)+log(((x1)^alpha2)*(h2)^(1-alpha2)));
% mf2=N2*(((c2/(N1+N2))^alpha1)*(h2/((N1+N2)^2))^(1-alpha1)+log(((x2)^alpha2)*(h2)^(1-alpha2)));
% mf=-1*((mf1+mf2)^beta)/(N1+N2);

%mf1=-1*N1*(((c1/(N1+N2))^alpha1)*(h2/(N1+N2))^(1-alpha1)+log(((x1)^alpha2)*(h2)^(1-alpha2)));
%mf2=-1*N2*(((c2/(N1+N2))^alpha1)*(h2/(N1+N2))^(1-alpha1)+log(((x2)^alpha2)*(h2)^(1-alpha2)));
%mf=(mf1+mf2)/(N1+N2);

%  mf=-1*(((c/N)^alpha1)*(h/N)^(1-alpha1)+((x)^alpha2)*(h)^(1-alpha2));

end



