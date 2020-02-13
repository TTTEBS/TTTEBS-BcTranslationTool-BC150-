codeunit 80115 "TTT-PR BCTTranslManagement"
{
    Description = 'Holds all procedures for managing translations';

    // REMARK: Version 14 is required in order to have access to XmlBuffer.LoadFromStream

    var
        lblOverwriteExistingContentQst: Label 'Do you want to overwrite the existing content?';
        lblTargetLangNeSuggestLangQst: Label 'Target and suggest file have different target languages.\(%1 vs. %2)\Do you want to continue?';
        lblSelectFileToUploadTxt: Label 'Select a file to upload';
        lblSelectFileToDownloadTxt: Label 'Select a file to download';
        lblXliffFilesTxt: Label 'Xliff Files (*.xlf)|*.xlf';
        lblUnableToConvertFileToXmlBufferLinesErr: Label 'Unable to convert file to xml buffer lines';
        lblOnlyWorksOnTemporaryLinesErr: Label 'This function is restricted to work only on the Translate window using temporary records';
        lblUnableToFindTargetLanguageInXmlBufferErr: Label 'Unable to find "%1" in %2';
        lblSuggestionsFoundMsg: Label '%1 Suggestions found';

    procedure ImportXliffFile()
    var
        locrecFile: Record "TTT-PR BCTTranslationFile";
    begin
        if locrecFile.FindLast() then;
        locrecFile."EntryNo" += 1;
        locrecFile.Init();
        locrecFile."Description" := Format(locrecFile."EntryNo");
        locrecFile.Insert(true);
        if ImportXliffFile(locrecFile) then
            locrecFile.Modify(true)
        else
            locrecFile.Delete(true);
    end;

    procedure ImportXliffFile(var parvarrecFile: Record "TTT-PR BCTTranslationFile"): Boolean
    var
        locstrmIn: InStream;
        locstrmOut: OutStream;
        loctxtClientFilename: Text;
    begin
        CheckOverwriteExistingContent(parvarrecFile);
        if not UploadIntoStream(lblSelectFileToUploadTxt, '', lblXliffFilesTxt, loctxtClientFilename, locstrmIn) then
            exit;
        parvarrecFile."Content".CreateOutStream(locstrmOut);
        CopyStream(locstrmOut, locstrmIn);
        parvarrecFile.CalcFields("Content");
        parvarrecFile."Description" := CopyStr(loctxtClientFilename, 1, MaxStrLen(parvarrecFile."Description"));
        exit(true);
    end;

    local procedure CheckOverwriteExistingContent(var parvarrecFile: Record "TTT-PR BCTTranslationFile")
    begin
        parvarrecFile.CalcFields("Content");
        if not parvarrecFile."Content".HasValue() then
            exit;
        if not Confirm(lblOverwriteExistingContentQst, false) then
            Error('');
    end;

    procedure DecodeTranslationFile(var parvarrecFile: Record "TTT-PR BCTTranslationFile")
    var
        locrecLine: Record "TTT-PR BCTTranslationFileLine";
        loctmprecXmlBuffer: Record "XML Buffer" temporary;
        loctmprecXmlBufferCopy: Record "XML Buffer" temporary;
    begin
        if not GetTranslationFileXmlBuffer(parvarrecFile, loctmprecXmlBuffer) then
            exit;
        if not GetTranslationFileXmlBuffer(parvarrecFile, loctmprecXmlBufferCopy) then
            exit;
        locrecLine.SetRange("TranslFileEntryNo", parvarrecFile."EntryNo");
        locrecLine.DeleteAll(true);
        loctmprecXmlBuffer.FindSet();
        repeat
            case loctmprecXmlBuffer.Path.ToUpper() of
                '/XLIFF/FILE/@SOURCE-LANGUAGE':
                    parvarrecFile."SourceLanguage" := CopyStr(loctmprecXmlBuffer.Value, 1, MaxStrLen(parvarrecFile."SourceLanguage"));
                '/XLIFF/FILE/@TARGET-LANGUAGE':
                    parvarrecFile."TargetLanguage" := CopyStr(loctmprecXmlBuffer.Value, 1, MaxStrLen(parvarrecFile."TargetLanguage"));
                '/XLIFF/FILE/BODY/GROUP/TRANS-UNIT':
                    begin
                        if locrecline."LineNo" > 0 then
                            locrecLine.Insert(false);
                        locrecLine.Init();
                        locrecLine."TranslFileEntryNo" := parvarrecFile."EntryNo";
                        locrecLine."LineNo" += 1;
                    end;
                '/XLIFF/FILE/BODY/GROUP/TRANS-UNIT/@ID':
                    locrecLine."Id" := loctmprecXmlBuffer."Value";
                '/XLIFF/FILE/BODY/GROUP/TRANS-UNIT/@SIZE-UNIT':
                    locrecLine."SizeUnit" := CopyStr(loctmprecXmlBuffer."Value", 1, MaxStrLen(locrecLine."SizeUnit"));
                '/XLIFF/FILE/BODY/GROUP/TRANS-UNIT/@MAXWIDTH':
                    if Evaluate(locrecLine."MaxWidth", loctmprecXmlBuffer."Value") then
                        ;
                '/XLIFF/FILE/BODY/GROUP/TRANS-UNIT/@TRANSLATE':
                    locrecline."Translate" := loctmprecXmlBuffer."Value".ToUpper() in ['YES', 'TRUE'];
                '/XLIFF/FILE/BODY/GROUP/TRANS-UNIT/SOURCE':
                    locrecLine."Source" := loctmprecXmlBuffer."Value";
                '/XLIFF/FILE/BODY/GROUP/TRANS-UNIT/TARGET':
                    locrecLine."Target" := loctmprecXmlBuffer."Value";
                '/XLIFF/FILE/BODY/GROUP/TRANS-UNIT/NOTE':
                    begin
                        loctmprecXmlBufferCopy.SetRange("Parent Entry No.", loctmprecXmlBuffer."Entry No.");
                        if loctmprecXmlBufferCopy.FindSet() then
                            repeat
                                case loctmprecXmlBufferCopy.Path.ToUpper() of
                                    '/XLIFF/FILE/BODY/GROUP/TRANS-UNIT/NOTE/@FROM':
                                        case loctmprecXmlBufferCopy.Value.ToUpper() of
                                            'DEVELOPER':
                                                locrecLine."Developer" := loctmprecXmlBuffer.Value;
                                            'XLIFF GENERATOR':
                                                locrecLine."Generator" := loctmprecXmlBuffer.Value;
                                        end;
                                end;
                            until loctmprecXmlBufferCopy.Next() = 0;
                    end;
            end;
        until loctmprecXmlBuffer.Next() = 0;

        if locrecline."LineNo" = 0 then
            exit;
        locrecLine.Insert(false);
        parvarrecFile.Modify(true);

        Clear(locrecLine);
        locrecLine.SetRange("TranslFileEntryNo", parvarrecFile."EntryNo");
        Page.Run(0, locrecLine);
    end;

    procedure GetTranslationFileXmlBuffer(parrecFile: Record "TTT-PR BCTTranslationFile"; var parvartmprecXmlBuffer: Record "XML Buffer" temporary): Boolean
    var
        locstrmIn: InStream;
    begin
        parrecFile.CalcFields("Content");
        if not parrecFile."Content".HasValue() then
            exit;
        parrecFile."Content".CreateInStream(locstrmIn);
        parvartmprecXmlBuffer.LoadFromStream(locstrmIn);
        parvartmprecXmlBuffer.Reset();
        exit(parvartmprecXmlBuffer.FindSet());
    end;

    procedure ShowTranslationFileXmlBuffer(parrecFile: Record "TTT-PR BCTTranslationFile")
    var
        loctmprecXmlBuffer: Record "XML Buffer" temporary;
    begin
        if GetTranslationFileXmlBuffer(parrecFile, loctmprecXmlBuffer) then
            Page.Run(Page::"TTT-PR BCTXmlBuffer", loctmprecXmlBuffer);
    end;

    procedure TranslateProjectFile(parrecProjectFile: Record "TTT-PR BCTTranslProjectFile")
    var
        locrecSourceFile: Record "TTT-PR BCTTranslationFile";
        locrecTargetFile: Record "TTT-PR BCTTranslationFile";
        locrecSourceLine: Record "TTT-PR BCTTranslationFileLine";
        locrecTargetLine: Record "TTT-PR BCTTranslationFileLine";
        loctmprecLine: Record "TTT-PR BCTTranslationFileLine" temporary;
    begin
        GetSourceFile(parrecProjectFile, locrecSourceFile);
        locrecTargetFile.Get(parrecProjectFile."TranslFileEntryNo");

        locrecSourceLine.SetRange("TranslFileEntryNo", locrecSourceFile."EntryNo");
        locrecSourceLine.FindSet();
        repeat
            loctmprecLine := locrecSourceLine;
            loctmprecLine."TargetFileEntryNo" := locrecTargetFile."EntryNo";

            locrecTargetLine.Reset();
            locrecTargetLine.SetCurrentKey("Id");
            locrecTargetLine.SetRange("TranslFileEntryNo", locrecTargetFile."EntryNo");
            locrecTargetLine.SetRange("Id", locrecSourceLine."Id");
            if locrecTargetLine.FindFirst() then
                loctmprecLine."Target" := locrecTargetLine."Target"
            else begin
                // Find suggestion from target lines
                locrecTargetLine.Reset();
                locrecTargetLine.SetCurrentKey("Source");
                locrecTargetLine.SetRange("TranslFileEntryNo", locrecTargetFile."EntryNo");
                locrecTargetLine.SetRange("Source", locrecSourceLine."Source");
                locrecTargetLine.SetFilter("Target", '<>%1', '');
                if locrecTargetLine.FindFirst() then begin
                    loctmprecLine."Target" := locrecTargetLine."Target";
                    loctmprecline."Suggestion" := true;
                end;
            end;
            loctmprecLine.Insert(false);
        until locrecSourceLine.Next() = 0;

        Page.Run(0, loctmprecLine);
    end;

    procedure GetSourceFile(parrecProjectFile: Record "TTT-PR BCTTranslProjectFile"; var parvarrecFile: Record "TTT-PR BCTTranslationFile")
    var
        locrecProjectFile: Record "TTT-PR BCTTranslProjectFile";
    begin
        parrecProjectFile.CalcFields("TranslFileSourceLang", "TranslFileTargetLang");
        if parrecProjectFile."TranslFileSourceLang" = parrecProjectFile."TranslFileTargetLang" then
            parrecProjectFile.FieldError("TranslFileTargetLang");
        locrecProjectFile.SetRange("TranslProjectCode", parrecProjectFile."TranslProjectCode");
        locrecProjectFile.SetRange("TranslFileTargetLang", parrecProjectFile."TranslFileSourceLang");
        locrecProjectFile.FindFirst();
        parvarrecFile.Get(locrecProjectFile."TranslFileEntryNo");
    end;

    procedure ExportProjectFile(parrecProjectFile: Record "TTT-PR BCTTranslProjectFile")
    var
        locrecSourceFile: Record "TTT-PR BCTTranslationFile";
        locrecTargetFile: Record "TTT-PR BCTTranslationFile";
        locrecSourceLine: Record "TTT-PR BCTTranslationFileLine";
        locrecTargetLine: Record "TTT-PR BCTTranslationFileLine";
        loctmprecXmlBuffer: Record "XML Buffer" temporary;
        locintParentEntryNo: Integer;
        locintEntryNo: Integer;
    begin
        GetSourceFile(parrecProjectFile, locrecSourceFile);
        locrecTargetFile.Get(parrecProjectFile."TranslFileEntryNo");

        if not GetTranslationFileXmlBuffer(locrecSourceFile, loctmprecXmlBuffer) then
            Error(lblUnableToConvertFileToXmlBufferLinesErr);

        // Replace the target language
        loctmprecXmlBuffer.Reset();
        loctmprecXmlBuffer.SetRange(Name, 'target-language');
        if not loctmprecXmlBuffer.FindFirst() then
            Error(lblUnableToFindTargetLanguageInXmlBufferErr, 'target-language', loctmprecXmlBuffer.TableCaption());
        loctmprecXmlBuffer.Value := locrecTargetFile."TargetLanguage";
        loctmprecXmlBuffer.Modify(false);

        // Find matching id in target file and insert target element
        locrecSourceLine.SetRange("TranslFileEntryNo", locrecSourceFile."EntryNo");
        locrecSourceLine.FindSet();
        repeat
            locrecTargetLine.SetCurrentKey("Id");
            locrecTargetLine.SetRange("TranslFileEntryNo", locrecTargetFile."EntryNo");
            locrecTargetLine.SetRange("Id", locrecSourceLine."Id");
            if locrecTargetLine.FindFirst() then
                if locrecTargetLine."Target" <> '' then begin
                    loctmprecXmlBuffer.Reset();
                    loctmprecXmlBuffer.SetRange(Name, 'id');
                    loctmprecXmlBuffer.SetRange("Value", locrecSourceLine."Id");
                    if loctmprecXmlBuffer.FindFirst() then begin
                        locintParentEntryNo := loctmprecXmlBuffer."Parent Entry No.";
                        loctmprecXmlBuffer.Reset();
                        loctmprecXmlBuffer.SetRange("Parent Entry No.", locintparentEntryNo);
                        loctmprecXmlBuffer.SetRange(Name, 'source');
                        if loctmprecXmlBuffer.FindFirst() then begin
                            loctmprecXmlBuffer.Reset();
                            locintEntryNo := loctmprecXmlBuffer."Entry No.";
                            locintEntryNo := loctmprecXmlBuffer.AddGroupElementAt('target', locintEntryNo);
                            loctmprecXmlBuffer.SetValue(locrecTargetLine."Target");
                        end;
                    end;
                end;
        until locrecSourceLine.Next() = 0;

        SaveXmlBufferToFile(loctmprecXmlBuffer, locrecTargetFile."Description", lblXliffFilesTxt);
    end;

    procedure SaveXmlBufferToFile(var parvartmprecXmlBuffer: Record "XML Buffer"; partxtFilename: Text; partxtFileTypes: Text): Text
    var
        loccuTempBlob: Codeunit "Temp Blob";
        loccuXmlBufferReader: Codeunit "XML Buffer Reader";
        locstrmIn: InStream;
        lblUnableToCovertXmlBufferLinesToBlobErr: Label 'Unable to convert xml buffer lines to blob field';
    begin
        Clear(parvartmprecXmlBuffer);
        parvartmprecXmlBuffer.FindSet();
        if not loccuXmlBufferReader.SaveToTempBlob(loccuTempBlob, parvartmprecXmlBuffer) then
            Error(lblUnableToCovertXmlBufferLinesToBlobErr);
        loccuTempBlob.CreateInStream(locstrmIn);
        if DownloadFromStream(locstrmIn, lblSelectFileToDownloadTxt, '', lblXliffFilesTxt, partxtFilename) then
            exit(partxtFilename);
    end;

    procedure AcceptAllSuggestions(var parvarrecLine: Record "TTT-PR BCTTranslationFileLine")
    var
        locrecCurrentLine: Record "TTT-PR BCTTranslationFileLine";
        loctxtCurrentView: Text;
    begin
        if not parvarrecLine.IsTemporary() then
            Error(lblOnlyWorksOnTemporaryLinesErr);
        loctxtCurrentView := parvarrecLine.GetView(false);
        locrecCurrentLine := parvarrecLine;
        parvarrecLine.SetCurrentKey("TranslFileEntryNo", "LineNo");
        parvarrecLine.FindSet(true, false);
        repeat
            if parvarrecLine."Suggestion" then
                if parvarrecLine."Target" <> '' then begin
                    parvarrecLine.Validate("Suggestion", false);
                    parvarrecLine.Modify(true);
                end;
        until parvarrecLine.Next() = 0;
        parvarrecLine.SetView(loctxtCurrentView);
        parvarrecLine.get(locrecCurrentLine."TranslFileEntryNo", locrecCurrentLine."LineNo");
    end;

    procedure SuggestAllLinesFromFile(var parvarrecLine: Record "TTT-PR BCTTranslationFileLine")
    var
        locrecCurrentLine: Record "TTT-PR BCTTranslationFileLine";
        locrecSuggestFile: Record "TTT-PR BCTTranslationFile";
        locrecTargetFile: Record "TTT-PR BCTTranslationFile";
        locrecSuggestFileLine: Record "TTT-PR BCTTranslationFileLine";
        loctxtCurrentView: Text;
    begin
        if not parvarrecLine.IsTemporary() then
            Error(lblOnlyWorksOnTemporaryLinesErr);
        loctxtCurrentView := parvarrecLine.GetView(false);
        locrecCurrentLine := parvarrecLine;

        parvarrecLine.Reset();
        parvarrecLine.SetRange("TranslFileEntryNo", parvarrecLine."TranslFileEntryNo");
        parvarrecLine.SetRange("Suggestion", false);
        parvarrecLine.SetRange("Target", '');
        parvarrecLine.SetRange("Translate", true);
        parvarrecLine.SetFilter("Source", '<>%1', '');
        if parvarrecLine.IsEmpty() then
            exit;
        if Page.RunModal(0, locrecSuggestFile) <> Action::LookupOK then
            exit;
        locrecTargetFile.Get(parvarrecLine."TargetFileEntryNo");
        if locrecSuggestFile."TargetLanguage" <> locrecTargetFile."TargetLanguage" then
            if not Confirm(lblTargetLangNeSuggestLangQst, false, locrecTargetFile."TargetLanguage", locrecSuggestFile."TargetLanguage") then
                exit;

        locrecSuggestFileLine.SetRange("TranslFileEntryNo", locrecSuggestFile."EntryNo");
        locrecSuggestFileLine.SetFilter("Target", '<>%1', '');
        parvarrecLine.FindSet();
        repeat
            locrecSuggestFileLine.SetRange("Source", parvarrecLine."Source");
            if locrecSuggestFileLine.FindFirst() then begin
                parvarrecLine."Target" := locrecSuggestFileLine."Target";
                parvarrecLine."Suggestion" := true;
                parvarrecLine.Modify(false);
            end;
        until parvarrecLine.Next() = 0;

        parvarrecLine.Reset();
        parvarrecLine.SetView(loctxtCurrentView);
        parvarrecLine.Get(locrecCurrentLine."TranslFileEntryNo", locrecCurrentLine."LineNo");
    end;

    procedure SelectFilesForSuggestions(var parvarrecLine: Record "TTT-PR BCTTranslationFileLine")
    var
        locrecCurrentLine: Record "TTT-PR BCTTranslationFileLine";
        locrecSuggestFile: Record "TTT-PR BCTTranslationFile";
        locrecTargetFile: Record "TTT-PR BCTTranslationFile";
        locrecSuggestFileLine: Record "TTT-PR BCTTranslationFileLine";
        locpagFiles: Page "TTT-PR BCTTranslationFiles";
        loctxtCurrentView: Text;
        locintSuggestions: Integer;
    begin
        if not parvarrecLine.IsTemporary() then
            Error(lblOnlyWorksOnTemporaryLinesErr);
        loctxtCurrentView := parvarrecLine.GetView(false);
        locrecCurrentLine := parvarrecLine;

        parvarrecLine.Reset();
        parvarrecLine.SetRange("TranslFileEntryNo", parvarrecLine."TranslFileEntryNo");
        parvarrecLine.SetRange("Suggestion", false);
        parvarrecLine.SetRange("Target", '');
        parvarrecLine.SetRange("Translate", true);
        parvarrecLine.SetFilter("Source", '<>%1', '');
        if parvarrecLine.IsEmpty() then
            exit;

        // Select files for suggestions
        locpagFiles.LookupMode(true);
        if locpagFiles.RunModal() <> Action::LookupOK then
            exit;
        locpagFiles.SetSelectionFilter(locrecSuggestFile);

        locrecTargetFile.Get(parvarrecLine."TargetFileEntryNo");
        locrecSuggestFile.FindSet();
        repeat
            if locrecSuggestFile."TargetLanguage" <> locrecTargetFile."TargetLanguage" then
                if not Confirm(lblTargetLangNeSuggestLangQst, false, locrecTargetFile."TargetLanguage", locrecSuggestFile."TargetLanguage") then
                    break;

            locrecSuggestFileLine.SetRange("TranslFileEntryNo", locrecSuggestFile."EntryNo");
            locrecSuggestFileLine.SetFilter("Target", '<>%1', '');
            parvarrecLine.FindSet();
            repeat
                locrecSuggestFileLine.SetRange("Source", parvarrecLine."Source");
                if locrecSuggestFileLine.FindFirst() then begin
                    parvarrecLine."Target" := locrecSuggestFileLine."Target";
                    parvarrecLine."Suggestion" := true;
                    parvarrecLine.Modify(false);
                    locintSuggestions += 1;
                end;
            until parvarrecLine.Next() = 0;
        until locrecSuggestFile.Next() = 0;

        parvarrecLine.Reset();
        parvarrecLine.SetView(loctxtCurrentView);
        parvarrecLine.Get(locrecCurrentLine."TranslFileEntryNo", locrecCurrentLine."LineNo");

        Message(lblSuggestionsFoundMsg, locintSuggestions);
    end;
}
