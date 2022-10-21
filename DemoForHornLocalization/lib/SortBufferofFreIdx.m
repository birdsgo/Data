function [sortmeanbuf,sortcutnum]=SortBufferofFreIdx(BufferofFreIdx,th)
% Function SortBufferofFreIdx
%INPUT
%BufferofFreIdx :Frequency bins of first 6 frames
%sortcutnum :Times of occurrence of each frequency bin in 6 frames
%sortmeanbuf  : Frequency bin of sortcutnum


[sizeBuffer1,sizeBuffer2]=size(BufferofFreIdx);
numZeros=0;
sortFreIdx=0;
for index1=1:sizeBuffer1
    for index2=1:sizeBuffer2
        if BufferofFreIdx(index1,index2)~=0
            numZeros=numZeros+1;
            sortFreIdx=[sortFreIdx;BufferofFreIdx(index1,index2)];
        end
    end
end

sortFreIdx=sort(sortFreIdx); 
cutnum=1;
for indexnumZeros=2:numZeros
    if sortFreIdx(indexnumZeros)-sortFreIdx(indexnumZeros-1)>=th
        cutnum=[cutnum,1];
    else
        cutnum(end)=cutnum(end)+1;
    end
end
meanbuf=zeros(length(cutnum),1);
for indexcutnum=1:length(cutnum)
    cutend=sum(cutnum(1:indexcutnum));
    cutbegin=cutend-cutnum(indexcutnum)+1;
    numbuf=sortFreIdx(cutbegin:cutend);
    meanbuf(indexcutnum)=round(mean(numbuf));
end
[sortcutnum,sortcutnumIdx]=sort(cutnum,'descend');
sortcutnum=sortcutnum';
sortmeanbuf=meanbuf(sortcutnumIdx); 
