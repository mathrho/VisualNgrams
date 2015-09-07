function cmpval=PAScmprecords(a,b)
% Returns 1 if record a == record b otherwise 0

cmpval=strcmp(a.imgname,b.imgname) & ...
    strcmp(a.database,b.database) & ...
    all(a.imgsize==b.imgsize) & ...
    (length(a.objects)==length(b.objects));
if cmpval
    for i=1:length(a.objects)
        cmpval=cmpval & ...
            strcmp(char(a.objects(i).label),char(b.objects(i).label)) & ...
            strcmp(char(a.objects(i).mask),char(b.objects(i).mask)) & ...
            all(a.objects(i).bbox==b.objects(i).bbox) & ...
            (length(a.objects(i).polygon)==length(b.objects(i).polygon)) & ...
            (length(a.objects(i).orglabel)==length(b.objects(i).orglabel));
        if (cmpval && (length(a.objects(i).polygon)>0)),
            cmpval=all(a.objects(i).polygon==b.objects(i).polygon);
        end;
        if (cmpval && (length(a.objects(i).orglabel)>0)),
            cmpval=strcmp(char(a.objects(i).orglabel),char(b.objects(i).orglabel));
        end;
    end;
end;
return
