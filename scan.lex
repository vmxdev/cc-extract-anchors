%{
#include <stdio.h>
#include <sys/types.h>

struct href
{
	char *src_url;
	char *dst_url;

	char *text;
	size_t tsize;
} href;


/* called after we've got anchor text */
void
text_stop()
{
	printf("====================\n");
	if (href.src_url) {
		printf("source url:     %s\n", href.src_url);
	}
	if (href.dst_url) {
		printf("destination url: %s\n", href.dst_url);
	}
	if (href.text) {
		href.text[href.tsize] = '\0';
		printf("text: %s\n", href.text);
		free(href.text);
		href.text = NULL;
		href.tsize = 0;
	}
}

%}

TGBGN	"<"
TGEND	">"
HREF	(?i:"href")
A	(?i:"a")
WS	[ \t\n\v]+

%option noyywrap

%x TAG
%x TEXT
%x SRCURL
%x HREF
%x HREF_DQS
%x HREF_SQS

%%

<INITIAL>{TGBGN}{WS}?{A}{WS}	{
	BEGIN(TAG);
}

<INITIAL,TEXT>"WARC\-Target\-URI\:"	{
	BEGIN(SRCURL);
}

<SRCURL>[^\n]+	{
	if (href.src_url) {
		free(href.src_url);
	}
	href.src_url = strdup(yytext);
	BEGIN(INITIAL);
}

<TAG>{HREF}{WS}?={WS}?	{
	BEGIN(HREF);
}

<TAG>"/"{WS}?{TGEND}	{
	BEGIN(INITIAL);
}

<TAG>{TGEND}	{
	BEGIN(TEXT);
}

 /* double quoted string */
<HREF>\"	{
	BEGIN(HREF_DQS);
}

<HREF_DQS>[^\\"\n]*	{
	if (href.dst_url) {
		free(href.dst_url);
	}
	href.dst_url = strdup(yytext);
}

<HREF_DQS>\"	{
	BEGIN(TAG);
}

 /* single quoted string */
<HREF>\'	{
	BEGIN(HREF_SQS);
}

<HREF_SQS>[^\\'\n]*	{
	if (href.dst_url) {
		free(href.dst_url);
	}
	href.dst_url = strdup(yytext);
}

<HREF_SQS>\'	{
	BEGIN(TAG);
}

<TEXT>"WARC\/1\.0"	{
	text_stop();
	BEGIN(INITIAL);
}

<TEXT>{TGBGN}{WS}?"/"{WS}?{A}{WS}?{TGEND}	{
	text_stop();
	BEGIN(INITIAL);
}

<TEXT>.|{WS}	{
	href.text = realloc(href.text, href.tsize + 2);
	href.text[href.tsize] = yytext[0];
	href.tsize++;
}

<INITIAL,TAG>{WS}
<INITIAL,TAG>.

%%

int
main(int argc, char *argv[])
{
	++argv, --argc;  /* skip over program name */
	if (argc > 0) {
		yyin = fopen(argv[0], "r");
	} else {
		yyin = stdin;
	}

	memset(&href, 0, sizeof(href));

	yylex();

	if (href.text) {
		free(href.text);
	}
	if (href.src_url) {
		free(href.src_url);
	}
	if (href.dst_url) {
		free(href.dst_url);
	}

	return 0;
}

