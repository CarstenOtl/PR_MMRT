function y = int_wagen_a(x,t,T,k,a_5,a_4,a_3,a_2,a_1,a_0,t_1,t_2,h)
% Argument f�r y_w (nicht �ndern)
z =  T * sin(x) + t;

%% wie muss die Funktion y(z) lauten? 
y = k.*(4*5*a_5.*z.^3 + 3*4*a_4.*z.^2 + 2*3*a_3.*z + 2*a_2);