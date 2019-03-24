function [c,ceq] =confun(a)

global  Y;

c1=a(1,1);
c2=a(1,2);
z1=a(1,3);
z2=a(1,4);

c = [];

% ceq = Y - (c2+z1+z2+(1/(z1+z2+1)) -1);

ceq = Y - (x1+c2+z1+z2);

end
