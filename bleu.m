function score = bleu( candidate, reference1, reference2, n )
%BLEU Returns the BLEU score for a translated sentence.
%   According to this formula:
%   BLEU = BPC × (p1p2 . . . pn)^(1/n)
%   Where pn is the n-gram precision.
%
%   candidate : str
%   reference1: str
%   reference2: str
%   n         : int
%   score     : float

    candidate = strsplit(' ', candidate);
    ref1 = strsplit(' ', reference1);
    ref2 = strsplit(' ', reference2);
    
    % Get precision for each value of n
    % Only supports up to n=3
    precision = [0 0 0];
    for i=1:n
        C = 0;
        if i == 1
            N = length(candidate);
            for j=1:N
                word = candidate{j};
                find1 = ~isempty(find(ismember(ref1, word), 1));
                find2 = ~isempty(find(ismember(ref2, word), 1));
                if (find1 || find2)
                    C = C + 1;
                end
            end
            precision(i) = C / N;
        
        elseif i == 2
            N = length(candidate) - 1;
            for j=1:N
                word1 = candidate{j};
                word2 = candidate{j+1};
                find1 = find(ismember(ref1, word2), 1) - find(ismember(ref1, word1), 1);
                find2 = find(ismember(ref2, word2), 1) - find(ismember(ref2, word1), 1);
                if (~isempty(find1) && (find1 == 1)) || (~isempty(find2) && (find2 == 1))
                    C = C + 1;
                end
            end
            precision(i) = C / N;
        
        elseif i == 3
            N = length(candidate) - 2;
            for j=1:N
                word1 = candidate{j};
                word2 = candidate{j+1};
                word3 = candidate{j+2};
                find1 = find(ismember(ref1, word2), 1) - find(ismember(ref1, word1), 1);
                find1_1 = find(ismember(ref1, word3), 1) - find(ismember(ref1, word1), 1);
                find2 = find(ismember(ref2, word2), 1) - find(ismember(ref2, word1), 1);
                find2_1 = find(ismember(ref2, word3), 1) - find(ismember(ref2, word1), 1);
                if ((~isempty(find1)) && (~isempty(find1_1)) && (find1 == 1) && (find1_1 == 2))
                    C = C + 1;
                elseif ((~isempty(find2)) && (~isempty(find2_1)) && (find2 == 1) && (find2_1 == 2))
                    C = C + 1;
                end
            end
            precision(i) = C / N;
        end
    end
    
    % Now calculate brevity
    len1 = length(ref1);
    len2 = length(ref2);
    
    diff1 = abs(len1 - length(candidate));
    diff2 = abs(len2 - length(candidate));
    if diff1 < diff2
        closest = len1;
    else
        closest = len2;
    end
    
    brevity = closest / length(candidate);
    if brevity < 1
        bp = 1;
    else
        bp = exp(1-brevity);
    end
    
    % Calculate score
    score = 1;
    for i=1:n
        score = score * precision(i);
    end
    score = score ^ (1/n);
    score = score * bp;
    
    return
end

