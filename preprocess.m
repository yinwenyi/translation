function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz 

  global CSC401_A2_DEFNS
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % trim whitespaces down 
  inSentence = regexprep( inSentence, '\s+', ' '); 

  % initialize outSentence
  outSentence = inSentence;

  % perform language-agnostic changes
  % 1. end-of-sentence punctuation (? ! .)
  outSentence = regexprep( outSentence, ['(?<!\s)\.+\s' CSC401_A2_DEFNS.SENTEND], ' $0');
  outSentence = regexprep( outSentence, ['(?<!\s)\?+\s' CSC401_A2_DEFNS.SENTEND], ' $0');
  outSentence = regexprep( outSentence, ['(?<!\s)\!+\s' CSC401_A2_DEFNS.SENTEND], ' $0');
  outSentence = regexprep( outSentence, ['(?<!\s)-+\s' CSC401_A2_DEFNS.SENTEND], ' $0');
  % 2. commas
  outSentence = regexprep( outSentence, '(?<!\s),', ' $0');
  % 3. colons and semicolons
  outSentence = regexprep( outSentence, '(?<!\s):', ' $0');
  outSentence = regexprep( outSentence, '(?<!\s);', ' $0');
  % 4. parentheses
  outSentence = regexprep( outSentence, '\((?!\s)', '$0 ');
  outSentence = regexprep( outSentence, '\[(?!\s)', '$0 ');
  outSentence = regexprep( outSentence, '\{(?!\s)', '$0 ');
  outSentence = regexprep( outSentence, '(?<!\s)\)', ' $0');
  outSentence = regexprep( outSentence, '(?<!\s)\]', ' $0');
  outSentence = regexprep( outSentence, '(?<!\s)\}', ' $0');
  % 5. dashes in between parentheses
  outSentence = regexprep( outSentence, '(?<!\()(?<=\w+)-(?=\w+)(?!\))', ' $0 ');
  % 6. math operators:  +, <, >, =
  outSentence = regexprep( outSentence, '(?<=.)+(?=.)', ' $0 ');
  outSentence = regexprep( outSentence, '(?<=.)<(?=.)', ' $0 ');
  outSentence = regexprep( outSentence, '(?<=.)>(?=.)', ' $0 ');
  outSentence = regexprep( outSentence, '(?<=.)=(?=.)', ' $0 ');
  % 7. quotation marks
  outSentence = regexprep( outSentence, '``(?=\w+)', '$0 ');
  outSentence = regexprep( outSentence, '(?<=\w+)['']{2}', ' $0');
  outSentence = regexprep( outSentence, '"(?=\w+)', '$0 ');
  outSentence = regexprep( outSentence, '(?<=\w+)"', ' $0');

  switch language
   case 'e'
    % clitics: 'm, 're, 's, 'd, 'll, 've, 'nt
    outSentence = regexprep( outSentence, '(?<=\w+)''m', ' $0');
    outSentence = regexprep( outSentence, '(?<=\w+)''re', ' $0');
    outSentence = regexprep( outSentence, '(?<=\w+)''s', ' $0');
    outSentence = regexprep( outSentence, '(?<=\w+)''d', ' $0');
    outSentence = regexprep( outSentence, '(?<=\w+)''ll', ' $0');
    outSentence = regexprep( outSentence, '(?<=\w+)''ve', ' $0');
    outSentence = regexprep( outSentence, '(?<=\w+)''nt', ' $0');
    % possessive s'
    outSentence = regexprep( outSentence, '(?<=s)''', ' $0');

   case 'f'
    % 1. separate l'
    outSentence = regexprep( outSentence, 'l''(?=\w+)', '$0 ');
    % separate t', c', m', j', d', n'
    outSentence = regexprep( outSentence, 'c''(?=\w+)', '$0 ');
    outSentence = regexprep( outSentence, 'd''(?=\w+)', '$0 ');
    outSentence = regexprep( outSentence, 'j''(?=\w+)', '$0 ');
    outSentence = regexprep( outSentence, 'm''(?=\w+)', '$0 ');
    outSentence = regexprep( outSentence, 'n''(?=\w+)', '$0 ');
    outSentence = regexprep( outSentence, 't''(?=\w+)', '$0 ');
    % separate qu'
    outSentence = regexprep( outSentence, 'qu''(?=\w+)', '$0 ');
    % puisqu'on and lorsqu'il
    outSentence = regexprep( outSentence, 'puisqu''(?=\w+)', '$0 ');
    outSentence = regexprep( outSentence, 'lorsqu''(?=\w+)', '$0 ');
    % don't separate: d’abord, d’accord, d’ailleurs, d’habitude
    outSentence = regexprep( outSentence, 'd'' abord', 'd''abord');
    outSentence = regexprep( outSentence, 'd'' accord', 'd''accord');
    outSentence = regexprep( outSentence, 'd'' ailleurs', 'd''ailleurs');
    outSentence = regexprep( outSentence, 'd'' habitude', 'd''habitude');

  end

  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );
  
  outSentence = regexprep(outSentence, '\s+', ' ');

