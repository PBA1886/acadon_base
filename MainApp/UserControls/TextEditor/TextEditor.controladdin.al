controladdin "ACA Text Editor"
{
    VerticalStretch = true;
    HorizontalStretch = true;
    RequestedHeight = 540;
    RequestedWidth = 500;

    Scripts = 'UserControls\TextEditor\script\jquery-2.1.4.js',
                'https://polyfill.io/v3/polyfill.min.js?features=getComputedStyle%2CElement.prototype.getAttributeNames%2CElement.prototype.classList%2CPromise%2CObject.keys%2CObject.entries%2CArray.from',
                'UserControls\TextEditor\script\acadonLib.js',
                'UserControls\TextEditor\script\bootstrap.js',
                'UserControls\TextEditor\script\summernote.js',
                'UserControls\TextEditor\script\Script.js';

    Images = 'UserControls\TextEditor\font\summernote.eot',
             'UserControls\TextEditor\font\summernote.ttf',
             'UserControls\TextEditor\font\summernote.woff',
             'UserControls\TextEditor\font\summernote.woff2';

    StyleSheets = 'UserControls\TextEditor\css\main.css',
                  'UserControls\TextEditor\css\summernote.css',
                  'UserControls\TextEditor\css\acadon.css',
                  'UserControls\TextEditor\css\bootstrap.css';

    StartupScript = 'UserControls\TextEditor\script\startup.js';

    event ControlAddInReady();
    event SaveHtml(html: text);
    event CancelHtml();
    event EditModeSelected();
    event RequestOpenPage(PageID: Integer);
    procedure RequestOpenPageResult("Text": Text);
    procedure SetMode(Mode: Text);
    procedure SetOptions(Options: JsonObject);
    procedure RegisterLookup(Name: Text; LookupPageID: Integer);
    procedure AddVariable(Substitution: Text; Caption: Text);
    procedure SetTextConstant(keys: Text; value: Text);
    procedure SetReadOnly(Boolean: Boolean);
    procedure LoadHtml(HtmlData: Text);
}
