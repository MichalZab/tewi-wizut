%(C) Antoni Wili�ski 2013
%skrypt strategii S4 w projekcie TEWI - z dopasowaniem parametr�w dla po�owy danych
%S4b - drugi kwadrant - oznaczajacy za�o�enie, ze trend jest horyzontalny i
%nale�y otwierac pozycje kr�tkie wg zasady Sell Limit

%parametry:
% paramBLength= 5;%2;
% paramBVolLength=4;%10; %liczba swiec wstecz do obliczenia sredniego wolumenu
% paramBBuffer=0.00021;%0.0007;
% paramBVolThreshold=110;%950; %pr�g dla sredniego wolumenu
% paramBDuration=8; %liczba krok�w wprz�d do zamkniecia pozycji
% paramBSL=0.0023;  %Stop Loss

%Dane:
tStart=tic;
eurusd1h5k;
bestReturn=-100;verificationC=C(2500:end,:); C=C(1:2500,:);
cSizes = size(C);
candlesCount = cSizes(1);
bestCalmar = 0;
bestMa = 0;
bestparamBVolLength = 0;
bestparamBDuration = 0;
bestparamBBuffer = 0;
bestparamBVolThreshold = 0;
bestparamBSL = 0;
spread = 0.00016;
lastCandle = 0 ;


