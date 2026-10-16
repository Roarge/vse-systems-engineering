// A string literal that holds a comment opener opens no comment. A
// scanner that ignores strings reads the "/*" in US_101 as the start of
// a comment, closes it at the "*/" in US_102, and loses US_102.
package StringOpenerFixture {
    private import VSE_Library::*;

    requirement US_101_PublishDocs : UserStory {
        attribute :>> capability = "publish docs/*.md to the documentation site";
        attribute :>> benefit    = "readers find every guide in one place";
    }

    requirement US_102_KeepIndex : UserStory {
        attribute :>> capability = "keep the index current";
        attribute :>> benefit    = "no page drops out */ of the index";
    }

    requirement US_103_ListFiles : UserStory {
        attribute :>> capability = "list the published files";
    }
}
