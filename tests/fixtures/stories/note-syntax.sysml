// A KerML note opens with //* and closes with */, and it may span
// lines. The scanner checks for //* before //, because reading //* as a
// line comment leaves the rest of the note in view as model text. No
// declaration inside a note, a comment or a doc body is a story.
package NoteFixture {
    private import VSE_Library::*;

    //* This note names a story that does not exist:
        requirement US_901_InsideNote : UserStory {
    and it spans lines before it closes. */

    requirement US_301_AfterNote : UserStory {
        //* an inline note with a brace } inside */
        attribute :>> capability = "read past the note";
    }

    // requirement US_902_InLineComment : UserStory {
    /* requirement US_903_InBlockComment : UserStory { */

    requirement US_302_Last : UserStory {
        doc /* requirement US_904_InDoc : UserStory { } */
    }
}