for paramBLength=9:9:91%liczba swiec wstecz do obliczenia maksimum
    maxes=zeros(1, candlesCount);
    kon=candlesCount-1;
    for i=2:kon
        maxes(i) = max(C(i-min(i-1,paramBLength):i,4));
    end
    for paramBVolLength=26%:1:38;%liczba swiec wstecz do obliczenia sredniego wolumenu
        disp(['paramBLength ', num2str(paramBLength), '  paramBVolLength ', num2str(paramBVolLength)]);
        volBverages=zeros(1, candlesCount);
        for i=2:kon
            volBverages(i) = mean(C(i-min(i-1,paramBVolLength):i,5))-C(i,5);
        end
        for paramBDuration=16%6:1:16; %liczba krok�w wprz�d do zamkniecia pozycji
            for paramBVolThreshold=100%-100:100:100; %pr�g dla sredniego wolumenu
                for paramBBuffer=-spread*28:spread:spread%-0.0032%-0.0032:0.0032:0.0032%dla kwadrantu a i b szukamy ujemnych warto�ci, dla kwadrant�w c i d dodatnich warto�ci bufora
                    for paramBSL=spread*35:spread*1:spread*48;  %Stop Loss minimalnie mo�e by� r�wny 8*spread 0.00384%
                        
                        sumRa=zeros(1,candlesCount);
                        Ra=zeros(1,candlesCount);
                        dZ=zeros(1,candlesCount);
                        pocz=max(paramBVolLength, paramBLength)+2;
                        la=0; %liczba otwieranych pozycji
                        kas=0;
                        lastCandle = kon-max(paramBLength, paramBVolLength) - paramBDuration;
                        for i=pocz:lastCandle
                            
                            if maxes(i) + paramBBuffer <C(i,4) && volBverages(i)<paramBVolThreshold
                                Ra(i)=-C(i+paramBDuration,4)+C(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkni�ciu po paramBDuration kroku
                                H=max(C(i+1:i+paramBDuration,2));
                                
                                if (C(i+1,1)-H)<-paramBSL
                                    Ra(i)=-paramBSL;
                                    ls=ls+1;
                                end
                                
                                la=la+1;
                                kas=1;
                            end
                            sumRa(i)=sumRa(i-1) + Ra(i);  %krzywa narastania kapita�u
                        end
                        
                        
                        recordReturn=0;  %rekord zysku
                        recordDrawdown=0;  %rekord obsuniecia
                        
                        for j=1:lastCandle
                            if sumRa(j)>recordReturn
                                recordReturn=sumRa(j);
                            end
                            
                            dZ(j)=sumRa(j)-recordReturn; %r�znica pomiedzy bie��c� wartoscia kapita�u skumulowanego a dotychczasowym rekordem
                            
                            if dZ(j)<recordDrawdown
                                recordDrawdown=dZ(j);  %obsuniecie maksymalne
                            end
                            
                        end
                        
                        %wyniki ko�cowe
                        sumReturn=sumRa(lastCandle);
                        Calmar=-sumReturn/recordDrawdown;  %wskaznik Calmara
                        if bestReturn<sumReturn
                            bestReturn=sumReturn;bestCalmar=Calmar;
                            bestMa = paramBLength;
                            bestparamBVolLength = paramBVolLength ;
                            bestparamBDuration = paramBDuration;
                            bestparamBBuffer = paramBBuffer;
                            bestparamBVolThreshold = paramBVolThreshold;
                            bestparamBSL = paramBSL;
                            disp(['zysk: ', num2str(sumReturn), ...
                                ' paramBLength: ', num2str(paramBLength), ...
                                ' paramBVolLength: ', num2str(paramBVolLength), ...
                                ' paramBBuffer: ', num2str(paramBBuffer), ...
                                ' paramBVolThreshold: ', num2str(paramBVolThreshold), ...
                                ' paramBDuration: ', num2str(paramBDuration), ...
                                ' paramBSL: ', num2str(paramBSL), ...
                                ' Calmar: ', num2str(Calmar) ...
                                ]);
                        end
                        
                        
                    end
                end
            end
        end
    end
end
disp(['1stHalfSumReturn = ', num2str(bestReturn)]);
cSizes = size(verificationC);
candlesCount = cSizes(1);

for paramBLength=bestMa
    maxes=zeros(1, candlesCount);
    kon=candlesCount-1;
    for i=2:kon
        maxes(i) = max(verificationC(i-min(i-1,paramBLength):i,4));
    end
    for paramBVolLength=bestparamBVolLength%liczba swiec wstecz do obliczenia sredniego wolumenu
        disp(['paramBLength ', num2str(paramBLength), '  paramBVolLength ', num2str(paramBVolLength)]);
        volBverages=zeros(1, candlesCount);
        for i=2:kon
            volBverages(i) = mean(verificationC(i-min(i-1,paramBVolLength):i,5))-verificationC(i,5);
        end
        for paramBDuration=bestparamBDuration %liczba krok�w wprz�d do zamkniecia pozycji
            for paramBVolThreshold=bestparamBVolThreshold%pr�g dla sredniego wolumenu
                for paramBBuffer=bestparamBBuffer%dla kwadrantu a i b szukamy ujemnych warto�ci, dla kwadrant�w c i d dodatnich warto�ci bufora
                    for paramBSL=bestparamBSL  %Stop Loss minimalnie mo�e by� r�wny 8*spread 0.00384%
                        
                        sumRa=zeros(1,candlesCount);
                        Ra=zeros(1,candlesCount);
                        dZ=zeros(1,candlesCount);
                        pocz=max(paramBVolLength, paramBLength)+2;
                        la=0; %liczba otwieranych pozycji
                        kas=0;
                        lastCandle = kon-max(paramBLength, paramBVolLength) - paramBDuration;
                        for i=pocz:lastCandle
                            
                            if maxes(i) + paramBBuffer <verificationC(i,4) && volBverages(i)<paramBVolThreshold
                                Ra(i)=-verificationC(i+paramBDuration,4)+verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkni�ciu po paramBDuration kroku
                                H=max(verificationC(i+1:i+paramBDuration,2));
                                
                                if (verificationC(i+1,1)-H)<-paramBSL
                                    Ra(i)=-paramBSL;
                                    ls=ls+1;
                                end
                                
                                la=la+1;
                                kas=1;
                            end
                            sumRa(i)=sumRa(i-1) + Ra(i);  %krzywa narastania kapita�u
                        end
                        
                        
                        recordReturn=0;  %rekord zysku
                        recordDrawdown=0;  %rekord obsuniecia
                        
                        for j=1:lastCandle
                            if sumRa(j)>recordReturn
                                recordReturn=sumRa(j);
                            end
                            
                            dZ(j)=sumRa(j)-recordReturn; %r�znica pomiedzy bie��c� wartoscia kapita�u skumulowanego a dotychczasowym rekordem
                            
                            if dZ(j)<recordDrawdown
                                recordDrawdown=dZ(j);  %obsuniecie maksymalne
                            end
                            
                        end
                        
                        %wyniki ko�cowe
                        sumReturn=sumRa(lastCandle);
                        Calmar=-sumReturn/recordDrawdown;  %wskaznik Calmara
                        disp(['zysk: ', num2str(sumReturn), ...
                            ' paramBLength: ', num2str(paramBLength), ...
                            ' paramBVolLength: ', num2str(paramBVolLength), ...
                            ' paramBBuffer: ', num2str(paramBBuffer), ...
                            ' paramBVolThreshold: ', num2str(paramBVolThreshold), ...
                            ' paramBDuration: ', num2str(paramBDuration), ...
                            ' paramBSL: ', num2str(paramBSL), ...
                            ' Calmar: ', num2str(Calmar) ...
                            ]);
                    end
                end
            end
        end
    end
end

disp(['2ndHalfSumReturn = ', num2str(sumRa(lastCandle))]);
disp(['bestCalmar = ', num2str(bestCalmar)]);
disp(['2ndHalfCalmar = ', num2str(Calmar)]);
disp(['la = ', num2str(la)]); %liczba otwartych pozycji
disp(['bestMa = ', num2str(bestMa)]);
disp(['sharpeRatio = ', num2str(sharpe(sumRa, 0))]);
disp(['bestparamBVolLength = ', num2str(bestparamBVolLength)]);
disp(['bestparamBDuration = ', num2str(bestparamBDuration)]);
disp(['bestparamBBuffer = ', num2str(bestparamBBuffer)]);
disp(['bestparamBVolThreshold = ', num2str(bestparamBVolThreshold)]);
disp(['bestparamBSL = ', num2str(bestparamBSL)]);
sumRa = sumRa(sumRa~=0);
hFig = figure(1);
set(hFig, 'Position', [200 200 640 480])
plot(sumRa)
title(['Zysk skumulowany - strategia: ', mfilename]);
xlabel('Liczba �wiec');
ylabel('Zysk');
set(hFig, 'PaperPositionMode','auto')   %# WYSIWYG
print(hFig,'-dpng', '-r0',mfilename)
disp(['tElapsed', num2str(toc(tStart))]);
