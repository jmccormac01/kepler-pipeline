grammar FsQuery;

/*
 This is an ANTLR 3.0 compatible grammar.
 
 The parser rules are divided into path and name rules.  These are there in
 order to allow the query interpreter to know when the path part of the FsId
 matches, but not the name part.
 
 Copyright 2017 United States Government as represented by the
 Administrator of the National Aeronautics and Space Administration.
 All Rights Reserved.
 
 This file is available under the terms of the NASA Open Source Agreement
 (NOSA). You should have received a copy of this agreement with the
 Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 
 No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 AND DISTRIBUTES IT "AS IS."

 Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 TERMINATION OF THIS AGREEMENT.
*/


options { 
    output = AST;
    backtrack = true;
}

tokens {
    AND;
    OR;
    NAMEMATCH;
    PATHMATCH;
    I_INTERVAL;
    D_INTERVAL;
    PATH;
    STR_TOKEN; //used by Java implementation
    SPECIAL;
    DATA_TYPE;
}

@lexer::header {
package gov.nasa.kepler.fs.query;
}

@header {
package gov.nasa.kepler.fs.query;
//This file is automatically generated from fsquery.g
}

@members {

@Override
public void emitErrorMessage(String message) {
}

@Override
public void displayRecognitionError(String[] tokenNames,
                                        RecognitionException e) {
    
}
    
}

@rulecatch {
catch (RecognitionException re) {
    throw re;
}
}


//--------------- Parser Rules --------------------
fsQuery : dataType '@' pathExpr nameExpr -> ^(AND ^(PATH pathExpr) nameExpr dataType);

dataType: AllowedChar+ -> ^(DATA_TYPE AllowedChar+);

pathExpr: PathSep pathFragment+ -> ^(AND PathSep pathFragment+);

pathFragment:  pathSomething+ PathSep -> ^(AND pathSomething+ PathSep);
pathSomething
	:	(pathLiteral | constraintExpr);
	
nameExpr: ( nameLiteral | constraintExpr )+;

special: AnyDigits -> ^(SPECIAL AnyDigits)
          | AnyCadence -> ^(SPECIAL AnyCadence)
          | Any -> ^(SPECIAL Any);

nameLiteral
    : DoubleToken -> ^(NAMEMATCH DoubleToken)
    | IntegerToken -> ^(NAMEMATCH IntegerToken)
    | special
    | AllowedChar -> ^(NAMEMATCH AllowedChar)
    | Dash -> ^(NAMEMATCH Dash)
    | Plus -> ^(NAMEMATCH Plus);
   

pathLiteral
    : DoubleToken -> ^(PATHMATCH DoubleToken)
    | IntegerToken -> ^(PATHMATCH IntegerToken)
    | special
    | AllowedChar -> ^(PATHMATCH AllowedChar)
    | Dash -> ^(NAMEMATCH Dash)
    | Plus -> ^(NAMEMATCH Plus);

constraintExpr: ConstraintStart! (numericalExpr | enumExpr) ConstraintEnd!;

enumExpr: enumPart (',' enumPart)* ->  ^(OR  enumPart+ );

enumPart: nameLiteral+ -> ^(AND nameLiteral+);

numericalExpr: numericalConstraint (',' numericalConstraint)* ->  ^(OR numericalConstraint+);

numericalConstraint
    : start=IntegerToken Dash end=IntegerToken -> ^(I_INTERVAL $start $end)
    | start=DoubleToken Dash end=DoubleToken -> ^(D_INTERVAL $start $end)
    ;
    


// -------------- Lexer Rules ---------------------


AnyDigits: EscapeChar 'd';

AnyCadence: EscapeChar 'c';

Any: '*';

AllowedChar : 'a'..'z' |  'A'..'Z' |  '@' |  '_'  | ':' | '.';

Dash:  '-';
Plus: '+';

IntegerToken: '0'..'9'+;

DoubleToken
      : '.' '0'..'9'+ | '0'..'9'+ '.' | '0'..'9'+ '.' '0'..'9'+  //Fixed format
     | '0'..'9'? '.' '0'..'9'+ ('e' | 'E') (Plus | Dash ) ? '0'..'9'+ //Exponent format
      ;

ConstraintStart:'[';
ConstraintEnd:']';

PathSep: '/';

EscapeChar: '\u005C'; // The backslash char.

