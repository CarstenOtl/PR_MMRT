function y = int_wagen_phi(x,t,T,k,a_5,a_4,a_3,a_2,a_1,a_0,t_1,t_2,sqrt_gl)
% Argument f�r y_w (nicht �ndern)
z =  T * sin(x) + t;

%% wie muss die Funktion y(z) lauten? 
y = -k.*(5*a_5.*z.^4 + 4*a_4.*z.^3 + 3*a_3.*z.^2 + 2*a_2.*z + a_1).*sin(x)./sqrt_gl;