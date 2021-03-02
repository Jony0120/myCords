function ping4()
text1="�̏�(�^�C���A�E�g�̘A����)�F";
text2="�ߕ��׏�Ԃ̊(�w�W�ɂ��钼��ping�f�[�^�̐�)�F";
text3="�ߕ��׏�Ԃ̊(����ping(ms)�̒l)�F";
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
    for i=1:height(datad{ii})
        during=i-m+1;
        if during<=0
            during=1;
        end
        if nanmean(datad{ii}.Var3(during:i))>t
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
errorCount=0;
for i=1:size(error{1})
    bothError=0;
    for ii=1:size(error,2)
        bothError=bothError+error{ii}(i);
    end
    BE(i)=bothError==size(error,2);
    if i==1
        if BE(i)==1
            fin=1;
            errorCount=errorCount+1;
            chainNumber=1;
            bothErrorTime(errorCount,fin)=datad{1}.Var1(i);
        end
    elseif BE(i)==0 && BE(i-1)==1
        fin=2;
        chain{1}=chainNumber;
        bothErrorTime(errorCount,fin)=datad{1}.Var1(i)-seconds(1);
        if chain{1}<N
            bothErrorTime(errorCount,:)=[];
            errorCount=errorCount-1;
        end
    elseif BE(i)==1 && BE(i-1)==0
        fin=1;
        errorCount=errorCount+1;
        chainNumber=1;
        bothErrorTime(errorCount,fin)=datad{1}.Var1(i);
    elseif BE(i)==1 && BE(i-1)==1
        chainNumber=chainNumber+1;
    end
end
save("ping4");
for ii=1:length(address)
    %fid=fopen("report3_" + strrep(strrep(address{ii},".","_"),"/","_") + ".csv","w");
    ET{ii}=exceltime(errorTime{ii});
    OT{ii}=exceltime(overTime{ii});
    BT=exceltime(bothErrorTime);
end
for ii=1:length(address)
    fid=fopen("report4_" + strrep(strrep(address{ii},".","_"),"/","_") + ".csv","w");
    fprintf(fid,"%s,%s\n", "�̏�", num2str(N) + "��ȏ�A�����Ẵ^�C���A�E�g");
    fprintf(fid,"%s,%s\n", "start","finish");
    for i=1:size(ET{ii},1)
        fprintf(fid,"%f,%f\n", ET{ii}(i,1),ET{ii}(i,2));
    end
    fprintf(fid,"%s,%s\n", "�ߕ��׏�Ԃ̊", "����" + num2str(m) + "��̉������Ԃ�" + num2str(t) + "�~���b�ȏ�̎�");
    fprintf(fid,"%s,%s\n", "start","finish");
    for i=1:size(OT{ii},1)
        fprintf(fid,"%f,%f\n", OT{ii}(i,1),OT{ii}(i,2));
    end
    fprintf(fid,"%s\n", "���L���Ԃ̓T�[�o�[�̌̏�ł͂Ȃ��T�u�l�b�g�X�C�b�`�̌̏Ⴊ�l������");
    fprintf(fid,"%s,%s\n", "start","finish");
    for i=1:size(BT)
        fprintf(fid,"%f,%f\n", BT(i,1),BT(i,2));
    end
    fclose(fid);
end
save("ping4");