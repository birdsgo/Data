function [FreIdx_nonzeros]=FindFrePeak_new4(Ybuf_log,Fre_high,Fre_low,FreIdx_extend,th_log1,th_log2,NumFre)
% Function FindFrePeak_new4
%INPUT
%Ybuf_log: Logarithmic power spectrum of Ybuf
% OUTPUT
% FreIdx_nonzeros:Frequency bins found in Ybuf_log
%

mean_Ybuf=mean(Ybuf_log(Fre_low:Fre_high));
FrePeakIdx=zeros(Fre_high-Fre_low+1,1);
for FreIdx=Fre_low+FreIdx_extend+1:Fre_high-FreIdx_extend-1
    if Ybuf_log(FreIdx)>Ybuf_log(FreIdx-1) & Ybuf_log(FreIdx)>Ybuf_log(FreIdx+1) 
        if Ybuf_log(FreIdx)-mean_Ybuf>th_log1 
            if Ybuf_log(FreIdx)-min(Ybuf_log(FreIdx-FreIdx_extend:FreIdx-1)) >th_log2 & Ybuf_log(FreIdx)-min(Ybuf_log(FreIdx+1:FreIdx+FreIdx_extend))>th_log2 %比较大能量的条件
                FrePeakIdx(FreIdx)=1;
            end
        else
            if Ybuf_log(FreIdx)-min(Ybuf_log(FreIdx-FreIdx_extend:FreIdx-1)) >th_log2+5 & Ybuf_log(FreIdx)-min(Ybuf_log(FreIdx+1:FreIdx+FreIdx_extend))>th_log2+5 & Ybuf_log(FreIdx)-mean_Ybuf>th_log1-5
                FrePeakIdx(FreIdx)=1;
            end
        end
    end
end


FreIdx_nonzeros=find(FrePeakIdx==1); 
Buffer=zeros(NumFre,1);
BufferId=zeros(NumFre,1);


Ybuf_log_new2=Ybuf_log;
Ybuf_log_new2(FreIdx_nonzeros)=0;
for i=1:length(FreIdx_nonzeros)
    Ybuf_log_new2(FreIdx_nonzeros(i)-1:FreIdx_nonzeros(i)+1)=0;
end
if length(FreIdx_nonzeros)>NumFre
    Buffer(1:NumFre,1)=Ybuf_log(FreIdx_nonzeros(1:NumFre)); %
    BufferId(1:NumFre,1)=FreIdx_nonzeros(1:NumFre);    %
    for i=NumFre+1:length(FreIdx_nonzeros)
        [val,id]=min(Buffer);
        if Ybuf_log(FreIdx_nonzeros(i))>val
            Buffer(id)=Ybuf_log(FreIdx_nonzeros(i));
            BufferId(id)=FreIdx_nonzeros(i);
        end
    end
    FreIdx_nonzeros=sort(BufferId,'ASCEND');
else
    if sum(FreIdx_nonzeros)>0
        BufferId(1:length(FreIdx_nonzeros))=FreIdx_nonzeros;
    else
        FreIdx_nonzeros=[0];
    end
end



