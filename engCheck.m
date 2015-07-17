dirs = load('GradientVectorMag.txt');

r = zeros(30);
for i = 1:30
    if dirs(i,3) < 0
        dirs(i,:) = -dirs(i,:);
    end
end

for i = 1:30
    for j = 1:30
        r(i,j) = sqrt(sum((dirs(i,:)-dirs(j,:)).^2));
        r(i,j) = min(sqrt(sum((-dirs(i,:)-dirs(j,:)).^2)),r(i,j));
    end
end

nums = nchoosek(30,7);
eng = zeros(1,nums);
vecs = zeros(7,nums);
counter = 0;
%maxcnt = factorial(30)/factorial(23);
maxcnt = 0;
cnt = 0;
for a = 1:24
    a
    %cnt = 0;
    for b = a+1:25
        eng1 = 1./r(a,b);
        for c = b+1:26
            eng2 = eng1 + 1./r(a,c) + 1./r(b,c);
            for d = c+1:27
                eng3 = eng2 + 1./r(a,d) + 1./r(b,d) + 1./r(c,d);
                for e = d+1:28
                    eng4 = eng3 + 1./r(a,e) + 1./r(b,e) + 1./r(c,e) + 1./r(d,e);
                    for f = e+1:29
                        eng5 = eng4 + 1./r(a,f) + 1./r(b,f) + 1./r(c,f) + 1./r(d,f) + 1./r(e,f);
                        for g = f+1:30
                            counter = counter + 1;
                            if mod(counter/maxcnt,.1) < mod((counter-1)/maxcnt,.1)
                                disp([num2str(counter/maxcnt*100) '%'])
                            end
                            if all(diff(sort([a b c d e f g])))
                                cnt = cnt + 1;
                                if cnt > maxcnt
                                    maxcnt = cnt;
                                end
                                eng(cnt) = eng5 + 1./r(a,g) + 1./r(b,g) + 1./r(c,g) + 1./r(d,g) + 1./r(e,g) + 1./r(f,g);
                                vecs(:,cnt) = [a b c d e f g]';
                            end
                        end
                    end
                end
            end
        end
    end
end
% ---------------------------------------
% Save point
% ---------------------------------------
% Sort and keep indicies, then flip for smallest values
[eng,ind] = sort(eng);
vecsind=vecs(:,ind);

scns = 5;

locs = zeros(30,scns);
vecsMin = zeros(7,30*scns);


for i = 1:30
    [~,locs(i,:)] = find(vecsind==i,scns);
    vecsMin(:,scns*(i-1)+1:scns*(i)) = vecsind(:,locs(i,:));
end

vecsMin = unique(vecsMin','rows');

amts = zeros(1,30);

for i = 1:30
    amts(i) = numel(vecsMin(vecsMin==i));
end

[cts,srt] = sort(amts);
srthold = srt;
qEng = quantile(eng,4);

while cts(end)/cts(1) >= 1.1
    
    [~,indx] = ismember(sort(srt(1:7)),vecsind','rows');
    
    if eng(indx) < qEng(2)
        vecsMin(end+1,:) = sort(srt(1:7));
    else
        [~,indx] = ismember(sort(srt([1:6,8])),vecsind','rows');
        if eng(indx) < qEng(2)
            vecsMin(end+1,:) = sort(srt([1:6,8]));
        else
            while eng(indx) >= qEng(2)
                arr = [];
                while length(arr) ~= 7
                    st = ceil(25*rand(1));
                    if ~any(arr==st)
                        arr(end+1) = st;
                    end
                end
                [~,indx] = ismember(sort(srt(arr)),vecsind','rows');
            end
            vecsMin(end+1,:) = sort(srt(arr));
        end
    end
    
    for i = 1:30
        amts(i) = numel(vecsMin(vecsMin==i));
    end
    
    [cts,srt] = sort(amts);
    %srthold = srthold(srt);
end
for i = 1:30
    amts(i) = numel(vecsMin(vecsMin==i));
end