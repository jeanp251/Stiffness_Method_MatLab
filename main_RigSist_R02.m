%% main_RigSist
%---DESCRIPCION:
%---Rutina que realiza el metodo de Rigidez Sistematizado para la Tarea 03
%---del Curso Analis Matricial de Estructuras
%---Profesor: Christian Asmat
%
%
%---Hecho por: jeanp_251
clear all
close all
clc
tic
%% LECTURA # BARRAS, # NUDOS
%-------------------------
%---NUMERO DE BARRAS
n1 = xlsread('INPUT_01.xlsx','BARRAS','X2');
%---NUMERO DE GDL
n2 = xlsread('INPUT_01.xlsx','NUDOS','J2'); 
%---NUMERO DE NUDOS
n3 = n2/3;
%-------------------------
%% LECTURA COORDEANADAS TOTALES
%-------------------------
% COORDENADAS DE NUDOS
Cord = xlsread('INPUT_01.xlsx','NUDOS','B2:C21');
% CARGAS EN LOS NUDOS
%---NOTA IMPORTANTE: Vamos a considerar que esas cargas estan en el sentido de los grados de libertad globales
%---CONFIRMAR DESPUES CON EL JEFE DE PRACTICA
Q1 = xlsread('INPUT_01.xlsx','NUDOS','G2:I21');
Q2 = transpose(Q1);
Q  = Q2(:);
%---PASANDO A UN VECTOR
% GRADOS DE LIBERTAD RESTRINGIDOS
gdlr = xlsread('INPUT_01.xlsx','RESTRIC','A2:A21');
%--------------------------
%% LECTURA DE LOS DATOS DE LAS BARRAS
%--------------------------
Barras = xlsread('INPUT_01.xlsx','BARRAS','A2:W21');
%--------------------------
%% MATRIZ DE RIGIDEZ GLOBAL [K] Y VECTOR DE RESTRICCION GLOBAL [R]
%---DEFINIENDO MATRICES Y VECTORES
K = zeros(n2,n2);       % Matriz de Rigidez Global [K] (NXN)
R = zeros(n2,1);        % Vector de Restriccion Global [R] (Nx1)
k_barras = cell(1,n1); % Matriz de rigidez de las barras
A_barras = cell(1,n1); % Matriz de Transformacion de las barras
r_barras = cell(1,n1); % Matriz de Restricciones de las barras
K_aporte_barras = cell(1,n1); % Aporte de Rigidez de cada Barra al sistema
R_aporte_barras = cell(1,n1); % Aporte al vector de Restriccion de cada barra
d_barras = cell(1,n1); % Vectores de desplazamientos locales de cada barra
q = cell(1,n1); % Vector de cargas local de cada barra
  for i=1:n1
    %---INPUT PARA LA FUNCION LOCAL_STIFFNESS
    %---[A-I-E-L-alpha-BR1-BR2-w-v-x]
    %---LAS BARRAS - VER LA FUNCION LOCAL_STIFFNESSS SERA EL CASO 1
    input_localstiff = [Barras(i,2),Barras(i,3),Barras(i,4),Barras(i,17),Barras(i,18),...
                        Barras(i,19), Barras(i,20), Barras(i,21), Barras(i,22),Barras(i,23)];
    %---FUNCION PARA OBTENER LA MATRIZ DE RIGIDEZ LOCAL, ROTACION Y DE RESTRICCIONES
    %---GUARDAMOS ESAS MATRICES
    [k_barras{i},A_barras{i},r_barras{i}] = local_stiffness_R02(input_localstiff);
    %---MATRIZ DE RIGIDEZ LOCAL CON GDL DIRECCION GLOBAL
    %---(Ai)^T.Ki.A -> Kest
    k_est = transpose(A_barras{i})*k_barras{i}*A_barras{i};
    %---MATRIZ DE RESTRICCION CON GDL DIRECCION GLOBAL
    R_est = transpose(A_barras{i})*(r_barras{i});
    %---APORTE DEL ELEMENTO i A LA MATRIZ DE RIGIDEZ GLOBAL Y VECTOR
    %---DE RESTRICCION GLOBAL
    %---INPUT PARA LA FUNCION GLOB_STIFF
    %---[GDLx1-GDLy1-GDLz1-GDLx2-GDLy2-GDLz2]
    input_globstiff = [Barras(i,11),Barras(i,12),Barras(i,13),Barras(i,14),Barras(i,15),Barras(i,16)];
    %---GUARDAMOS ESAS MATRICES
    % glob_stiff(k, R, input_globstiff,n)
    [K_aporte_barras{i}, R_aporte_barras{i}] = glob_stiff_R01(k_est,R_est,input_globstiff, n2);
    K = K + K_aporte_barras{i};
    R = R + R_aporte_barras{i};
  end
