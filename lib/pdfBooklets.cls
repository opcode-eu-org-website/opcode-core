% Copyright (c) 2019-2020 Robert Ryszard Paciorek <rrp@opcode.eu.org>
% 
% MIT License
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{pdfBooklets}[2019/05/01 v1.0 class for PDF educational booklets]

\LoadClass[ fontSize=12pt, tmargin=10mm, bmargin=17mm, lmargin=10mm, rmargin=10mm, extra ]{pdfArticle}

% alllow break URLs
\usepackage{xurl}

% multilingual support
\RequirePackage{polyglossia}
\setdefaultlanguage{polish} % by default polish settings and names
                            % only this, NOT \RequirePackage{polski} NOR \RequirePackage[polish]{babel}
\setotherlanguages{english} % provide english language option too (for code printing)

% polish math ...
\newcommand{\tg}{\ensuremath{\operatorfont tg}}
\newcommand{\ctg}{\ensuremath{\operatorfont ctg}}
\newcommand{\arctg}{\ensuremath{\operatorfont arctg}}
\newcommand{\arcctg}{\ensuremath{\operatorfont arcctg}}
\newcommand{\tgh}{\ensuremath{\operatorfont tgh}}
\newcommand{\ctgh}{\ensuremath{\operatorfont ctgh}}
\newcommand{\nwd}{\ensuremath{\operatorfont nwd}}
\AtBeginDocument{\let\le=\leqslant \let\ge=\geqslant}

