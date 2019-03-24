function mf = opt_split2_2(a)

global Y N1 N2 N alpha1 alpha2 e Z2 h2 beta k;

%a=[5 5 5 5 5]
%c=a(1,1);
%h=a(1,2);
%x=a(1,3);

c1=a(1,1);
h1=a(1,2);
x1=2;
c2=a(1,3);
%h2=a(1,2);
x2=2;

% straight cobb douglas doesn't seem to work
 mf1=N1*(((c1/N1)^alpha1)*((h1/(N1^beta))^(1-alpha1)));
 mf2=N2*(((c2/N2)^alpha1)*((h2/(N2^beta))^(1-alpha1)));
 mf=-1*((mf1/(N1+N2))*(mf2/(N1+N2)));

% mf1=N1*(((c1/N1)^alpha1)*((h1/N1)^(1-alpha1))+log(h1/N1));
% mf2=N2*(((c2/N2)^alpha1)*((h2/N2)^(1-alpha1))+log(h2/N2));
% mf=-1*(mf1+mf2)/(N1+N2);

end