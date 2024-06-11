%% Skrit um die Wunschtrajektorien zu berechnen
% hierzu werden die Matlab-Funktionen:
% int_wagen_pos.m
% int_wagen_phi.m
% int_wagen_a.m
% int_wagen_v.m
% aufgerufen.
%% Parameter des Aufbaus
% L�nge der Kette in m
L = 62*0.019; 
% Dichte pro L�nge (kg/m)
rho = 2.3;
% Masse des Schlittens mit allen starr verbundenen Teilen (kg)
r = 0.150/2/pi; %Radius des Riementriebs
i = 3; %�bersetzung: Drehzahl Motor zu Drehzahl Riementrieb
M = (0.94 + 0.45) + 25.01e-5 * i^2 /r^2 + 0.09*2 + 2*1.8e-4 / r^2;  %in kg (Masse_Schlitten mit Aufbau) + Tr�gheit Anker projeziert auf Bewegung Schlitten
% + Gewicht Riemen + Tr�gheit der Scheiben
% Erdbeschleunigung
g = 9.81; 
% Zeitkonstante T 
T = 2*sqrt(L/g);
% Zeiten f�r die Bewegung
t_ende = 2.75*T;
t_1 = T;
t_2 = t_ende - T;
% Koeffizienten f�r die analytische Bestimmung von gamma
a_5 = 0.2;
a_4 = -0.5*(t_1+t_2);
a_3 = 1/3*(t_1^2+t_2^2+4*t_1*t_2);
a_2 = -t_1*t_2*(t_1+t_2);
a_1 = t_1^2*t_2^2;
% Bestimmung von a_0, so dass gamma(t_1)=0
a_0 = -(a_5*t_1^5 + a_4*t_1^4 + a_3*t_1^3 + a_2*t_1^2 + a_1*t_1);


% Berechnung der Wunschtrajektorie f�r das Kettenende 
t=0:0.005:t_ende;
for index=1:size(t,2)
    if t(index)<t_1
        y_w(index) = 0;       
    elseif t(index)<t_2
        z = t(index);
        y_w(index) = a_5*z^5 + a_4*z^4 + a_3*z^3 + a_2*z^2 + a_1*z + a_0;
    else
        y_w(index) = y_w(index-1);
    end
end




%% Skalierung so dass y_w(t_2) = 0.5
h = 0.5;
k = h/y_w(end);
y_w = k*y_w;


%% Plotten der Kurve
close all
figure(1)
axes('FontSize',24)
hold on
box on
%grid on
axis([0 ceil(t_ende) -0.1 0.6])
%plot([-T,t,t_ende+T],[0,y,y(end)],'LineWidth',2)
plot([-T,t,t_ende+T],[0,y_w,y_w(end)],'b','LineWidth',2)
xlabel('x')
ylabel('y')

%% Bestimmung der Wagenposition w(0,t)
% in der Funktion int_wagen_pos wurde der Integrand f�r das zu
% l�sende Integral definiert
for index=1:size(t,2)
    y_wagen(index) = 1/pi * quad(@(x) int_wagen_pos(x,t(index),T,k,a_5,a_4,a_3,a_2,a_1,a_0,t_1,t_2,h),-pi/2,pi/2);
end
plot(t,y_wagen,'r--','LineWidth',2)
legend('A','B')

%% Hausaufgabe 
% Bestimmen Sie �hnlich wie die Wagenposition w(0,t) die zeitlichen und
% �rtlichen Ableitungen: 
% dw(0,t)/dt = Geschwindigkeit Wagen
% d^2w(0,t)/dt^2 = Beschleunigung Wagen
% phi = dw(0,t)/dx = Kettenwinkel.
% Sie m�ssen hierzu nur die Funktionen int_wagen_v,int_wagen_a und
% int_wagen_phi vervollst�ndigen (nicht das steuerung.m Skript).
% Orientieren Sie sich an der Funktion int_wagen_pos.m .
for index=1:size(t,2)
    phi_1 = -pi/2;
    phi_2 = pi/2;
    % Anpassung der Integrationsgrenzen, damit die numerische Integration
    % mit Hilfe der Funktion quad.m problemlos erfolgen kann. 
    if t(index)-T<t_1
        phi_1 = asin((t_1 - t(index))/T);
    end
    if t(index)+T>t_2
        phi_2 = asin((t_2 - t(index))/T);
    end
    v_wagen(index)      = 1/pi * quad(@(x) int_wagen_v(x,t(index),T,k,a_5,a_4,a_3,a_2,a_1,a_0,t_1,t_2,h),phi_1,phi_2);
    a_wagen(index)      = 1/pi * quad(@(x) int_wagen_a(x,t(index),T,k,a_5,a_4,a_3,a_2,a_1,a_0,t_1,t_2,h),phi_1,phi_2);
    phi_wagen(index)    = 1/pi * quad(@(x) int_wagen_phi(x,t(index),T,k,a_5,a_4,a_3,a_2,a_1,a_0,t_1,t_2,sqrt(g*L)),phi_1,phi_2);
