var navControlContainer;
var currentMode = "RichText";
var Version = "2.0";

var Options = {
    enableButtons: true,
    languageCode: "en-US", // https://github.com/summernote/summernote/tree/develop/lang
    allowedHTMLNodes: [],
    headerStyleMapping: {},
    removePxFontSizes: false,
    forceFontFamily: false,
    disableVariables: true,
    customListStyleElements: ['•', '-', '+'] // Removes each element if found after list tag (<li>). Example: copy: <li>• anything</li> paste: <li>anything</li>. RegEx allowed
}
requestOpenPage = getALEventHandler("RequestOpenPage").bind(null, 0); // bind argument type and count so that BC accepts the function defined in the controladdin object

var Modes = {
    Preview: {
        allowedHTMLNodes: [],
        headerStyleMapping: {},
        enableButtons: false,
        disableVariables: true,
        forceFontFamily: false,
        removePxFontSizes: false
    },
    RichText: {
        allowedHTMLNodes: [],
        headerStyleMapping: {},
        forceFontFamily: false,
        removePxFontSizes: false,
        disableVariables: false,
    },
    "WYSIWYG-Report": {
        removePxFontSizes: true,
        disableVariables: false,
        forceFontFamily: "",
        allowedHTMLNodes: ["b", "i", "u", "s", "ol", "ul", "li", "div", "span", "p", "font", "href", "a", "br",
                        "font-family", "font-size", "text-align", "text-indent", "font-weight", "padding", "padding-bottom", "padding-top", "padding-right", "padding-left"],
        headerStyleMapping: { // default headers look wrong in the report
            h1: {
                "font-size": "18pt"
            },
            h2: {
                "font-size": "16pt"
            },
            h3: {
                "font-size": "16pt"
            },
            h4: {
                "font-size": "15pt"
            }
        },
    }
}

function SetMode(mode) {
    if (!Modes[mode]) return;

    currentMode = mode;

    SetOptions(Modes[mode])
}

function SetOptions(options) {
    if (!options) return;

    Object.keys(options).forEach(function(key) {
        Options[key] = options[key];
    })
}

function SetLanguage(langCode) {
    SetOptions({
        languageCode: langCode
    })
}

function DisableVariables(value) {
    SetOptions({
        disableVariables: value
    })
}

function RemoveButtons(value) {
    SetOptions({
        enableButtons: !value
    })
}

var textConstants = {};
textConstants['variableTooltip'] = "Several variables which will insert special values.";
textConstants['lookupTooltip'] = "Lookup on %1";
textConstants['mode'] = "Mode: %1 - Version %2";
function SetTextConstant(key, value) {
    textConstants[key] = value;
}

var editorVariables = [];
function AddVariable(value, variableName) {
    if (variableName == '') { return };
    variableDefinition = { Value: value, VariableName: variableName };
    editorVariables.push(variableDefinition);
}


var registeredLookupButtons = {};
function RegisterLookup(name, pageId) {
    registeredLookupButtons[name] = function (context) {
        return $.summernote.ui.button({
            contents: name,
            tooltip: formatString(textConstants['lookupTooltip'], name),
            click: function() {
                requestOpenPage(pageId).then(function(result) {
                    context.invoke('editor.insertText', result);
                })
            }
        }).render();
    }
}

function SetReadOnly(value) {
    $('#editText').removeClass('readOnly');
    $('#cancelText').removeClass('readOnly');

    if (value) {
        $('#editText').addClass('readOnly');
        $('#cancelText').addClass('readOnly');
    }
}

var VarButton = function (context) {
    var ui = $.summernote.ui;
    const variableNames = editorVariables.map(function (variableDef) {return variableDef.VariableName});
    const variableValues = editorVariables.map(function (variableDef) {return variableDef.Value});

    var button = ui.buttonGroup([
        ui.button({
            className: 'dropdown-toggle',
            contents: 'Var ' + ui.icon(context.options.icons.caret, 'span'),
            tooltip: textConstants['variableTooltip'],
            data: {
                toggle: 'dropdown'
            }
        }),
        ui.dropdownCheck({
            items: variableNames || [],
            checkClassName: context.options.icons.menuCheck,
            className: 'dropdown-variables',
            click: function (event) {
                var $button = $(event.target);
                var value = $button.data('value');
                context.invoke('editor.insertText', variableValues[variableNames.indexOf(value)]);
            }
        }),
    ]);

    return button.render();
}

