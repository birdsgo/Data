function  Plot_results(xEst, yEst,x_true,y_true,x)
[n_src] = size(x_true,2);
s=14; %字体
N=1024; %帧长
t=(1:length(xEst))*0.032;
figure
for i = 1 : n_src
subplot(2,n_src,(i-1)*2+1)
plot(t,xEst(i,:),'r*'); %x轴坐标
hold on
y0(1:length(t)) = x_true(i);
plot(t,y0,'r-')
hold on
plot(t,yEst(i,:),'b*'); %y轴坐标
hold on
y0(1:length(t)) = y_true(i);
plot(t,y0,'b-')
set(gca,'FontName','Times New Roman','FontSize',s);
xlabel('\fontname{Times New Roman} Time \fontname{Times New Roman}[Sec]','FontSize',s);
ylabel('\fontname{Times New Roman} Coordinates \fontname{Times New Roman}[m]','FontSize',s);
axis([0 t(length(t)) 0 55])
subplot(2,n_src,i*2)
set(gca,'FontSize',s);
[S,F,T,P] = spectrogram(x(:,1).'*100,N,N*0.5,N,16000);
F=F(1:length(F/2));
P=P(1:length(F),:);
P = 10*log10(P);
imagesc(T,F,P,[-100,0]);
axis xy;colormap(jet);
hold on
set(gca,'FontName','Times New Roman','FontSize',s);
xlabel('\fontname{Times New Roman} Time \fontname{Times New Roman}[Sec]','FontSize',s);
ylabel('\fontname{Times New Roman} Frequency \fontname{Times New Roman}[kHz]','FontSize',s);
axis([0 t(length(t)) 0 8000])
set(gca,'YTicklabel',0:2:8)
end;

