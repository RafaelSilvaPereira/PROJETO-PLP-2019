:- [literal].

% --------------------------- INTERFACE COM USUARIO

% Funcao inicial que sera chamada no main, executa o meu de opcoes.
truth_table_generator() :-
    tty_clear,
    writeln(" --------------GERADOR DE TABELA VERDADE-------------------"),
    options_menu().

% Menu de opcoes, recebe a opcao e executa o executor das funcoes.
options_menu() :-
    writeln("\n Escolha sua opcao! (0, 1, 2 ou 3)"),
    writeln(" 0. Retornar ao Menu."), 
    writeln(" 1. Qual o objetivo do gerador de Tabela Verdade?"),
    writeln(" 2. Tutorial como funciona o literal (util para criar a expressao)."),
    writeln(" 3. Gerar a tabela verdade de uma expressao.\n"),
    str_input(Op),
    string_to_atom(Op,Option),
    choose_option(Option).

% Executa a funcao com base na opcao escolhida.
choose_option(Op) :-
    (Op == '0'),
    writeln("\n Volte sempre!"),
    writeln(" -----------------------------------------------------------");
    (Op == '1'),
    explain_table();
    (Op == '2'),
    explain_literal();
    (Op == '3'),
    create_table;
    writeln("\n Opcao invalida!"),
    writeln(" -----------------------------------------------------------"),
    options_menu().

% Mostra um texto explicativo sobre tabela verdade.
explain_table() :-
    tty_clear,
    writeln("\n ---------------------TABELA VERDADE------------------------"),
    writeln("\n Tabela verdade eh um dispositivo utilizado no estudo da logica."),
    writeln(" Com o uso desta tabela eh possível definir o valor logico de uma expressao,"),
    writeln(" ou seja, saber quando uma sentenca eh verdadeira ou falsa.\n"),
    writeln(" Quanto mais variaveis fizerem parte da expressao, maior o numero de linhas, que eh obtido por (2 ^ n),"),
    writeln(" onde n eh o numero de variaveis."),
    writeln(" Eh simples fazer manualmente uma tabela com duas variaveis, e ate tres."),
    writeln(" Mas quanto mais adicionamos variaveis a expressao, o numero de linhas fica exponencialmente maior.\n"),
    writeln(" O objetivo dessa parte do programa eh justamente facilitar a construcao da tabela de qualquer expressao,"),
    writeln(" Nao importando o numero de variaveis.\n"),
    writeln(" -----------------------------------------------------------"),
    options_menu().

% Mostra um texto explicativo sobre o literal.
explain_literal() :-
    tty_clear,
    writeln("\n ---------------------LITERAL TUTORIAL----------------------"),
    writeln("\n Um literal pode ser uma expressao ou uma proposicao.\nUma expressao eh formada por:"),
    writeln(" - Um operador unario (~, ) para dizer se o valor da expressao eh negado;"),
    writeln(" - Um valor A: esse valor pode ser uma outra expressao ou uma simples proposicao;"),
    writeln(" - Um operador binario (&,|,*,#), que serve para dizer se a expressao eh uma conjuncao, uma disjuncao, uma implicacao ou uma bi-implicacao;"),
    writeln(" - Um valor B: esse valor pode ser uma outra expressao ou uma simples proposicao;\n"), 
    writeln(" Uma proposicao eh formada por:"),
    writeln(" - Um operador unario (~, ) para dizer se o valor da proposicao eh negado;"),
    writeln(" - Um valor: esse valor eh obrigatoriamente uma string, que no caso, vai ser a letra que representa a proposicao."),
    writeln(" Agora que ja sabemos como eh formado um literal, podemos criar um a seguir:\n"),
    writeln(" -----------------------------------------------------------"),
    options_menu().

