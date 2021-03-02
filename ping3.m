function ping3()
text1="故障基準(タイムアウトの連続回数)：";
text2="過負荷状態の基準(指標にする直近pingデータの数)：";
text3="過負荷状態の基準(平均ping(ms)の値)：";
N=input(text1,"s");
m=input(text2,"s");
t=input(text3,"s");
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
    overCount=0;
    datad{ii}=rmmissing(datad{ii},"MinNumMissing",2);
    error{ii}=ismissing(datad{ii}.Var3);
    save("ping3");
    for i=1:height(datad{ii})
        during=i-m+1;
        if during<=0 
            during=1;
        end
        if nanmean(datad{ii}.Var3(during:i))>t
            overload{ii}(i)=1;
        elseif isnan(nanmean(datad{ii}.Var3(during:i)))
            overload{ii}(i)=1;
        else
            overload{ii}(i)=0;
        end
    end
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
        if i==1
            if overload{ii}(i)==1
                fin=1;
                overCount=overCount+1;
                overTime{ii}(overCount,fin)=datad{ii}.Var1(i);
            end
        elseif overload{ii}(i)==0 && overload{ii}(i-1)==1
            fin=2;
            overTime{ii}(overCount,fin)=datad{ii}.Var1(i)-seconds(1);
        elseif overload{ii}(i)==1 && overload{ii}(i-1)==0
            fin=1;
            overCount=overCount+1;
            overTime{ii}(overCount,fin)=datad{ii}.Var1(i);
        end
        
    end
end
save("ping3");
for ii=1:length(address)
    fid=fopen("report3_" + strrep(strrep(address{ii},".","_"),"/","_") + ".csv","w");
    ET{ii}=exceltime(errorTime{ii});
    OT{ii}=exceltime(overTime{ii});
    fprintf(fid,"%s,%s\n", "故障基準", num2str(N) + "回以上連続してのタイムアウト");
    fprintf(fid,"%s,%s\n", "start","finish");
    for i=1:size(ET{ii},1)
        fprintf(fid,"%f,%f\n", ET{ii}(i,1),ET{ii}(i,2));
    end
    fprintf(fid,"%s,%s\n", "過負荷状態の基準", "直近" + num2str(m) + "回の応答時間が" + num2str(t) + "ミリ秒以上の時");
    fprintf(fid,"%s,%s\n", "start","finish");
    for i=1:size(OT{ii},1)
        fprintf(fid,"%f,%f\n", OT{ii}(i,1),OT{ii}(i,2));
    end
    fclose(fid);
    %dlmwrite("report_" + strrep(strrep(address{ii},".","_"),"/","_") + ".csv",ET{ii},"precision",16);
end
save("ping3");