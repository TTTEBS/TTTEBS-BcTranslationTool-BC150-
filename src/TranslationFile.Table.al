table 80116 "TTT-PR BCTTranslationFile"
{
    Caption = 'Translation File';
    DataClassification = CustomerContent;
    DrillDownPageId = "TTT-PR BCTTranslationFiles";
    LookupPageId = "TTT-PR BCTTranslationFiles";
    DataCaptionFields = "EntryNo", "Description";

    fields
    {
        field(1; "EntryNo"; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            BlankZero = true;
            Width = 5;
        }
        field(2; "Description"; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Content"; Blob)
        {
            Caption = 'Content';
            DataClassification = CustomerContent;
        }
        field(4; "SourceLanguage"; Text[10])
        {
            Caption = 'Source Language';
            DataClassification = CustomerContent;
        }
        field(5; "TargetLanguage"; Text[10])
        {
            Caption = 'Target Language';
            DataClassification = CustomerContent;
        }
        field(6; "NoOfLines"; Integer)
        {
            Caption = 'No. of Lines';
            BlankZero = true;
            Editable = false;
            Width = 5;
            FieldClass = FlowField;
            CalcFormula = count ("TTT-PR BCTTranslationFileLine" where("TranslFileEntryNo" = field("EntryNo")));
        }
    }

    keys
    {
        key(PK; "EntryNo")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "EntryNo", "Description", "SourceLanguage", "TargetLanguage")
        {
        }
        fieldgroup(Brick; "EntryNo", "Description", "SourceLanguage", "TargetLanguage")
        {
        }
    }

    trigger OnDelete()
    var
        locrecProjectFile: Record "TTT-PR BCTTranslProjectFile";
        locrecLine: Record "TTT-PR BCTTranslationFileLine";
    begin
        locrecProjectFile.SetRange("TranslFileEntryNo", "EntryNo");
        if locrecProjectFile.FindFirst() then
            locrecProjectFile.FieldError("TranslFileEntryNo");
        locrecLine.SetRange("TranslFileEntryNo", "EntryNo");
        locrecLine.DeleteAll(true);
    end;

    procedure DecodeFile()
    var
        loccuMgt: Codeunit "TTT-PR BCTTranslManagement";
    begin
        loccuMgt.DecodeTranslationFile(Rec);
    end;

    procedure ShowXmlBuffer()
    var
        loccuMgt: Codeunit "TTT-PR BCTTranslManagement";
    begin
        loccuMgt.ShowTranslationFileXmlBuffer(Rec);
    end;
}