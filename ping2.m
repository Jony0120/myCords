function ping2()
text1="故障基準(タイムアウトの連続回数)：";
N=input(text1,"s");
N=str2double(N);
formatSpec="%{yyyyMMddHHmmss}D%C%q";
dat=readtable("ping12.csv","Format",formatSpec);
dat.Var3=str2double(dat.Var3);
address=categories(dat.Var2);
for i=1:height(dat)
    for ii=1:length(address)
        if dat.Var2(i)==address{ii}
            datad{ii}(i,:)=dat(i,:);
        end
    end
end

for ii=1:length(address)
    errorCount=0;
    datad{ii}=rmmissing(datad{ii},"MinNumMissing",2);
    error{ii}=ismissing(datad{ii}.Var3);
    for i=1:height(datad{ii})
        if i==1
            if error{ii}(i)==1
                fin=1;
                errorCount=errorCount+1;
                chainNumber=1;
                errorTime{ii}(errorCount,fin)=datad{ii}.Var1(i);
            end
            
        elseif error{ii}(i)==0 && error{ii}(i-1)==1
            fin=2;
            chain{ii}=chainNumber;
            errorTime{ii}(errorCount,fin)=datad{ii}.Var1(i)-seconds(1);
            if chain{ii}<N
                errorTime{ii}(errorCount,:)=[];
                errorCount=errorCount-1;
            end
        elseif error{ii}(i)==1 && error{ii}(i-1)==0
            fin=1;
            errorCount=errorCount+1;
            chainNumber=1;
            errorTime{ii}(errorCount,fin)=datad{ii}.Var1(i);
        elseif error{ii}(i)==1 && error{ii}(i-1)==1
            chainNumber=chainNumber+1;
        end
        
    end
end

for ii=1:length(address)
    fid=fopen("report2_" + strrep(strrep(address{ii},".","_"),"/","_") + ".csv","w");
    ET{ii}=exceltime(errorTime{ii});
    fprintf(fid,"%s,%s\n", "故障基準", num2str(N) + "以上連続してのタイムアウト");
    fprintf(fid,"%s,%s\n", "start","finish");
    for i=1:size(ET{ii},1)
        fprintf(fid,"%f,%f\n", ET{ii}(i,1),ET{ii}(i,2));
    end
    fclose(fid);
    %dlmwrite("report_" + strrep(strrep(address{ii},".","_"),"/","_") + ".csv",ET{ii},"precision",16);
end
save("ping2");