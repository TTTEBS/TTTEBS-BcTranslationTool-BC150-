page 80115 "TTT-PR BCTTranslationProjects"
{
    Caption = 'Translation Projects';
    AdditionalSearchTerms = 'TTT, TTT-PR, TTTPR';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TTT-PR BCTTranslationProject";
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater("TranslationProjectRepeater")
            {
                Caption = 'Projects';
                field("Code"; "Code")
                {
                    ToolTip = 'This is the code that uniquely identifies the project.';
                    ApplicationArea = All;
                }
                field("Description"; "Description")
                {
                    ToolTip = 'This describes the translation project.';
                    ApplicationArea = All;
                }
                field("NoOfFiles"; "NoOfFiles")
                {
                    ToolTip = 'Shows the no. of files attached to the project.';
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {
        }
    }

    actions
    {
        area(Navigation)
        {
            action("ProjectFiles")
            {
                Caption = 'Project Translation Files';
                ToolTip = 'Show translation files connected to this project';
                ApplicationArea = All;
                Image = Action;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "TTT-PR BCTTranslProjectFiles";
                RunPageLink = "TranslProjectCode" = field("Code");
                RunPageMode = Edit;
            }

            action("TranslationFiles")
            {
                Caption = 'All Translation Files';
                ToolTip = 'Show all translation files';
                ApplicationArea = All;
                Image = Action;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                begin
                    Page.Run(Page::"TTT-PR BCTTranslationFiles");
                end;
            }
        }
    }
}