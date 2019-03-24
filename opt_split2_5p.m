function mf = opt_split2_5p(a)

global Y N1 N2 N alpha1 alpha2 e Z2 h2 beta k;

%a=[5 5 5 5]
%c=a(1,1);
%h=a(1,2);
%x=a(1,3);

c1=a(1,1);
h1=a(1,6);
x1=a(1,2);
c2=a(1,3);
x2=a(1,4);
H2=a(1,5);

% very simplified! but need substitution patterns to vary with n!!
 mf1=N1*(((c1/(N1))^alpha1)*((x1/(N1^k))^(alpha2+e))*(((h1/((N1)^beta)))^(1-alpha1-alpha2)));
 mf2=N2*(((c2/(N2))^alpha1)*((x2/(N2^k))^(alpha2+e))*(((H2/((N2)^beta)))^(1-alpha1-alpha2)));
 mf=-1*((mf1/(N1+N2))*(mf2/(N1+N2)));

% mf1=N1*(((c1/(N1))^alpha1)*((h2/(N1+N2))^(1-alpha1))+log(h2/(N1+N2)));
% mf2=N2*(((c2/(N2))^alpha1)*((h2/(N1+N2))^(1-alpha1))+log(h2/(N1+N2)));
% mf=-1*(mf1+mf2)/(N1+N2);


end