% date and time (iso-like format: %Y-%m-%d %H:%M:%S %z)
\RequirePackage{datetime2}
	\renewcommand*{\DTMdisplaydate}[4]{\number#1-\DTMtwodigits{#2}-\DTMtwodigits{#3}}
	\renewcommand*{\DTMDisplaydate}{\DTMdisplaydate}
	\renewcommand*{\DTMdisplaytime}[3]{\DTMtwodigits{#1}:\DTMtwodigits{#2}:\DTMtwodigits{#3}}
	\renewcommand*{\DTMdisplayzone}[2]{\ifnum#1<0-\else+\fi\DTMtwodigits{#1}\DTMtwodigits{#2}}
	\renewcommand*{\DTMdisplay}[9]{\DTMdisplaydate{#1}{#2}{#3}{#4} \DTMdisplaytime{#5}{#6}{#7} \DTMdisplayzone{#8}{#9}}
	\renewcommand*{\DTMDisplay}{\DTMdisplay}
	\newcommand{\currentTime}{\DTMnow}

% footnotes always on page bottom
\let\svfootnoterule\footnoterule
\renewcommand\footnoterule{\vfill\vspace{4pt}\svfootnoterule}

% redefine looks of footnotes to:
%   margin (3mm), number (with constant filed width 6mm), empty space (remained from number filed width), text
\makeatletter\renewcommand{\@makefntext}[1]{%
  \setlength{\@tempdima}{\columnwidth}\addtolength{\@tempdima}{-9mm}%
  \protect\footnotesize\hspace{3mm}\makebox[6mm][l]{\@thefnmark.}\parbox[t]{\@tempdima}{#1}%
}\makeatother

% change default settings for itemize and enumerate environments
\setlist[itemize,enumerate]{topsep=4pt, parsep=3pt, itemsep=0pt, partopsep=0pt}

% add some extra fonts
\newfontfamily{\Symbola}{Symbola}

% add easylist
\RequirePackage[ampersand]{easylist}


%
% code syntax highlight and placing
%

%\RequirePackage{minted} % nice code highlight (use minted insted of listings, due to encoding problems in listings)
\RequirePackage{xparse, ifthen} % some tools for CodeFrame environment
\newlength{\NextCodeFrameWidth}
\newlength{\CurrCodeFrameWidth}
\NewDocumentEnvironment{CodeFrame}{O{text} O{} m}{\VerbatimEnvironment
	\ifthenelse{\equal{#3}{auto}} {
		\global\setlength{\CurrCodeFrameWidth}{\NextCodeFrameWidth}
		\typeout{"CodeFrame auto:", arg=#3, curr = \the\CurrCodeFrameWidth, next = \the\NextCodeFrameWidth}
	}{
		\setlength{\CurrCodeFrameWidth}{#3}
		\setlength{\global\NextCodeFrameWidth}{0.95\textwidth - \CurrCodeFrameWidth}
		\typeout{"CodeFrame std:", arg=#3, curr = \the\CurrCodeFrameWidth, next = \the\NextCodeFrameWidth}
	}
	\noindent\begin{minipage}[t]{\CurrCodeFrameWidth}\begin{english}
	\begin{minted}[frame=single, #2]{#1}%
}{%
	\end{minted}
	\end{english}\end{minipage}\hfill
}
\NewDocumentEnvironment{VerbFrame}{O{text} O{} m}{\VerbatimEnvironment
	\ifthenelse{\equal{#3}{auto}} {
		\global\setlength{\CurrCodeFrameWidth}{\NextCodeFrameWidth}
		\typeout{"CodeFrame auto:", arg=#3, curr = \the\CurrCodeFrameWidth, next = \the\NextCodeFrameWidth}
	}{
		\setlength{\CurrCodeFrameWidth}{#3}
		\setlength{\global\NextCodeFrameWidth}{0.95\textwidth - \CurrCodeFrameWidth}
		\typeout{"CodeFrame std:", arg=#3, curr = \the\CurrCodeFrameWidth, next = \the\NextCodeFrameWidth}
	}
	\noindent\begin{minipage}[t]{\CurrCodeFrameWidth}\begin{english}
	\begin{Verbatim}[frame=single, #2]{#1}%
}{%
	\end{Verbatim}
	\end{english}\end{minipage}\hfill
}

\NewDocumentEnvironment{CodeFrame*}{O{text} O{} m}{\VerbatimEnvironment
	\vspace{-8pt}\noindent\begin{english}
	\begin{minted}[frame=single, #2]{#1}%
}{%
	\end{minted}
	\end{english}
}

\newmintinline[python]{python}{}
\newmintinline[shell]{bash}{}
\newmintinline[cpp]{cpp}{}


%
% icons for advanced topics
%

\newcommand{\zaawansowane}[1]{%
	\ifnumcomp{#1}{<}{5}  {} {%
	\ifnumcomp{#1}{<}{15} {\Symbola 🤔} {%
	\ifnumcomp{#1}{<}{25} {\Symbola 🤓} {\Symbola 🧐}%
	}}%
}


%
% boxes for tips and exercises
%

%\RequirePackage[many,vignette,minted,magazine,poster,external]{tcolorbox} % nice framed boxes
\newtcolorbox{ProTip}[2][]{
	colback=white,
	colbacktitle=white,
	coltitle=black,
	colframe=white!50!black,
	fonttitle=\Symbola\small,
	fontupper=\small,
	enhanced, attach boxed title to top left={xshift=1cm, yshift=-2mm},
	before skip=13pt plus 2pt,
	title=#2,
	#1
}
\newtcolorbox[auto counter, number within=subsection]{Zadanie}[3][]{
	\teacher*{breakable},
	colback=white,
	colbacktitle=white,
	coltitle=black,
	colframe=black,
	fonttitle=\bf,
	enhanced, attach boxed title to top left={xshift=1cm, yshift=-2mm},
	before skip=13pt plus 2pt,after skip=7pt plus 2pt,
	title=Zadanie \thetcbcounter #2,
	label=#3,
	#1
}
\newcommand{\domowe}[1]{\teacher{{} -- \bf proponowane zadanie domowe za #1 pkt}}


%
% exercises databases
%

\RequirePackage{xstring, currfile}
\def\dbEntryID{}
\newcommand{\dbEntryBegin}[1]{\IfStrEq{\dbEntryID}{#1}{\def\dbEntryCheckResults{1}}{\def\dbEntryCheckResults{0}}}
\newcommand{\dbEntryInsert}[2]{\def\dbEntryID{#2}\input{#1}\def\dbEntryID{}}

\newcommand{\insertZadanie}[3]{\begin{Zadanie}{#3}{#2} \dbEntryInsert{#1}{#2} \end{Zadanie}}
\newcommand{\insertRozwiazanie}[3]{\subsubsection*{Rozwiązanie zadania \ref{#2}} \dbEntryInsert{#1}{#2-rozwiazanie}}

% input file content without preambule and \end{document} protected by \inputOnlyContent
\newcommand{\inputFileContent}[1]{
	\providecommand{\inputOnlyContent}{TRUE}
	\input{#1}
	\let\inputOnlyContent\undefined
}


%
% title ad footer
%

\RequirePackage{titling} % configure \maketitle command
\renewcommand{\maketitlehooka}{\vspace{-44pt}}
\renewcommand{\maketitlehookb}{\vspace{-14pt}\teacher*{\color{teacherColor}\centerline{\Large(wersja dla prowadzącego)}\color{black}}}
\renewcommand{\maketitlehookd}{\vspace{-13pt}}
\renewcommand{\maketitlehookd}{\vspace{-12pt}}

\newcommand{\copyrightFooter}[1]{%
	%\null\nopagebreak[4]\vfill\nopagebreak[4]\parbox{\textwidth}{\footnotesize\noindent\hspace{-0.3cm}\rule{5cm}{0.4pt}\\#1}%
	\begin{figure}[b]\footnotesize\noindent\hspace{-0.3cm}\rule{5cm}{0.4pt}\\#1\end{figure}%
}


%
% teacher vs standard version
%

\ifdefined\teacherVersion
	\definecolor{teacherColor}{cmyk}{0,0.8,0,0}
	\NewExpandableDocumentCommand{\teacher}{s m}{%
		\IfBooleanF#1{\FSPush{colors}{teacherColor}\color{teacherColor}}%
		#2\IfBooleanF#1{\FSPop{colors}\color{\FSTop{colors}}}%
	}
	\newenvironment{teacherOnly}{
		\FSPush{colors}{teacherColor}\color{teacherColor}
	}{
		\FSPop{colors}\color{\FSTop{colors}}
	}
	\NewDocumentEnvironment{rozwiazanie}{O{Rozwiązanie} m}{\VerbatimEnvironment
		\begin{teacherOnly}
		\noindent #1:
		\begin{minted}[frame=single]{#2}%
	}{
		\end{minted}
		\end{teacherOnly}
	}
	\newcommand{\student}[1]{}
	\newtcolorbox{RozwiazanieBox}[1][]{
		fontupper=\footnotesize,
		before skip=13pt plus 2pt,
		left=43pt,right=53pt,
		breakable,
		colback=white!100!black,
		boxrule=0pt, frame hidden, colframe=white,
		#1
	}
\else
	\NewExpandableDocumentCommand{\teacher}{s m}{}
	\usepackage{comment}
	\excludecomment{teacherOnly}
	\excludecomment{rozwiazanie}
	\newcommand{\rozwiazania}{}
	\newcommand{\student}[1]{#1}
	\newtcolorbox{RozwiazanieBox}[1][]{
		fontupper=\footnotesize,
		before skip=13pt plus 2pt,
		left=53pt,right=43pt,rotate=180,
		breakable,
		colback=white!100!black,
		boxrule=0pt, frame hidden, colframe=white,
		#1
	}
\fi


%
% misc
%

\newcommand{\todo}[1]{{\color{red} TODO: #1}}
\newcommand{\fixme}[1]{{\color{red} FIXME: #1}}
\makeatletter\newcommand\noParBreak{\par\nobreak\@afterheading}\makeatother

\emergencystretch=1em

\typeout{Loading document class "pdfBooklets" completed!}\typeout{}
