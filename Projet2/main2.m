#pkg install "./geometry-1.2.2.tar.gz";
pkg load geometry;
#Program Parameters



%Data Loading
workspace = pwd();
csv = csvread(strcat(workspace,"/Dataset/dataset.csv")); 
txt = textread(strcat(workspace,"/Dataset/dataset.csv"),"%s"); %for titles

N = csv(2:size(csv)(1), 2:size(csv)(2)); %without columns and rows titles

lines = cell(size(N)(1),1);
cols = cell(size(N)(2),1);

cols = ostrsplit(txt(1){:}, ",")(2:size(N)(2)+1); %without row x column title
for i=2:size(txt)
  lines(i-1) = ostrsplit(txt(i){:}, ",")(1); %only take the row title
endfor

%disp(cols);


%Matrix processing
%AFC (chi)

%hand, foot and total
ni = sum(N,2);
nj = sum(N,1);
n = sum(sum(N,2),1);

U = (ni .* nj) / n;

chi = zeros(size(N)(2), 1);
for j=1:size(N)(2)
  chi(j) = sum(  (((N(:,j))-U(:,j))./sqrt(U(:,j))) .* (((N(:,j))-U(:,j))./sqrt(U(:,j)))  );
endfor
chi *= 1/(size(N)(1)-1)

figure(1);
bar(1:size(chi), chi);


X = (N-U) ./ sqrt(U); %X matrix for ACP computing
#X = N
%disp(X);

%ACP

disp("ACP DEBUG HERE")

#for easier debug :
#X = X(:,[10,11,12,13]);
X = X(:,[6,24,10,11]);
#X = X(:,[6,2,7,10,1,5]);
#disp(X);

#calcul de la matrice variance/covariance:
moy = mean(X);

Etype = std(X);
disp(Etype)

figure(2)
scatter(X(:,1),X(:,2))
figure(3)
scatter(X(:,3),X(:,4))

Xred = zeros(rows(X),columns(X));
Xnorm = zeros(rows(X),columns(X));


for i=1:columns(X)
   Xred(:,i)=(X(:,i)-moy(i));
   Xnorm(:,i)=Xred(:,i)/Etype(i);
endfor

#verification de la standardisation :
#calcul de la matrice variance/covariance:
disp("Matrice de covariance")
covariance = cov(Xred);
disp(covariance);
disp("Matrice de corrélation")
#V=(1/rows(X)).*(X'*X);
V=cov(Xnorm);
disp(V);
disp("std dev");
disp(std(Xnorm));
disp("avg");
disp(mean(Xnorm));
disp("X standardized");
disp(Xnorm);

figure(4)
scatter(Xnorm(:,1),Xnorm(:,2))
figure(5)
scatter(Xnorm(:,3),Xnorm(:,4))

[E,D] = eig(Xnorm'*Xnorm);
V = E * ((D/rows(X)).^(1/2));
disp(columns(Xnorm))

infoTot = sum(diag(D));
percentInfo = (diag(D)/infoTot)*100;

disp("eigenValues");
disp(D);
disp("eigenVectors");
disp(E);
figure(6);
bar(diag(D));
figure(7);
bar(percentInfo);

finalValues = Xnorm*E;

#selecting 2 bests dimentions
first = 1;
second = 1;

maxFirst = 1;
maxSecond = 1;

max = 0;

while(first<=rows(D))
  if D(first,first)
    max = D(first,first);
    maxFirst = first;
  endif
  first += 1;
endwhile

max = 0;
while(second<=rows(D))
  if D(second,second) > max && second != maxFirst
    max = D(second,second);
    maxSecond = second;
  endif
  second += 1;
endwhile

disp(maxFirst)
disp(maxSecond)

#drawing of the correlation circle
figure(8)

x=0;
y=0;
r1=1;
drawCircle(x,y,r1);
hold on
quiver(zeros(1,rows(E)),zeros(1,rows(E)),V(:,maxFirst),V(:,maxSecond));

for i=1:columns(finalValues)
  text(V(i,maxFirst),V(i,maxSecond),cols(1,i));
endfor


#getting limits of each axis
minX = inf;
maxX = -inf;

minY = inf;
maxY = -inf;

for i=1:rows(finalValues)
  if finalValues(i,maxFirst) > maxX
    maxX = finalValues(i,maxFirst);
  endif    
  if finalValues(i,maxFirst) < minX
    minX = finalValues(i,maxFirst);
  endif
  
   if finalValues(i,maxSecond) > maxY
    maxY = finalValues(i,maxSecond);
  endif    
  if finalValues(i,maxSecond) < minY
    minY = finalValues(i,maxSecond);
  endif
endfor

disp(maxX)
disp(minX)
disp(maxY)
disp(minY)

#drawing with main axis

figure(9)
axis([minX;maxX;minY;maxY],"equal")
for i=1:rows(finalValues)
  text(finalValues(i,maxFirst),finalValues(i,maxSecond),lines(i));
endfor

xlabel(strcat("factor1 :",num2str(percentInfo(maxFirst))," %"));
ylabel(strcat("factor2 :",num2str(percentInfo(maxSecond))," %"));