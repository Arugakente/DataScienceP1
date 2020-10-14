n = ones(15,1);
multiCount = true;

files = glob("/Users/guillaume/Documents/Travail/2020-2021/data_science/Projets/DataScienceP1/Dataset/processed/*.txt");

M = zeros(numel(files),numel(files));

wordList = cell(0,1);
listSite =  cell(0,1);

for i=1:numel(files)
  currentFile = textread(files{i}, "%s");
  linkFrom = str2num(substr(files{i},rindex(files{i},"\\") + 5, rindex(files{i},".") - (rindex(files{i},"\\") + 5)));
  for j=1:numel(currentFile)
    currentWord = currentFile{j};
    if isempty(regexp(currentWord,"linkTo:.*")) == 0 %On traite le lien
      linkTo = str2num(substr(currentWord,index(currentWord,":")+5,index(currentWord,".")-(index(currentWord,":")+5)));
      if linkTo != linkFrom
        if multiCount
          M(linkFrom,linkTo)+=1;
        else  
          M(linkFrom,linkTo)=1;
        endif
      endif
    else %On traite le mot
      if size(currentWord) != 0
        %nettoyage des mots
        
        isContained = false;
        for i=1:size(wordList)
          if size(wordList)!=0 && strcmp(wordList(i),currentWord) %On rajoute le lien associ�
            currentParc = 1;
            found = false;
            while !found && currentParc <= size(listSite{i})
              if(size(listSite{i}) == 1)
                found = strcmp(listSite{i},linkFrom);
              else
                found = strcmp(listSite(i)(currentParc),linkFrom);
              endif
              currentParc+=1;
            endwhile;
            if !found
              listSite{i} = [listSite{i}; linkFrom];
              isContained = true;
            endif;
            break;
          endif
        endfor 
        if !isContained %On rajoute le mot � la liste
          wordList = [wordList;[currentWord]];
          listSite = [listSite; num2cell([linkFrom])];
        endif
      endif
    endif
  endfor
endfor

disp(M);

for i=1:size(M)(1)
  somme = sum(M(:,i));
  
  for j=1:size(M)(2)
    M(j,i) = M(j,i)/somme;
  endfor
  
  disp(sum(M(:,i)));
endfor

disp(M);

T = 10;

x = zeros(size(M)(1), T);
x(:,1) = n;

for i=1:T
    n = M*n;
    x(:,i+1) = n;
endfor

figure(1);
plot(0:T, x(1,:));
hold on;

for i=1:size(M)(1)
  plot(0:T, x(i,:));
endfor