end

%% Ausgabe der Ergebnisse

figure(2)
axes('FontSize',24)
plot([-T,t,t_ende+T],[0,v_wagen,v_wagen(end)],'b','LineWidth',2)
title('Geschwindigkeit Wagen (m/sec)')

figure(3)
axes('FontSize',24)
plot([-T,t,t_ende+T],[0,a_wagen,a_wagen(end)],'b','LineWidth',2)
title('Beschleunigung Wagen (m/sec^2)')

figure(4)
axes('FontSize',24)
plot([-T,t,t_ende+T],180/pi*[0,phi_wagen,phi_wagen(end)],'b','LineWidth',2)
title('Phi (in �)')


% Kraft auf Wagen durch Kette und Tr�gheitskrraft des Wagens
F_m =  a_wagen * M;

% Mechanischen Reibung im Antrieb (viel kleiner als "elektrische Reibung")
Mo_r = 0.006; %Nm/(rad/s) Reibung im Motor
F_r = 2.3*0.6/r * (v_wagen>0) + v_wagen/r*i*Mo_r*i/r; %(Reibung Schiene + Reibung Motor)

% Summe aus Tr�gheitskraft + Reibung 
F = F_m+F_r;
% Berechnung der daf�r n�tigen Spannung unter ber�cksichtigung der induzierten
% Spannung
% Parameter des Elektromotors
R = 1.35; %Widerstand in Ohm
k = 0.265; %Motorkonstante Nm/A
U_motor     = (F - sin(phi_wagen) * L * rho * g)*r/i/k*R + v_wagen * k*i/r ; 

figure(6)
axes('FontSize',24)
plot([-T,t,t_ende,t_ende+T],[0,U_motor,0,0],'b','LineWidth',2)
title('Spannung (V)')

%% R�ckfahrt der Kette durch Spiegelung der Trajektorien
T_pause = 4; % Pause am Zielpunkt
% Zeit f�r die Initialisierung des Systems
Zeitinit=10;
% Aufbau eines Zeitvektors f�r Hin- und R�ckfahrt
t_gesamt        = [t,t(end)+0.001,t+t(end)+T_pause,2*t(end)+T_pause+0.01,2*t(end)+2*T_pause];
% Umkehrung der Werte f�r die R�ckfahrt
phi_wa_gesamt   = [phi_wagen,0,-phi_wagen,0,0];
a_wa_gesamt     = [a_wagen,0,-a_wagen,0,0];
v_wa_gesamt     = [v_wagen,0,-v_wagen,0,0];
y_wa_gesamt     = [y_wagen,y_wagen(end),h-y_wagen,h-y_wagen(end),h-y_wagen(end)];
U_mo_gesamt     = [U_motor,0,-U_motor,0,0];

% Aufbau der Vektoren f�r 5 malige Wiederholung des Vorgangs
t_W         = [-15,t_gesamt,t_gesamt+t_gesamt(end),t_gesamt+2*t_gesamt(end),t_gesamt+3*t_gesamt(end),t_gesamt+4*t_gesamt(end)]+Zeitinit+15;
Y_w         = [t_W',[0;y_wa_gesamt';y_wa_gesamt';y_wa_gesamt';y_wa_gesamt';y_wa_gesamt']];
Y_w_dot     = [t_W',[0;v_wa_gesamt';v_wa_gesamt';v_wa_gesamt';v_wa_gesamt';v_wa_gesamt']];
Y_w_ddot    = [t_W',[0;a_wa_gesamt';a_wa_gesamt';a_wa_gesamt';a_wa_gesamt';a_wa_gesamt']];
Phi_w       = [t_W',[0;phi_wa_gesamt';phi_wa_gesamt';phi_wa_gesamt';phi_wa_gesamt';phi_wa_gesamt']];
U_w         = [t_W',[0;U_mo_gesamt';U_mo_gesamt';U_mo_gesamt';U_mo_gesamt';U_mo_gesamt']];