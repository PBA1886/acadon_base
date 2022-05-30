function getALEventHandler(eventName) {
    return function() {
        var args = Array.prototype.slice.call(arguments, 1);
        var result;

        var eventResult = eventName+"Result";
        window[eventResult] = function(alresult) {
            result = alresult;
            delete window[eventResult];
        };

        return new Promise(function (resolve) {
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
                eventName,
                args,
                false,
                function() {resolve(result);}
            );
        });
    }
}

/*
 * 
 * @param {element} editable
 * Removes all attributes but the allowed ones of an element and its childs
*/
function removeAttributes(editable) {
    $(editable).children().each(function(k, child) {

        handleAttribute(child);

        if (child.hasChildNodes())
            removeAttributes(child);
    })
}

function handleAttribute(element) {
    for (let i = 0; i < element.attributes.length; i++) {
        const attribute = element.attributes[i];
        if (skipAttribute(attribute))
            continue;

        if (attribute.name === "style")
            handleStyle(element)
        else element.attributes[i] = null;
    }
}

function skipAttribute(attribute) {
    return (attribute.name == "class" && attribute.value == "header")
}

function handleStyle(element) {
    var styles = getAllStyles(element);
    styles.forEach(function(style) {
        if (Options.allowedHTMLNodes.indexOf(style.Name) == -1 || forceRemoveStyle(element, style)) {
            element.style.removeProperty(style.Name);
        }
    })
}


function getAllStyles(elem) {
    if (!elem) return []; // Element does not exist, empty list.
    var win = document.defaultView || window, style, styleNode = [];
    if (win.getComputedStyle) { /* Modern browsers */
        style = win.getComputedStyle(elem, '');
        for (var i=0; i<style.length; i++) {
            styleNode.push( {Name: style[i], Value: style.getPropertyValue(style[i])} );
        }
    } else if (elem.currentStyle) { /* IE */
        style = elem.currentStyle;
        for (var name in style) {
            styleNode.push( {Name: name, Value: style[name]} );
        }
    } else { /* Ancient browser..*/
        style = elem.style;
        for (var i=0; i<style.length; i++) {
            styleNode.push( {Name: style[i], Value: style[style[i]]} );
        }
    }
    return styleNode;
}

function forceRemoveStyle(element, style) {
    element = $(element);
    var remStyles = (element.is('ul') & style.Name.search('padding') != -1 ); // We don't want lists with padding
    return remStyles;
}



// function removeAttributes(editable) {
//     $(editable).children().each((_,child) => {
//         $(child.attributes).each((_, attribute)=> {
//             if (attribute.name == "style") {
//                 strip_styles(child, attribute);
//             } else if (Options.allowedHTMLNodes.indexOf(attribute.name) == -1 && !skipAttribute(attribute))
//                 child.removeAttribute(attribute.name);
//         })
//         if (child.hasChildNodes())
//             removeAttributes(child);
//     });
// }

function replacePXwithPT(html) {    
    return html.replace(/font-size:\s?(\d*)(.*?);/g, function(original, size, unit) {
        if ($.inArray(unit, ["pt", "pc", "mm", "cm"]) != -1)
            return original;

        var text = "font-size: %1pt;";

        if (unit == "em" || unit == "rem") // em refers to font size of parent element. We cannot get the parent element here so we assume it is 14pt as it is the default. Rem is default root fontsize
            return formatString(text, size*14)
        if (unit == "px")
            return formatString(text, size*0.75);

        return formatString(text, '14pt');
    });
}

function removeCustomListStyleElements(html, notAllowedListElements) {
    var listRegEx = new RegExp("(<li.*?>)["+ notAllowedListElements.join('|') +"]\s?", "g");
    return html.replace(listRegEx, "$1");;
}

function removeZeroWidthCharacters(html) {
    return html.replace(/([\u200B]+|[\u200C]+|[\u200D]+|[\u200E]+|[\u200F]+|[\uFEFF]+)/g, '')
}

function replaceHeaders(html, headerStyleMapping) {
    return html.replace(/<h(\d).*?>(.*?)<\/h\d>/g, function(_,hN,text) {
        var wrap = '<p style="%1" class="header">%2</p>';
        var style = '%1: %2;';

        if (!text.length)
            return "";

        text = strip_tags(text, ["i>", "b>", "u>", "s>"]);

        var styleMapping = headerStyleMapping["h"+hN];

        var styles = "";

        Object.entries(styleMapping).forEach(function (obj) {
            styles += formatString(style, obj[0], obj[1]);
        });
        var newtext = formatString(wrap, styles, text);

        return newtext;
    })
}

function strip_tags(html, allowedNodes) {
    var tagRegEx = new RegExp("<(?!\/?("+ allowedNodes.join('|') +")\s*\/?)[^>]+>", "g");
    return allowedNodes.length && html.replace(tagRegEx, '') || html;
}

function formatString(format) {
    var args = Array.prototype.slice.call(arguments, 1);
    args.unshift(''); // Set %0 = '', so it starts with %1 like in BC
    return format.replace(/%(\d+)/g, function(match, number) {
        return typeof args[number] != 'undefined' ? args[number] : match;
    });
};

function getClipboardHtml(event) {
    var clipboardData = ((event.originalEvent || event).clipboardData || window.clipboardData);
    if (clipboardData.types != null && clipboardData.types.indexOf("text/html") != -1)
        return Promise.resolve(clipboardData.getData("text/html"));

    return new Promise(function (resolve) {
        setTimeout(function() {
            var html = $('.note-editable').html();
            resolve(html);
        }, 100)
    })
}

function handleClipboardHtml(html) {
    var bufferText = html;
    bufferText = bufferText.replace(/&nbsp;/g, " ");

    bufferText = removeZeroWidthCharacters(bufferText);
    
    if (!$.isEmptyObject(Options.headerStyleMapping))
        bufferText = replaceHeaders(bufferText, Options.headerStyleMapping);

    if (Options.allowedHTMLNodes.length)
            bufferText = strip_tags(bufferText, Options.allowedHTMLNodes);

    if (Options.customListStyleElements.length)
        bufferText = removeCustomListStyleElements(bufferText, Options.customListStyleElements);

    if (Options.removePxFontSizes)
        bufferText = replacePXwithPT(bufferText);
    
    return bufferText;
}

function GetToolbarDefinition(allowedHTMLNodes) {
    var allowed = function(node, style) {
        if (!allowedHTMLNodes.length) return style;
        if ($.inArray(node, allowedHTMLNodes) >= 0) return style;
    }
    return [
        ['style', [allowed('hN', 'style'), allowed('b', 'bold'), allowed('i', 'italic'), allowed('u', 'underline'), allowed('s', 'strikethrough'), 'clear']],
        ['fonts', [allowed('font', 'fontsize'), allowed('font','fontname')]],
        ['color', [allowed('font', allowed('color', 'color'))]],
        ['undo', ['undo', 'redo', 'help']],
        ['misc', [allowed('a', allowed('href', 'link')), allowed('img', 'picture'), allowed('td', allowed('tr', allowed('table', 'table'))), allowed('hr', 'hr'), 'codeview']],
        ['para', [allowed('ul', 'ul'), allowed('ol', 'ol'), allowed('p', 'paragraph'), 'leftButton', 'centerButton', 'rightButton', 'justifyButton', 'outdentButton', 'indentButton']]
    ];
}