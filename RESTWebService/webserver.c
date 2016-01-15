/* Server.c
 *
 *  Created on: JAN 10, 2016
 *      Author: sendtochenkai@gmail.com
 */
/*

 TODO:
 scalbility: working threads pools
 security:SSL connection


*/

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <sys/stat.h>
#include <dirent.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <stdlib.h>


/*hiredis---redis client*/ 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <hiredis.h>




#define SERVER "webserver/1.0"
#define PROTOCOL "HTTP/1.0"
#define RFC1123FMT "%a, %d %b %Y %H:%M:%S GMT"
#define PORT 8088

static char commandbuf[128];








char *get_mime_type(char *name) {
  char *ext = strrchr(name, '.');
  if (!ext) return NULL;
  if (strcmp(ext, ".html") == 0 || strcmp(ext, ".htm") == 0) return "text/html";
  if (strcmp(ext, ".jpg") == 0 || strcmp(ext, ".jpeg") == 0) return "image/jpeg";
  if (strcmp(ext, ".gif") == 0) return "image/gif";
  if (strcmp(ext, ".png") == 0) return "image/png";
  if (strcmp(ext, ".css") == 0) return "text/css";
  if (strcmp(ext, ".au") == 0) return "audio/basic";
  if (strcmp(ext, ".wav") == 0) return "audio/wav";
  if (strcmp(ext, ".avi") == 0) return "video/x-msvideo";
  if (strcmp(ext, ".mpeg") == 0 || strcmp(ext, ".mpg") == 0) return "video/mpeg";
  if (strcmp(ext, ".mp3") == 0) return "audio/mpeg";
  return NULL;
}

void send_headers(FILE *f, int status, char *title, char *extra, char *mime,
                  int length, time_t date) {
  time_t now;
  char timebuf[128];

  fprintf(f, "%s %d %s\r\n", PROTOCOL, status, title);
  fprintf(f, "Server: %s\r\n", SERVER);
  now = time(NULL);
  strftime(timebuf, sizeof(timebuf), RFC1123FMT, gmtime(&now));
  fprintf(f, "Date: %s\r\n", timebuf);
  if (extra) fprintf(f, "%s\r\n", extra);
  if (mime) fprintf(f, "Content-Type: %s\r\n", mime);
  if (length >= 0) fprintf(f, "Content-Length: %d\r\n", length);
  if (date != -1) {
    strftime(timebuf, sizeof(timebuf), RFC1123FMT, gmtime(&date));
    fprintf(f, "Last-Modified: %s\r\n", timebuf);
  }
  fprintf(f, "Connection: close\r\n");
  fprintf(f, "\r\n");
}

void send_feedback(FILE *f, int status, char *title, char *extra, char *text) {
  send_headers(f, status, title, extra, "text/html", -1, -1);
  fprintf(f, "<HTML><HEAD><TITLE>%d %s</TITLE></HEAD>\r\n", status, title);
  fprintf(f, "<BODY><H4>%d %s</H4>\r\n", status, title);
  fprintf(f, "%s\r\n", text);
  fprintf(f, "</BODY></HTML>\r\n");
}


int process(FILE *f) {
  char buf[4096];
  char *method;
  char *path;
  char *protocol;
  struct stat statbuf;
  char pathbuf[4096];
  int len;

  if (!fgets(buf, sizeof(buf), f)) return -1;
  printf("URL: %s", buf);

  method = strtok(buf, " ");
  path = strtok(NULL, " ");
  protocol = strtok(NULL, "\r");
  if (!method || !path || !protocol) return -1;

  fseek(f, 0, SEEK_CUR); // Force change of stream direction
  printf("Path: %s", path);

  if (strcasecmp(method, "GET") != 0) {
    send_feedback(f, 501, "Not supported", NULL, "Method is not supported.");
  } else if (strcasecmp(path, "/Tx") == 0 ) {
	fp = popen("python TxService.py","r");
	if (fp == NULL)
            exit(1);
	send_feedback(f, NULL, "Tx request", NULL,"Tx request completed" );
  } else if (strcasecmp(path, "/Rx") == 0 ) {
	fp = popen("python RxService.py","r");
	if (fp == NULL)
            exit(1);
	send_feedback(f, NULL, "Rx request", NULL,"Rx request completed" );
  } else  {
    send_feedback(f, 404, "Not Found", NULL, "File not found.");
  } 

  return 0;
}

int main(int argc, char *argv[]) {
  int sock;
  struct sockaddr_in sin;
  struct sockaddr_in Inetaddr;

  sock = socket(AF_INET, SOCK_STREAM, 0);
  if (sock < 0) {
		/* kernel may not support ipv6 */
		printf( "create socket issue");
		return 1;
		}

  Inetaddr.sin_family = AF_INET;
  Inetaddr.sin_addr.s_addr = INADDR_ANY;
  Inetaddr.sin_port = htons(PORT);

  if (bind(sock, (struct sockaddr *)&Inetaddr, sizeof(Inetaddr))< 0) {
		/* kernel may not support ipv6 */
		printf( "bind socket issue\n");
		return 1;
		}

  if (listen(sock, 5) < 0) {
	  printf( "listening socket issue\n");
		}

  printf("HTTP server listening on port %d\n", PORT);

  

  while (1) {
    int s;
    FILE *f;

    s = accept(sock, NULL, NULL);
    if (s < 0) break;

    f = fdopen(s, "a+");
    process(f);
    fclose(f);
  }

  close(sock);
  return 0;
}