%% MATRIZ DE RIGIDEZ GLOBAL Y VECTOR DE RESTRICCION CON LOS GDL LIBRES
[KLL, RL, QL, gdll] = stiff_red(K, R, Q, n2, gdlr);
%% DEFORMACIONES EN LOS GDLL [DL](Q-D)
DL = (KLL)\(QL-RL);
%---HALLAMOS EL VECTOR DESPLAZAMIENTOS GLOBAL CON TODOS LOS GDL [D](Q-D)
D = zeros(n2,1);
for i=1:length(gdll)
    D(gdll(i)) = DL(i);
end
%% DEFORMACIONES Y CARGAS EN LAS BARRAS (q-d)
for i=1:n1
    %---LLAMAMOS LA MATRIZ DE RIGIDEZ LOCAL Y DE TRANSFORMACION
    k = k_barras{i};
    A = A_barras{i};
    r = r_barras{i};
    %---OBTENEMOS EL VECTOR DE DESPLAZAMIENTOS LOCAL (q-d)
    aux = size(k);
    if aux(1) == 6
        %---CASO 1: MATRIZ DE RIGIDEZ LOCAL 6X6
        %---[GDLx1-GDLy1-GDLz1-GDLx2-GDLy2-GDLz2]
        gdl_loc = [Barras(i,11),Barras(i,12),Barras(i,13),Barras(i,14),Barras(i,15),Barras(i,16)];
    elseif aux(1) == 4
        %---CASO 3: MATRIZ DE RIGIDEZ LOCAL 4x4
        %---[GDLy1-GDLz1-GDLy2-GDLz2]
        gdl_loc = [Barras(i,11),Barras(i,12),Barras(i,13),Barras(i,14),Barras(i,15),Barras(i,16)];
    else
        %---CASO 3: MATRIZ DE RIGIDEZ LOCAL 4x4
        %---[GDLx1-GDLy1-GDLx2-GDLy2]
        gdl_loc = [Barras(i,11),Barras(i,12),Barras(i,14),Barras(i,15)];
    end
    %---GUARDAMOS EL VECTOR DE DESPLAZAMIENTOS LOCAL
    %---di = A*Di
    d_barras{i} = A*D(gdl_loc);
    %---FUERZAS INTERNAS EN LOS GDL locales (q-d)
    %---qi = ki*di+ri
    q{i} = k*d_barras{i} + r;
end
disp('--->Tiempo de Procesamiento')
toc
%% DISPLAY CONCURSO PROGRAMACION
disp('#Barras, #NUDOS, #GDL')
txt1 = num2str(n1);
txt2 = num2str(n3);
txt3 = num2str(n2);
text = strcat('---',txt1,'------',txt2,'------',txt3,'---');
disp(text)
format short
disp('--->a)Vector con los GDLL')
disp(gdll)
disp('--->b)Vector con los GDLR')
disp(gdlr)
disp('--->c)Matriz de Rigidez [ki] y de Transformacion [Ai] de cada barra')
for i=1:n1
    n = num2str(i);
    text1 = strcat('Matriz de Rigidez Lolcal [ki] de la Barra #',n);
    disp(text1)
    disp(k_barras{i})
    text2 = strcat('Matriz de Transformacion [Ai] de la Barra #',n);
    disp(text2)
    disp(A_barras{i})
end
disp('--->d.1)Matriz de Rigidez de la estructura [K]')
disp(K)
disp('--->d.2)Matriz de Rigidez de la estructura de los GDLL [KLL]')
disp(KLL)
disp('--->e)Vector de Restriccion de cada Barra (q-d)')
for i=1:n1
    n = num2str(i);
    text1 = strcat('Vector de Restriccion [ri] de la Barra #',n);
    disp(text1)
    disp(r_barras{i})
end
disp('--->f)Vector de Cargas [QL-RL]')
disp(QL-RL)
format shorte
disp('--->g.1)Vector de desplazamientos de los GDLL [DL]')
disp(DL)
disp('--->g.2)Vector de desplazamientos de la estructura [D]')
disp(D)
disp('--->h)Vector de desplazamientos de cada barra [di]')
for i=1:n1
    n = num2str(i);
    text1 = strcat('Vector de Desplazamientos [di] de la Barra #',n);
    disp(text1)
    disp(d_barras{i})
end
disp('--->i)Vector de cargas de cada barra [qi]')
for i=1:n1
    n = num2str(i);
    text1 = strcat('Vector de Cargas [qi] de la Barra #',n);
    disp(text1)
    disp(q{i})
end
disp('--->FIN')
%% PLOT
P = [Cord, Q1];
Post_Process(Barras,P,q)