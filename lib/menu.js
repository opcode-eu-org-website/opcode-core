/**
 * Copyright (c) 2017-2019, Robert Ryszard Paciorek <rrp@opcode.eu.org>, MIT license
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
**/

function init() {
	if (initCalled)
		return;
	initCalled = true;
	
	MakeTree( document.querySelector("#toc") );
}

function MakeTree(element) {
	var el = element.getElementsByTagName("*");
	for (var i = 0; i < el.length; i++) {
		if (el[i].tagName == 'li' && el[i].querySelector('ul li') ) {
			el[i].onclick = SwitchTreeElement;
			el[i].addEventListener("mousedown", CancelEvent2, false);
			el[i].classList.add('hasSubMenu');
			if (el[i].classList.contains('menu2') /*|| el[i].classList.contains('menu3')*/)
				el[i].classList.add('hide');
		} else if (el[i].tagName == 'a') {
			el[i].onclick = OpenTreeElement;
		} else {
			if (el[i].tagName == 'li') {
				el[i].classList.add('noSubMenu');
			}
			el[i].onclick = CancelEvent;
		}
	}
}

function SwitchTreeElement(e) {
	if (this.classList.contains('hide')) {
		this.classList.remove('hide');
		this.scrollIntoView(true);
	} else {
		this.classList.add('hide');
	}
	e.stopPropagation();
}

function OpenTreeElement(e) {
	if (this.parentElement.classList.contains('hide')) {
		this.parentElement.classList.remove('hide');
		this.parentElement.scrollIntoView(true);
	}
	e.stopPropagation();
}

function CancelEvent(e) {
	e.stopPropagation();
}
function CancelEvent2(e) {
	e.preventDefault();
}

initCalled = false;
addEventListener('DOMContentLoaded', init, false);
addEventListener('load', init, false);
