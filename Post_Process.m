function Post_Process(Barras,P,q)
%% Post_Process
%   Funcion para realizar el Post Procesamiento del Metodo Sistematizado de
%   Rigidez
%
%   Hecho por: jeanp_251
%% ESTRUCTURA
figure()
set(gcf,'Position',[20 50 800 900]);
hold on
for i=1:numel(Barras(:,1))
    plot([Barras(i,7),Barras(i,9)],[Barras(i,8), Barras(i,10)],'b-o','LineWidth',2)
end
grid on
grid minor
xticks(min(P(:,1))-1:0.5:max(P(:,1))+1)
axis equal
axis([min(P(:,1))-1 max(P(:,1))+1 min(P(:,2)) max(P(:,2))+1])
title('\textbf{Estructura Estudiada}','interpreter','latex')
xlabel('$x$ $[m]$','interpreter','latex')
ylabel('$y$ $[m]$','interpreter','latex')
%% CARGAS EN LA ESTRUCTURA
%---CARGAS PUNTUALES
L = max(Barras(:,17)); % Maxima Longitud de las Barras
h1 = L/50;
h2 = L/10;
h3 = L/100;
h1 = h1 + h3;
y1 = h1*0.25;
for i=1:numel(P(:,4))
    x = P(i,1);
    y = P(i,2);
    %---CARGAS HORIZONTALES
    if P(i,3) ~= 0
        dir = sign(P(i,3));
        plot([x-dir*h3,x-dir*h2],[y,y],'LineWidth',3.5,'color',[0.6 0.2 0.2]);
        patch([x-dir*h1 x-dir*h3 x-dir*h1],[y-y1 y y+y1],'k');
        text(P(i,1)-h1*sign(P(i,3)),y+h1,num2str(P(i,3))+ "ton",'color',[0.6 0.2 0.2])
    end 
    %---CARGAS VERTICALES
    if P(i,4) ~= 0
        dir = sign(P(i,4));
        plot([x,x],[y-dir*h3,y-dir*h2],'LineWidth',3.5,'color',[0.6 0.2 0.2]);
        patch([x-y1 x x+y1],[y-dir*h1 y-h3*dir y-dir*h1],'k');
        text(P(i,1)-h1,y-h1*sign(P(i,4)),num2str(P(i,4))+ "ton",'color',[0.6 0.2 0.2])
    end
    %---MOMENTOS
    if P(i,5) ~= 0
        dir = -sign(P(i,5));
        r = L/35;
        hdiv = 50;
        divs = linspace(-90,90,hdiv);
        x_ = zeros(hdiv,1);
        y_ = zeros(hdiv,1);
        for j=1:hdiv
            x_(j)= x + r*cosd(divs(j));
            y_(j)= y + r*sind(divs(j));
        end
        plot(x_,y_,'Linewidth',3.5,'color',[0.2 0.4 0.8]);
        if dir<0
            x0 = x_(end); y0=y_(end);
        else
            x0 = x_(1); y0=y_(1);
        end
        patch([x0 x0 x0-(L/75)],[y0-(L/75) y0+(L/75) y0],'k');
        text(x+L/85,y+L/25,num2str(P(i,5))+ "ton-m",'color',[0.2 0.4 0.8])
    end
end
%---CARGAS DISTRIBUIDAS
for i=1:numel(Barras(:,1))
    if Barras(i,21) ~= 0
        w = Barras(i,21);
        xi = Barras(i,7); 
        yi = Barras(i,8);
        xf = Barras(i,9);
        yf = Barras(i,10);
        alpha = Barras(i,18);
        f = [1,2,3,4];
        v = [xi,yi;xi-0.5*w*sin(alpha),yi+0.5*w*cos(alpha);xf-0.5*w*sin(alpha),yf+0.5*w*cos(alpha);xf,yf];
        patch('Faces',f,'Vertices',v,'FaceColor',[0.1 0.6 0.1],'FaceAlpha',.5);
        text(0.5*(xi+xf),0.5*(yi+yf),num2str(w)+"ton/m",'color',[0.1 0.6 0.1])
    end
end
%% DIAGRAMA DE MOMENTO FLECTOR (M) Y FUERZA CORTANTE (V)
for i=1:numel(Barras(:,1))
    type = Barras(i,23);
    cargas = q{i};
    switch type
        case 1
            V1 = cargas(2);
            M1 = cargas(3);
            V2 = cargas(5);
            M2 = cargas(6);
        case 2
            V1 = cargas(1);
            M1 = cargas(2);
            V2 = cargas(3);
            M2 = cargas(4);
        case 3
            V1 = 0;
            V2 = 0;
            M1 = 0;
            M2 = 0;
        case 4
            V1 = cargas(1);
            M1 = cargas(2);
            V2 = cargas(3);
            M2 = cargas(4);
        case 5
            V1 = cargas(1);
            M1 = cargas(2);
            V2 = cargas(3);
            M2 = cargas(4);
    end
    L = Barras(i,17);
    x = linspace(0,L,50);
    if Barras(i,21)~=0
        w = Barras(i,21);
        M = -(w*x/2).*(L-x) - M1*(x/L-1) - M2.*x/L;
        V = (-(V2+V1)/L)*x + V1;
    else
        M = (-(M1+M2)/L)*x + M1;
        V = V1*ones(1,length(x));
    end
    % IMPORTANTE FACTOR DE ESCALAMIENTO DE LOS GRAFICOS
    scale = 1;
    n = num2str(i);
    text1 = strcat('DMF Barra #',n);
    text2 = strcat('DFC Barra #',n);
    Mmax = num2str(max(M));
    Mmin = num2str(min(M));
    figure()
    subplot(2,1,1)
    plot(x,scale*M)
    hold on
    plot([0,L],[0,0],'LineWidth',3.5,'color','b')
    text(0.5*L,1,Mmax+"ton/m",'color',[0.1 0.6 0.1])
    text(0.5*L,-1,Mmin+"ton/m",'color',[0.1 0.6 0.1])
    title(text1)
    subplot(2,1,2)
    plot(x,scale*V)
    hold on
    plot([0,L],[0,0],'LineWidth',3.5,'color','b')
    title(text2)
    %---TESTANDO LA MATRIZ DE ROTACION
%     alpha = Barras(i,18);
%     c = cos(alpha);
%     s = sin(alpha);
%     zaux = ones(1,length(M));
%     ROT = [c -s 0;s c 0;0 0 1];
%     [xp;Mp;zp] = ROT*[x;M';zaux];
%     figure()
%     plot(xp,Mp)
end
end