% Cria o literal, gera a tabela verdade e exibe.
create_table() :-
    tty_clear,
    writeln("\n -----------------------------------------------------------"),
    writeln("\n Primeiro monte o literal (expressao) que sera usado para obtencao da tabela\n"),
    verifyEntryAndCreatesANewLiteral(Literal),

    tty_clear,
    writeln("\n Essa eh a tabela verdade da expressao:\n"),
    writeln(" ---------------------TABELA VERDADE------------------------\n"),
    get_table(Literal,Table),
    writeln(Table),
    writeln(" -----------------------------------------------------------\n"),
    options_menu().

% --------------------------- AUXILIARES

% Not logico.
negate(Value,Return) :-
    Value, Return = false;
    Return = true.

% And logico.
and(A,B,Return) :-
    A,B,Return = true; Return = false.

% Or logico.
or(A,B,Return) :-
    (A;B),Return = true; Return = false.

% Implicacao logica.
implication(A,B,Return) :-
    (\+A;B),Return = true; Return = false.

% Dupla implicacao logica.
xor(A,B,Return) :-
    (A,B;\+A,\+B),Return = true; Return = false.

% --------------------------- OBTENCAO DAS PROPOSICOES

% Verifica se determinado atomo eh uma proposicao.
is_proposition(Atom,Return) :-
    Ignore = ["(",")","&","|","*","#","-",">","<"," ","~"],
    atom_string(Atom, String),
    
    (member(String,Ignore)) -> Return = false; Return = true.
    
% Remove elementos repetidos de uma lista.
remove_repetitions([],_,[]).
remove_repetitions([H|T],Aux,Return) :-
    (member(H,Aux)) ->
    remove_repetitions(T,Aux,R1),
    Return = R1;
    append([H],Aux,Aux2),
    remove_repetitions(T,Aux2,R2),
    append([H],R2,R3),
    Return = R3.

% Obtem as proposicoes de uma determinada expressao.
get_propositions_aux([],Return) :- Return = [].
get_propositions_aux([H|T],Return) :-
    is_proposition(H,Proposicao),
    (Proposicao) -> get_propositions_aux(T,R),
    append([H],R,R2),
    Return = R2;
    get_propositions_aux(T,R),
    Return = R.

% Invoca a funcao que procura as proposicoes de forma correta.
get_propositions(Expression,Return) :-
    string_chars(Expression,List),
    get_propositions_aux(List,R),
    remove_repetitions(R,[],R2),
    Return = R2.

% --------------------------- OBTENCAO DA TABELA DE POSSIBILIDADES

% Transforma um decimal em binario
dec_bin(0,'0').
dec_bin(1,'1').
dec_bin(N,B) :-
    N > 1,
    X is N mod 2,
    Y is N//2,
    dec_bin(Y,B1),
    atom_concat(B1, X, B).

% Retorna o tamanho de um atomo.
len(Atom,Return) :-
    atom_chars(Atom,List),
    length(List,Len),
    Return = Len.

% Completa um binario baseado em um numero de casas.
complete_bin(Bin,Size,Return) :-
    len(Bin,Len),
    (Len =:= Size),
    Return = Bin;
    atom_concat('0',Bin,B2),
    complete_bin(B2,Size,R2),
    Return = R2.

% Obtem a tabela de possibilidades.
get_possibilities_aux(0,Fix,Return) :- 
    complete_bin('0',Fix,Bin),
    Return = [Bin].
get_possibilities_aux(Size,Fix,Return) :-
    NewSize is Size - 1,
    dec_bin(Size,R),
    get_possibilities_aux(NewSize,Fix,R2),
    complete_bin(R,Fix,B2),
    append(R2,[B2],R3),
    Return = R3.

% Invoca a funcao de obtencao da tabela de possibilidades de maneira correta.
get_possibilities(Expression,Return) :-
    get_propositions(Expression,Prop),
    length(Prop,Number),
    Lines is (2 ^ Number) - 1,
    get_possibilities_aux(Lines,Number,R),
    Return = R.

% --------------------------- OBTENCAO DO VALOR DE UMA PROPOSICAO

% Obtem a posicao de uma proposicao na lista de proposicoes.
get_proposition_position(Prop,[H|T],Return) :-
    (Prop == H) -> Return is 0;
    get_proposition_position(Prop,T,R2),
    R3 is 1 + R2,
    Return = R3.
    
