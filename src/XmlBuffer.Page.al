page 80118 "TTT-PR BCTXmlBuffer"
{
    Caption = 'Xml Buffer';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "XML Buffer";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater("XmlBufferRepeater")
            {
                Caption = 'Xml Buffer Lines';
                field("Entry No."; "Entry No.")
                {
                    ToolTip = 'Entry No.';
                    ApplicationArea = All;
                }
                field("Parent Entry No."; "Parent Entry No.")
                {
                    ToolTip = 'Parent Entry No.';
                    ApplicationArea = All;
                }
                field("Node Number"; "Node Number")
                {
                    ToolTip = 'Node Number';
                    ApplicationArea = All;
                }
                field("Depth"; "Depth")
                {
                    ToolTip = 'Depth';
                    ApplicationArea = All;
                }
                field("Name"; "Name")
                {
                    ToolTip = 'Name';
                    ApplicationArea = All;
                }
                field("Value"; "Value")
                {
                    ToolTip = 'Value';
                    ApplicationArea = All;
                }
                field("Data Type"; "Data Type")
                {
                    ToolTip = 'Data Type';
                    ApplicationArea = All;
                }
                field("Type"; "Type")
                {
                    ToolTip = 'Type';
                    ApplicationArea = All;
                }
                field("Path"; "Path")
                {
                    ToolTip = 'Path';
                    ApplicationArea = All;
                    Width = 50;
                }
                field("Namespace"; "Namespace")
                {
                    ToolTip = 'Namespace';
                    ApplicationArea = All;
                    Width = 10;
                }
                field("Value BLOB"; "Value BLOB".HasValue())
                {
                    ToolTip = 'Value BLOB';
                    ApplicationArea = All;
                }
                field("Import ID"; "Import ID")
                {
                    ToolTip = 'Import ID';
                    ApplicationArea = All;
                    Width = 5;
                }
            }
        }
    }
}