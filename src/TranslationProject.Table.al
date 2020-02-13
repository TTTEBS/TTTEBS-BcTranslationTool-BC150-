table 80115 "TTT-PR BCTTranslationProject"
{
    Caption = 'Translation Project';
    DataClassification = CustomerContent;
    DrillDownPageId = "TTT-PR BCTTranslationProjects";
    LookupPageId = "TTT-PR BCTTranslationProjects";
    DataCaptionFields = "Code", "Description";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Description"; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "NoOfFiles"; Integer)
        {
            Caption = 'No. of Files';
            BlankZero = true;
            Editable = false;
            Width = 5;
            FieldClass = FlowField;
            CalcFormula = count ("TTT-PR BCTTranslProjectFile" where(TranslProjectCode = field("Code")));
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", "Description")
        {
        }
        fieldgroup(Brick; "Code", "Description")
        {
        }
    }

    trigger OnDelete()
    var
        locrecProjectFile: Record "TTT-PR BCTTranslProjectFile";
    begin
        locrecProjectFile.SetRange("TranslProjectCode", "Code");
        locrecProjectFile.DeleteAll(true);
    end;
}
