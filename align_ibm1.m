
function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);

  % Iterate between E and M steps
  for iter=1:maxIter,
    AM = em_step(AM, eng, fre);
  end

  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end





% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
  eng = {};
  fre = {};

  eng_dir = dir( [ mydir, filesep, 'hansard*', 'e'] );
  
  % Keep counter to index main cell arrays
  i = 1;
  
  for iFile=1:length(eng_dir)
      % Find matching french file
      fre_file = regexprep(eng_dir(iFile).name, '\.e$', '.f');
      % If matching french file doesn't exist, move on
      if exist([mydir, filesep, fre_file], 'file') ~= 2
          continue
      end
      % Read all lines in each file
      eng_lines = textread([mydir, filesep, eng_dir(iFile).name], '%s','delimiter','\n');
      fre_lines = textread([mydir, filesep, fre_file], '%s','delimiter','\n');
      
      % Process all lines in pair of files
      for l=1:length(eng_lines)
          eng{i} = strsplit(' ', preprocess(eng_lines{l}, 'e'));
          fre{i} = strsplit(' ', preprocess(fre_lines{l}, 'f'));
          i = i + 1;
          % Stop after reading numSentences
          if i > numSentences
              return
          end
      end   
  end
  
  return
end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = struct(); % AM.(english_word).(foreign_word)
    
    for i=1:length(eng)
        % Loop through all sentences, ignore start and end tokens
        for j=2:length(eng{i})-1
            % Create field for english word if needed
            if isfield(AM, eng{i}{j}) == 0
                AM.(eng{i}{j}) = {};
            end
            % Now loop over all french words in matching sentence
            for k=2:length(fre{i})-1
                % Create field for french word if needed
                % Will adjust probabilities later, for now set to 1
                if isfield(AM.(eng{i}{j}), fre{i}{k}) == 0
                    AM.(eng{i}{j}).(fre{i}{k}) = 1;
                end
            end
        end
    end
    
    % Adjust probabilities
    f = fieldnames(AM);
    for i=1:length(f)
        prob = 1 / length(fieldnames(AM.(f{i})));
        % Setting all fields to same value at once
        AM.(f{i}) = structfun(@(x) (prob), AM.(f{i}), 'UniformOutput', false);
    end
    % Force start and stop tokens to have probability 1
    AM.SENTSTART.SENTSTART = 1;
    AM.SENTEND.SENTEND = 1;
    
    return
end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
  % Set tcount(f, e) = 0 for all f, e
  tcount = struct();
  % Set total(e) = 0 for all e
  total = struct();
  
  % Loop over all sentence pairs
  for i=1:length(eng)
      % Get unique french words f in F, ignoring start and stop tokens
      f = unique(fre{i}(2:length(fre{i})-1));
      count_f = cellfun(@(x) sum(ismember(f,x)), f);
      % For each unique french word F
      for j=1:length(f)
          denom_c = 0;
          % Get unique english words e in E
          e = unique(eng{i}(2:length(eng{i})-1));
          count_e = cellfun(@(x) sum(ismember(e,x)), e);
          % Calculate denominator
          for k=1:length(e)
              denom_c = denom_c + t.(e{k}).(f{j}) * count_f(j);
          end
          % Compute equation for each english word e
          for k=1:length(e)
              if isfield(tcount, e{k}) == 0
                  tcount.(e{k}) = struct();
              end
              if isfield(tcount.(e{k}), f{j}) == 0
                  tcount.(e{k}).(f{j}) = 0;
              end
              if isfield(total, e{k}) == 0
                  total.(e{k}) = 0;
              end
              tcount.(e{k}).(f{j}) = tcount.(e{k}).(f{j}) + t.(e{k}).(f{j}) * count_f(j) * count_e(k) / denom_c;
              total.(e{k}) = total.(e{k}) + t.(e{k}).(f{j}) * count_f(j) * count_e(k) / denom_c;
          end
      end
  end
  
  % For each e in domain(total)
  fields_e = fieldnames(total);
  for l=1:length(fields_e)
     total_e = total.(fields_e{l});
     % For each f in domain(tcount[all; e])
     fields_f = fieldnames(tcount.(fields_e{l}));
     for m=1:length(fields_f)
         % Recompute probability
         t.(fields_e{l}).(fields_f{m}) = tcount.(fields_e{l}).(fields_f{m}) / total_e;
     end
  end
  
end


