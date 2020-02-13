page 80119 "TTT-PR BCTTranslationFileLines"
{
    Caption = 'Translation File Lines';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TTT-PR BCTTranslationFileLine";

    layout
    {
        area(Content)
        {
            repeater("TranslationFileLineRepeater")
            {
                Caption = 'File Lines';
                field("TranslFileEntryNo"; "TranslFileEntryNo")
                {
                    ToolTip = 'This is the Translation File Entry No.';
                    ApplicationArea = All;
                    Width = 3;
                }
                field("LineNo"; "LineNo")
                {
                    ToolTip = 'This is a line no. that identifies this particular line within the file.';
                    ApplicationArea = All;
                    Width = 3;
                }
                field("Source"; "Source")
                {
                    ToolTip = 'This is the source text that must be translated.';
                    ApplicationArea = All;
                }
                field("Target"; "Target")
                {
                    ToolTip = 'This is the resulted translation.';
                    ApplicationArea = All;
                    Editable = booTranslateLine;
                }
                field("Suggestion"; "Suggestion")
                {
                    ToolTip = 'This field is marked if the translation originates from a suggestion. The suggestion must be accepted in order to be saved to the database.';
                    ApplicationArea = All;
                    Visible = booTranslateMode;
                }
                field("Translate"; "Translate")
                {
                    ToolTip = 'This indicates that the source can be translated.';
                    ApplicationArea = All;
                }
                field("MaxWidth"; "MaxWidth")
                {
                    ToolTip = 'The width of translation can be limited to this Max. Width.';
                    ApplicationArea = All;
                    Width = 3;
                }
                field("SizeUnit"; "SizeUnit")
                {
                    ToolTip = 'This is the unit specification of the Max Width attribute. Default is "char". Can be byte, cm, em, mm, pixel a.s.o.';
                    ApplicationArea = All;
                    Width = 5;
                }
                field("Generator"; "Generator")
                {
                    ToolTip = 'This shows where in the application the translation is used.';
                    ApplicationArea = All;
                }
                field("Developer"; "Developer")
                {
                    ToolTip = 'This is a comment from the developer.';
                    ApplicationArea = All;
                    Width = 20;
                }
                field("Id"; "Id")
                {
                    ToolTip = 'This is the ID that was assigned to the original text when generating the file from VSC.';
                    ApplicationArea = All;
                    Width = 10;
                }
            }
        }
    }


    actions
    {
        area(Processing)
        {
            action("SortTargetSource")
            {
                Caption = 'Sort Target/Source';
                ToolTip = 'Sort Target/Source (Let us change this to a VIEW, right?).';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Action;

                trigger OnAction()
                begin
                    if CurrentKey() = StrSubstNo('%1,%2', FieldCaption("Target"), FieldCaption("Source")) then
                        Ascending(not Ascending())
                    else
                        SetCurrentKey("Target", "Source");
                end;
            }
            action("AcceptSuggestions")
            {
                Caption = 'Accept suggestions';
                ToolTip = 'Accept all suggestions.';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Action;
                Visible = booTranslateMode;

                trigger OnAction()
                var
                    loccuMgt: Codeunit "TTT-PR BCTTranslManagement";
                begin
                    if not booTranslateMode then
                        exit;
                    loccuMgt.AcceptAllSuggestions(Rec);
                    CurrPage.Update(false);
                end;
            }
            action("SuggestAllLinesFromFile")
            {
                Caption = 'Suggest from file';
                ToolTip = 'Select a file to use for suggestions.';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Action;
                Visible = booTranslateMode;
                Ellipsis = true;

                trigger OnAction()
                var
                    loccuMgt: Codeunit "TTT-PR BCTTranslManagement";
                begin
                    if not booTranslateMode then
                        exit;
                    loccuMgt.SuggestAllLinesFromFile(Rec);
                    CurrPage.Update(false);
                end;
            }
            action("SelectFileForSuggestions")
            {
                Caption = 'Suggest from multiple files';
                ToolTip = 'Select file(s) to create suggestions for all lines.';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Action;
                Visible = booTranslateMode;
                Ellipsis = true;

                trigger OnAction()
                var
                    loccuMgt: Codeunit "TTT-PR BCTTranslManagement";
                begin
                    if not booTranslateMode then
                        exit;
                    loccuMgt.SelectFilesForSuggestions(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        booTranslateMode: Boolean;
        booTranslateLine: Boolean;

    trigger OnOpenPage()
    begin
        booTranslateMode := IsTemporary();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        booTranslateLine := "Translate";
    end;
}
