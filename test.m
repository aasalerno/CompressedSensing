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
    
end