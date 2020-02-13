table 80118 "TTT-PR BCTTranslationFileLine"
{
    Caption = 'Translation File Line';
    DataClassification = CustomerContent;
    DrillDownPageId = "TTT-PR BCTTranslationFileLines";
    LookupPageId = "TTT-PR BCTTranslationFileLines";
    DataCaptionFields = "TranslFileEntryNo", "LineNo", "Source";

    fields
    {
        field(1; "TranslFileEntryNo"; Integer)
        {
            Caption = 'File Entry No.';
            DataClassification = CustomerContent;
            BlankZero = true;
            NotBlank = true;
            Editable = false;
        }
        field(2; "LineNo"; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            BlankZero = true;
            NotBlank = true;
            Editable = false;
        }
        field(3; "Id"; Text[250])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "TargetFileEntryNo"; Integer)
        {
            Caption = 'Target File Entry No.';
            DataClassification = CustomerContent;
            BlankZero = true;
            Editable = false;
        }
        field(10; "Source"; Text[1024])
        {
            Caption = 'Source';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Target"; Text[1024])
        {
            Caption = 'Target';
            DataClassification = CustomerContent;
            Editable = true;
            trigger OnValidate()
            begin
                if "MaxWidth" = 0 then
                    exit;
                if StrLen("Target") > "MaxWidth" then
                    Error(lblMaxWidthExceededErr,
                        FieldCaption("MaxWidth"), FieldCaption("Target"), "MaxWidth", "Target", StrLen("Target"));
            end;
        }
        field(20; "Translate"; Boolean)
        {
            Caption = 'Translate';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(21; "MaxWidth"; Integer)
        {
            Caption = 'Max Width';
            DataClassification = CustomerContent;
            BlankZero = true;
            Editable = false;
        }
        field(22; "SizeUnit"; Text[20])
        {
            Caption = 'Size Unit';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(23; "Generator"; Text[250])
        {
            Caption = 'Generator';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(24; "Developer"; Text[250])
        {
            Caption = 'Developer';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30; "Suggestion"; Boolean)
        {
            Caption = 'Suggestion';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "TranslFileEntryNo", "LineNo")
        {
            Clustered = true;
        }
        key(ID; "Id")
        {
        }
    }

    var
        lblMaxWidthExceededErr: Label '%1 (%3) for %2 exceeded!\"%4" = %5';

    trigger OnModify()
    var
        locrecTargetLine: Record "TTT-PR BCTTranslationFileLine";
        locintLastLineNo: Integer;
    begin
        if not IsTemporary() then
            exit;
        if "TargetFileEntryNo" = 0 then
            exit;
        locrecTargetLine.SetCurrentKey("Id");
        locrecTargetLine.SetRange("Id", "Id");
        locrecTargetLine.SetRange("TranslFileEntryNo", "TargetFileEntryNo");
        if locrecTargetLine.FindFirst() then begin
            if locrecTargetLine."Target" <> "Target" then begin
                locrecTargetLine."Target" := "Target";
                locrecTargetLine.Modify(true);
            end;
        end else begin
            locrecTargetLine.Reset();
            locrecTargetLine.SetRange("TranslFileEntryNo", "TargetFileEntryNo");
            if locrecTargetLine.FindLast() then
                locintLastLineNo := locrecTargetLine."LineNo";
            locrecTargetLine := Rec;
            locrecTargetLine."TranslFileEntryNo" := "TargetFileEntryNo";
            locrecTargetLine."LineNo" := locintLastLineNo + 1;
            locrecTargetLine."TargetFileEntryNo" := 0;
            locrecTargetLine.Insert(false);
        end;
    end;

}