page 80116 "TTT-PR BCTTranslationFiles"
{
    Caption = 'Translation Files';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TTT-PR BCTTranslationFile";
    Editable = true;
    PromotedActionCategories = 'New,Process,Report,Navigate';

    layout
    {
        area(Content)
        {
            repeater("TranslationFileRepeater")
            {
                Caption = 'Translation Files';
                field("EntryNo"; "EntryNo")
                {
                    ToolTip = 'The Entry No. uniquely identifies the file.';
                    ApplicationArea = All;
                }
                field("Description"; "Description")
                {
                    ToolTip = 'You can enter your own description for each file.';
                    ApplicationArea = All;
                }
                field("SourceLanguage"; "SourceLanguage")
                {
                    ToolTip = 'Source Language usually is "en-US".';
                    ApplicationArea = All;
                }
                field("TargetLanguage"; "TargetLanguage")
                {
                    ToolTip = 'You can manually change the Target Language to suit your needs. Target Language must be different from Source Language if you want to translate the content.';
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = "SourceLanguage" <> "TargetLanguage";
                }
                field("HasContent"; "Content".HasValue())
                {
                    Caption = 'Has Content';
                    ToolTip = 'This shows if a file has been imported.';
                    ApplicationArea = All;
                }
                field("NoOfLines"; "NoOfLines")
                {
                    ToolTip = 'This will show the no. of lines after decoding the imported file. The lines are the ones you actually translate.';
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
        area(Processing)
        {
            action("ImportNew")
            {
                Caption = 'Import new';
                ToolTip = 'Import a new xliff file and create a Translation File record.';
                ApplicationArea = All;
                Image = Import;
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                var
                    loccuMgt: Codeunit "TTT-PR BCTTranslManagement";
                begin
                    loccuMgt.ImportXliffFile();
                    CurrPage.Update();
                end;
            }
            action("DecodeTranslationFile")
            {
                Caption = 'Decode file';
                ToolTip = 'Create lines from this file.';
                ApplicationArea = All;
                Image = EncryptionKeys;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                begin
                    Rec.DecodeFile();
                end;
            }
            action("Import")
            {
                Caption = 'Import';
                ToolTip = 'Import xliff file to this record.';
                ApplicationArea = All;
                Image = ImportLog;
                Ellipsis = true;

                trigger OnAction();
                var
                    loccuMgt: Codeunit "TTT-PR BCTTranslManagement";
                begin
                    loccuMgt.ImportXliffFile(Rec);
                end;
            }
        }
        area(Navigation)
        {
            action("Lines")
            {
                Caption = 'Show Lines';
                ToolTip = 'Show lines from this file.';
                ApplicationArea = All;
                Image = AllLines;
                RunObject = Page "TTT-PR BCTTranslationFileLines";
                RunPageLink = "TranslFileEntryNo" = field("EntryNo");
            }
            action("ShowXmlBuffer")
            {
                Caption = 'Show Xml Buffer';
                ToolTip = 'Show Xml buffer lines from this file.';
                ApplicationArea = All;
                Image = XMLFile;
                Enabled = EntryNo <> 0;

                trigger OnAction();
                begin
                    Rec.ShowXmlBuffer();
                end;
            }
            action("ProjectFiles")
            {
                Caption = 'Project Translation Files';
                ToolTip = 'Show project files connected to this file.';
                ApplicationArea = All;
                Image = Filed;
                RunObject = page "TTT-PR BCTTranslProjectFiles";
                RunPageLink = "TranslFileEntryNo" = field("EntryNo");
                RunPageMode = Edit;
            }
        }
    }
}