function LoadPreviewHtml(HTMLData) {
    SetMode('Preview');
    LoadHtml(HTMLData);
}

var isInitialized;
function LoadHtml(HTMLData) {
    navControlContainer = $("#controlAddIn");
    navControlContainer.empty();
    if (Options.enableButtons)
        navControlContainer.append('<div class="buttonHeader" id="buttonHeader"><button id="editText" class="btn btn-default"></button><button id="cancelText" class="btn btn-default"></button><br /></div>');

    navControlContainer.append('<div id="summernote">'+ HTMLData +'</div>');

    if (!Options.enableButtons) {
        $('#cancelText').hide();
        $('#editText').hide();
        return;
    };

    $('#cancelText').hide();
    $('#editText').text(textConstants['edit']);
    $('#cancelText').text(textConstants['cancel']);

    $('#cancelText').on("click", function() {
        RequestCancel();
    });


    if (!isInitialized) {
        $('#editText').text(textConstants['accept']);
        $('#cancelText').text(textConstants['cancel']);
        $('#cancelText').show();
        isInitialized = true;
        initializeSummernote();
    }

    $('#editText').on("click", function() {
        if ($(this).text() === textConstants['edit']) {
            initializeSummernote();
            $(this).text(textConstants['accept']);
            $('#cancelText').show();
            RequestEditMode();
        } else {
            RequestSave();
            $(this).text(textConstants['edit']);
            $('#summernote').summernote('destroy');
            $('#cancelText').hide();
        }
    });
}

function initializeSummernote() {
    var toolbarDefinition = GetToolbarDefinition(Options.allowedHTMLNodes);

    if ((!Options.disableVariables) && (editorVariables.length)) {
        toolbarDefinition.push(['timber', ['varBtn']]);
    };
    var lookupButtons = Object.keys(registeredLookupButtons)
    if (lookupButtons.length) {
        toolbarDefinition.push(['lookups', lookupButtons]);
    }
    const variableNames = editorVariables.map(function (variableDef) {return variableDef.VariableName});
    const variableValues = editorVariables.map(function (variableDef) {return variableDef.Value});
    var Btns = $.extend({}, registeredLookupButtons, {varBtn: VarButton});

    $('#summernote').summernote({
        height: 400,
        minHeight: 100,
        fontNames: ["Arial", "Calibri", "Segoe UI"],
        addDefaultFonts: false,
        toolbar: toolbarDefinition,
        lang: Options.languageCode,
        forceFontSizeUnit: "pt",
        buttons: Btns,
        hint: {
            words: variableNames,
            match: /\b(\w{3,})$/,
            search: function (keyword, callback) {
                callback($.grep(this.words, function (item) {
                    return item.toLowerCase().indexOf(keyword.toLowerCase()) === 0;
                }));
            },
            content: function (item) {
                var value = variableValues[variableNames.indexOf(item)];
                if (value)
                    return value;
                return '';
            }
        },
        callbacks: {
            onPaste: function (e) {
                var clipboardData = ((e.originalEvent || e).clipboardData || window.clipboardData);
                const htmlAvailable = clipboardData.types != null && clipboardData.types.indexOf("text/html") != -1;
                if (htmlAvailable)
                    e.preventDefault();

                getClipboardHtml(e).then(function (html) {
                    var newHtml = handleClipboardHtml(html);

                    if (htmlAvailable)
                        document.execCommand('insertHtml', false, newHtml);
                    else
                        $('.note-editable').html(newHtml);

                    setTimeout(function () {
                        removeAttributes(e.currentTarget);
                    }, 100);
                }).catch(function (err) { console.log(err); });

                setTimeout(function () {
                    $('.note-editable').css("font-family", Options.forceFontFamily || "");
                    $("p.header *").css("font-size", "");
                }, 100);

            },
            onDialogShown: function () {
                var helpDialog = $(".modal-content:contains('Help')");
                if (!helpDialog.is(':visible')) { return; }

                var footerP = helpDialog.children('.modal-footer').find('p');
                var modeInfo = footerP.find("b");

                if (modeInfo.length)
                    modeInfo.text(formatString(textConstants["mode"], currentMode, Version));
                else
                    footerP.append(" - <b>" + formatString(textConstants["mode"], currentMode, Version));
            }
        }
    });
}

function RequestSave() {
    var $editable = $('.note-editable')
    var html = $editable.html();
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('SaveHtml', [html]);
}

function RequestCancel() {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('CancelHtml');
}

function RequestEditMode() {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('EditModeSelected');
}