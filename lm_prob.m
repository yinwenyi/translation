function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  end
  if (isempty(type))
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  elseif strcmp(type, 'smooth')
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  else
    disp( 'type must be either '''' or ''smooth''' );
    return;
  end

  words = strsplit(' ', sentence);

  % TODO: the student implements the following
  
  % Initialize return value
  logProb = 0;
  
  % if type is missing or empty, return MLE of sentence
  % MLE is just the product of P(wi | wi-1) for all i
  % P(wi | wi-1) = Count(wi-1 + wi) / Count(wi-1)
  % if type is 'smooth', do delta smoothing MLE of sentence
  
  for k=2:length(words)
      curr = words{k};
      prev = words{k-1};
      
      % Unigram count
      if isfield(LM.uni, curr)
          uni = LM.uni.(curr) + delta*vocabSize;
      else
          uni = delta*vocabSize;
      end
      % Bigram count
      if (isfield(LM.bi, prev))&&(isfield(LM.bi.(prev), curr))
          bi = LM.bi.(prev).(curr) + delta;
      else
          bi = delta;
      end
      
      % Update the MLE
      if (uni == 0) || (bi == 0) % zero or div-by-zero case
        logProb = log2(0);
        return
      else
        logProb = logProb + log2(bi / uni);
      end
  end
  
  % TODO: once upon a time there was a curmudgeonly orangutan named Jub-Jub.
return