                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 %Calculation and display of the gravitational force of any solid STL 
clc
clearvars
close all
format long
tic
%% Parte 1 - Lendo o Arquivo STR
% Lê o arquivo ASCII STL e fornece coordenadas dos vértices, as suas relações, os vetores normais as faces e a lista de .
% Abrindo o aquivo .stl 
TRI = stlread('arquivos/cubo.stl');
% Definindo um fator de multiplicação, sem o fator 
%Vértices0.
Vrn = TRI.Points;
%Lista de Coneções entre esses pontos (que formam as faces)
Frn = TRI.ConnectivityList;
%Vetores normais as faces 
Normal = faceNormal(TRI);
%Lista de arestas
Edg = edges(TRI);
%Lista dos lados
ID = cell2mat(edgeAttachments(TRI,Edg));
% Máximo e Minimo e distância entre ambos
MaxV = max(max(Vrn)); 
MinV = min(min(Vrn));
Raio = MaxV-MinV;

%% Parte 2 - Criando uma estrutura solida
% Com isso podemos estimar volume, massa e evitar pontos dentro da
% estrutura, consideramos sempre estruturas sem buracos e únicas
% isso não é um requisito, mas sem essa restrição o volume deve ser 
% fornecido pelo usuario
shp = alphaShape(Vrn,Inf);
toc
tic
%% Parte 3 Definindo as propriedades Básicas
Vol = volume(shp); % m^3
%Massa em KG (Definida pelo usuario)
Massa = 100; 
%Densidade
S = Massa/Vol; % Kg/m^3;
G = 6.67384e-11; % m^3/Kg/s^2  Constante Gravitacional
GS = G*S;  % Produto da densidade pela constante gravitacional
toc
tic
%% Parte 4 Definindo as arestas e os vetores normais as arestas
%Definindo o tamanho dos vetores para realizar as interaçöes e melhorar a
%performace
Lv = size(Vrn,1); %Numero de Vertices 
Lf = size(Frn,1); %Numero de Faces 
Le = size(Edg,1); %Numero de Arestas 

% Criando vetores e  preenchendo  para uma maior performace  
EstNomal = nan(3,Lf); % Matriz onde produto externo das normais é armazenado         
EstMatrix = nan(3,Le);
EstLink(Le) = struct();
ct = 1; % Contador
% Definido a matriz de vetores nomais, que serve para realizar o produto
% vetorial
for i = 1 : Lf
    EstNomal(1:3,ct:1:(ct+2)) = Normal(i,:)'*Normal(i,:);
    ct = ct+3; % Somando 3 pois temos um triângulo 
end 

% Aqui sáo salvas as informações sobre os vetores bem como as faces que
% são relacionadas esses esses vetores 
for i = 1:Le
    Link = [Edg(i,1), Edg(i,2)];
    % Vetor com relação a primeira face
    EstLink(i).vetor1.start   = Vrn(Link(1),:)';
    EstLink(i).vetor1.end   = Vrn(Link(2),:)';
    EstLink(i).FaceNumber1     = ID(i,2);
    % Vetor com relação a segunda face 
    EstLink(i).vetor2.start   = Vrn(Link(2),:)';
    EstLink(i).vetor2.end   = Vrn(Link(1),:)';
    EstLink(i).FaceNumber2     = ID(i,1);
end

% Definido normais das arestas e armazenando o resultado   
% Definido normais das arestas e armazenando o resultado   
    ct = 1;
    for i = 1 : Le
        %Normal da primeira face
        NN1 = Normal(EstLink(i).FaceNumber1,:); %Normal da primeira face
        %Normal da aeresta rem realaçao a primeira face
        NE1 = cross(EstLink(i).vetor1.end-EstLink(i).vetor1.start,NN1);
        %Convertendo em unitário 
        NE1 = NE1/norm(NE1,2);
        %Normal da segunda face
        NN2 = Normal(EstLink(i).FaceNumber2,:); %Normal da segunda face
        %Normal da aeresta rem realaçao a segunda  face
        NE2 = cross(EstLink(i).vetor2.end-EstLink(i).vetor2.start,NN2);
        %Convertendo em unitário
        NE2 = NE2/norm(NE2,2);                            
        % Resultado dos vetores normais da borda comptalhada i
        EstLink(i).Matrix = (NN1'*NE1 + NN2'*NE2);
        % Alocando o valor para o produto matricial 
        EstMatrix(1:3,ct:1:(ct+2)) = EstLink(i).Matrix;                    
        ct = ct+3;
    end

toc
tic
%% Parte 5 Definindo as posições no espaço

%Definindo o minino o maximo e os passos. 

%%IMPORTANTE O FATOR DE MULTIPLICAÇÃO IRA DETERNIMAR O TAMANHO DA GRADE SE
%%EXISTIREM MUITOS POLIGONOS E O FATOR FOR GRANDE O TEMPO DE EXECUÇÃO SERA
%%ENORME 

% Alocando o vetor para mais performace 
PosVector = [0;0;0]; 
Acelera = [];
PosFinal = [];
% FATOR DE MULTIPLICAÇÃO
Fator = 10; 
% TAMANHO DA GRADE
tg2 = -MaxV*2;
tg1 = MaxV*2;