% Obtem o valor de uma proposicao em determinado momento.
get_proposition_value(Prop,List,Poss,Return) :-
    get_proposition_position(Prop,List,Position),
    nth0(Position,Poss,Value),
    Return = Value.

% Verifica o operador unario e inverte, se preciso.
check_unary_operator(Value,Operator,Return) :-
    (Operator == "~") ->
    negate(Value,V),
    Return = V;
    Return = Value.

% Obtem o valor do literal para cada linha de interpretacao.
result(proposition(UnOp,Prop),List,Poss,Return) :- 
    get_proposition_value(Prop,List,Poss,R1),
    check_unary_operator(R1,UnOp,R2),
    Return = R2.
result(expression(UnOp,V1,BinOp,V2),List,Poss,Return) :-
    (BinOp == '&') ->
    result(V1,List,Poss,A),
    result(V2,List,Poss,B),
    and(A,B,AB),
    check_unary_operator(AB,UnOp,R1),
    Return = R1;
    (BinOp == '|') ->
    result(V1,List,Poss,C),
    result(V2,List,Poss,D),
    or(C,D,CD),
    check_unary_operator(CD,UnOp,R2),
    Return = R2;
    (BinOp == '*') ->
    result(V1,List,Poss,E),
    result(V2,List,Poss,F),
    implication(E,F,EF),
    check_unary_operator(EF,UnOp,R3),
    Return = R3;
    (BinOp == '#') ->
    result(V1,List,Poss,G),
    result(V2,List,Poss,H),
    xor(G,H,GH),
    check_unary_operator(GH,UnOp,R4),
    Return = R4.

% Transforma um boolean em string.
rest_to_string(true, Return) :- Return = "1".
rest_to_string(false,Return) :- Return = "0".

% Transforma uma lista de atomos em uma lista de booleans.
boolean_list([],[]).
boolean_list([H|T],Return) :-
    (H == '1') ->
    A = [true],
    boolean_list(T,R1),
    append(A,R1,R2),
    Return = R2;
    B = [false],
    boolean_list(T,R1),
    append(B,R1,R2),
    Return = R2.

% --------------------------- MONTAGEM DA TABELA

% Monta a primeira linha da tabela.
first_line([],Exp,Return) :-
    concat("| ",Exp,R), Return = R.
first_line([H|T],Exp,Return) :-
    concat(H," ",R),
    first_line(T,Exp,R2),
    concat(R,R2,R3),
    Return = R3.

% Monta uma linha da tabela.
get_line([],Value,Prop,Literal,Return) :-
    result(Literal,Prop,Value,R1),
    rest_to_string(R1,R2),
    concat(" | ",R2,R3),
    Return = R3.
get_line([H|T],Value,Prop,Literal,Return) :-
    concat(" ",H,R1),
    get_line(T,Value,Prop,Literal,R2),
    concat(R1,R2,R3),
    Return = R3.

% Junta as linhas de interpretacao da tabela.
get_every_line([], _, _, "").
get_every_line([H|T],Prop,Literal,Return) :-
    atom_chars(H,H2),
    boolean_list(H2,H3),
    get_line(H2,H3,Prop,Literal,R1),
    concat(R1,"\n",R2),
    get_every_line(T,Prop,Literal,R3),
    concat(R2,R3,R4),
    Return = R4.

% Junta todas linhas da tabela.
mount_table(Interpretations,Propositions,Literal,Return) :-
    literalsToString(Literal,Expression),
    first_line(Propositions,Expression,First),
    concat(" ",First,F1),
    concat(F1,"\n",F2),
    get_every_line(Interpretations,Propositions,Literal,R1),
    concat(F2,R1,R2),
    Return = R2.

% Gera a tabela verdade da expressao passada.
get_table(Literal,Return) :-
    literalsToString(Literal,Expression),
    get_possibilities(Expression,Interpretations),
    get_propositions(Expression,Propositions),
    mount_table(Interpretations,Propositions,Literal,R1),
    Return = R1.