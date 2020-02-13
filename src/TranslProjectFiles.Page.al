page 80117 "TTT-PR BCTTranslProjectFiles"
{
    Caption = 'Translation Project Files';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TTT-PR BCTTranslProjectFile";
    Editable = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater("ProjectFileRepeater")
            {
                Caption = 'Project Files';
                field("TranslProjectCode"; "TranslProjectCode")
                {
                    ToolTip = 'Translation Project Code identifies connection to the project.';
                    ApplicationArea = All;
                    Visible = not booProjectFilter;
                }
                field("TranslProjectDescr"; "TranslProjectDescr")
                {
                    ToolTip = 'Translation Project Description comes from the project record.';
                    ApplicationArea = All;
                    Visible = not booProjectFilter;
                }
                field("TranslFileEntryNo"; "TranslFileEntryNo")
                {
                    ToolTip = 'Translation File Entry No. is the unique reference to a translation file.';
                    ApplicationArea = All;
                }
                field("TranslFileDescription"; "TranslFileDescription")
                {
                    ToolTip = 'Translation File Description comes from the translation file record.';
                    ApplicationArea = All;
                }
                field("TranslFileSourceLang"; "TranslFileSourceLang")
                {
                    ToolTip = 'This is the source language code of the translation file.';
                    ApplicationArea = All;
                }
                field("TranslFileTargetLang"; "TranslFileTargetLang")
                {
                    ToolTip = 'This is the target language code of the translation file.';
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = "TranslFileSourceLang" <> "TranslFileTargetLang";
                }
            }
        }

        area(Factboxes)
        {
        }
    }

    actions
    {
        area(Processing)
        {
            action("Translate")
            {
                Caption = 'Translate';
                Tooltip = 'Translate.';
                ApplicationArea = All;
                Image = Action;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                begin
                    Translate();
                end;
            }
            action("Export")
            {
                Caption = 'Export';
                ToolTip = 'Export.';
                ApplicationArea = All;
                Image = Action;
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                begin
                    Export();
                end;
            }
        }
    }

    var
        booProjectFilter: Boolean;

    trigger OnOpenPage()
    begin
        booProjectFilter := GetFilter("TranslProjectCode") <> '';
    end;
}