% Gerando o meshgrid
Line = linspace(tg2,tg1, Fator);
% Gerando o GRID DE PONTOS
Grid = meshgrid(Line, Line, Line);
toc
tic
%% Parte 6 Executando o LOOP 
for I = 1 : size(Grid,1)
    for J = 1 : size(Grid,2)
        for K = 1 : size(Grid,3)
            %% Parte 7 Verificando os ângulos com relaçao ao ponto de interesse 
             PosVector = [Grid(1,I);Grid(2,J);Grid(3,K)];
            %Verfificando quais pontos não estao dentro do objeto
            tf = inShape(shp,(PosVector(1)),(PosVector(2)),(PosVector(3)));
            if false == false
                %Alocando os vetores para performace 
                wf = nan(Lf,1);     % Ângulo que relaciona ponto de interesse as faces e vertices
                distTotal = nan(3,3);   % Vetor do ponto de interesse até o vertice 
                distMag = nan(3,1);     % magnitude do vetor anterior
                for i = 1 : Lf
                    for j = 1 : 3 %APENAS TRIANGULOS
                    % Calculando a distância 
                    distTotal(j,:) =  Vrn(Frn(i,j),:) - PosVector';
                    % Calculando a magnitude  
                    distMag(j) = norm(distTotal(j,:),2);
                    end
                    Num = dot(distTotal(1,:),cross(distTotal(2,:),distTotal(3,:)));
                    Den = distMag(1)*distMag(2)*distMag(3) + distMag(1)*dot(distTotal(2,:),distTotal(3,:)) + distMag(2)*dot(distTotal(3,:),distTotal(1,:)) + distMag(3)*dot(distTotal(1,:),distTotal(2,:));
                    wf(i) = 2*atan2(Num,Den);
                end
            %% Parte 8 Verificando Avaliando o Ponto com relação a FACE E A AERESTA
                %Alocando os vetores para performace 
                RelFace = nan(Lf*3,1);
                RelAers = nan(Le*3,1);
                ct = 1;
                %% Parte 8.1 Verificando Avaliando o Ponto com relação a FACE
                for i = 1 : Lf
                    RelFace(ct:1:(ct+2),1) = (Vrn(Frn(i,1),:)' - PosVector)*wf(i);
                    ct = ct+3; 
                end
                ct = 1;
                %% Parte 8.2 Verificando Avaliando o Ponto com relação a AERESTA
                for i = 1 : Le
                    re = EstLink(i).vetor2.start - PosVector; 
                    %Distâncias Absolutas
                    a = norm(EstLink(i).vetor2.start-PosVector,2);
                    b = norm(EstLink(i).vetor2.end - PosVector,2);
                    e = norm(EstLink(i).vetor2.end-EstLink(i).vetor2.start,2);
                    % Considerando Condicóes especiais 
                    if (a+b-e) == 0
                        Let = 0;
                    else
                        %Entenda Log como Ln
                        Let = log((a+b+e)/(a+b-e));
                    end

                    RelAers(ct:1:(ct+2),1) = re*Let;
                    ct = ct+3;
                end
                %% Parte 9 Multiplicando as forças pelo ângulo da Face e da Aersta
                %Aeresta
                TotalAresta = EstMatrix * RelAers;
                %Face
                TotalFace = EstNomal * RelFace;
                %Somando as forças e adicionado a constante gravitacional e a
                %densidade
                Acc = GS * (-TotalAresta + TotalFace);
                %Preenchendo os valores para o plot 
                PosFinal(end + 1) = PosVector(1);
                PosFinal(end + 1) = PosVector(2);
                PosFinal(end + 1) = PosVector(3);
                %Preenchendo os valores para o plot 
                Acelera(end + 1) = Acc(1);
                Acelera(end + 1) = Acc(2);
                Acelera(end + 1) = Acc(3);
                % magnitude da Aceleração
                A = norm(Acc);
                ADIS = norm(PosVector);
                fprintf('No ponto = [');
                fprintf('%g ,', PosVector);
                fprintf(']\n');
                fprintf('NA a distância do centro de massa é = [');
                fprintf('%g ,', ADIS);
                fprintf(']\n');
                fprintf('A aceleracao é = [');
                fprintf('%g ,', Acc);
                fprintf(']\n');
                fprintf('A magnitude da aceleracao é = %1.4E [m s^-2]\n',A);
            end
        end
    end
end
toc
tic
%% Parte 10 Plotando tudo. 
VetPos = reshape(PosFinal, 3, [])';
VetAcelera =   -1*reshape(Acelera, 3, [])';
maxA = max(max(VetAcelera));
minA = min(min(VetAcelera));
VecPosValue = zeros(size(VetPos,1),1);
for I = 1 : size(VetPos,1)
    r = [VetAcelera(I,1) VetAcelera(I,2) VetAcelera(I,3)];
    VecPosValue(I) = round(norm(r),4,"significant");
end
MaxValue = round(max(VecPosValue),4,"significant");
MinValue = round(min(VecPosValue),4,"significant");
figure(1)
trisurf(TRI)
hold on
color1 = zeros(size(VetPos,1),1);
color2 = zeros(size(VetPos,1),1);
for I = 1 : size(VetPos,1)
    rlocal = [VetAcelera(I,1) VetAcelera(I,2) VetAcelera(I,3)];
    tf = inShape(shp,(VetPos(I,1)),(VetPos(I,2)),(VetPos(I,3)));
    if tf == false
        cv = round(norm(rlocal),4,"significant");
        if MaxValue == 0
            color1(I) = 0;
            color2(I) = 0;
        else
            color1(I) = cv/MaxValue;
            color2(I) = (MaxValue-cv)/MaxValue;
        end
        q = quiver3((VetPos(I,1)),(VetPos(I,2)),(VetPos(I,3)),(VetAcelera(I,1)),(VetAcelera(I,2)),(VetAcelera(I,3)),(1/MaxValue),'color',[color1(I) 0 color2(I)]);
        q.ShowArrowHead = 0;
        hold on
    end
end
toc
 