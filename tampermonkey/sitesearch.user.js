// ==UserScript==
// @name        Search selection in current domain
// @namespace   pberger.online
// @match       *://*/*
// @exclude     *://*google.com/
// @grant       none
// @version     1.0
// @author      Peter.Bergeron@gmail.com
// @description 1/27/2024, 12:10:33 PM
// @run-at      context-menu
// ==/UserScript==

(function() {
    'use strict';

    let site = document.documentURI
    .replace(/https?:\/\/(www\.)?/g, '')
    .replace(/\/[^\/]*/, '');
    let query = window.getSelection().toString();
    let searchUriPattern = 'https://www.google.com/search?q=site%3A{site}+{query}';
    let searchUri = searchUriPattern.replace('{site}', site).replace('{query}', query)
    window.open(searchUri);
    //console.log(searchUri);
})();