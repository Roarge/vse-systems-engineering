// Backslash escapes inside a string are honoured. The escaped quote in
// US_201 does not end its string. Read as a closing quote, it would
// leave a stray quote at the end of the line, and the string that opens
// there would hide US_202. The escaped backslash at the end of the
// benefit does not escape the closing quote, so that string ends there.
// Braces inside strings and comments do not count towards the matching
// closing brace.
package StringEscapeFixture {
    private import VSE_Library::*;

    requirement US_201_QuoteInString : UserStory {
        attribute :>> capability = "print a lone \" quote and a closing brace } on the console";
        attribute :>> benefit    = "the path ends in a backslash \\";
        // a brace in a line comment }
        /* a brace in a block comment } */
    }

    requirement US_202_AfterEscapes : UserStory {
        attribute :>> capability = "an opening brace { inside a string";
    }
}
