table 80117 "TTT-PR BCTTranslProjectFile"
{
    Caption = 'Translation Project File';
    DataClassification = CustomerContent;
    DrillDownPageId = "TTT-PR BCTTranslProjectFiles";
    LookupPageId = "TTT-PR BCTTranslProjectFiles";
    DataCaptionFields = "TranslProjectCode", "TranslFileEntryNo", "TranslProjectDescr", "TranslFileDescription";

    fields
    {
        field(1; "TranslProjectCode"; Code[20])
        {
            Caption = 'Project Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "TTT-PR BCTTranslationProject";
            ValidateTableRelation = true;
        }
        field(2; "TranslProjectDescr"; Text[50])
        {
            Caption = 'Project Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup ("TTT-PR BCTTranslationProject"."Description" where("Code" = field("TranslProjectCode")));
        }
        field(3; "TranslFileEntryNo"; Integer)
        {
            Caption = 'File Entry No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            BlankZero = true;
            TableRelation = "TTT-PR BCTTranslationFile";
            ValidateTableRelation = true;
        }
        field(4; "TranslFileDescription"; Text[50])
        {
            Caption = 'File Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup ("TTT-PR BCTTranslationFile"."Description" where("EntryNo" = field("TranslFileEntryNo")));
        }
        field(5; "TranslFileSourceLang"; Text[10])
        {
            Caption = 'File Source Language';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup ("TTT-PR BCTTranslationFile"."SourceLanguage" where("EntryNo" = field("TranslFileEntryNo")));
        }
        field(6; "TranslFileTargetLang"; Text[10])
        {
            Caption = 'File Target Language';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup ("TTT-PR BCTTranslationFile"."TargetLanguage" where("EntryNo" = field("TranslFileEntryNo")));
        }
    }

    keys
    {
        key(PK; "TranslProjectCode", "TranslFileEntryNo")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "TranslProjectCode", "TranslFileEntryNo", "TranslProjectDescr", "TranslFileDescription")
        {
        }
        fieldgroup(Brick; "TranslProjectCode", "TranslFileEntryNo", "TranslProjectDescr", "TranslFileDescription")
        {
        }
    }

    procedure Translate()
    var
        loccuMgt: Codeunit "TTT-PR BCTTranslManagement";
    begin
        loccuMgt.TranslateProjectFile(Rec);
    end;

    procedure Export()
    var
        loccuMgt: Codeunit "TTT-PR BCTTranslManagement";
    begin
        loccuMgt.ExportProjectFile(Rec);
    end;
}