%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training';
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing';
fn_LME       = 'LM_english.mat';
fn_LMF       = 'LM_french.mat';
lm_type      = '';
delta        = 0;
% vocabSize    = 0;
iter         = 15;              % Number of iterations of EM
name         = '10K_AM.mat';
n            = 3;               % The n in n-gram for BLEU scoring
numSentences = 10000;

% Train your language models. This is task 2 which makes use of task 1
LME = lm_train( trainDir, 'e', fn_LME );
LMF = lm_train( trainDir, 'f', fn_LMF );

vocabSize = length(fields(LME.uni));

% Train your alignment model of French, given English 
AMFE = align_ibm1( trainDir, numSentences, iter, name );

% Get french and translated reference lines
fre_lines = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.f', '%s','delimiter','\n');
eng_lines = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.e', '%s','delimiter','\n');
goog_lines = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.google.e', '%s','delimiter','\n');

for i=1:length(fre_lines)
    % Preprocess lines
    fre = preprocess(fre_lines{i}, 'f');
    ref1 = preprocess(eng_lines{i}, 'e');
    ref2 = preprocess(goog_lines{i}, 'e');

    % Decode the test sentence 'fre'
    eng = decode2( fre, LME, AMFE, lm_type, delta, vocabSize );

    % BLEU scoring with 2 ref sentences and prespecified n
    score = bleu( eng, ref1, ref2, n );
    fprintf('Sentence: %s\nN = %d, Score = %5.4f\n', eng, n, score);

end
% [status, result] = unix('')