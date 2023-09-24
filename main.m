% Projet

%Transformation d'une chaîne de caractères en une séquence binaire
c = 'Projet CNUM : modulations numériques : PSK 8';
c_send = char2bit(c);
c_send = [c_send, 0];
c_send = [c_send, 0];

%Création d'un cardinal de symbole (avec racine de 3 afin d'obtenir des
%bits d'énergie égale à 1
symboles=sqrt(3)*[exp(j*pi/8);exp(j*3*pi/8);exp(j*7*pi/8);
    exp(j*5*pi/8);exp(j*15*pi/8);exp(j*13*pi/8);exp(j*9*pi/8);exp(j*11*pi/8)];

%Mapping des bits
A1=c_send(1:3:length(c_send));
A2=c_send(2:3:length(c_send));
A3=c_send(3:3:length(c_send));
S=symboles(4*A1+2*A2+A3+1);

%Traçage de la constellation
%plot(S, 'x');

%Insertion des 3 zéros
S2=[];
for i = 1:118
    S2 = [S2; S(i); 0; 0; 0];
end

%Application du filtre de mise en forme
b = [1/sqrt(4) 1/sqrt(4) 1/sqrt(4) 1/sqrt(4)]; 
filtered_signal = filter(b, 1, S2);

%Traçage de la densité spectrale de puissance
a= [S2; 0; 0; 0; 0; 0; 0; 0; 0]; %On ajoute 8 0 afin de pouvoir faire un zero padding
dsp = periodogram(a);
%plot(dsp);

%Application du filtre adapté
adapted_filtered_signal = filter(b, 1, filtered_signal);

%Ajout d'un bruit blanc gaussien
n = gauss(0, 0.5, 2000);
adapted_filtered_signal = adapted_filtered_signal + n;

%Observation des parties réelles et imaginaires du signal
 subplot(2,1,1);
 real_part = real(adapted_filtered_signal);
 plot(real_part);
 title('Real Part')
 
 subplot(2,1,2);
 image_part = imag(adapted_filtered_signal);
 plot(image_part);
 title('Image Part')

%Observation des parties réelles et imaginaires des 20 premiers échantillon du signal
echantillon = adapted_filtered_signal(1:1:20);
 subplot(2,1,1);
 real_part2 = real(echantillon);
 plot(real_part2);
 title('Real Part')
 
 subplot(2,1,2);
 image_part2 = imag(echantillon);
 plot(image_part2);
 title('Image Part')
 eyediagram(echantillon, 4);

%Traçage de la constellation après le sous-échantillonnage
t = adapted_filtered_signal(4:4:length(adapted_filtered_signal));
%plot(t, "x")

%Prise de décision et reformation du train binaire
Symboles_recup = [];
for i=1:length(t)
    if(real(t(i)) > 0 && real(t(i)) <= 1.2 && imag(t(i)) < 1.8 && imag(t(i)) >= 1.2)
        Symboles_recup = [Symboles_recup, 0, 0, 1];

    elseif(real(t(i)) > 1.2 && real(t(i)) <= 1.8 && imag(t(i)) < 1.2 && imag(t(i)) >= 0)
        Symboles_recup = [Symboles_recup, 0, 0, 0];

    elseif(real(t(i)) > 1.2 && real(t(i)) <= 1.8 && imag(t(i)) < 0 && imag(t(i)) >= -1.2)
        Symboles_recup = [Symboles_recup, 1, 0, 0];
    
    elseif(real(t(i)) > 0 && real(t(i)) <= 1.2 && imag(t(i)) < -1.2 && imag(t(i)) >= -1.8)
        Symboles_recup = [Symboles_recup, 1, 0, 1];

    elseif(real(t(i)) > -1.2 && real(t(i)) <= 0 && imag(t(i)) < -1.2 && imag(t(i)) >= -1.8)
        Symboles_recup = [Symboles_recup, 1, 1, 1];

    elseif(real(t(i)) > -1.8 && real(t(i)) <= -1.2 && imag(t(i)) < 0 && imag(t(i)) >= -1.2)
        Symboles_recup = [Symboles_recup, 1, 1, 0];

    elseif(real(t(i)) > -1.8 && real(t(i)) <= -1.2 && imag(t(i)) < 1.2 && imag(t(i)) >= 0)
        Symboles_recup = [Symboles_recup, 0, 1, 0];

    else
        Symboles_recup = [Symboles_recup, 0, 1, 1];
    end
end

%Suppresion des 2 zéros qui ont été ajouté à la trame binaire au début du
%projet
Symboles_recup([length(Symboles_recup), length(Symboles_recup)-1]) = [];

%Reconstitution de la chaîne de caractères
char_recu = bit2char(Symboles_recup);








