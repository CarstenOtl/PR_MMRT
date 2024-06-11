function y = int_wagen_pos(x,t,T,k,a_5,a_4,a_3,a_2,a_1,a_0,t_1,t_2,h)
% Argument von y_w
z =  T * sin(x) + t;
% hier steht der Integrand y_w(z)=y(z)
y = k.*(a_5.*z.^5 + a_4.*z.^4 + a_3.*z.^3 + a_2.*z.^2 + a_1.*z + a_0);
% Korrektur an den Ränder (bei der Hausaufgabe nicht nötig, da dort die
% Integrationsgrenzen angepasst sind.
sel_mitte = (t_1<z) & (z<t_2);
y = sel_mitte.* y;
sel_rand = z>t_2;
y = y + sel_rand * h;
